package com.example.thitracnghiem.controller.gv;

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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/gv")
public class QuestionBankController {

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;

    public QuestionBankController(JdbcTemplate jdbcTemplate, ControllerSupport support) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
    }

    @GetMapping("/bo-de")
    public String boDe(
            @RequestParam(value = "mamh", required = false) String mamh,
            @RequestParam(value = "trinhdo", required = false) String trinhdo,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "edit", required = false) Integer edit,
            HttpSession session,
            Model model
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "bo-de", "Nháº­p cÃ¢u há»i thi");
        mamh = support.safeTrim(mamh).toUpperCase();
        trinhdo = support.safeTrim(trinhdo).toUpperCase();
        keyword = support.safeTrim(keyword);

        try {
            List<Map<String, Object>> subjects = jdbcTemplate.queryForList("EXEC dbo.sp_4_2_MonHoc_DanhSach");
            List<Map<String, Object>> allQuestions = jdbcTemplate.queryForList(
                    "EXEC dbo.sp_4_5_BoDe_DanhSachCuaNguoiDung ?",
                    session.getAttribute("LOGINNAME")
            );
            List<Map<String, Object>> rows = support.filterQuestions(allQuestions, mamh, trinhdo, keyword);

            model.addAttribute("subjects", subjects);
            model.addAttribute("questions", rows);
            List<Map<String, Object>> deletedQuestions = support.optionalList(
                    "EXEC dbo.sp_4_5_BoDe_DaXoaCuaNguoiDung ?",
                    session.getAttribute("LOGINNAME")
            );
            model.addAttribute("deletedQuestions", "PGV".equals(session.getAttribute("ROLE_NAME"))
                    ? deletedQuestions
                    : support.visibleQuestions(deletedQuestions, session));
            model.addAttribute("selectedMamh", mamh);
            model.addAttribute("selectedTrinhdo", trinhdo);
            model.addAttribute("keyword", keyword);
            model.addAttribute("form", edit == null ? new HashMap<String, Object>() : support.findBy(allQuestions, "CAUHOI", String.valueOf(edit)));
            model.addAttribute("mode", edit == null ? "create" : "edit");
        } catch (DataAccessException ex) {
            model.addAttribute("subjects", List.of());
            model.addAttribute("questions", List.of());
            model.addAttribute("deletedQuestions", List.of());
            model.addAttribute("form", new HashMap<String, Object>());
            model.addAttribute("mode", "create");
            model.addAttribute("selectedMamh", mamh);
            model.addAttribute("selectedTrinhdo", trinhdo);
            model.addAttribute("keyword", keyword);
            model.addAttribute("error", support.dbMessage(ex));
        }

        return "auth/gv/bo-de";
    }

    @PostMapping("/bo-de/save")
    public String saveBoDe(
            @RequestParam(value = "mode", required = false) String mode,
            @RequestParam(value = "cauhoi", required = false) Integer cauhoi,
            @RequestParam("mamh") String mamh,
            @RequestParam("trinhdo") String trinhdo,
            @RequestParam("noidung") String noidung,
            @RequestParam("a") String a,
            @RequestParam("b") String b,
            @RequestParam("c") String c,
            @RequestParam("d") String d,
            @RequestParam("dapAn") String dapAn,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        String loginname = support.toStr(session.getAttribute("LOGINNAME"));
        try {
            if ("edit".equals(mode) && cauhoi != null) {
                jdbcTemplate.update(
                        "EXEC dbo.sp_4_5_BoDe_Sua ?, ?, ?, ?, ?, ?, ?, ?, ?, ?",
                        loginname, cauhoi, support.safeTrim(mamh).toUpperCase(), support.safeTrim(trinhdo).toUpperCase(),
                        support.safeTrim(noidung), support.safeTrim(a), support.safeTrim(b), support.safeTrim(c), support.safeTrim(d), support.safeTrim(dapAn).toUpperCase()
                );
                redirect.addFlashAttribute("success", "ÄÃ£ ghi thay Ä‘á»•i cÃ¢u há»i.");
                return "redirect:/gv/bo-de?edit=" + cauhoi;
            }

            jdbcTemplate.update(
                    "EXEC dbo.sp_4_5_BoDe_Them ?, ?, ?, ?, ?, ?, ?, ?, ?",
                    loginname, support.safeTrim(mamh).toUpperCase(), support.safeTrim(trinhdo).toUpperCase(),
                    support.safeTrim(noidung), support.safeTrim(a), support.safeTrim(b), support.safeTrim(c), support.safeTrim(d), support.safeTrim(dapAn).toUpperCase()
            );
            redirect.addFlashAttribute("success", "ÄÃ£ thÃªm cÃ¢u há»i má»›i.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/bo-de";
    }

    @PostMapping("/bo-de/restore")
    public String restoreBoDe(@RequestParam("cauhoi") Integer cauhoi, HttpSession session, RedirectAttributes redirect) {
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_5_BoDe_PhucHoi ?, ?", session.getAttribute("LOGINNAME"), cauhoi);
            redirect.addFlashAttribute("success", "ÄÃ£ phá»¥c há»“i cÃ¢u há»i.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/bo-de?edit=" + cauhoi;
    }

    @PostMapping("/bo-de/delete")
    public String deleteBoDe(@RequestParam("cauhoi") Integer cauhoi, HttpSession session, RedirectAttributes redirect) {
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_5_BoDe_Xoa ?, ?", session.getAttribute("LOGINNAME"), cauhoi);
            redirect.addFlashAttribute("success", "ÄÃ£ xÃ³a cÃ¢u há»i.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/bo-de";
    }
}
