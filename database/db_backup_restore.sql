USE [THI_TRAC_NGHIEM]
GO

/*
    Backup / Restore objects for THI_TRAC_NGHIEM.

    Run order:
    1. thitracnghiem_db.sql
    2. db_nghiepvu_thi.sql
    3. db_triggers_thi.sql
    4. db_backup_restore.sql

    Demo backup:
        EXEC dbo.sp_TTN_Backup_TaoDevice;
        EXEC dbo.sp_TTN_Backup_Full;
        EXEC dbo.sp_TTN_Backup_DanhSach;

    Demo point-in-time restore requires FULL recovery model and log backups:
        ALTER DATABASE [THI_TRAC_NGHIEM] SET RECOVERY FULL;
        EXEC dbo.sp_TTN_Backup_Full;
        EXEC dbo.sp_TTN_Backup_Log;
        EXEC master.dbo.sp_TTN_Restore_PointInTime
             @DatabaseName = N'THI_TRAC_NGHIEM',
             @FullBackupPath = N'C:\...\THI_TRAC_NGHIEM.bak',
             @LogBackupPath = N'C:\...\THI_TRAC_NGHIEM_LOG_yyyyMMdd_HHmmss.trn',
             @RestoreTo = '2026-06-22T10:30:00';
*/

IF OBJECT_ID('dbo.BackupRestoreHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BackupRestoreHistory (
        ID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ACTION_NAME NVARCHAR(30) NOT NULL,
        DATABASE_NAME SYSNAME NOT NULL,
        BACKUP_TYPE NVARCHAR(20) NULL,
        FILE_PATH NVARCHAR(4000) NULL,
        DEVICE_NAME SYSNAME NULL,
        RESTORE_TO DATETIME2(0) NULL,
        EXECUTED_BY SYSNAME NOT NULL CONSTRAINT DF_BackupRestoreHistory_ExecutedBy DEFAULT ORIGINAL_LOGIN(),
        EXECUTED_AT DATETIME2(0) NOT NULL CONSTRAINT DF_BackupRestoreHistory_ExecutedAt DEFAULT SYSDATETIME(),
        NOTE NVARCHAR(1000) NULL
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.BackupRestoreHistory')
      AND name = 'IX_BackupRestoreHistory_Time'
)
    CREATE INDEX IX_BackupRestoreHistory_Time
    ON dbo.BackupRestoreHistory(EXECUTED_AT DESC, ACTION_NAME);
GO

