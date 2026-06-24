package com.example.thitracnghiem.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class BackupRestoreService {

    private static final String DATABASE_NAME = "THI_TRAC_NGHIEM";

    private final JdbcTemplate jdbcTemplate;

    public BackupRestoreService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Map<String, Object>> createDevice(String backupDirectory) {
        return jdbcTemplate.queryForList(
                "EXEC dbo.sp_TTN_Backup_TaoDevice ?, ?",
                DATABASE_NAME,
                blankToNull(backupDirectory)
        );
    }

    public List<Map<String, Object>> backupFull(String backupDirectory) {
        return jdbcTemplate.queryForList(
                "EXEC dbo.sp_TTN_Backup_Full ?, ?",
                DATABASE_NAME,
                blankToNull(backupDirectory)
        );
    }

    public List<Map<String, Object>> backupLog(String backupDirectory) {
        return jdbcTemplate.queryForList(
                "EXEC dbo.sp_TTN_Backup_Log ?, ?",
                DATABASE_NAME,
                blankToNull(backupDirectory)
        );
    }

    public List<Map<String, Object>> listMsdbBackups() {
        return jdbcTemplate.queryForList("EXEC dbo.sp_TTN_Backup_DanhSach ?", DATABASE_NAME);
    }

    public List<Map<String, Object>> listAppHistory() {
        return jdbcTemplate.queryForList("""
                SELECT TOP 100
                    ACTION_NAME,
                    DATABASE_NAME,
                    BACKUP_TYPE,
                    FILE_PATH,
                    DEVICE_NAME,
                    RESTORE_TO,
                    EXECUTED_BY,
                    EXECUTED_AT,
                    NOTE
                FROM dbo.BackupRestoreHistory
                ORDER BY EXECUTED_AT DESC, ID DESC
                """);
    }

    public void restoreFull(String fullBackupPath, boolean withReplace) {
        jdbcTemplate.update(
                "EXEC master.dbo.sp_TTN_Restore_Full ?, ?, ?",
                DATABASE_NAME,
                fullBackupPath,
                withReplace ? 1 : 0
        );
    }

    public void restorePointInTime(String fullBackupPath, String logBackupPath, LocalDateTime restoreTo) {
        jdbcTemplate.update(
                "EXEC master.dbo.sp_TTN_Restore_PointInTime ?, ?, ?, ?",
                DATABASE_NAME,
                fullBackupPath,
                logBackupPath,
                restoreTo
        );
    }

    public List<Map<String, Object>> buildRestoreCommands(
            String fullBackupPath,
            String logBackupPath,
            LocalDateTime restoreTo
    ) {
        return jdbcTemplate.queryForList(
                "EXEC master.dbo.sp_TTN_Restore_SinhLenh ?, ?, ?, ?",
                DATABASE_NAME,
                fullBackupPath,
                blankToNull(logBackupPath),
                restoreTo
        );
    }

    private String blankToNull(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }
}
