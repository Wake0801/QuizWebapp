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
public class AccountController {

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;
    private final SqlAuditContext auditContext;

    public AccountController(JdbcTemplate jdbcTemplate, ControllerSupport support, SqlAuditContext auditContext) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
        this.auditContext = auditContext;
    }

    @GetMapping("/tai-khoan")
    public String page(HttpSession session, Model model, RedirectAttributes redirect) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }
        if (!support.isPgv(session)) {
            redirect.addFlashAttribute("error", "Chỉ PGV được tạo tài khoản.");
            return "redirect:/gv/home";
        }

        support.addTeacherShell(model, session, "tai-khoan", "Tạo tài khoản");
        loadPageData(model);
        return "auth/gv/tai-khoan";
    }

    @PostMapping("/tai-khoan")
    public String create(
            @RequestParam("loginname") String loginname,
            @RequestParam("matkhau") String matkhau,
            @RequestParam("roleName") String roleName,
            @RequestParam("magv") String magv,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }
        if (!support.isPgv(session)) {
            redirect.addFlashAttribute("error", "Chỉ PGV được tạo tài khoản.");
            return "redirect:/gv/home";
        }

        try {
            String currentLogin = support.toStr(session.getAttribute("LOGINNAME"));
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                    auditContext.withAppLogin("EXEC dbo.sp_4_11_TaoTaiKhoan ?, ?, ?, ?, ?"),
                    auditContext.params(currentLogin,
                            currentLogin,
                            support.safeTrim(loginname),
                            support.safeTrim(matkhau),
                            support.safeTrim(roleName).toUpperCase(),
                            support.safeTrim(magv).toUpperCase())
            );
            String message = rows.isEmpty() ? "Đã tạo tài khoản." : support.toStr(rows.get(0).get("MESSAGE"));
            redirect.addFlashAttribute("success", message.isBlank() ? "Đã tạo tài khoản." : message);
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/tai-khoan";
    }

    private void loadPageData(Model model) {
        model.addAttribute("teachers", support.optionalList("EXEC dbo.sp_4_4_GiaoVien_DanhSach"));
        model.addAttribute("accounts", support.optionalList("""
                SELECT
                    TK.LOGINNAME,
                    TK.ROLE_NAME,
                    CASE TK.ROLE_NAME
                        WHEN N'GIANGVIEN' THEN N'Giảng viên'
                        WHEN N'PGV' THEN N'PGV'
                        ELSE TK.ROLE_NAME
                    END AS ROLE_LABEL,
                    RTRIM(TK.MAGV) AS MAGV,
                    LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN,
                    TK.IS_ACTIVE,
                    CASE
                        WHEN TK.IS_ACTIVE = 1 THEN N'Đang hoạt động'
                        ELSE N'Khóa'
                    END AS STATUS_LABEL,
                    TK.CREATED_AT
                FROM dbo.TaiKhoan AS TK
                LEFT JOIN dbo.GiaoVien AS GV ON GV.MAGV = TK.MAGV
                ORDER BY TK.ROLE_NAME DESC, TK.LOGINNAME
                """));
    }
}
