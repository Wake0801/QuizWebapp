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

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/gv")
public class PasswordController {

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;

    public PasswordController(JdbcTemplate jdbcTemplate, ControllerSupport support) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
    }

    @GetMapping("/mat-khau")
    public String matKhau(HttpSession session, Model model) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "mat-khau", "Äá»•i máº­t kháº©u");
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
            redirect.addFlashAttribute("error", "PhiÃªn Ä‘Äƒng nháº­p khÃ´ng cÃ³ loginname. Vui lÃ²ng Ä‘Äƒng nháº­p láº¡i.");
            return "redirect:/gv/mat-khau";
        }

        if (currentPassword.isBlank() || newPassword.isBlank() || confirmPassword.isBlank()) {
            redirect.addFlashAttribute("error", "Vui lÃ²ng nháº­p Ä‘áº§y Ä‘á»§ máº­t kháº©u hiá»‡n táº¡i, máº­t kháº©u má»›i vÃ  xÃ¡c nháº­n.");
            return "redirect:/gv/mat-khau";
        }

        if (newPassword.length() < 6 || newPassword.length() > 128) {
            redirect.addFlashAttribute("error", "Máº­t kháº©u má»›i pháº£i tá»« 6 Ä‘áº¿n 128 kÃ½ tá»±.");
            return "redirect:/gv/mat-khau";
        }

        if (!newPassword.equals(confirmPassword)) {
            redirect.addFlashAttribute("error", "XÃ¡c nháº­n máº­t kháº©u má»›i khÃ´ng khá»›p.");
            return "redirect:/gv/mat-khau";
        }

        if (newPassword.equals(currentPassword)) {
            redirect.addFlashAttribute("error", "Máº­t kháº©u má»›i pháº£i khÃ¡c máº­t kháº©u hiá»‡n táº¡i.");
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
                redirect.addFlashAttribute("error", "Mat khau hien tai khong dung.");
                return "redirect:/gv/mat-khau";
            }

            jdbcTemplate.update(
                    "EXEC dbo.sp_4_6_DoiMatKhauGiangVien @LOGINNAME = ?, @NEW_PASSWORD = ?",
                    loginname,
                    newPassword
            );
            redirect.addFlashAttribute("success", "ÄÃ£ Ä‘á»•i máº­t kháº©u cho tÃ i khoáº£n Ä‘ang Ä‘Äƒng nháº­p.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/mat-khau";
    }
}
