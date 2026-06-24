package com.example.thitracnghiem.controller.gv;

import com.example.thitracnghiem.service.BackupRestoreService;
import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/gv/backup-restore")
public class BackupRestoreController {

    private final BackupRestoreService backupRestoreService;
    private final ControllerSupport support;

    public BackupRestoreController(BackupRestoreService backupRestoreService, ControllerSupport support) {
        this.backupRestoreService = backupRestoreService;
        this.support = support;
    }

    @GetMapping
    public String page(HttpSession session, Model model, RedirectAttributes redirect) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }
        if (!support.isPgv(session)) {
            redirect.addFlashAttribute("error", "Chỉ PGV được sử dụng chức năng backup/restore.");
            return "redirect:/gv/home";
        }

        support.addTeacherShell(model, session, "backup-restore", "Backup / Restore");
        loadPageData(model);
        return "auth/gv/backup-restore";
    }

    @PostMapping("/device")
    public String createDevice(
            @RequestParam(required = false) String backupDirectory,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!allowPgv(session, redirect)) {
            return "redirect:/gv/home";
        }

        try {
            redirect.addFlashAttribute("operationRows", backupRestoreService.createDevice(backupDirectory));
            redirect.addFlashAttribute("success", "Đã tạo backup device.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }
        return "redirect:/gv/backup-restore";
    }

    @PostMapping("/full")
    public String backupFull(
            @RequestParam(required = false) String backupDirectory,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!allowPgv(session, redirect)) {
            return "redirect:/gv/home";
        }

        try {
            redirect.addFlashAttribute("operationRows", backupRestoreService.backupFull(backupDirectory));
            redirect.addFlashAttribute("success", "Đã backup full database và verify file backup.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }
        return "redirect:/gv/backup-restore";
    }

    @PostMapping("/log")
    public String backupLog(
            @RequestParam(required = false) String backupDirectory,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!allowPgv(session, redirect)) {
            return "redirect:/gv/home";
        }

        try {
            redirect.addFlashAttribute("operationRows", backupRestoreService.backupLog(backupDirectory));
            redirect.addFlashAttribute("success", "Đã backup transaction log.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }
        return "redirect:/gv/backup-restore";
    }

    @PostMapping("/restore-script")
    public String restoreScript(
            @RequestParam String fullBackupPath,
            @RequestParam(required = false) String logBackupPath,
            @RequestParam(required = false) String restoreTo,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!allowPgv(session, redirect)) {
            return "redirect:/gv/home";
        }

        try {
            LocalDateTime restoreAt = parseDateTimeOrNull(restoreTo);
            List<Map<String, Object>> rows = backupRestoreService.buildRestoreCommands(
                    support.safeTrim(fullBackupPath),
                    support.safeTrim(logBackupPath),
                    restoreAt
            );
            redirect.addFlashAttribute("restoreCommands", rows);
            redirect.addFlashAttribute("success", "Đã sinh lệnh restore để kiểm tra trước khi chạy thật.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("error", userMessage(ex));
        }
        return "redirect:/gv/backup-restore";
    }

    @PostMapping("/restore-full")
    public String restoreFull(
            @RequestParam String fullBackupPath,
            @RequestParam(defaultValue = "true") boolean withReplace,
            @RequestParam(required = false) String confirmRestore,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!allowPgv(session, redirect)) {
            return "redirect:/gv/home";
        }
        if (!"YES".equals(confirmRestore)) {
            redirect.addFlashAttribute("error", "Nhập YES để xác nhận restore full database.");
            return "redirect:/gv/backup-restore";
        }

        try {
            backupRestoreService.restoreFull(support.safeTrim(fullBackupPath), withReplace);
            redirect.addFlashAttribute("success", "Đã thực hiện restore full database.");
        } catch (DataAccessException ex) {
            redirect.addFlashAttribute("error", support.dbMessage(ex));
        }
        return "redirect:/gv/backup-restore";
    }

    @PostMapping("/restore-point")
    public String restorePoint(
            @RequestParam String fullBackupPath,
            @RequestParam String logBackupPath,
            @RequestParam String restoreTo,
            @RequestParam(required = false) String confirmRestore,
            HttpSession session,
            RedirectAttributes redirect
    ) {
        if (!allowPgv(session, redirect)) {
            return "redirect:/gv/home";
        }
        if (!"YES".equals(confirmRestore)) {
            redirect.addFlashAttribute("error", "Nhập YES để xác nhận restore theo thời điểm.");
            return "redirect:/gv/backup-restore";
        }

        try {
            backupRestoreService.restorePointInTime(
                    support.safeTrim(fullBackupPath),
                    support.safeTrim(logBackupPath),
                    parseRequiredDateTime(restoreTo)
            );
            redirect.addFlashAttribute("success", "Đã thực hiện restore theo thời điểm.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("error", userMessage(ex));
        }
        return "redirect:/gv/backup-restore";
    }

    private void loadPageData(Model model) {
        try {
            model.addAttribute("backupRows", backupRestoreService.listMsdbBackups());
        } catch (DataAccessException ex) {
            model.addAttribute("backupRows", List.of());
            model.addAttribute("backupLoadError", support.dbMessage(ex));
        }

        try {
            model.addAttribute("historyRows", backupRestoreService.listAppHistory());
        } catch (DataAccessException ex) {
            model.addAttribute("historyRows", List.of());
        }
    }

    private boolean allowPgv(HttpSession session, RedirectAttributes redirect) {
        if (!support.isTeacher(session)) {
            redirect.addFlashAttribute("error", "Vui lòng đăng nhập.");
            return false;
        }
        if (!support.isPgv(session)) {
            redirect.addFlashAttribute("error", "Chỉ PGV được sử dụng chức năng backup/restore.");
            return false;
        }
        return true;
    }

    private LocalDateTime parseDateTimeOrNull(String value) {
        String trimmed = support.safeTrim(value);
        return trimmed.isBlank() ? null : LocalDateTime.parse(trimmed);
    }

    private LocalDateTime parseRequiredDateTime(String value) {
        String trimmed = support.safeTrim(value);
        if (trimmed.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập thời điểm restore.");
        }
        return LocalDateTime.parse(trimmed);
    }

    private String userMessage(RuntimeException ex) {
        if (ex instanceof DataAccessException dataAccessException) {
            return support.dbMessage(dataAccessException);
        }
        return ex.getMessage() == null ? "Thao tác backup/restore không thành công." : ex.getMessage();
    }
}
