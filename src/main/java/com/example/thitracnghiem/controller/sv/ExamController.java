package com.example.thitracnghiem.controller.sv;

import com.example.thitracnghiem.dto.ExamResultData;
import com.example.thitracnghiem.dto.ExamSession;
import com.example.thitracnghiem.dto.ExamSubmitResult;
import com.example.thitracnghiem.service.CatalogService;
import com.example.thitracnghiem.service.ExamService;
import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

@Controller
@RequestMapping("/sv")
public class ExamController {

    private final ExamService examService;
    private final CatalogService catalogService;
    private final ControllerSupport support;

    public ExamController(ExamService examService, CatalogService catalogService, ControllerSupport support) {
        this.examService = examService;
        this.catalogService = catalogService;
        this.support = support;
    }

    @GetMapping("/thi")
    public String startPage(HttpSession session, Model model) {
        if (!support.isStudent(session)) {
            return "redirect:/login";
        }

        String maSv = support.toStr(session.getAttribute("MASV"));
        support.addStudentShell(model, session, "thi", "Vào thi");
        model.addAttribute("availableExams", examService.availableExams(maSv));
        model.addAttribute("subjects", catalogService.findAllMonHoc());
        return "auth/sv/thi";
    }

    @PostMapping("/thi/bat-dau")
    public String startExam(
            @RequestParam String maMh,
            @RequestParam Short lan,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {
        if (!support.isStudent(session)) {
            return "redirect:/login";
        }

        String maSv = support.toStr(session.getAttribute("MASV"));
        try {
            ExamSession examSession = examService.startExam(maSv, maMh, lan);
            redirectAttributes.addAttribute("maBt", examSession.getMaBt());
            return "redirect:/sv/thi/phong-thi";
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
            return "redirect:/sv/thi";
        }
    }

    @GetMapping("/thi/phong-thi")
    public String examRoom(
            @RequestParam Long maBt,
            HttpSession session,
            Model model,
            RedirectAttributes redirectAttributes
    ) {
        if (!support.isStudent(session)) {
            return "redirect:/login";
        }

        try {
            ExamSession exam = examService.loadAttemptForStudent(maBt, support.toStr(session.getAttribute("MASV")));
            support.addStudentShell(model, session, "thi", "Phòng thi");
            model.addAttribute("exam", exam);
            return "auth/sv/phong-thi";
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
            return "redirect:/sv/thi";
        }
    }

    @PostMapping("/thi/luu-cau-tra-loi")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveAnswer(
            @RequestParam Long maBt,
            @RequestParam Integer cauHoi,
            @RequestParam(required = false) String dapAn,
            HttpSession session
    ) {
        try {
            if (!support.isStudent(session)) {
                return ResponseEntity.status(401).body(Map.of("saved", false, "message", "Chưa đăng nhập."));
            }
            examService.saveAnswerForStudent(maBt, support.toStr(session.getAttribute("MASV")), cauHoi, dapAn);
            return ResponseEntity.ok(Map.of("saved", true));
        } catch (RuntimeException ex) {
            return ResponseEntity.badRequest().body(Map.of("saved", false, "message", ex.getMessage()));
        }
    }

    @PostMapping("/thi/nop-bai")
    public String submit(
            @RequestParam Long maBt,
            @RequestParam Map<String, String> params,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {
        if (!support.isStudent(session)) {
            return "redirect:/login";
        }

        try {
            Map<Integer, String> answers = examService.extractAnswers(params);
            ExamSubmitResult result = examService.submitForStudent(maBt, support.toStr(session.getAttribute("MASV")), answers);
            redirectAttributes.addFlashAttribute(
                    "success",
                    "Đã nộp bài. Điểm: " + result.getDiem()
                            + " (" + result.getSoCauDung() + "/" + result.getSoCau() + " câu đúng)."
            );
            redirectAttributes.addAttribute("maMh", result.getMaMh());
            redirectAttributes.addAttribute("lan", result.getLan());
            return "redirect:/sv/ket-qua";
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
            redirectAttributes.addAttribute("maBt", maBt);
            return "redirect:/sv/thi/phong-thi";
        }
    }

    @GetMapping("/ket-qua")
    public String studentResult(
            @RequestParam(required = false) String maMh,
            @RequestParam(required = false) Short lan,
            HttpSession session,
            Model model
    ) {
        if (!support.isStudent(session)) {
            return "redirect:/login";
        }

        String maSv = support.toStr(session.getAttribute("MASV"));
        support.addStudentShell(model, session, "ket-qua", "Kết quả / điểm");
        model.addAttribute("maMh", maMh);
        model.addAttribute("lan", lan);
        model.addAttribute("subjects", catalogService.findAllMonHoc());
        if (maMh != null && lan != null) {
            ExamResultData result = examService.findResult(maSv, maMh, lan);
            model.addAttribute("result", result);
        }
        return "auth/sv/ket-qua";
    }
}
