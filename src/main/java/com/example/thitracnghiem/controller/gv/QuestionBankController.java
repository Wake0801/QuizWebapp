package com.example.thitracnghiem.controller.gv;

import com.example.thitracnghiem.support.ControllerSupport;
import com.example.thitracnghiem.support.SqlAuditContext;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Controller
@RequestMapping("/gv")
public class QuestionBankController {

    private final JdbcTemplate jdbcTemplate;
    private final ControllerSupport support;
    private final SqlAuditContext auditContext;

    public QuestionBankController(JdbcTemplate jdbcTemplate, ControllerSupport support, SqlAuditContext auditContext) {
        this.jdbcTemplate = jdbcTemplate;
        this.support = support;
        this.auditContext = auditContext;
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

        support.addTeacherShell(model, session, "bo-de", "Nhập câu hỏi thi");
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
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        String loginname = support.toStr(session.getAttribute("LOGINNAME"));
        String cleanMamh = support.safeTrim(mamh).toUpperCase();
        String cleanTrinhdo = support.safeTrim(trinhdo).toUpperCase();
        String cleanNoidung = support.safeTrim(noidung);
        String cleanA = support.safeTrim(a);
        String cleanB = support.safeTrim(b);
        String cleanC = support.safeTrim(c);
        String cleanD = support.safeTrim(d);
        String cleanDapAn = support.safeTrim(dapAn).toUpperCase();

        try {
            if ("edit".equals(mode) && cauhoi != null) {
                if (questionExists(cleanMamh, cleanNoidung, cauhoi)) {
                    redirect.addFlashAttribute("error", "Câu hỏi này đã có trong bộ đề.");
                    return "redirect:/gv/bo-de?edit=" + cauhoi;
                }

                jdbcTemplate.update(
                        auditContext.withAppLogin("EXEC dbo.sp_4_5_BoDe_Sua ?, ?, ?, ?, ?, ?, ?, ?, ?, ?"),
                        auditContext.params(loginname,
                                loginname, cauhoi, cleanMamh, cleanTrinhdo, cleanNoidung, cleanA, cleanB, cleanC, cleanD, cleanDapAn)
                );
                redirect.addFlashAttribute("success", "Đã ghi thay đổi câu hỏi.");
                return "redirect:/gv/bo-de?edit=" + cauhoi;
            }

            if (questionExists(cleanMamh, cleanNoidung, null)) {
                redirect.addFlashAttribute("error", "Câu hỏi này đã có trong bộ đề.");
                return "redirect:/gv/bo-de";
            }

            jdbcTemplate.update(
                    auditContext.withAppLogin("EXEC dbo.sp_4_5_BoDe_Them ?, ?, ?, ?, ?, ?, ?, ?, ?"),
                    auditContext.params(loginname,
                            loginname, cleanMamh, cleanTrinhdo, cleanNoidung, cleanA, cleanB, cleanC, cleanD, cleanDapAn)
            );
            redirect.addFlashAttribute("success", "Đã thêm câu hỏi mới.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", questionSaveMessage(ex));
        }

        return "redirect:/gv/bo-de";
    }
    @GetMapping("/bo-de/template")
    public ResponseEntity<byte[]> downloadImportTemplate(HttpSession session) {
        if (!support.isTeacher(session)) {
            return ResponseEntity.status(302)
                    .header(HttpHeaders.LOCATION, "/login")
                    .build();
        }

        String csv = "\uFEFFMAMH,TRINHDO,NOIDUNG,A,B,C,D,DAP_AN\r\n"
                + "CSDL,A,\"Noi dung cau hoi mau\",\"Dap an A\",\"Dap an B\",\"Dap an C\",\"Dap an D\",A\r\n";
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=bo-de-import-template.csv")
                .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
                .body(csv.getBytes(StandardCharsets.UTF_8));
    }

