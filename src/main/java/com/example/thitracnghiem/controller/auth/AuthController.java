package com.example.thitracnghiem.controller.auth;

import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@Controller
public class AuthController {

    private static final String VIEW_LOGIN = "auth/login";

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;

    public AuthController(JdbcTemplate jdbcTemplate, ControllerSupport support) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
    }

    @GetMapping({"/", "/login"})
    public String loginPage(HttpSession session) {
        String role = (String) session.getAttribute("ROLE_NAME");

        if ("PGV".equals(role) || "GIANGVIEN".equals(role)) {
            return "redirect:/gv/home";
        }

        if ("SINHVIEN".equals(role)) {
            return "redirect:/sv/home";
        }

        return VIEW_LOGIN;
    }

    @PostMapping("/login")
    public String login(
            @RequestParam(value = "role", required = false) String role,
            @RequestParam(value = "account", required = false) String account,
            @RequestParam(value = "username", required = false) String username,
            @RequestParam(value = "masv", required = false) String masv,
            @RequestParam(value = "password", required = false) String password,
            HttpServletRequest request,
            Model model
    ) {
        role = support.safeTrim(role).toUpperCase();
        account = support.firstNotBlank(account, masv, username).toUpperCase();
        password = support.safeTrim(password);

        model.addAttribute("selectedRole", role);
        model.addAttribute("account", account);

        if (role.isBlank() || account.isBlank() || password.isBlank()) {
            model.addAttribute("error", "Vui lòng nhập đầy đủ thông tin đăng nhập.");
            return VIEW_LOGIN;
        }

        List<Map<String, Object>> rows;
        try {
            rows = loginWithStoredProcedure(role, account, password);
        } catch (DataAccessException ex) {
            try {
                rows = loginDirectly(role, account, password);
            } catch (DataAccessException fallbackEx) {
                model.addAttribute("error", "Không thể đăng nhập do lỗi SQL Server: " + support.dbMessage(fallbackEx));
                return VIEW_LOGIN;
            }
        }

        if (rows.isEmpty() || !support.toBoolean(rows.get(0).get("SUCCESS"))) {
            model.addAttribute("error", rows.isEmpty()
                    ? "Đăng nhập không thành công."
                    : support.toStr(rows.get(0).get("MESSAGE")));
            return VIEW_LOGIN;
        }

        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }

        Map<String, Object> user = rows.get(0);
        HttpSession session = request.getSession(true);

        String loggedRole = support.toStr(user.get("ROLE_NAME"));
        session.setAttribute("ROLE_NAME", loggedRole);
        session.setAttribute("HOTEN", support.toStr(user.get("HOTEN")));

        if ("SINHVIEN".equals(loggedRole)) {
            session.setAttribute("LOGINNAME", "sv");
            session.setAttribute("MASV", support.toStr(user.get("MASV")));
            session.setAttribute("MALOP", support.toStr(user.get("MALOP")));
            session.setAttribute("TENLOP", support.toStr(user.get("TENLOP")));
            return "redirect:/sv/home";
        }

        session.setAttribute("LOGINNAME", support.toStr(user.get("LOGINNAME")));
        session.setAttribute("MAGV", support.toStr(user.get("MAGV")));
        return "redirect:/gv/home";
    }

    private List<Map<String, Object>> loginWithStoredProcedure(String role, String account, String password) {
        return jdbcTemplate.queryForList(
                "EXEC dbo.sp_4_1_DangNhap ?, ?, ?",
                role,
                account,
                password
        );
    }

    private List<Map<String, Object>> loginDirectly(String role, String account, String password) {
        if ("SINHVIEN".equals(role)) {
            if (!"123456".equals(password)) {
                return List.of(Map.of(
                        "SUCCESS", false,
                        "MESSAGE", "Mật khẩu sinh viên không đúng."
                ));
            }

            List<Map<String, Object>> students = jdbcTemplate.queryForList("""
                    SELECT
                        CAST(1 AS BIT) AS SUCCESS,
                        N'Đăng nhập thành công.' AS MESSAGE,
                        N'SINHVIEN' AS ROLE_NAME,
                        RTRIM(SV.MASV) AS MASV,
                        LTRIM(RTRIM(ISNULL(SV.HO, N'') + N' ' + ISNULL(SV.TEN, N''))) AS HOTEN,
                        RTRIM(SV.MALOP) AS MALOP,
                        L.TENLOP
                    FROM dbo.SinhVien AS SV
                    LEFT JOIN dbo.Lop AS L ON L.MALOP = SV.MALOP
                    WHERE UPPER(RTRIM(SV.MASV)) = ?
                    """, account);

            return students.isEmpty()
                    ? List.of(Map.of("SUCCESS", false, "MESSAGE", "Mã sinh viên không tồn tại."))
                    : students;
        }

        if ("PGV".equals(role) || "GIANGVIEN".equals(role)) {
            List<Map<String, Object>> teachers = jdbcTemplate.queryForList("""
                    SELECT
                        CAST(1 AS BIT) AS SUCCESS,
                        N'Đăng nhập thành công.' AS MESSAGE,
                        TK.LOGINNAME,
                        TK.ROLE_NAME,
                        RTRIM(TK.MAGV) AS MAGV,
                        LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN
                    FROM dbo.TaiKhoan AS TK
                    LEFT JOIN dbo.GiaoVien AS GV ON GV.MAGV = TK.MAGV
                    WHERE UPPER(RTRIM(TK.LOGINNAME)) = ?
                      AND TK.MATKHAU = ?
                      AND TK.ROLE_NAME = ?
                      AND TK.IS_ACTIVE = 1
                    """, account, password, role);

            return teachers.isEmpty()
                    ? List.of(Map.of("SUCCESS", false, "MESSAGE", "Login hoặc password không đúng với vai trò đã chọn."))
                    : teachers;
        }

        return List.of(Map.of("SUCCESS", false, "MESSAGE", "Vai trò đăng nhập không hợp lệ."));
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}
