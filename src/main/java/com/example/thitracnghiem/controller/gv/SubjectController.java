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
public class SubjectController {

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;

    public SubjectController(JdbcTemplate jdbcTemplate, ControllerSupport support) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
    }

    @GetMapping("/mon-hoc")
    public String monHoc(
            @RequestParam(value = "mamh", required = false) String mamh,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "edit", required = false) String edit,
            HttpSession session,
            Model model
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "mon-hoc", "Quáº£n lÃ½ mÃ´n há»c");
        mamh = support.safeTrim(mamh).toUpperCase();
        keyword = support.safeTrim(keyword);
        edit = support.safeTrim(edit).toUpperCase();

        try {
            List<Map<String, Object>> allSubjects = jdbcTemplate.queryForList("EXEC dbo.sp_4_2_MonHoc_DanhSach");
            List<Map<String, Object>> rows = support.filterByKeyword(
                    support.filterByValue(allSubjects, "MAMH", mamh),
                    keyword,
                    "MAMH", "TENMH"
            );

            model.addAttribute("allSubjects", allSubjects);
            model.addAttribute("subjects", rows);
            model.addAttribute("deletedSubjects", support.optionalList("EXEC dbo.sp_4_2_MonHoc_DaXoa"));
            model.addAttribute("selectedMamh", mamh);
            model.addAttribute("keyword", keyword);
            model.addAttribute("form", edit.isBlank()
                    ? new HashMap<String, Object>()
                    : support.findBy(allSubjects, "MAMH", edit));
            model.addAttribute("mode", edit.isBlank() ? "create" : "edit");
        } catch (DataAccessException ex) {
            model.addAttribute("allSubjects", List.of());
            model.addAttribute("subjects", List.of());
            model.addAttribute("deletedSubjects", List.of());
            model.addAttribute("form", new HashMap<String, Object>());
            model.addAttribute("mode", "create");
            model.addAttribute("selectedMamh", mamh);
            model.addAttribute("keyword", keyword);
            model.addAttribute("error", support.dbMessage(ex));
        }

        return "auth/gv/mon-hoc";
    }

    @PostMapping("/mon-hoc/save")
    public String saveMonHoc(
            @RequestParam(value = "mode", required = false) String mode,
            @RequestParam("mamh") String mamh,
            @RequestParam("tenmh") String tenmh,
            RedirectAttributes redirect
    ) {
        try {
            if ("edit".equals(mode)) {
                jdbcTemplate.update("EXEC dbo.sp_4_2_MonHoc_Sua ?, ?", support.safeTrim(mamh).toUpperCase(), support.safeTrim(tenmh));
                redirect.addFlashAttribute("success", "ÄÃ£ ghi thay Ä‘á»•i mÃ´n há»c.");
                return "redirect:/gv/mon-hoc?edit=" + support.safeTrim(mamh).toUpperCase();
            }

            jdbcTemplate.update("EXEC dbo.sp_4_2_MonHoc_Them ?, ?", support.safeTrim(mamh).toUpperCase(), support.safeTrim(tenmh));
            redirect.addFlashAttribute("success", "ÄÃ£ thÃªm mÃ´n há»c má»›i.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/mon-hoc";
    }

    @PostMapping("/mon-hoc/restore")
    public String restoreMonHoc(@RequestParam("mamh") String mamh, RedirectAttributes redirect) {
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_2_MonHoc_PhucHoi ?", support.safeTrim(mamh).toUpperCase());
            redirect.addFlashAttribute("success", "ÄÃ£ phá»¥c há»“i mÃ´n há»c.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/mon-hoc";
    }

    @PostMapping("/mon-hoc/delete")
    public String deleteMonHoc(@RequestParam("mamh") String mamh, RedirectAttributes redirect) {
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_2_MonHoc_Xoa ?", support.safeTrim(mamh).toUpperCase());
            redirect.addFlashAttribute("success", "ÄÃ£ xÃ³a mÃ´n há»c.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/mon-hoc";
    }
}
