package com.example.thitracnghiem.controller.gv;

import com.example.thitracnghiem.service.CatalogService;
import com.example.thitracnghiem.service.ExamService;
import com.example.thitracnghiem.service.ScoreExcelExportService;
import com.example.thitracnghiem.service.ScoreService;
import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.nio.charset.StandardCharsets;
import java.util.List;

@Controller
@RequestMapping("/gv")
public class ScoreController {

    private final ExamService examService;
    private final ScoreService scoreService;
    private final ScoreExcelExportService scoreExcelExportService;
    private final CatalogService catalogService;
    private final ControllerSupport support;

    public ScoreController(
            ExamService examService,
            ScoreService scoreService,
            ScoreExcelExportService scoreExcelExportService,
            CatalogService catalogService,
            ControllerSupport support
    ) {
        this.examService = examService;
        this.scoreService = scoreService;
        this.scoreExcelExportService = scoreExcelExportService;
        this.catalogService = catalogService;
        this.support = support;
    }

    @GetMapping("/ket-qua")
    public String result(
            @RequestParam(required = false) String maSv,
            @RequestParam(required = false) String maMh,
            @RequestParam(required = false) Short lan,
            HttpSession session,
            Model model
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "ket-qua", "Xem kết quả bài thi");
        model.addAttribute("maSv", maSv);
        model.addAttribute("maMh", maMh);
        model.addAttribute("lan", lan);
        model.addAttribute("subjects", catalogService.findAllMonHoc());
        if (maSv != null && maMh != null && lan != null) {
            model.addAttribute("result", examService.findResult(maSv, maMh, lan));
        }
        return "auth/gv/ket-qua";
    }

    @GetMapping("/bang-diem")
    public String scoreboard(
            @RequestParam(required = false) String maLop,
            @RequestParam(required = false) String maMh,
            @RequestParam(required = false) Short lan,
            HttpSession session,
            Model model
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "bang-diem", "Bảng điểm môn học");
        model.addAttribute("maLop", maLop);
        model.addAttribute("maMh", maMh);
        model.addAttribute("lan", lan);
        model.addAttribute("classes", catalogService.findAllLop());
        model.addAttribute("subjects", catalogService.findAllMonHoc());
        model.addAttribute("scores", scoreService.findScoreBoard(maLop, maMh, lan));
        return "auth/gv/bang-diem";
    }

    @GetMapping("/bang-diem/excel")
    public ResponseEntity<byte[]> exportScoreboard(
            @RequestParam(required = false) String maLop,
            @RequestParam(required = false) String maMh,
            @RequestParam(required = false) Short lan,
            HttpSession session
    ) {
        if (!support.isTeacher(session)) {
            return ResponseEntity.status(401).build();
        }

        List<com.example.thitracnghiem.dto.ScoreRow> scores = scoreService.findScoreBoard(maLop, maMh, lan);
        byte[] content = scoreExcelExportService.exportScoreBoard(scores, maLop, maMh, lan);
        String fileName = scoreExcelExportService.buildFileName(maLop, maMh, lan);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDisposition(ContentDisposition.attachment().filename(fileName, StandardCharsets.UTF_8).build());
        headers.setContentLength(content.length);

        return ResponseEntity.ok()
                .headers(headers)
                .body(content);
    }
}
