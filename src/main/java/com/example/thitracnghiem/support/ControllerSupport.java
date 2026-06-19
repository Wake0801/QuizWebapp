package com.example.thitracnghiem.support;

import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.ui.Model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Component
public class ControllerSupport {

    private final JdbcTemplate jdbcTemplate;

    public ControllerSupport(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void addTeacherShell(Model model, HttpSession session, String active, String title) {
        model.addAttribute("active", active);
        model.addAttribute("pageTitle", title);
        model.addAttribute("hoten", session.getAttribute("HOTEN"));
        model.addAttribute("loginname", session.getAttribute("LOGINNAME"));
        model.addAttribute("magv", session.getAttribute("MAGV"));
        model.addAttribute("role", session.getAttribute("ROLE_NAME"));
        model.addAttribute("isPgv", "PGV".equals(session.getAttribute("ROLE_NAME")));
    }

    public boolean isTeacher(HttpSession session) {
        String role = toStr(session.getAttribute("ROLE_NAME"));
        return "PGV".equals(role) || "GIANGVIEN".equals(role);
    }

    public boolean isStudent(HttpSession session) {
        return "SINHVIEN".equals(toStr(session.getAttribute("ROLE_NAME")));
    }

    public List<Map<String, Object>> visibleQuestions(List<Map<String, Object>> rows, HttpSession session) {
        if ("PGV".equals(session.getAttribute("ROLE_NAME"))) {
            return rows;
        }

        String magv = toStr(session.getAttribute("MAGV"));
        List<Map<String, Object>> filtered = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            if (toStr(row.get("MAGV")).equalsIgnoreCase(magv)) {
                filtered.add(row);
            }
        }
        return filtered;
    }

    public List<Map<String, Object>> filterByValue(List<Map<String, Object>> rows, String key, String value) {
        String expected = safeTrim(value);
        if (expected.isBlank()) {
            return rows;
        }

        List<Map<String, Object>> filtered = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            if (toStr(row.get(key)).equalsIgnoreCase(expected)) {
                filtered.add(row);
            }
        }
        return filtered;
    }

    public List<Map<String, Object>> filterByKeyword(List<Map<String, Object>> rows, String keyword, String... keys) {
        String expected = safeTrim(keyword).toLowerCase(Locale.ROOT);
        if (expected.isBlank()) {
            return rows;
        }

        List<Map<String, Object>> filtered = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            for (String key : keys) {
                if (toStr(row.get(key)).toLowerCase(Locale.ROOT).contains(expected)) {
                    filtered.add(row);
                    break;
                }
            }
        }
        return filtered;
    }

    public List<Map<String, Object>> filterQuestions(List<Map<String, Object>> rows, String mamh, String trinhdo, String keyword) {
        String expectedMamh = safeTrim(mamh);
        String expectedTrinhdo = safeTrim(trinhdo);
        String expectedKeyword = safeTrim(keyword).toLowerCase(Locale.ROOT);
        List<Map<String, Object>> filtered = new ArrayList<>();

        for (Map<String, Object> row : rows) {
            boolean matchesSubject = expectedMamh.isBlank() || toStr(row.get("MAMH")).equalsIgnoreCase(expectedMamh);
            boolean matchesLevel = expectedTrinhdo.isBlank() || toStr(row.get("TRINHDO")).equalsIgnoreCase(expectedTrinhdo);
            boolean matchesKeyword = expectedKeyword.isBlank()
                    || toStr(row.get("CAUHOI")).toLowerCase(Locale.ROOT).contains(expectedKeyword)
                    || toStr(row.get("MAMH")).toLowerCase(Locale.ROOT).contains(expectedKeyword)
                    || toStr(row.get("NOIDUNG")).toLowerCase(Locale.ROOT).contains(expectedKeyword)
                    || toStr(row.get("HOTEN_GV")).toLowerCase(Locale.ROOT).contains(expectedKeyword);
            if (matchesSubject && matchesLevel && matchesKeyword) {
                filtered.add(row);
            }
        }
        return filtered;
    }

    public List<Map<String, Object>> optionalList(String sql, Object... args) {
        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, args);
            return rows == null ? List.of() : rows;
        } catch (DataAccessException ex) {
            return List.of();
        }
    }

    public Map<String, Object> defaultStudentForm(String malop) {
        Map<String, Object> form = new HashMap<>();
        form.put("MALOP", safeTrim(malop).toUpperCase());
        return form;
    }

    public Map<String, Object> findStudent(String masv) {
        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList("EXEC dbo.sp_4_3_SinhVien_Tim ?", masv);
            return findBy(rows, "MASV", masv);
        } catch (DataAccessException ex) {
            return new HashMap<>();
        }
    }

    public Map<String, Object> findBy(List<Map<String, Object>> rows, String key, String value) {
        String expected = safeTrim(value);
        for (Map<String, Object> row : rows) {
            if (toStr(row.get(key)).equalsIgnoreCase(expected)) {
                return row;
            }
        }
        return new HashMap<>();
    }

    public String nullIfBlank(String value) {
        String trimmed = safeTrim(value);
        return trimmed.isBlank() ? null : trimmed;
    }

    public String firstNotBlank(String... values) {
        for (String value : values) {
            String trimmed = safeTrim(value);
            if (!trimmed.isBlank()) {
                return trimmed;
            }
        }
        return "";
    }

    public String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }

    public String toStr(Object value) {
        return value == null ? "" : value.toString().trim();
    }

    public boolean toBoolean(Object value) {
        if (value instanceof Boolean bool) {
            return bool;
        }
        if (value instanceof Number number) {
            return number.intValue() != 0;
        }
        return Boolean.parseBoolean(toStr(value));
    }

    public String dbMessage(DataAccessException ex) {
        Throwable cause = ex.getMostSpecificCause();
        String message = cause == null ? ex.getMessage() : cause.getMessage();
        return message == null ? "Có lỗi dữ liệu. Vui lòng kiểm tra lại." : message;
    }
}
