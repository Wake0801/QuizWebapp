USE [msdb];
GO

/*
    Optional SQL Server Agent jobs for THI_TRAC_NGHIEM.
    Run this file after db_nghiepvu_thi.sql only on editions that support SQL Server Agent.
*/

DECLARE
    @JobName SYSNAME = N'TTN_TuDongNopBaiHetGio',
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM';

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = @JobName)
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = @JobName, @delete_unused_schedule = 1;
END;
GO

DECLARE
    @JobId UNIQUEIDENTIFIER,
    @JobName SYSNAME = N'TTN_TuDongNopBaiHetGio',
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM',
    @ScheduleName SYSNAME = N'TTN_Moi_1_Phut_Kiem_Tra_Het_Gio';

EXEC msdb.dbo.sp_add_job
    @job_name = @JobName,
    @enabled = 1,
    @description = N'Tu dong nop cac bai thi da het gio trong he thong thi trac nghiem.',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa',
    @job_id = @JobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_name = N'Kiem tra va nop bai het gio',
    @subsystem = N'TSQL',
    @database_name = @DatabaseName,
    @command = N'EXEC dbo.sp_TTN_TuDongNopBaiHetGio;',
    @retry_attempts = 3,
    @retry_interval = 1;

EXEC msdb.dbo.sp_add_schedule
    @schedule_name = @ScheduleName,
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 4,
    @freq_subday_interval = 1,
    @active_start_time = 0;

EXEC msdb.dbo.sp_attach_schedule
    @job_id = @JobId,
    @schedule_name = @ScheduleName;

EXEC msdb.dbo.sp_add_jobserver
    @job_id = @JobId,
    @server_name = N'(LOCAL)';
GO