IF OBJECT_ID('dbo.sp_TTN_Backup_TaoDevice', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TTN_Backup_TaoDevice;
GO

CREATE PROCEDURE dbo.sp_TTN_Backup_TaoDevice
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM',
    @BackupDirectory NVARCHAR(4000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF DB_ID(@DatabaseName) IS NULL
        THROW 56001, N'Co so du lieu can backup khong ton tai.', 1;

    DECLARE
        @DeviceName SYSNAME = N'DEVICE_' + REPLACE(UPPER(@DatabaseName), N' ', N'_'),
        @DefaultBackupPath NVARCHAR(4000) = CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultBackupPath')),
        @BackupPath NVARCHAR(4000);

    SET @BackupDirectory = NULLIF(LTRIM(RTRIM(@BackupDirectory)), N'');
    SET @BackupDirectory = COALESCE(@BackupDirectory, NULLIF(@DefaultBackupPath, N''), N'C:\SQLBackup');

    IF RIGHT(@BackupDirectory, 1) IN (N'\', N'/')
        SET @BackupDirectory = LEFT(@BackupDirectory, LEN(@BackupDirectory) - 1);

    BEGIN TRY
        EXEC master.dbo.xp_create_subdir @BackupDirectory;
    END TRY
    BEGIN CATCH
        -- If SQL Server cannot create the directory, BACKUP will raise the real path error below.
    END CATCH;

    SET @BackupPath = @BackupDirectory + N'\' + @DatabaseName + N'.bak';

    IF EXISTS (SELECT 1 FROM master.sys.backup_devices WHERE name = @DeviceName)
        EXEC master.dbo.sp_dropdevice @logicalname = @DeviceName;

    EXEC master.dbo.sp_addumpdevice
        @devtype = N'disk',
        @logicalname = @DeviceName,
        @physicalname = @BackupPath;

    INSERT INTO dbo.BackupRestoreHistory(ACTION_NAME, DATABASE_NAME, BACKUP_TYPE, FILE_PATH, DEVICE_NAME, NOTE)
    VALUES (N'CREATE_DEVICE', @DatabaseName, N'DEVICE', @BackupPath, @DeviceName, N'Tao backup device theo format DEVICE_TENCSDL.');

    SELECT
        @DeviceName AS DEVICE_NAME,
        @BackupPath AS BACKUP_FILE;
END;
GO

IF OBJECT_ID('dbo.sp_TTN_Backup_Full', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TTN_Backup_Full;
GO

CREATE PROCEDURE dbo.sp_TTN_Backup_Full
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM',
    @BackupDirectory NVARCHAR(4000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF DB_ID(@DatabaseName) IS NULL
        THROW 56011, N'Co so du lieu can backup khong ton tai.', 1;

    DECLARE
        @DeviceName SYSNAME = N'DEVICE_' + REPLACE(UPPER(@DatabaseName), N' ', N'_'),
        @BackupPath NVARCHAR(4000),
        @Sql NVARCHAR(MAX),
        @BackupName NVARCHAR(300) = N'FULL_' + @DatabaseName + N'_' + CONVERT(NVARCHAR(19), SYSDATETIME(), 120);

    EXEC dbo.sp_TTN_Backup_TaoDevice @DatabaseName = @DatabaseName, @BackupDirectory = @BackupDirectory;

    SELECT @BackupPath = physical_name
    FROM master.sys.backup_devices
    WHERE name = @DeviceName;

    SET @Sql = N'BACKUP DATABASE ' + QUOTENAME(@DatabaseName)
        + N' TO ' + QUOTENAME(@DeviceName)
        + N' WITH INIT, CHECKSUM, NAME = N''' + REPLACE(@BackupName, N'''', N'''''') + N''', STATS = 10;';
    EXEC (@Sql);

    SET @Sql = N'RESTORE VERIFYONLY FROM ' + QUOTENAME(@DeviceName) + N' WITH CHECKSUM;';
    EXEC (@Sql);

    INSERT INTO dbo.BackupRestoreHistory(ACTION_NAME, DATABASE_NAME, BACKUP_TYPE, FILE_PATH, DEVICE_NAME, NOTE)
    VALUES (N'BACKUP', @DatabaseName, N'FULL', @BackupPath, @DeviceName, N'Full backup da verify bang RESTORE VERIFYONLY.');

    SELECT
        @DatabaseName AS DATABASE_NAME,
        N'FULL' AS BACKUP_TYPE,
        @DeviceName AS DEVICE_NAME,
        @BackupPath AS BACKUP_FILE;
END;
GO

IF OBJECT_ID('dbo.sp_TTN_Backup_Log', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TTN_Backup_Log;
GO

CREATE PROCEDURE dbo.sp_TTN_Backup_Log
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM',
    @BackupDirectory NVARCHAR(4000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @RecoveryModel NVARCHAR(60),
        @DefaultBackupPath NVARCHAR(4000) = CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultBackupPath')),
        @BackupPath NVARCHAR(4000),
        @Sql NVARCHAR(MAX),
        @Stamp NVARCHAR(30) = REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(19), SYSDATETIME(), 120), N'-', N''), N':', N''), N' ', N'_'),
        @BackupName NVARCHAR(300);

    SELECT @RecoveryModel = recovery_model_desc
    FROM sys.databases
    WHERE name = @DatabaseName;

    IF @RecoveryModel IS NULL
        THROW 56021, N'Co so du lieu can backup log khong ton tai.', 1;

    IF @RecoveryModel = N'SIMPLE'
        THROW 56022, N'Muon backup log de restore theo thoi diem thi database phai dung FULL hoac BULK_LOGGED recovery model.', 1;

    SET @BackupDirectory = NULLIF(LTRIM(RTRIM(@BackupDirectory)), N'');
    SET @BackupDirectory = COALESCE(@BackupDirectory, NULLIF(@DefaultBackupPath, N''), N'C:\SQLBackup');

    IF RIGHT(@BackupDirectory, 1) IN (N'\', N'/')
        SET @BackupDirectory = LEFT(@BackupDirectory, LEN(@BackupDirectory) - 1);

    BEGIN TRY
        EXEC master.dbo.xp_create_subdir @BackupDirectory;
    END TRY
    BEGIN CATCH
    END CATCH;

    SET @BackupPath = @BackupDirectory + N'\' + @DatabaseName + N'_LOG_' + @Stamp + N'.trn';
    SET @BackupName = N'LOG_' + @DatabaseName + N'_' + @Stamp;

    SET @Sql = N'BACKUP LOG ' + QUOTENAME(@DatabaseName)
        + N' TO DISK = N''' + REPLACE(@BackupPath, N'''', N'''''') + N''''
        + N' WITH INIT, CHECKSUM, NAME = N''' + REPLACE(@BackupName, N'''', N'''''') + N''', STATS = 10;';
    EXEC (@Sql);

    SET @Sql = N'RESTORE VERIFYONLY FROM DISK = N''' + REPLACE(@BackupPath, N'''', N'''''') + N''' WITH CHECKSUM;';
    EXEC (@Sql);

    INSERT INTO dbo.BackupRestoreHistory(ACTION_NAME, DATABASE_NAME, BACKUP_TYPE, FILE_PATH, DEVICE_NAME, NOTE)
    VALUES (N'BACKUP', @DatabaseName, N'LOG', @BackupPath, NULL, N'Log backup dung cho restore theo thoi diem.');

    SELECT
        @DatabaseName AS DATABASE_NAME,
        N'LOG' AS BACKUP_TYPE,
        @BackupPath AS BACKUP_FILE;
END;
GO

IF OBJECT_ID('dbo.sp_TTN_Backup_DanhSach', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TTN_Backup_DanhSach;
GO

CREATE PROCEDURE dbo.sp_TTN_Backup_DanhSach
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 100
        BS.database_name AS DATABASE_NAME,
        CASE BS.type
            WHEN 'D' THEN N'FULL'
            WHEN 'I' THEN N'DIFFERENTIAL'
            WHEN 'L' THEN N'LOG'
            ELSE BS.type
        END AS BACKUP_TYPE,
        BS.backup_start_date AS START_TIME,
        BS.backup_finish_date AS FINISH_TIME,
        CONVERT(DECIMAL(18,2), BS.backup_size / 1024.0 / 1024.0) AS SIZE_MB,
        BMF.physical_device_name AS FILE_PATH,
        BS.name AS BACKUP_NAME
    FROM msdb.dbo.backupset AS BS
    INNER JOIN msdb.dbo.backupmediafamily AS BMF
        ON BMF.media_set_id = BS.media_set_id
    WHERE BS.database_name = @DatabaseName
    ORDER BY BS.backup_finish_date DESC;
END;
GO

IF DATABASE_PRINCIPAL_ID(N'PGV') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_TTN_Backup_TaoDevice TO PGV;
    GRANT EXECUTE ON dbo.sp_TTN_Backup_Full TO PGV;
    GRANT EXECUTE ON dbo.sp_TTN_Backup_Log TO PGV;
    GRANT EXECUTE ON dbo.sp_TTN_Backup_DanhSach TO PGV;
    GRANT SELECT ON dbo.BackupRestoreHistory TO PGV;
END;
GO

USE [master]
GO

IF OBJECT_ID('dbo.sp_TTN_Restore_Full', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TTN_Restore_Full;
GO

CREATE PROCEDURE dbo.sp_TTN_Restore_Full
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM',
    @FullBackupPath NVARCHAR(4000),
    @WithReplace BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@FullBackupPath)), N'') IS NULL
        THROW 56101, N'Duong dan file full backup khong duoc de trong.', 1;

    DECLARE
        @Sql NVARCHAR(MAX),
        @MultiUserSql NVARCHAR(MAX),
        @ReplaceClause NVARCHAR(30) = CASE WHEN @WithReplace = 1 THEN N', REPLACE' ELSE N'' END;

    SET @MultiUserSql = N'ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET MULTI_USER;';
    SET @Sql = N'ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;'
        + N' RESTORE DATABASE ' + QUOTENAME(@DatabaseName)
        + N' FROM DISK = N''' + REPLACE(@FullBackupPath, N'''', N'''''') + N''''
        + N' WITH RECOVERY, CHECKSUM' + @ReplaceClause + N';'
        + N' ' + @MultiUserSql;

    BEGIN TRY
        EXEC (@Sql);
    END TRY
    BEGIN CATCH
        BEGIN TRY
            EXEC (@MultiUserSql);
        END TRY
        BEGIN CATCH
        END CATCH;
        THROW;
    END CATCH;
END;
GO

IF OBJECT_ID('dbo.sp_TTN_Restore_PointInTime', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TTN_Restore_PointInTime;
GO

CREATE PROCEDURE dbo.sp_TTN_Restore_PointInTime
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM',
    @FullBackupPath NVARCHAR(4000),
    @LogBackupPath NVARCHAR(4000),
    @RestoreTo DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@FullBackupPath)), N'') IS NULL
        THROW 56111, N'Duong dan file full backup khong duoc de trong.', 1;

    IF NULLIF(LTRIM(RTRIM(@LogBackupPath)), N'') IS NULL
        THROW 56112, N'Duong dan file log backup khong duoc de trong.', 1;

    IF @RestoreTo IS NULL
        THROW 56113, N'Thoi diem restore khong duoc de trong.', 1;

    DECLARE
        @Sql NVARCHAR(MAX),
        @MultiUserSql NVARCHAR(MAX),
        @RestoreToText NVARCHAR(30) = CONVERT(NVARCHAR(30), @RestoreTo, 126);

    SET @MultiUserSql = N'ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET MULTI_USER;';
    SET @Sql = N'ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;'
        + N' RESTORE DATABASE ' + QUOTENAME(@DatabaseName)
        + N' FROM DISK = N''' + REPLACE(@FullBackupPath, N'''', N'''''') + N''''
        + N' WITH NORECOVERY, REPLACE, CHECKSUM;'
        + N' RESTORE LOG ' + QUOTENAME(@DatabaseName)
        + N' FROM DISK = N''' + REPLACE(@LogBackupPath, N'''', N'''''') + N''''
        + N' WITH STOPAT = N''' + @RestoreToText + N''', RECOVERY, CHECKSUM;'
        + N' ' + @MultiUserSql;

    BEGIN TRY
        EXEC (@Sql);
    END TRY
    BEGIN CATCH
        BEGIN TRY
            EXEC (@MultiUserSql);
        END TRY
        BEGIN CATCH
        END CATCH;
        THROW;
    END CATCH;
END;
GO

IF OBJECT_ID('dbo.sp_TTN_Restore_SinhLenh', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TTN_Restore_SinhLenh;
GO

CREATE PROCEDURE dbo.sp_TTN_Restore_SinhLenh
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM',
    @FullBackupPath NVARCHAR(4000),
    @LogBackupPath NVARCHAR(4000) = NULL,
    @RestoreTo DATETIME2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT N'ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;' AS RESTORE_COMMAND
    UNION ALL
    SELECT N'RESTORE DATABASE ' + QUOTENAME(@DatabaseName)
        + N' FROM DISK = N''' + REPLACE(@FullBackupPath, N'''', N'''''') + N''' WITH '
        + CASE WHEN @LogBackupPath IS NULL THEN N'RECOVERY' ELSE N'NORECOVERY' END
        + N', REPLACE, CHECKSUM;'
    UNION ALL
    SELECT N'RESTORE LOG ' + QUOTENAME(@DatabaseName)
        + N' FROM DISK = N''' + REPLACE(@LogBackupPath, N'''', N'''''') + N''' WITH STOPAT = N'''
        + CONVERT(NVARCHAR(30), @RestoreTo, 126) + N''', RECOVERY, CHECKSUM;'
    WHERE @LogBackupPath IS NOT NULL AND @RestoreTo IS NOT NULL
    UNION ALL
    SELECT N'ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET MULTI_USER;';
END;
GO
