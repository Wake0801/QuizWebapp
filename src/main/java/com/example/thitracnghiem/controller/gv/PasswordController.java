package com.example.thitracnghiem.controller.gv;

import com.example.thitracnghiem.support.ControllerSupport;
import com.example.thitracnghiem.support.SqlAuditContext;
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

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/gv")
public class PasswordController {

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;
    private final SqlAuditContext auditContext;

    public PasswordController(JdbcTemplate jdbcTemplate, ControllerSupport support, SqlAuditContext auditContext) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
        this.auditContext = auditContext;
    }

    @GetMapping("/mat-khau")
    public String matKhau(HttpSession session, Model model) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "mat-khau", "Đổi mật khẩu");
        return "auth/gv/mat-khau";
    }

    @PostMapping("/mat-khau/doi")
    public String doiMatKhau(
            @RequestParam(value = "currentPassword", required = false) String currentPassword,
            @RequestParam(value = "newPassword", required = false) String newPassword,
            @RequestParam(value = "confirmPassword", required = false) String confirmPassword,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        String loginname = support.toStr(session.getAttribute("LOGINNAME"));
        currentPassword = support.safeTrim(currentPassword);
        newPassword = support.safeTrim(newPassword);
        confirmPassword = support.safeTrim(confirmPassword);

        if (loginname.isBlank()) {
            redirect.addFlashAttribute("error", "Phiên đăng nhập không có loginname. Vui lòng đăng nhập lại.");
            return "redirect:/gv/mat-khau";
        }

        if (currentPassword.isBlank() || newPassword.isBlank() || confirmPassword.isBlank()) {
            redirect.addFlashAttribute("error", "Vui lòng nhập đầy đủ mật khẩu hiện tại, mật khẩu mới và xác nhận.");
            return "redirect:/gv/mat-khau";
        }

        if (newPassword.length() < 6 || newPassword.length() > 128) {
            redirect.addFlashAttribute("error", "Mật khẩu mới phải từ 6 đến 128 ký tự.");
            return "redirect:/gv/mat-khau";
        }

        if (!newPassword.equals(confirmPassword)) {
            redirect.addFlashAttribute("error", "Xác nhận mật khẩu mới không khớp.");
            return "redirect:/gv/mat-khau";
        }

        if (newPassword.equals(currentPassword)) {
            redirect.addFlashAttribute("error", "Mật khẩu mới phải khác mật khẩu hiện tại.");
            return "redirect:/gv/mat-khau";
        }

        try {
            List<Map<String, Object>> loginRows = jdbcTemplate.queryForList(
                    "EXEC dbo.sp_4_1_DangNhap ?, ?, ?",
                    session.getAttribute("ROLE_NAME"),
                    loginname,
                    currentPassword
            );
            if (loginRows.isEmpty() || !support.toBoolean(loginRows.get(0).get("SUCCESS"))) {
                redirect.addFlashAttribute("error", "Mật khẩu hiện tại không đúng.");
                return "redirect:/gv/mat-khau";
            }

            jdbcTemplate.update(
                    auditContext.withAppLogin(
                            "EXEC dbo.sp_4_6_DoiMatKhauGiangVien @LOGINNAME = ?, @CURRENT_PASSWORD = ?, @NEW_PASSWORD = ?"
                    ),
                    auditContext.params(loginname, loginname, currentPassword, newPassword)
            );
            redirect.addFlashAttribute("success", "Đã đổi mật khẩu cho tài khoản đang đăng nhập.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/mat-khau";
    }
}
