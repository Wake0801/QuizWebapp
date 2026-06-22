package com.example.thitracnghiem.controller.gv;

import com.example.thitracnghiem.dto.ExamQuestion;
import com.example.thitracnghiem.dto.ExamSession;
import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Controller
@RequestMapping("/gv")
public class TrialExamController {

    private static final String TRIAL_EXAM_SESSION = "TRIAL_EXAM";

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;

    public TrialExamController(JdbcTemplate jdbcTemplate, ControllerSupport support) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
    }

    @GetMapping("/thi-thu")
    public String page(
            HttpSession session,
            Model model
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "thi-thu", "Thi thử");
        model.addAttribute("subjects", support.optionalList("EXEC dbo.sp_4_2_MonHoc_DanhSach"));
        model.addAttribute("mamh", "");
        model.addAttribute("trinhdo", "A");
        model.addAttribute("socau", 10);
        model.addAttribute("thoigian", 15);

        return "auth/gv/thi-thu";
    }

    @PostMapping("/thi-thu/bat-dau")
    public String startTrialExam(
            @RequestParam String mamh,
            @RequestParam String trinhdo,
            @RequestParam Integer socau,
            @RequestParam(defaultValue = "15") Integer thoigian,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        String normalizedMamh = support.safeTrim(mamh).toUpperCase();
        String normalizedTrinhDo = support.safeTrim(trinhdo).toUpperCase();
        int normalizedSoCau = socau == null ? 10 : socau;
        int normalizedThoiGian = thoigian == null ? 15 : thoigian;

        if (normalizedSoCau < 1 || normalizedSoCau > 100) {
            redirectAttributes.addFlashAttribute("error", "Số câu thi thử phải từ 1 đến 100.");
            return "redirect:/gv/thi-thu";
        }
        if (normalizedThoiGian < 1 || normalizedThoiGian > 180) {
            redirectAttributes.addFlashAttribute("error", "Thời gian thi thử phải từ 1 đến 180 phút.");
            return "redirect:/gv/thi-thu";
        }

        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                    "EXEC dbo.sp_ThiThu_PhatDe ?, ?, ?",
                    normalizedMamh,
                    normalizedTrinhDo,
                    normalizedSoCau
            );
            if (rows.isEmpty()) {
                redirectAttributes.addFlashAttribute("error", "Không phát được đề thi thử cho môn và trình độ đã chọn.");
                return "redirect:/gv/thi-thu";
            }

            ExamSession trialExam = buildTrialExam(rows, normalizedMamh, normalizedTrinhDo, normalizedThoiGian, session);
            session.setAttribute(TRIAL_EXAM_SESSION, trialExam);
            return "redirect:/gv/thi-thu/phong-thi";
        } catch (DataAccessException ex) {
            redirectAttributes.addFlashAttribute("error", support.dbMessage(ex));
            return "redirect:/gv/thi-thu";
        }
    }

    @GetMapping("/thi-thu/phong-thi")
    public String trialExamRoom(
            HttpSession session,
            Model model,
            RedirectAttributes redirectAttributes
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        ExamSession exam = (ExamSession) session.getAttribute(TRIAL_EXAM_SESSION);
        if (exam == null || exam.getQuestions().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Chưa có đề thi thử. Vui lòng bấm bắt đầu thi thử trước.");
            return "redirect:/gv/thi-thu";
        }

        long remainingSeconds = Math.max(0, java.time.Duration.between(LocalDateTime.now(), exam.getKetThucLuc()).toSeconds());
        exam.setRemainingSeconds(remainingSeconds);
        support.addTeacherShell(model, session, "thi-thu", "Phòng thi thử");
        model.addAttribute("exam", exam);
        return "auth/gv/phong-thi-thu";
    }

    @PostMapping("/thi-thu/nop-bai")
    public String submitTrialExam(
            @RequestParam Map<String, String> params,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        ExamSession exam = (ExamSession) session.getAttribute(TRIAL_EXAM_SESSION);
        if (exam == null || exam.getQuestions().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Không tìm thấy đề thi thử để nộp bài.");
            return "redirect:/gv/thi-thu";
        }

        int correct = 0;
        for (ExamQuestion question : exam.getQuestions()) {
            String selected = support.safeTrim(params.get("answers[" + question.getCauHoi() + "]")).toUpperCase();
            question.setDapAnChon(selected);
            if (Objects.equals(selected, question.getDapAnDung())) {
                correct++;
            }
        }

        int total = exam.getQuestions().size();
        double score = total == 0 ? 0 : Math.round((correct * 10.0 / total) * 100.0) / 100.0;
        session.removeAttribute(TRIAL_EXAM_SESSION);
        redirectAttributes.addFlashAttribute(
                "success",
                "Đã nộp bài thi thử. Điểm: " + score + " (" + correct + "/" + total + " câu đúng)."
        );
        return "redirect:/gv/thi-thu";
    }

    private ExamSession buildTrialExam(
            List<Map<String, Object>> rows,
            String mamh,
            String trinhdo,
            int thoigian,
            HttpSession session
    ) {
        ExamSession exam = new ExamSession();
        exam.setMaBt(-System.currentTimeMillis());
        exam.setMaSv(support.toStr(session.getAttribute("LOGINNAME")));
        exam.setHoTenSinhVien(support.toStr(session.getAttribute("HOTEN")));
        exam.setMaLop("THI_THU");
        exam.setTenLop("Giảng viên");
        exam.setMaMh(mamh);
        exam.setTenMh(subjectName(mamh));
        exam.setLan((short) 0);
        exam.setThoiGian((short) thoigian);
        exam.setBatDauLuc(LocalDateTime.now());
        exam.setKetThucLuc(LocalDateTime.now().plusMinutes(thoigian));
        exam.setRemainingSeconds(thoigian * 60L);
        exam.setTrangThai("DANG_THI");

        List<ExamQuestion> questions = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            ExamQuestion question = new ExamQuestion();
            question.setCauHoi(toInteger(row.get("CAUHOI")));
            question.setNoiDung(support.toStr(row.get("NOIDUNG")));
            question.setA(support.toStr(row.get("A")));
            question.setB(support.toStr(row.get("B")));
            question.setC(support.toStr(row.get("C")));
            question.setD(support.toStr(row.get("D")));
            question.setDapAnDung(support.toStr(row.get("DAP_AN")).toUpperCase());
            question.setTrinhDoCau(support.firstNotBlank(support.toStr(row.get("TRINHDO")), trinhdo));
            questions.add(question);
        }
        exam.setQuestions(questions);
        return exam;
    }

    private String subjectName(String mamh) {
        return support.optionalList("EXEC dbo.sp_4_2_MonHoc_DanhSach")
                .stream()
                .filter(row -> support.toStr(row.get("MAMH")).equalsIgnoreCase(mamh))
                .findFirst()
                .map(row -> support.toStr(row.get("TENMH")))
                .orElse(mamh);
    }

    private Integer toInteger(Object value) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        return Integer.parseInt(support.toStr(value));
    }
}
