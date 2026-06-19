package com.example.thitracnghiem.controller.gv;

import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataAccessException;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/gv")
public class ClassStudentController {

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;

    public ClassStudentController(JdbcTemplate jdbcTemplate, ControllerSupport support) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
    }

    @GetMapping("/lop-sinh-vien")
    public String lopSinhVien(
            @RequestParam(value = "malop", required = false) String malop,
            @RequestParam(value = "classKeyword", required = false) String classKeyword,
            @RequestParam(value = "studentKeyword", required = false) String studentKeyword,
            @RequestParam(value = "editLop", required = false) String editLop,
            @RequestParam(value = "editSv", required = false) String editSv,
            HttpSession session,
            Model model
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "lop-sinh-vien", "Quản lý lớp - sinh viên");
        malop = support.safeTrim(malop).toUpperCase();
        classKeyword = support.safeTrim(classKeyword);
        studentKeyword = support.safeTrim(studentKeyword);
        editLop = support.safeTrim(editLop).toUpperCase();
        editSv = support.safeTrim(editSv).toUpperCase();
        if (malop.isBlank() && !editLop.isBlank()) {
            malop = editLop;
        }

        try {
            List<Map<String, Object>> allClasses = jdbcTemplate.queryForList("EXEC dbo.sp_4_3_Lop_DanhSach");
            List<Map<String, Object>> classes = support.filterByKeyword(allClasses, classKeyword, "MALOP", "TENLOP");

            List<Map<String, Object>> students = malop.isBlank()
                    ? List.of()
                    : support.filterByKeyword(
                            jdbcTemplate.queryForList("EXEC dbo.sp_4_3_SinhVien_DanhSachTheoLop ?", malop),
                            studentKeyword,
                            "MASV", "HO", "TEN", "HOTEN"
                    );

            model.addAttribute("classes", classes);
            model.addAttribute("allClasses", allClasses);
            model.addAttribute("students", students);
            model.addAttribute("deletedClasses", support.optionalList("EXEC dbo.sp_4_3_Lop_DaXoa"));
            model.addAttribute("deletedStudents", malop.isBlank()
                    ? support.optionalList("EXEC dbo.sp_4_3_SinhVien_DaXoa")
                    : support.optionalList("EXEC dbo.sp_4_3_SinhVien_DaXoaTheoLop ?", malop));
            model.addAttribute("selectedMalop", malop);
            model.addAttribute("classKeyword", classKeyword);
            model.addAttribute("studentKeyword", studentKeyword);
            model.addAttribute("editingClass", !editLop.isBlank());
            model.addAttribute("classForm", editLop.isBlank() ? new HashMap<String, Object>() : support.findBy(allClasses, "MALOP", editLop));
            model.addAttribute("classMode", editLop.isBlank() ? "create" : "edit");
            model.addAttribute("studentForm", editSv.isBlank() ? support.defaultStudentForm(malop) : support.findStudent(editSv));
            model.addAttribute("studentMode", editSv.isBlank() ? "create" : "edit");
        } catch (DataAccessException ex) {
            model.addAttribute("classes", List.of());
            model.addAttribute("allClasses", List.of());
            model.addAttribute("students", List.of());
            model.addAttribute("deletedClasses", List.of());
            model.addAttribute("deletedStudents", List.of());
            model.addAttribute("classForm", new HashMap<String, Object>());
            model.addAttribute("studentForm", support.defaultStudentForm(malop));
            model.addAttribute("editingClass", false);
            model.addAttribute("classMode", "create");
            model.addAttribute("studentMode", "create");
            model.addAttribute("selectedMalop", malop);
            model.addAttribute("classKeyword", classKeyword);
            model.addAttribute("studentKeyword", studentKeyword);
            model.addAttribute("error", support.dbMessage(ex));
        }

        return "auth/gv/lop-sinh-vien";
    }

    @PostMapping("/lop/save")
    public String saveLop(
            @RequestParam(value = "mode", required = false) String mode,
            @RequestParam("malop") String malop,
            @RequestParam("tenlop") String tenlop,
            RedirectAttributes redirect
    ) {
        String normalizedMalop = support.safeTrim(malop).toUpperCase();
        try {
            if ("edit".equals(mode)) {
                jdbcTemplate.update("EXEC dbo.sp_4_3_Lop_Sua ?, ?", normalizedMalop, support.safeTrim(tenlop));
                redirect.addFlashAttribute("success", "Đã ghi thay đổi lớp.");
            } else {
                jdbcTemplate.update("EXEC dbo.sp_4_3_Lop_Them ?, ?", normalizedMalop, support.safeTrim(tenlop));
                redirect.addFlashAttribute("success", "Đã thêm lớp mới.");
            }
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/lop-sinh-vien?malop=" + normalizedMalop;
    }

    @PostMapping("/lop/delete")
    public String deleteLop(@RequestParam("malop") String malop, RedirectAttributes redirect) {
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_3_Lop_Xoa ?", support.safeTrim(malop).toUpperCase());
            redirect.addFlashAttribute("success", "Đã xóa lớp.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/lop-sinh-vien";
    }

    @PostMapping("/lop/restore")
    public String restoreLop(@RequestParam("malop") String malop, RedirectAttributes redirect) {
        String normalizedMalop = support.safeTrim(malop).toUpperCase();
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_3_Lop_PhucHoi ?", normalizedMalop);
            redirect.addFlashAttribute("success", "Đã phục hồi lớp.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/lop-sinh-vien?malop=" + normalizedMalop;
    }

    @PostMapping("/sinh-vien/save")
    public String saveSinhVien(
            @RequestParam(value = "mode", required = false) String mode,
            @RequestParam("masv") String masv,
            @RequestParam("ho") String ho,
            @RequestParam("ten") String ten,
            @RequestParam(value = "ngaysinh", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate ngaysinh,
            @RequestParam(value = "diachi", required = false) String diachi,
            @RequestParam("malop") String malop,
            RedirectAttributes redirect
    ) {
        String normalizedMalop = support.safeTrim(malop).toUpperCase();
        Object sqlDate = ngaysinh == null ? null : Date.valueOf(ngaysinh);

        try {
            if ("edit".equals(mode)) {
                jdbcTemplate.update(
                        "EXEC dbo.sp_4_3_SinhVien_Sua ?, ?, ?, ?, ?, ?",
                        support.safeTrim(masv).toUpperCase(), support.safeTrim(ho), support.safeTrim(ten), sqlDate, support.nullIfBlank(diachi), normalizedMalop
                );
                redirect.addFlashAttribute("success", "Đã ghi thay đổi sinh viên.");
            } else {
                jdbcTemplate.update(
                        "EXEC dbo.sp_4_3_SinhVien_Them ?, ?, ?, ?, ?, ?",
                        support.safeTrim(masv).toUpperCase(), support.safeTrim(ho), support.safeTrim(ten), sqlDate, support.nullIfBlank(diachi), normalizedMalop
                );
                redirect.addFlashAttribute("success", "Đã thêm sinh viên mới.");
            }
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/lop-sinh-vien?malop=" + normalizedMalop;
    }

    @PostMapping("/sinh-vien/delete")
    public String deleteSinhVien(
            @RequestParam("masv") String masv,
            @RequestParam(value = "malop", required = false) String malop,
            RedirectAttributes redirect
    ) {
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_3_SinhVien_Xoa ?", support.safeTrim(masv).toUpperCase());
            redirect.addFlashAttribute("success", "Đã xóa sinh viên.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        String normalizedMalop = support.safeTrim(malop).toUpperCase();
        return normalizedMalop.isBlank()
                ? "redirect:/gv/lop-sinh-vien"
                : "redirect:/gv/lop-sinh-vien?malop=" + normalizedMalop;
    }

    @PostMapping("/sinh-vien/restore")
    public String restoreSinhVien(
            @RequestParam("masv") String masv,
            @RequestParam(value = "malop", required = false) String malop,
            RedirectAttributes redirect
    ) {
        String normalizedMalop = support.safeTrim(malop).toUpperCase();
        try {
            jdbcTemplate.update("EXEC dbo.sp_4_3_SinhVien_PhucHoi ?", support.safeTrim(masv).toUpperCase());
            redirect.addFlashAttribute("success", "Đã phục hồi sinh viên.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return normalizedMalop.isBlank()
                ? "redirect:/gv/lop-sinh-vien"
                : "redirect:/gv/lop-sinh-vien?malop=" + normalizedMalop;
    }
}