    @PostMapping("/bo-de/import")
    public String importBoDe(
            @RequestParam("file") MultipartFile file,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        if (file == null || file.isEmpty()) {
            redirect.addFlashAttribute("error", "Vui lòng chọn file CSV để nhập câu hỏi.");
            return "redirect:/gv/bo-de";
        }

        String filename = support.toStr(file.getOriginalFilename()).toLowerCase();
        if (!filename.endsWith(".csv") && !filename.endsWith(".txt")) {
            redirect.addFlashAttribute("error", "Chỉ hỗ trợ file .csv hoặc .txt lưu UTF-8.");
            return "redirect:/gv/bo-de";
        }

        String loginname = support.toStr(session.getAttribute("LOGINNAME"));
        int imported = 0;
        int failed = 0;
        List<String> errors = new ArrayList<>();
        Set<String> seenQuestions = new HashSet<>();

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(file.getInputStream(), StandardCharsets.UTF_8))) {
            String firstLine = reader.readLine();
            if (firstLine == null || support.safeTrim(stripBom(firstLine)).isBlank()) {
                redirect.addFlashAttribute("error", "File nhập câu hỏi đang trống.");
                return "redirect:/gv/bo-de";
            }

            char delimiter = detectDelimiter(firstLine);
            int rowNumber = 1;
            boolean firstLineIsHeader = isImportHeader(firstLine, delimiter);

            if (!firstLineIsHeader) {
                if (importQuestionLine(firstLine, delimiter, rowNumber, loginname, seenQuestions, errors)) {
                    imported++;
                } else {
                    failed++;
                }
            }

            String line;
            while ((line = reader.readLine()) != null) {
                rowNumber++;
                if (support.safeTrim(line).isBlank()) {
                    continue;
                }

                if (importQuestionLine(line, delimiter, rowNumber, loginname, seenQuestions, errors)) {
                    imported++;
                } else {
                    failed++;
                }
            }
        } catch (IOException ex) {
            redirect.addFlashAttribute("error", "Không đọc được file nhập câu hỏi.");
            return "redirect:/gv/bo-de";
        }

        if (failed == 0) {
            redirect.addFlashAttribute("success", "Đã nhập " + imported + " câu hỏi từ file.");
        } else {
            redirect.addFlashAttribute("error", "Đã nhập " + imported + " câu hỏi, lỗi " + failed + " dòng.");
            redirect.addFlashAttribute("importErrors", errors);
        }

        return "redirect:/gv/bo-de";
    }

    @PostMapping("/bo-de/restore")
    public String restoreBoDe(@RequestParam("cauhoi") Integer cauhoi, HttpSession session, RedirectAttributes redirect) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        try {
            String loginname = support.toStr(session.getAttribute("LOGINNAME"));
            jdbcTemplate.update(
                    auditContext.withAppLogin("EXEC dbo.sp_4_5_BoDe_PhucHoi ?, ?"),
                    auditContext.params(loginname, loginname, cauhoi)
            );
            redirect.addFlashAttribute("success", "Đã phục hồi câu hỏi.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/bo-de?edit=" + cauhoi;
    }

    @PostMapping("/bo-de/delete")
    public String deleteBoDe(@RequestParam("cauhoi") Integer cauhoi, HttpSession session, RedirectAttributes redirect) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        try {
            String loginname = support.toStr(session.getAttribute("LOGINNAME"));
            jdbcTemplate.update(
                    auditContext.withAppLogin("EXEC dbo.sp_4_5_BoDe_Xoa ?, ?"),
                    auditContext.params(loginname, loginname, cauhoi)
            );
            redirect.addFlashAttribute("success", "Đã xóa câu hỏi.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }

        return "redirect:/gv/bo-de";
    }

    private boolean importQuestionLine(
            String line,
            char delimiter,
            int rowNumber,
            String loginname,
            Set<String> seenQuestions,
            List<String> errors
    ) {
        try {
            ImportQuestion row = parseImportRow(line, delimiter, rowNumber);
            String duplicateKey = row.duplicateKey();
            if (!seenQuestions.add(duplicateKey)) {
                addImportError(errors, "Dòng " + rowNumber + ": câu hỏi này bị trùng trong file.");
                return false;
            }
            if (questionExists(row.mamh(), row.noidung(), null)) {
                addImportError(errors, "Dòng " + rowNumber + ": câu hỏi này đã có trong bộ đề.");
                return false;
            }
            return insertImportedQuestion(row, loginname, errors);
        } catch (IllegalArgumentException ex) {
            addImportError(errors, ex.getMessage());
            return false;
        }
    }

    private boolean insertImportedQuestion(ImportQuestion row, String loginname, List<String> errors) {
        try {
            jdbcTemplate.update(
                    auditContext.withAppLogin("EXEC dbo.sp_4_5_BoDe_Them ?, ?, ?, ?, ?, ?, ?, ?, ?"),
                    auditContext.params(loginname,
                            loginname, row.mamh(), row.trinhdo(), row.noidung(), row.a(), row.b(), row.c(), row.d(), row.dapAn())
            );
            return true;
        } catch (DataAccessException ex) {
            addImportError(errors, "Dòng " + row.rowNumber() + ": " + questionSaveMessage(ex));
            return false;
        }
    }

    private boolean questionExists(String mamh, String noidung, Integer exceptCauhoi) {
        String sql = """
                SELECT COUNT(1)
                FROM dbo.BoDe
                WHERE UPPER(RTRIM(MAMH)) = ?
                  AND UPPER(LTRIM(RTRIM(NOIDUNG))) = ?
                  AND (? IS NULL OR CAUHOI <> ?)
                """;
        Integer count = jdbcTemplate.queryForObject(
                sql,
                Integer.class,
                support.safeTrim(mamh).toUpperCase(),
                support.safeTrim(noidung).toUpperCase(),
                exceptCauhoi,
                exceptCauhoi
        );
        return count != null && count > 0;
    }

    private String questionSaveMessage(DataAccessException ex) {
        Throwable cause = ex.getMostSpecificCause();
        if (cause instanceof SQLException sqlException
                && (sqlException.getErrorCode() == 2601 || sqlException.getErrorCode() == 2627)) {
            return "Câu hỏi này đã có trong bộ đề.";
        }

        String message = support.dbMessage(ex);
        String normalized = message.toLowerCase();
        if (normalized.contains("uq_bode_mamh_noidung")
                || normalized.contains("duplicate key")
                || normalized.contains("cannot insert duplicate key")) {
            return "Câu hỏi này đã có trong bộ đề.";
        }
        return message;
    }

    private ImportQuestion parseImportRow(String line, char delimiter, int rowNumber) {
        List<String> cells = parseDelimitedLine(stripBom(line), delimiter);
        if (cells.size() != 8) {
            throw new IllegalArgumentException("Dòng " + rowNumber + ": cần đủ 8 cột MAMH, TRINHDO, NOIDUNG, A, B, C, D, DAP_AN.");
        }

        String mamh = support.safeTrim(cells.get(0)).toUpperCase();
        String trinhdo = support.safeTrim(cells.get(1)).toUpperCase();
        String noidung = support.safeTrim(cells.get(2));
        String a = support.safeTrim(cells.get(3));
        String b = support.safeTrim(cells.get(4));
        String c = support.safeTrim(cells.get(5));
        String d = support.safeTrim(cells.get(6));
        String dapAn = support.safeTrim(cells.get(7)).toUpperCase();

        if (mamh.isBlank() || trinhdo.isBlank() || noidung.isBlank() || a.isBlank() || b.isBlank() || c.isBlank() || d.isBlank() || dapAn.isBlank()) {
            throw new IllegalArgumentException("Dòng " + rowNumber + ": không được để trống cột bắt buộc.");
        }
        if (!List.of("A", "B", "C").contains(trinhdo)) {
            throw new IllegalArgumentException("Dòng " + rowNumber + ": trình độ chỉ nhận A, B hoặc C.");
        }
        if (!List.of("A", "B", "C", "D").contains(dapAn)) {
            throw new IllegalArgumentException("Dòng " + rowNumber + ": đáp án đúng chỉ nhận A, B, C hoặc D.");
        }
        if (noidung.length() > 200 || a.length() > 50 || b.length() > 50 || c.length() > 50 || d.length() > 50) {
            throw new IllegalArgumentException("Dòng " + rowNumber + ": nội dung tối đa 200 ký tự, mỗi đáp án tối đa 50 ký tự.");
        }

        return new ImportQuestion(rowNumber, mamh, trinhdo, noidung, a, b, c, d, dapAn);
    }

    private boolean isImportHeader(String line, char delimiter) {
        List<String> cells = parseDelimitedLine(stripBom(line), delimiter);
        if (cells.size() < 2) {
            return false;
        }
        return "MAMH".equalsIgnoreCase(support.safeTrim(cells.get(0)))
                && "TRINHDO".equalsIgnoreCase(support.safeTrim(cells.get(1)));
    }

    private char detectDelimiter(String line) {
        int tabs = countChar(line, '\t');
        int semicolons = countChar(line, ';');
        int commas = countChar(line, ',');
        if (tabs >= semicolons && tabs >= commas && tabs > 0) {
            return '\t';
        }
        return semicolons > commas ? ';' : ',';
    }

    private int countChar(String value, char expected) {
        int count = 0;
        for (int i = 0; i < value.length(); i++) {
            if (value.charAt(i) == expected) {
                count++;
            }
        }
        return count;
    }

    private List<String> parseDelimitedLine(String line, char delimiter) {
        List<String> cells = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean quoted = false;

        for (int i = 0; i < line.length(); i++) {
            char ch = line.charAt(i);
            if (ch == '"') {
                if (quoted && i + 1 < line.length() && line.charAt(i + 1) == '"') {
                    current.append('"');
                    i++;
                } else {
                    quoted = !quoted;
                }
            } else if (ch == delimiter && !quoted) {
                cells.add(current.toString());
                current.setLength(0);
            } else {
                current.append(ch);
            }
        }

        if (quoted) {
            throw new IllegalArgumentException("Dòng CSV thiếu dấu nháy kép đóng.");
        }

        cells.add(current.toString());
        return cells;
    }

    private String stripBom(String value) {
        return value != null && !value.isEmpty() && value.charAt(0) == '\uFEFF' ? value.substring(1) : value;
    }

    private void addImportError(List<String> errors, String message) {
        if (errors.size() < 5) {
            errors.add(message);
        }
    }

    private record ImportQuestion(
            int rowNumber,
            String mamh,
            String trinhdo,
            String noidung,
            String a,
            String b,
            String c,
            String d,
            String dapAn
    ) {
        private String duplicateKey() {
            return mamh + "|" + noidung.toUpperCase();
        }
    }
}
