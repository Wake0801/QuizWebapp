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
public class TeacherController {

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;

    public TeacherController(JdbcTemplate jdbcTemplate, ControllerSupport support) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
    }

    @GetMapping("/giao-vien")
    public String giaoVien(
            @RequestParam(value = "magv", required = false) String magv,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "edit", required = false) String edit,
            HttpSession session,
            Model model
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "giao-vien", "Quản lý giáo viên");
        magv = support.safeTrim(magv).toUpperCase();
        keyword = support.safeTrim(keyword);
        edit = support.safeTrim(edit).toUpperCase();

        try {
            List<Map<String, Object>> allTeachers = jdbcTemplate.queryForList("EXEC dbo.sp_4_4_GiaoVien_DanhSach");
            List<Map<String, Object>> rows = support.filterByKeyword(
                    support.filterByValue(allTeachers, "MAGV", magv),
                    keyword,
                    "MAGV", "HO", "TEN", "HOTEN", "SODTLL"
            );

            model.addAttribute("allTeachers", allTeachers);
            model.addAttribute("teachers", rows);
            model.addAttribute("deletedTeachers", support.optionalList("EXEC dbo.sp_4_4_GiaoVien_DaXoa"));
            model.addAttribute("selectedMagv", magv);
            model.addAttribute("keyword", keyword);
            model.addAttribute("form", edit.isBlank() ? new HashMap<String, Object>() : support.findBy(allTeachers, "MAGV", edit));
            model.addAttribute("mode", edit.isBlank() ? "create" : "edit");
        } catch (DataAccessException ex) {
            model.addAttribute("allTeachers", List.of());
            model.addAttribute("teachers", List.of());
            model.addAttribute("deletedTeachers", List.of());
            model.addAttribute("form", new HashMap<String, Object>());
            model.addAttribute("mode", "create");
            model.addAttribute("selectedMagv", magv);
            model.addAttribute("keyword", keyword);
            model.addAttribute("error", support.dbMessage(ex));
        }

        return "auth/gv/giao-vien";
    }

    @PostMapping("/giao-vien/save")
    public String saveGiaoVien(
            @RequestParam(value = "mode", required = false) String mode,
            @RequestParam("magv") String magv,
            @RequestParam("ho") String ho,
            @RequestParam("ten") String ten,
            @RequestParam(value = "sodtll", required = false) String sodtll,
            @RequestParam(value = "diachi", required = false) String diachi,
            RedirectAttributes redirect
    ) {
        String normalizedMagv = support.safeTrim(magv).toUpperCase();
        try {
            if ("edit".equals(mode)) {
                jdbcTemplate.update(
                        "EXEC dbo.sp_4_4_GiaoVien_Sua ?, ?, ?, ?, ?",
                        normalizedMagv, support.safeTrim(ho), support.safeTrim(ten), support.nullIfBlank(sodtll), support.nullIfBlank(diachi)
                );
                redirect.addFlashAttribute("success", "Đã ghi thay đổi giáo viên.");
            } else {
                jdbcTemplate.update(
                        "EXEC dbo.sp_4_4_GiaoVien_Them ?, ?, ?, ?, ?",
                        normalizedMagv, support.safeTrim(ho), support.safeTrim(ten), support.nullIfBlank(sodtll), support.nullIfBlank(diachi)
                );
                redirect.addFlashAttribute("success", "Đã thêm giáo viên mới.");
            }
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/giao-vien?edit=" + normalizedMagv;
    }

    @PostMapping("/giao-vien/delete")
    public String deleteGiaoVien(@RequestParam("magv") String magv, RedirectAttributes redirect) {
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_4_GiaoVien_Xoa ?", support.safeTrim(magv).toUpperCase());
            redirect.addFlashAttribute("success", "Đã xóa giáo viên.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/giao-vien";
    }

    @PostMapping("/giao-vien/restore")
    public String restoreGiaoVien(@RequestParam("magv") String magv, RedirectAttributes redirect) {
        String normalizedMagv = support.safeTrim(magv).toUpperCase();
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_4_GiaoVien_PhucHoi ?", normalizedMagv);
            redirect.addFlashAttribute("success", "Đã phục hồi giáo viên.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/giao-vien?edit=" + normalizedMagv;
    }
}
