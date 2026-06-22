USE [THI_TRAC_NGHIEM]
GO

/*
    SQL Server advanced objects for thi trac nghiem:
    - SinhVien, GiaoVien_DangKy, thi trac nghiem, BangDiem.
    - Run thitracnghiem_db.sql first, then run this file, then db_triggers_thi.sql.
*/

/* =========================================================
   1. Supporting tables for storing generated exams/results
   ========================================================= */
IF OBJECT_ID('dbo.SinhVien', 'U') IS NULL
   OR OBJECT_ID('dbo.MonHoc', 'U') IS NULL
   OR OBJECT_ID('dbo.BoDe', 'U') IS NULL
BEGIN
    THROW 53000, N'Hay chay thitracnghiem_db.sql truoc khi chay db_nghiepvu_thi.sql.', 1;
END;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.SinhVien
    GROUP BY MASV
    HAVING COUNT(*) > 1
)
BEGIN
    THROW 53001, N'Khong the tao khoa tham chieu vi SinhVien.MASV dang bi trung.', 1;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.SinhVien')
      AND name = 'UX_SinhVien_MASV'
)
BEGIN
    CREATE UNIQUE INDEX UX_SinhVien_MASV ON dbo.SinhVien(MASV);
END;
GO

/****** Object:  Table [dbo].[BaiThi_CauTraLoi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.BaiThi_CauTraLoi', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BaiThi_CauTraLoi (
        MABT BIGINT NOT NULL,
        CAUHOI INT NOT NULL,
        THUTU SMALLINT NOT NULL,
        MAMH NCHAR(5) NOT NULL,
        TRINHDO_CAU NCHAR(1) NOT NULL,
        NOIDUNG NVARCHAR(200) NOT NULL,
        A NVARCHAR(50) NULL,
        B NVARCHAR(50) NULL,
        C NVARCHAR(50) NULL,
        D NVARCHAR(50) NULL,
        DAP_AN_DUNG NCHAR(1) NOT NULL CHECK (DAP_AN_DUNG IN ('A','B','C','D')),
        DAP_AN_CHON NCHAR(1) NULL CHECK (DAP_AN_CHON IS NULL OR DAP_AN_CHON IN ('A','B','C','D')),
        CONSTRAINT PK_BaiThi_CauTraLoi PRIMARY KEY (MABT, CAUHOI)
    );
END;
GO

IF OBJECT_ID('dbo.BaiThi_CauTraLoi', 'U') IS NOT NULL
   AND COL_LENGTH('dbo.BaiThi_CauTraLoi', 'MAMH') IS NULL
    ALTER TABLE dbo.BaiThi_CauTraLoi ADD MAMH NCHAR(5) NULL;
GO

IF OBJECT_ID('dbo.BaiThi_CauTraLoi', 'U') IS NOT NULL
   AND COL_LENGTH('dbo.BaiThi_CauTraLoi', 'TRINHDO_CAU') IS NULL
    ALTER TABLE dbo.BaiThi_CauTraLoi ADD TRINHDO_CAU NCHAR(1) NULL;
GO

IF OBJECT_ID('dbo.BaiThi_CauTraLoi', 'U') IS NOT NULL
   AND COL_LENGTH('dbo.BaiThi_CauTraLoi', 'NOIDUNG') IS NULL
    ALTER TABLE dbo.BaiThi_CauTraLoi ADD NOIDUNG NVARCHAR(200) NULL;
GO

IF OBJECT_ID('dbo.BaiThi_CauTraLoi', 'U') IS NOT NULL
BEGIN
    IF OBJECT_ID('dbo.trg_BaiThiCauTraLoi_KiemTraHopLe', 'TR') IS NOT NULL
        DISABLE TRIGGER dbo.trg_BaiThiCauTraLoi_KiemTraHopLe ON dbo.BaiThi_CauTraLoi;

    UPDATE CT
    SET
        MAMH = COALESCE(CT.MAMH, BD.MAMH),
        TRINHDO_CAU = COALESCE(CT.TRINHDO_CAU, BD.TRINHDO),
        NOIDUNG = COALESCE(CT.NOIDUNG, BD.NOIDUNG)
    FROM dbo.BaiThi_CauTraLoi AS CT
    INNER JOIN dbo.BoDe AS BD ON BD.CAUHOI = CT.CAUHOI
    WHERE CT.MAMH IS NULL
       OR CT.TRINHDO_CAU IS NULL
       OR CT.NOIDUNG IS NULL;

    IF OBJECT_ID('dbo.trg_BaiThiCauTraLoi_KiemTraHopLe', 'TR') IS NOT NULL
        ENABLE TRIGGER dbo.trg_BaiThiCauTraLoi_KiemTraHopLe ON dbo.BaiThi_CauTraLoi;
END;
GO

/****** Object:  Table [dbo].[BaiThi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.BaiThi', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BaiThi (
        MABT BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MASV NCHAR(10) NOT NULL,
        MAMH NCHAR(5) NOT NULL,
        LAN SMALLINT NOT NULL CHECK (LAN BETWEEN 1 AND 2),
        NGAYTHI DATETIME NOT NULL DEFAULT GETDATE(),
        BATDAU_LUC DATETIME NOT NULL DEFAULT GETDATE(),
        KETTHUC_LUC DATETIME NULL,
        NOPBAI_LUC DATETIME NULL,
        THOIGIAN SMALLINT NOT NULL DEFAULT 0 CHECK (THOIGIAN BETWEEN 0 AND 60),
        SOCAU SMALLINT NOT NULL CHECK (SOCAU > 0),
        SOCAUDUNG SMALLINT NOT NULL CHECK (SOCAUDUNG >= 0),
        DIEM DECIMAL(4,2) NOT NULL CHECK (DIEM BETWEEN 0 AND 10),
        TRANGTHAI VARCHAR(20) NOT NULL DEFAULT 'DANG_THI'
            CHECK (TRANGTHAI IN ('DANG_THI','DA_NOP','HET_GIO')),
        CONSTRAINT UQ_BaiThi_MASV_MAMH_LAN UNIQUE (MASV, MAMH, LAN)
    );
END;
GO

IF OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
   AND COL_LENGTH('dbo.BaiThi', 'BATDAU_LUC') IS NULL
    ALTER TABLE dbo.BaiThi ADD BATDAU_LUC DATETIME NOT NULL CONSTRAINT DF_BaiThi_BatDauLuc DEFAULT GETDATE();
GO

IF OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
   AND COL_LENGTH('dbo.BaiThi', 'KETTHUC_LUC') IS NULL
    ALTER TABLE dbo.BaiThi ADD KETTHUC_LUC DATETIME NULL;
GO

IF OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
   AND COL_LENGTH('dbo.BaiThi', 'NOPBAI_LUC') IS NULL
    ALTER TABLE dbo.BaiThi ADD NOPBAI_LUC DATETIME NULL;
GO

IF OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
   AND COL_LENGTH('dbo.BaiThi', 'THOIGIAN') IS NULL
    ALTER TABLE dbo.BaiThi ADD THOIGIAN SMALLINT NOT NULL CONSTRAINT DF_BaiThi_ThoiGian DEFAULT 0;
GO

IF OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
   AND COL_LENGTH('dbo.BaiThi', 'TRANGTHAI') IS NULL
    ALTER TABLE dbo.BaiThi ADD TRANGTHAI VARCHAR(20) NOT NULL CONSTRAINT DF_BaiThi_TrangThai DEFAULT 'DA_NOP';
GO

IF OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
BEGIN
    UPDATE dbo.BaiThi
    SET KETTHUC_LUC = DATEADD(MINUTE, THOIGIAN, BATDAU_LUC)
    WHERE KETTHUC_LUC IS NULL
      AND THOIGIAN > 0;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_BaiThi_SinhVien'
)
AND OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
AND OBJECT_ID('dbo.SinhVien', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.BaiThi WITH CHECK
    ADD CONSTRAINT FK_BaiThi_SinhVien
        FOREIGN KEY (MASV) REFERENCES dbo.SinhVien(MASV);

    ALTER TABLE dbo.BaiThi CHECK CONSTRAINT FK_BaiThi_SinhVien;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_BaiThi_MonHoc'
)
AND OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
AND OBJECT_ID('dbo.MonHoc', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.BaiThi WITH CHECK
    ADD CONSTRAINT FK_BaiThi_MonHoc
        FOREIGN KEY (MAMH) REFERENCES dbo.MonHoc(MAMH);

    ALTER TABLE dbo.BaiThi CHECK CONSTRAINT FK_BaiThi_MonHoc;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_BaiThi_CauTraLoi_BaiThi'
)
AND OBJECT_ID('dbo.BaiThi', 'U') IS NOT NULL
AND OBJECT_ID('dbo.BaiThi_CauTraLoi', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.BaiThi_CauTraLoi
    ADD CONSTRAINT FK_BaiThi_CauTraLoi_BaiThi
        FOREIGN KEY (MABT) REFERENCES dbo.BaiThi(MABT);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_BaiThi_CauTraLoi_BoDe'
)
AND OBJECT_ID('dbo.BoDe', 'U') IS NOT NULL
AND OBJECT_ID('dbo.BaiThi_CauTraLoi', 'U') IS NOT NULL
BEGIN
    ALTER TABLE dbo.BaiThi_CauTraLoi
    ADD CONSTRAINT FK_BaiThi_CauTraLoi_BoDe
        FOREIGN KEY (CAUHOI) REFERENCES dbo.BoDe(CAUHOI);
END;
GO

IF OBJECT_ID('dbo.AuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AuditLog (
        AUDIT_ID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        EVENT_TIME DATETIME2(0) NOT NULL CONSTRAINT DF_AuditLog_EventTime DEFAULT SYSDATETIME(),
        DB_LOGIN SYSNAME NOT NULL CONSTRAINT DF_AuditLog_DbLogin DEFAULT ORIGINAL_LOGIN(),
        DB_USER_NAME SYSNAME NOT NULL CONSTRAINT DF_AuditLog_DbUser DEFAULT USER_NAME(),
        APP_LOGINNAME NVARCHAR(128) NULL CONSTRAINT DF_AuditLog_AppLogin DEFAULT CONVERT(NVARCHAR(128), SESSION_CONTEXT(N'APP_LOGINNAME')),
        OBJECT_NAME SYSNAME NOT NULL,
        ACTION_NAME NVARCHAR(20) NOT NULL,
        KEY_VALUE NVARCHAR(300) NULL,
        DESCRIPTION NVARCHAR(1000) NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AuditLog_Object_Time' AND object_id = OBJECT_ID('dbo.AuditLog'))
    CREATE INDEX IX_AuditLog_Object_Time ON dbo.AuditLog(OBJECT_NAME, EVENT_TIME DESC);
GO

/* =====================
   2. Indexes for exam workflows
   ===================== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SinhVien_MALOP_TEN' AND object_id = OBJECT_ID('dbo.SinhVien'))
    CREATE INDEX IX_SinhVien_MALOP_TEN ON dbo.SinhVien(MALOP, TEN, HO);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_GiaoVien_DangKy_NgayThi' AND object_id = OBJECT_ID('dbo.GiaoVien_DangKy'))
    CREATE INDEX IX_GiaoVien_DangKy_NgayThi ON dbo.GiaoVien_DangKy(MALOP, MAMH, LAN, NGAYTHI);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BangDiem_MAMH_LAN' AND object_id = OBJECT_ID('dbo.BangDiem'))
    CREATE INDEX IX_BangDiem_MAMH_LAN ON dbo.BangDiem(MAMH, LAN, DIEM DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BaiThi_MASV_MAMH_LAN' AND object_id = OBJECT_ID('dbo.BaiThi'))
    CREATE INDEX IX_BaiThi_MASV_MAMH_LAN ON dbo.BaiThi(MASV, MAMH, LAN);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BaiThi_TrangThai_KetThuc' AND object_id = OBJECT_ID('dbo.BaiThi'))
    CREATE INDEX IX_BaiThi_TrangThai_KetThuc ON dbo.BaiThi(TRANGTHAI, KETTHUC_LUC);
GO

/* ========
   3. Views
   ======== */
IF OBJECT_ID('dbo.v_4_7_SinhVien_ThongTin', 'V') IS NOT NULL
    DROP VIEW dbo.v_4_7_SinhVien_ThongTin;
GO

IF OBJECT_ID('dbo.v_SinhVien_ThongTin', 'V') IS NOT NULL
    DROP VIEW dbo.v_SinhVien_ThongTin;
GO

/****** Object:  View [dbo].[v_4_7_SinhVien_ThongTin] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.v_4_7_SinhVien_ThongTin
AS
SELECT
    SV.MASV,
    RTRIM(LTRIM(ISNULL(SV.HO, N''))) + N' ' + RTRIM(LTRIM(ISNULL(SV.TEN, N''))) AS HOTEN,
    SV.NGAYSINH,
    SV.DIACHI,
    SV.MALOP,
    L.TENLOP
FROM dbo.SinhVien AS SV
LEFT JOIN dbo.Lop AS L ON L.MALOP = SV.MALOP;
GO

IF OBJECT_ID('dbo.v_4_6_LichThi', 'V') IS NOT NULL
    DROP VIEW dbo.v_4_6_LichThi;
GO

IF OBJECT_ID('dbo.v_LichThi', 'V') IS NOT NULL
    DROP VIEW dbo.v_LichThi;
GO

/****** Object:  View [dbo].[v_4_6_LichThi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.v_4_6_LichThi
AS
SELECT
    GDK.MAGV,
    RTRIM(LTRIM(ISNULL(GV.HO, N''))) + N' ' + RTRIM(LTRIM(ISNULL(GV.TEN, N''))) AS HOTEN_GV,
    GDK.MALOP,
    L.TENLOP,
    GDK.MAMH,
    MH.TENMH,
    GDK.TRINHDO,
    GDK.NGAYTHI,
    GDK.LAN,
    GDK.SOCAUTHI,
    GDK.THOIGIAN,
    ISNULL(CQ.SO_CAU_CUNG_TRINH_DO, 0) AS SO_CAU_CUNG_TRINH_DO,
    ISNULL(TQ.SO_CAU_THAP_HON, 0) AS SO_CAU_THAP_HON
FROM dbo.GiaoVien_DangKy AS GDK
INNER JOIN dbo.GiaoVien AS GV ON GV.MAGV = GDK.MAGV
INNER JOIN dbo.Lop AS L ON L.MALOP = GDK.MALOP
INNER JOIN dbo.MonHoc AS MH ON MH.MAMH = GDK.MAMH
OUTER APPLY (
    SELECT COUNT(*) AS SO_CAU_CUNG_TRINH_DO
    FROM dbo.BoDe AS BD
    WHERE BD.MAMH = GDK.MAMH
      AND BD.TRINHDO = GDK.TRINHDO
      AND BD.IS_DELETED = 0
) AS CQ
OUTER APPLY (
    SELECT COUNT(*) AS SO_CAU_THAP_HON
    FROM dbo.BoDe AS BD
    WHERE BD.MAMH = GDK.MAMH
      AND BD.TRINHDO =
            CASE GDK.TRINHDO
                WHEN 'A' THEN 'B'
                WHEN 'B' THEN 'C'
                ELSE '#'
            END
      AND BD.IS_DELETED = 0
) AS TQ;
GO

IF OBJECT_ID('dbo.v_4_8_KetQuaThi', 'V') IS NOT NULL
    DROP VIEW dbo.v_4_8_KetQuaThi;
GO

/****** Object:  View [dbo].[v_4_8_KetQuaThi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.v_4_8_KetQuaThi
AS
SELECT
    BT.MABT,
    CT.THUTU,
    BT.MASV,
    RTRIM(LTRIM(ISNULL(SV.HO, N''))) + N' ' + RTRIM(LTRIM(ISNULL(SV.TEN, N''))) AS HOTEN,
    SV.MALOP,
    L.TENLOP,
    BT.MAMH,
    MH.TENMH,
    BT.LAN,
    BT.NGAYTHI,
    BT.SOCAU,
    BT.SOCAUDUNG,
    BT.DIEM,
    CT.CAUHOI,
    CT.NOIDUNG,
    CT.A,
    CT.B,
    CT.C,
    CT.D,
    CT.DAP_AN_CHON,
    CT.DAP_AN_DUNG
FROM dbo.BaiThi AS BT
INNER JOIN dbo.BaiThi_CauTraLoi AS CT ON CT.MABT = BT.MABT
INNER JOIN dbo.SinhVien AS SV ON SV.MASV = BT.MASV
LEFT JOIN dbo.Lop AS L ON L.MALOP = SV.MALOP
INNER JOIN dbo.MonHoc AS MH ON MH.MAMH = BT.MAMH;
GO

IF OBJECT_ID('dbo.v_4_9_BangDiem_Thi', 'V') IS NOT NULL
    DROP VIEW dbo.v_4_9_BangDiem_Thi;
GO

IF OBJECT_ID('dbo.v_BangDiem_Thi', 'V') IS NOT NULL
    DROP VIEW dbo.v_BangDiem_Thi;
GO

/****** Object:  View [dbo].[v_4_9_BangDiem_Thi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.v_4_9_BangDiem_Thi
AS
SELECT
    BD.MASV,
    RTRIM(LTRIM(ISNULL(SV.HO, N''))) + N' ' + RTRIM(LTRIM(ISNULL(SV.TEN, N''))) AS HOTEN,
    SV.MALOP,
    L.TENLOP,
    BD.MAMH,
    MH.TENMH,
    BD.LAN,
    BD.NGAYTHI,
    BD.DIEM,
    CASE
        WHEN BD.DIEM >= 8.5 THEN N'A'
        WHEN BD.DIEM >= 7.0 THEN N'B'
        WHEN BD.DIEM >= 5.5 THEN N'C'
        WHEN BD.DIEM >= 4.0 THEN N'D'
        ELSE N'F'
    END AS DIEM_CHU
FROM dbo.BangDiem AS BD
INNER JOIN dbo.SinhVien AS SV ON SV.MASV = BD.MASV
LEFT JOIN dbo.Lop AS L ON L.MALOP = SV.MALOP
INNER JOIN dbo.MonHoc AS MH ON MH.MAMH = BD.MAMH;
GO

/* ===========
   4. Functions
   =========== */
IF OBJECT_ID('dbo.fn_TinhDiemThi', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhDiemThi;
GO

/****** Object:  UserDefinedFunction [dbo].[fn_TinhDiemThi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.fn_TinhDiemThi (
    @SoCauDung INT,
    @TongCau INT
)
RETURNS DECIMAL(4,2)
AS
BEGIN
    IF @TongCau IS NULL OR @TongCau <= 0
        RETURN 0;

    RETURN CAST(ROUND(CAST(ISNULL(@SoCauDung, 0) AS DECIMAL(10,4)) * 10 / @TongCau, 2) AS DECIMAL(4,2));
END;
GO

IF OBJECT_ID('dbo.fn_LayDiemCaoNhat', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_LayDiemCaoNhat;
GO

/****** Object:  UserDefinedFunction [dbo].[fn_LayDiemCaoNhat] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.fn_LayDiemCaoNhat (
    @MASV NCHAR(10),
    @MAMH NCHAR(5)
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @Diem FLOAT;

    SELECT @Diem = MAX(BD.DIEM)
    FROM dbo.BangDiem AS BD
    WHERE BD.MASV = @MASV
      AND BD.MAMH = @MAMH;

    RETURN @Diem;
END;
GO

IF OBJECT_ID('dbo.fn_DuSoCauThi', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DuSoCauThi;
GO

/****** Object:  UserDefinedFunction [dbo].[fn_DuSoCauThi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.fn_DuSoCauThi (
    @MAMH NCHAR(5),
    @TRINHDO NCHAR(1),
    @SOCAUTHI SMALLINT
)
RETURNS BIT
AS
BEGIN
    DECLARE
        @TrinhDoPhu NCHAR(1),
        @SoCauChinhToiThieu INT,
        @SoCauPhuToiDa INT,
        @SoCauChinh INT,
        @SoCauPhu INT;

    SET @TrinhDoPhu =
        CASE @TRINHDO
            WHEN 'A' THEN 'B'
            WHEN 'B' THEN 'C'
            ELSE NULL
        END;

    SET @SoCauChinhToiThieu =
        CASE WHEN @TrinhDoPhu IS NULL THEN @SOCAUTHI ELSE CEILING(0.7 * @SOCAUTHI) END;
    SET @SoCauPhuToiDa = @SOCAUTHI - @SoCauChinhToiThieu;

    SELECT @SoCauChinh = COUNT(*)
    FROM dbo.BoDe AS BD
    WHERE BD.MAMH = @MAMH
      AND BD.TRINHDO = @TRINHDO
      AND BD.IS_DELETED = 0;

    SELECT @SoCauPhu = COUNT(*)
    FROM dbo.BoDe AS BD
    WHERE BD.MAMH = @MAMH
      AND BD.TRINHDO = @TrinhDoPhu
      AND BD.IS_DELETED = 0;

    IF @SoCauChinh < @SoCauChinhToiThieu
        RETURN 0;

    IF (@SoCauChinh + CASE WHEN @SoCauPhu > @SoCauPhuToiDa THEN @SoCauPhuToiDa ELSE @SoCauPhu END) < @SOCAUTHI
        RETURN 0;

    RETURN 1;
END;
GO

IF OBJECT_ID('dbo.fn_KiemTraDieuKienThi', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_KiemTraDieuKienThi;
GO

/****** Object:  UserDefinedFunction [dbo].[fn_KiemTraDieuKienThi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.fn_KiemTraDieuKienThi (
    @MASV NCHAR(10),
    @MAMH NCHAR(5),
    @LAN SMALLINT
)
RETURNS BIT
AS
BEGIN
    DECLARE
        @MALOP NCHAR(15),
        @TRINHDO NCHAR(1),
        @SOCAUTHI SMALLINT;

    SELECT @MALOP = SV.MALOP
    FROM dbo.SinhVien AS SV
    WHERE SV.MASV = @MASV;

    IF @MALOP IS NULL
        RETURN 0;

    IF EXISTS (
        SELECT 1
        FROM dbo.BangDiem AS BD
        WHERE BD.MASV = @MASV
          AND BD.MAMH = @MAMH
          AND BD.LAN = @LAN
    )
        RETURN 0;

    SELECT
        @TRINHDO = GDK.TRINHDO,
        @SOCAUTHI = GDK.SOCAUTHI
    FROM dbo.GiaoVien_DangKy AS GDK
    WHERE GDK.MALOP = @MALOP
      AND GDK.MAMH = @MAMH
      AND GDK.LAN = @LAN
      AND CAST(GDK.NGAYTHI AS DATE) <= CAST(GETDATE() AS DATE);

    IF @TRINHDO IS NULL
        RETURN 0;

    RETURN dbo.fn_DuSoCauThi(@MAMH, @TRINHDO, @SOCAUTHI);
END;
GO

/* =================
   5. Stored procedures
   ================= */
IF OBJECT_ID('dbo.sp_ThemSinhVien', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ThemSinhVien;
GO

/****** Object:  StoredProcedure [dbo].[sp_ThemSinhVien] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_ThemSinhVien
    @MASV NCHAR(10),
    @HO NVARCHAR(40),
    @TEN NVARCHAR(10),
    @NGAYSINH DATE = NULL,
    @DIACHI NVARCHAR(100) = NULL,
    @MALOP NCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.SinhVien WHERE MASV = @MASV)
        THROW 51001, N'Ma sinh vien da ton tai.', 1;

    INSERT INTO dbo.SinhVien(MASV, HO, TEN, NGAYSINH, DIACHI, MALOP)
    VALUES (UPPER(@MASV), @HO, @TEN, @NGAYSINH, @DIACHI, UPPER(@MALOP));
END;
GO

IF OBJECT_ID('dbo.sp_SuaSinhVien', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SuaSinhVien;
GO

/****** Object:  StoredProcedure [dbo].[sp_SuaSinhVien] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_SuaSinhVien
    @MASV NCHAR(10),
    @HO NVARCHAR(40),
    @TEN NVARCHAR(10),
    @NGAYSINH DATE = NULL,
    @DIACHI NVARCHAR(100) = NULL,
    @MALOP NCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.SinhVien WHERE MASV = @MASV)
        THROW 51002, N'Ma sinh vien khong ton tai.', 1;

    UPDATE dbo.SinhVien
    SET HO = @HO,
        TEN = @TEN,
        NGAYSINH = @NGAYSINH,
        DIACHI = @DIACHI,
        MALOP = UPPER(@MALOP)
    WHERE MASV = @MASV;
END;
GO

IF OBJECT_ID('dbo.sp_XoaSinhVien', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_XoaSinhVien;
GO

/****** Object:  StoredProcedure [dbo].[sp_XoaSinhVien] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_XoaSinhVien
    @MASV NCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.BangDiem WHERE MASV = @MASV)
        THROW 51003, N'Khong the xoa sinh vien da co bang diem.', 1;

    DELETE FROM dbo.SinhVien
    WHERE MASV = @MASV;
END;
GO

IF OBJECT_ID('dbo.sp_DangKyThi', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DangKyThi;
GO

/****** Object:  StoredProcedure [dbo].[sp_DangKyThi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_DangKyThi
    @MAGV NCHAR(8),
    @MALOP NCHAR(15),
    @MAMH NCHAR(5),
    @TRINHDO NCHAR(1),
    @NGAYTHI DATETIME,
    @LAN SMALLINT,
    @SOCAUTHI SMALLINT,
    @THOIGIAN SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    IF @LAN NOT BETWEEN 1 AND 2
        THROW 51011, N'Lan thi chi duoc nhan gia tri 1 hoac 2.', 1;

    IF @SOCAUTHI NOT BETWEEN 10 AND 100
        THROW 51012, N'So cau thi phai tu 10 den 100.', 1;

    IF @THOIGIAN NOT BETWEEN 5 AND 60
        THROW 51013, N'Thoi gian thi phai tu 5 den 60 phut.', 1;

    IF dbo.fn_DuSoCauThi(@MAMH, @TRINHDO, @SOCAUTHI) = 0
        THROW 51014, N'Bo de khong du so cau theo quy tac trinh do 70/30.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.BangDiem AS BD
        INNER JOIN dbo.SinhVien AS SV ON SV.MASV = BD.MASV
        WHERE SV.MALOP = @MALOP
          AND BD.MAMH = @MAMH
          AND BD.LAN = @LAN
    )
        THROW 51015, N'Khong the sua dang ky thi da phat sinh bang diem.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.GiaoVien_DangKy
        WHERE MALOP = @MALOP
          AND MAMH = @MAMH
          AND LAN = @LAN
    )
    BEGIN
        UPDATE dbo.GiaoVien_DangKy
        SET MAGV = UPPER(@MAGV),
            TRINHDO = UPPER(@TRINHDO),
            NGAYTHI = @NGAYTHI,
            SOCAUTHI = @SOCAUTHI,
            THOIGIAN = @THOIGIAN
        WHERE MALOP = @MALOP
          AND MAMH = @MAMH
          AND LAN = @LAN;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.GiaoVien_DangKy(MAGV, MALOP, MAMH, TRINHDO, NGAYTHI, LAN, SOCAUTHI, THOIGIAN)
        VALUES (UPPER(@MAGV), UPPER(@MALOP), UPPER(@MAMH), UPPER(@TRINHDO), @NGAYTHI, @LAN, @SOCAUTHI, @THOIGIAN);
    END;
END;
GO

IF OBJECT_ID('dbo.sp_Thi_PhatDeNgauNhien', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Thi_PhatDeNgauNhien;
GO

/****** Object:  StoredProcedure [dbo].[sp_Thi_PhatDeNgauNhien] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_Thi_PhatDeNgauNhien
    @MASV NCHAR(10),
    @MAMH NCHAR(5),
    @LAN SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @MALOP NCHAR(15),
        @TRINHDO NCHAR(1),
        @SOCAUTHI SMALLINT,
        @THOIGIAN SMALLINT,
        @TrinhDoPhu NCHAR(1),
        @SoCauChinhToiThieu INT,
        @SoCauPhuToiDa INT,
        @SoCauChinhCo INT,
        @SoCauPhuCo INT,
        @SoCauChinh INT,
        @SoCauPhu INT;

    SELECT @MALOP = SV.MALOP
    FROM dbo.SinhVien AS SV
    WHERE SV.MASV = @MASV;

    IF @MALOP IS NULL
        THROW 52001, N'Ma sinh vien khong ton tai.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.BangDiem
        WHERE MASV = @MASV
          AND MAMH = @MAMH
          AND LAN = @LAN
    )
        THROW 52002, N'Sinh vien da co diem cho mon va lan thi nay.', 1;

    SELECT
        @TRINHDO = GDK.TRINHDO,
        @SOCAUTHI = GDK.SOCAUTHI,
        @THOIGIAN = GDK.THOIGIAN
    FROM dbo.GiaoVien_DangKy AS GDK
    WHERE GDK.MALOP = @MALOP
      AND GDK.MAMH = @MAMH
      AND GDK.LAN = @LAN;

    IF @TRINHDO IS NULL
        THROW 52003, N'Khong tim thay lich thi hop le cho sinh vien.', 1;

    SET @TrinhDoPhu =
        CASE @TRINHDO
            WHEN 'A' THEN 'B'
            WHEN 'B' THEN 'C'
            ELSE NULL
        END;

    SET @SoCauChinhToiThieu =
        CASE WHEN @TrinhDoPhu IS NULL THEN @SOCAUTHI ELSE CEILING(0.7 * @SOCAUTHI) END;
    SET @SoCauPhuToiDa = @SOCAUTHI - @SoCauChinhToiThieu;

    SELECT @SoCauChinhCo = COUNT(*)
    FROM dbo.BoDe AS BD
    WHERE BD.MAMH = @MAMH
      AND BD.TRINHDO = @TRINHDO
      AND BD.IS_DELETED = 0;

    SELECT @SoCauPhuCo = COUNT(*)
    FROM dbo.BoDe AS BD
    WHERE BD.MAMH = @MAMH
      AND BD.TRINHDO = @TrinhDoPhu
      AND BD.IS_DELETED = 0;

    IF @SoCauChinhCo < @SoCauChinhToiThieu
        THROW 52004, N'Khong du cau hoi cung trinh do toi thieu 70%.', 1;

    SET @SoCauPhu =
        CASE
            WHEN @TrinhDoPhu IS NULL THEN 0
            WHEN @SoCauPhuCo >= @SoCauPhuToiDa THEN @SoCauPhuToiDa
            ELSE @SoCauPhuCo
        END;
    SET @SoCauChinh = @SOCAUTHI - @SoCauPhu;

    IF @SoCauChinhCo < @SoCauChinh
        THROW 52005, N'Khong du cau hoi de lap de thi theo yeu cau.', 1;

    DECLARE @DeThi TABLE (
        CAUHOI INT PRIMARY KEY,
        NOIDUNG NVARCHAR(200),
        A_GOC NVARCHAR(50),
        B_GOC NVARCHAR(50),
        C_GOC NVARCHAR(50),
        D_GOC NVARCHAR(50),
        DAP_AN_GOC NCHAR(1),
        DAP_AN_DUNG_NOIDUNG NVARCHAR(50),
        CAP_DO_GOC NCHAR(1)
    );

    INSERT INTO @DeThi(CAUHOI, NOIDUNG, A_GOC, B_GOC, C_GOC, D_GOC, DAP_AN_GOC, DAP_AN_DUNG_NOIDUNG, CAP_DO_GOC)
    SELECT
        X.CAUHOI,
        X.NOIDUNG,
        X.A,
        X.B,
        X.C,
        X.D,
        X.DAP_AN,
        CASE X.DAP_AN
            WHEN 'A' THEN X.A
            WHEN 'B' THEN X.B
            WHEN 'C' THEN X.C
            WHEN 'D' THEN X.D
        END,
        X.TRINHDO
    FROM (
        SELECT TOP (@SoCauChinh)
            BD.CAUHOI, BD.NOIDUNG, BD.A, BD.B, BD.C, BD.D, BD.DAP_AN, BD.TRINHDO
        FROM dbo.BoDe AS BD
        WHERE BD.MAMH = @MAMH
          AND BD.TRINHDO = @TRINHDO
          AND BD.IS_DELETED = 0
        ORDER BY NEWID()
    ) AS X;

    IF @SoCauPhu > 0
    BEGIN
        INSERT INTO @DeThi(CAUHOI, NOIDUNG, A_GOC, B_GOC, C_GOC, D_GOC, DAP_AN_GOC, DAP_AN_DUNG_NOIDUNG, CAP_DO_GOC)
        SELECT
            Y.CAUHOI,
            Y.NOIDUNG,
            Y.A,
            Y.B,
            Y.C,
            Y.D,
            Y.DAP_AN,
            CASE Y.DAP_AN
                WHEN 'A' THEN Y.A
                WHEN 'B' THEN Y.B
                WHEN 'C' THEN Y.C
                WHEN 'D' THEN Y.D
            END,
            Y.TRINHDO
        FROM (
            SELECT TOP (@SoCauPhu)
                BD.CAUHOI, BD.NOIDUNG, BD.A, BD.B, BD.C, BD.D, BD.DAP_AN, BD.TRINHDO
            FROM dbo.BoDe AS BD
            WHERE BD.MAMH = @MAMH
              AND BD.TRINHDO = @TrinhDoPhu
              AND BD.IS_DELETED = 0
            ORDER BY NEWID()
        ) AS Y;
    END;

    ;WITH DeCoHoanVi AS (
        SELECT
            D.*,
            ABS(CHECKSUM(NEWID())) % 24 AS MA_HOAN_VI
        FROM @DeThi AS D
    )
    SELECT
        D.CAUHOI,
        D.NOIDUNG,
        CASE SUBSTRING(P.HOAN_VI, 1, 1) WHEN 'A' THEN D.A_GOC WHEN 'B' THEN D.B_GOC WHEN 'C' THEN D.C_GOC ELSE D.D_GOC END AS A,
        CASE SUBSTRING(P.HOAN_VI, 2, 1) WHEN 'A' THEN D.A_GOC WHEN 'B' THEN D.B_GOC WHEN 'C' THEN D.C_GOC ELSE D.D_GOC END AS B,
        CASE SUBSTRING(P.HOAN_VI, 3, 1) WHEN 'A' THEN D.A_GOC WHEN 'B' THEN D.B_GOC WHEN 'C' THEN D.C_GOC ELSE D.D_GOC END AS C,
        CASE SUBSTRING(P.HOAN_VI, 4, 1) WHEN 'A' THEN D.A_GOC WHEN 'B' THEN D.B_GOC WHEN 'C' THEN D.C_GOC ELSE D.D_GOC END AS D,
        SUBSTRING(N'ABCD', CHARINDEX(D.DAP_AN_GOC, P.HOAN_VI), 1) AS DAP_AN_MOI,
        @THOIGIAN AS THOIGIAN_THI,
        @TRINHDO AS TRINHDO_LICH_THI,
        D.CAP_DO_GOC AS TRINHDO_CAU
    FROM DeCoHoanVi AS D
    CROSS APPLY (
        SELECT CASE D.MA_HOAN_VI
            WHEN 0 THEN N'ABCD'
            WHEN 1 THEN N'ABDC'
            WHEN 2 THEN N'ACBD'
            WHEN 3 THEN N'ACDB'
            WHEN 4 THEN N'ADBC'
            WHEN 5 THEN N'ADCB'
            WHEN 6 THEN N'BACD'
            WHEN 7 THEN N'BADC'
            WHEN 8 THEN N'BCAD'
            WHEN 9 THEN N'BCDA'
            WHEN 10 THEN N'BDAC'
            WHEN 11 THEN N'BDCA'
            WHEN 12 THEN N'CABD'
            WHEN 13 THEN N'CADB'
            WHEN 14 THEN N'CBAD'
            WHEN 15 THEN N'CBDA'
            WHEN 16 THEN N'CDAB'
            WHEN 17 THEN N'CDBA'
            WHEN 18 THEN N'DABC'
            WHEN 19 THEN N'DACB'
            WHEN 20 THEN N'DBAC'
            WHEN 21 THEN N'DBCA'
            WHEN 22 THEN N'DCAB'
            ELSE N'DCBA'
        END AS HOAN_VI
    ) AS P
    ORDER BY NEWID();
END;
GO

IF OBJECT_ID('dbo.sp_BatDauThi', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_BatDauThi;
GO

/****** Object:  StoredProcedure [dbo].[sp_BatDauThi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_BatDauThi
    @MASV NCHAR(10),
    @MAMH NCHAR(5),
    @LAN SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @MABT BIGINT,
        @TRANGTHAI VARCHAR(20),
        @MALOP NCHAR(15),
        @TRINHDO NCHAR(1),
        @NGAYTHI DATETIME,
        @SOCAUTHI SMALLINT,
        @THOIGIAN SMALLINT,
        @BATDAU_LUC DATETIME,
        @KETTHUC_LUC DATETIME;

    SET @MASV = UPPER(LTRIM(RTRIM(@MASV)));
    SET @MAMH = UPPER(LTRIM(RTRIM(@MAMH)));

    DECLARE @DeThi TABLE (
        THUTU SMALLINT IDENTITY(1,1) PRIMARY KEY,
        CAUHOI INT NOT NULL,
        NOIDUNG NVARCHAR(200) NOT NULL,
        A NVARCHAR(50) NULL,
        B NVARCHAR(50) NULL,
        C NVARCHAR(50) NULL,
        D NVARCHAR(50) NULL,
        DAP_AN_MOI NCHAR(1) NOT NULL,
        THOIGIAN_THI SMALLINT NULL,
        TRINHDO_LICH_THI NCHAR(1) NULL,
        TRINHDO_CAU NCHAR(1) NOT NULL
    );

    BEGIN TRANSACTION;

    SELECT TOP 1
        @MABT = BT.MABT,
        @TRANGTHAI = BT.TRANGTHAI
    FROM dbo.BaiThi AS BT WITH (UPDLOCK, HOLDLOCK)
    WHERE BT.MASV = @MASV
      AND BT.MAMH = @MAMH
      AND BT.LAN = @LAN;

    IF @MABT IS NOT NULL
    BEGIN
        IF @TRANGTHAI = 'DANG_THI'
        BEGIN
            COMMIT TRANSACTION;
            SELECT @MABT AS MABT;
            RETURN;
        END;

        THROW 52020, N'Sinh vien da co bai thi hoan tat cho mon va lan thi nay.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM dbo.BangDiem WITH (UPDLOCK, HOLDLOCK)
        WHERE MASV = @MASV
          AND MAMH = @MAMH
          AND LAN = @LAN
    )
        THROW 52021, N'Sinh vien da co diem cho mon va lan thi nay.', 1;

    SELECT @MALOP = SV.MALOP
    FROM dbo.SinhVien AS SV WITH (HOLDLOCK)
    WHERE SV.MASV = @MASV;

    IF @MALOP IS NULL
        THROW 52022, N'Ma sinh vien khong ton tai.', 1;

    SELECT
        @TRINHDO = GDK.TRINHDO,
        @NGAYTHI = GDK.NGAYTHI,
        @SOCAUTHI = GDK.SOCAUTHI,
        @THOIGIAN = GDK.THOIGIAN
    FROM dbo.GiaoVien_DangKy AS GDK WITH (HOLDLOCK)
    WHERE GDK.MALOP = @MALOP
      AND GDK.MAMH = @MAMH
      AND GDK.LAN = @LAN;

    IF @TRINHDO IS NULL
        THROW 52023, N'Khong tim thay lich thi hop le cho sinh vien.', 1;

    IF GETDATE() < @NGAYTHI
        THROW 52024, N'Chua den thoi gian thi da dang ky.', 1;

    INSERT INTO @DeThi(CAUHOI, NOIDUNG, A, B, C, D, DAP_AN_MOI, THOIGIAN_THI, TRINHDO_LICH_THI, TRINHDO_CAU)
    EXEC dbo.sp_Thi_PhatDeNgauNhien @MASV, @MAMH, @LAN;

    IF (SELECT COUNT(1) FROM @DeThi) <> @SOCAUTHI
        THROW 52025, N'So cau phat ra khong khop voi dang ky thi.', 1;

    SET @BATDAU_LUC = GETDATE();
    SET @KETTHUC_LUC = DATEADD(MINUTE, @THOIGIAN, @BATDAU_LUC);

    INSERT INTO dbo.BaiThi(
        MASV, MAMH, LAN, NGAYTHI, BATDAU_LUC, KETTHUC_LUC, THOIGIAN,
        SOCAU, SOCAUDUNG, DIEM, TRANGTHAI
    )
    VALUES (
        @MASV, @MAMH, @LAN, @BATDAU_LUC, @BATDAU_LUC, @KETTHUC_LUC, @THOIGIAN,
        @SOCAUTHI, 0, 0, 'DANG_THI'
    );

    SET @MABT = CONVERT(BIGINT, SCOPE_IDENTITY());

    INSERT INTO dbo.BaiThi_CauTraLoi(
        MABT, CAUHOI, THUTU, MAMH, TRINHDO_CAU, NOIDUNG,
        A, B, C, D, DAP_AN_DUNG, DAP_AN_CHON
    )
    SELECT
        @MABT,
        DT.CAUHOI,
        DT.THUTU,
        @MAMH,
        DT.TRINHDO_CAU,
        DT.NOIDUNG,
        DT.A,
        DT.B,
        DT.C,
        DT.D,
        DT.DAP_AN_MOI,
        NULL
    FROM @DeThi AS DT
    ORDER BY DT.THUTU;

    COMMIT TRANSACTION;

    SELECT @MABT AS MABT;
END;
GO

IF OBJECT_ID('dbo.sp_NopBai', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_NopBai;
GO

/****** Object:  StoredProcedure [dbo].[sp_NopBai] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_NopBai
    @MABT BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @MASV NCHAR(10),
        @MAMH NCHAR(5),
        @LAN SMALLINT,
        @TrangThai VARCHAR(20),
        @TongCau INT,
        @SoCauDung INT,
        @Diem DECIMAL(4,2);

    BEGIN TRANSACTION;

    SELECT
        @MASV = BT.MASV,
        @MAMH = BT.MAMH,
        @LAN = BT.LAN,
        @TrangThai = BT.TRANGTHAI
    FROM dbo.BaiThi AS BT WITH (UPDLOCK, HOLDLOCK)
    WHERE BT.MABT = @MABT;

    IF @MASV IS NULL
        THROW 53001, N'Khong tim thay bai thi.', 1;

    IF @TrangThai <> 'DANG_THI'
    BEGIN
        SELECT
            BT.MABT,
            BT.SOCAU,
            BT.SOCAUDUNG,
            BT.DIEM,
            BT.MASV,
            BT.MAMH,
            BT.LAN,
            BT.TRANGTHAI
        FROM dbo.BaiThi AS BT
        WHERE BT.MABT = @MABT;
        COMMIT TRANSACTION;
        RETURN;
    END;

    SELECT
        @TongCau = COUNT(*),
        @SoCauDung = SUM(CASE WHEN DAP_AN_CHON = DAP_AN_DUNG THEN 1 ELSE 0 END)
    FROM dbo.BaiThi_CauTraLoi
    WHERE MABT = @MABT;

    SET @Diem = dbo.fn_TinhDiemThi(@SoCauDung, @TongCau);

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.BangDiem
        WHERE MASV = @MASV
          AND MAMH = @MAMH
          AND LAN = @LAN
    )
    BEGIN
        INSERT INTO dbo.BangDiem(MASV, MAMH, LAN, NGAYTHI, DIEM)
        VALUES (@MASV, @MAMH, @LAN, CAST(GETDATE() AS DATE), @Diem);
    END;

    UPDATE dbo.BaiThi
    SET SOCAU = @TongCau,
        SOCAUDUNG = @SoCauDung,
        DIEM = @Diem,
        NOPBAI_LUC = GETDATE(),
        TRANGTHAI =
            CASE
                WHEN KETTHUC_LUC IS NOT NULL AND GETDATE() > KETTHUC_LUC THEN 'HET_GIO'
                ELSE 'DA_NOP'
            END
    WHERE MABT = @MABT;

    COMMIT TRANSACTION;

    SELECT
        BT.MABT,
        BT.SOCAU,
        BT.SOCAUDUNG,
        BT.DIEM,
        BT.MASV,
        BT.MAMH,
        BT.LAN,
        BT.TRANGTHAI
    FROM dbo.BaiThi AS BT
    WHERE BT.MABT = @MABT;
END;
GO

IF OBJECT_ID('dbo.sp_TTN_TuDongNopBaiHetGio', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TTN_TuDongNopBaiHetGio;
GO

/****** Object:  StoredProcedure [dbo].[sp_TTN_TuDongNopBaiHetGio] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_TTN_TuDongNopBaiHetGio
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT OFF;

    DECLARE
        @MABT BIGINT,
        @DaXuLy INT = 0,
        @Loi INT = 0,
        @ThongBaoLoi NVARCHAR(4000);

    DECLARE @KetQua TABLE (
        MABT BIGINT,
        SOCAU SMALLINT,
        SOCAUDUNG SMALLINT,
        DIEM DECIMAL(4,2),
        MASV NCHAR(10),
        MAMH NCHAR(5),
        LAN SMALLINT,
        TRANGTHAI VARCHAR(20)
    );

    DECLARE curHetGio CURSOR LOCAL FAST_FORWARD FOR
        SELECT BT.MABT
        FROM dbo.BaiThi AS BT WITH (READPAST)
        WHERE BT.TRANGTHAI = 'DANG_THI'
          AND BT.KETTHUC_LUC IS NOT NULL
          AND GETDATE() > BT.KETTHUC_LUC
        ORDER BY BT.KETTHUC_LUC, BT.MABT;

    OPEN curHetGio;
    FETCH NEXT FROM curHetGio INTO @MABT;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            DELETE FROM @KetQua;
            EXEC sys.sp_set_session_context @key = N'APP_LOGINNAME', @value = N'AUTO_TIMEOUT';

            INSERT INTO @KetQua(MABT, SOCAU, SOCAUDUNG, DIEM, MASV, MAMH, LAN, TRANGTHAI)
            EXEC dbo.sp_NopBai @MABT;

            SET @DaXuLy += 1;
        END TRY
        BEGIN CATCH
            SET @Loi += 1;
            SET @ThongBaoLoi = CONCAT(N'MABT=', @MABT, N': ', ERROR_MESSAGE());

            INSERT INTO dbo.AuditLog(APP_LOGINNAME, DB_LOGIN, DB_USER_NAME, OBJECT_NAME, ACTION_NAME, KEY_VALUE, DESCRIPTION)
            VALUES (
                N'AUTO_TIMEOUT',
                SUSER_SNAME(),
                USER_NAME(),
                N'BaiThi',
                N'AUTO_SUBMIT_ERROR',
                CAST(@MABT AS NVARCHAR(100)),
                @ThongBaoLoi
            );
        END CATCH;

        FETCH NEXT FROM curHetGio INTO @MABT;
    END;

    CLOSE curHetGio;
    DEALLOCATE curHetGio;

    SELECT
        @DaXuLy AS SoBaiDaTuDongNop,
        @Loi AS SoBaiLoi;
END;
GO

IF OBJECT_ID('dbo.sp_LuuTamCauTraLoi', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_LuuTamCauTraLoi;
GO

/****** Object:  StoredProcedure [dbo].[sp_LuuTamCauTraLoi] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_LuuTamCauTraLoi
    @MABT BIGINT,
    @CAUHOI INT,
    @DAP_AN_CHON NCHAR(1) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @TRANGTHAI VARCHAR(20),
        @KETTHUC_LUC DATETIME;

    IF @DAP_AN_CHON IS NOT NULL AND @DAP_AN_CHON NOT IN ('A','B','C','D')
        THROW 53011, N'Dap an chon khong hop le.', 1;

    BEGIN TRANSACTION;

    SELECT
        @TRANGTHAI = TRANGTHAI,
        @KETTHUC_LUC = KETTHUC_LUC
    FROM dbo.BaiThi WITH (UPDLOCK, HOLDLOCK)
    WHERE MABT = @MABT;

    IF @TRANGTHAI IS NULL
        THROW 53015, N'Khong tim thay bai thi.', 1;

    IF @TRANGTHAI <> 'DANG_THI'
        THROW 53012, N'Bai thi khong o trang thai dang thi.', 1;

    IF @KETTHUC_LUC IS NOT NULL AND GETDATE() > @KETTHUC_LUC
        THROW 53013, N'Da het thoi gian lam bai.', 1;

    UPDATE dbo.BaiThi_CauTraLoi
    SET DAP_AN_CHON = @DAP_AN_CHON
    WHERE MABT = @MABT
      AND CAUHOI = @CAUHOI;

    IF @@ROWCOUNT = 0
        THROW 53014, N'Cau hoi khong thuoc bai thi.', 1;

    COMMIT TRANSACTION;
END;
GO

IF OBJECT_ID('dbo.sp_ChamDiem', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ChamDiem;
GO

/****** Object:  StoredProcedure [dbo].[sp_ChamDiem] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_ChamDiem
    @MABT BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @TongCau INT,
        @SoCauDung INT,
        @Diem DECIMAL(4,2);

    SELECT
        @TongCau = COUNT(*),
        @SoCauDung = SUM(CASE WHEN DAP_AN_CHON = DAP_AN_DUNG THEN 1 ELSE 0 END)
    FROM dbo.BaiThi_CauTraLoi
    WHERE MABT = @MABT;

    SET @Diem = dbo.fn_TinhDiemThi(@SoCauDung, @TongCau);

    UPDATE dbo.BaiThi
    SET SOCAU = @TongCau,
        SOCAUDUNG = @SoCauDung,
        DIEM = @Diem
    WHERE MABT = @MABT;

    SELECT @MABT AS MABT, @TongCau AS SOCAU, @SoCauDung AS SOCAUDUNG, @Diem AS DIEM;
END;
GO

IF OBJECT_ID('dbo.sp_TraCuuKetQua', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TraCuuKetQua;
GO

/****** Object:  StoredProcedure [dbo].[sp_TraCuuKetQua] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_TraCuuKetQua
    @MASV NCHAR(10),
    @MAMH NCHAR(5),
    @LAN SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        BT.MABT,
        BT.MASV,
        SV.HO,
        SV.TEN,
        SV.MALOP,
        L.TENLOP,
        BT.MAMH,
        MH.TENMH,
        BT.LAN,
        BT.NGAYTHI,
        BT.SOCAU,
        BT.SOCAUDUNG,
        BT.DIEM
    FROM dbo.BaiThi AS BT
    INNER JOIN dbo.SinhVien AS SV ON SV.MASV = BT.MASV
    LEFT JOIN dbo.Lop AS L ON L.MALOP = SV.MALOP
    INNER JOIN dbo.MonHoc AS MH ON MH.MAMH = BT.MAMH
    WHERE BT.MASV = @MASV
      AND BT.MAMH = @MAMH
      AND BT.LAN = @LAN
    ORDER BY BT.MABT DESC;

    SELECT
        CT.THUTU,
        CT.CAUHOI,
        CT.NOIDUNG,
        CT.A,
        CT.B,
        CT.C,
        CT.D,
        CT.DAP_AN_CHON,
        CT.DAP_AN_DUNG
    FROM dbo.BaiThi AS BT
    INNER JOIN dbo.BaiThi_CauTraLoi AS CT ON CT.MABT = BT.MABT
    WHERE BT.MASV = @MASV
      AND BT.MAMH = @MAMH
      AND BT.LAN = @LAN
    ORDER BY CT.THUTU;
END;
GO

IF OBJECT_ID('dbo.sp_BangDiemMonHoc', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_BangDiemMonHoc;
GO

/****** Object:  StoredProcedure [dbo].[sp_BangDiemMonHoc] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_BangDiemMonHoc
    @MALOP NCHAR(15),
    @MAMH NCHAR(5),
    @LAN SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ROW_NUMBER() OVER (ORDER BY SV.TEN, SV.HO, SV.MASV) AS STT,
        SV.MASV,
        SV.HO,
        SV.TEN,
        BD.DIEM,
        CASE
            WHEN BD.DIEM >= 8.5 THEN N'A'
            WHEN BD.DIEM >= 7.0 THEN N'B'
            WHEN BD.DIEM >= 5.5 THEN N'C'
            WHEN BD.DIEM >= 4.0 THEN N'D'
            ELSE N'F'
        END AS DIEM_CHU
    FROM dbo.SinhVien AS SV
    LEFT JOIN dbo.BangDiem AS BD
        ON BD.MASV = SV.MASV
       AND BD.MAMH = @MAMH
       AND BD.LAN = @LAN
    WHERE SV.MALOP = @MALOP
    ORDER BY SV.TEN, SV.HO, SV.MASV;
END;
GO

/* =========================================================
   4.11. Tao tai khoan PGV/GIANGVIEN
   ========================================================= */
IF OBJECT_ID('dbo.sp_4_11_TaoTaiKhoan', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_4_11_TaoTaiKhoan;
GO

/****** Object:  StoredProcedure [dbo].[sp_4_11_TaoTaiKhoan] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_4_11_TaoTaiKhoan
    @NGUOI_TAO NVARCHAR(50),
    @LOGINNAME NVARCHAR(50),
    @MATKHAU NVARCHAR(255),
    @ROLE_NAME NVARCHAR(20),
    @MAGV NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;

    SET @NGUOI_TAO = LOWER(LTRIM(RTRIM(@NGUOI_TAO)));
    SET @LOGINNAME = LOWER(LTRIM(RTRIM(@LOGINNAME)));
    SET @MATKHAU = LTRIM(RTRIM(@MATKHAU));
    SET @ROLE_NAME = UPPER(LTRIM(RTRIM(@ROLE_NAME)));
    SET @MAGV = UPPER(LTRIM(RTRIM(@MAGV)));

    IF dbo.fn_4_1_LaPGV(@NGUOI_TAO) = 0
        THROW 50411, N'Chi PGV duoc tao tai khoan.', 1;

    IF @LOGINNAME = N'' OR @MATKHAU = N'' OR @MAGV = N''
        THROW 50412, N'Login name, mat khau va ma giao vien khong duoc de trong.', 1;

    IF @LOGINNAME LIKE N'%[^a-zA-Z0-9_.-]%'
        THROW 50413, N'Login name chi duoc dung chu cai, so, dau gach duoi, cham hoac gach ngang.', 1;

    IF LEN(@MATKHAU) < 6
        THROW 50414, N'Mat khau phai co it nhat 6 ky tu.', 1;

    IF @ROLE_NAME NOT IN (N'PGV', N'GIANGVIEN')
        THROW 50415, N'Role chi nhan PGV hoac GIANGVIEN.', 1;

    IF EXISTS (SELECT 1 FROM dbo.TaiKhoan WHERE LOGINNAME = @LOGINNAME)
        THROW 50416, N'Login name da ton tai.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.GiaoVien WHERE MAGV = @MAGV AND IS_DELETED = 0)
        THROW 50417, N'Ma giao vien khong ton tai hoac da bi xoa.', 1;

    IF EXISTS (SELECT 1 FROM dbo.TaiKhoan WHERE MAGV = @MAGV AND IS_ACTIVE = 1)
        THROW 50418, N'Giao vien nay da co tai khoan dang hoat dong.', 1;

    INSERT INTO dbo.TaiKhoan (LOGINNAME, MATKHAU, ROLE_NAME, MAGV, IS_ACTIVE, CREATED_AT)
    VALUES (@LOGINNAME, @MATKHAU, @ROLE_NAME, @MAGV, 1, GETDATE());

    DECLARE
        @Message NVARCHAR(4000) = N'Da tao tai khoan ung dung.',
        @LoginSys SYSNAME = CONVERT(SYSNAME, @LOGINNAME),
        @UserName SYSNAME = CONVERT(SYSNAME, N'U_' + @LOGINNAME),
        @RoleDb SYSNAME = CASE WHEN @ROLE_NAME = N'PGV' THEN N'PGV' ELSE N'Giangvien' END,
        @Sql NVARCHAR(MAX);

    BEGIN TRY
        IF SUSER_ID(@LoginSys) IS NULL
        BEGIN
            SET @Sql = N'CREATE LOGIN ' + QUOTENAME(@LoginSys)
                + N' WITH PASSWORD = N''' + REPLACE(@MATKHAU, N'''', N'''''') + N''', CHECK_POLICY = OFF';
            EXEC (@Sql);
        END;

        IF DATABASE_PRINCIPAL_ID(@UserName) IS NULL
        BEGIN
            SET @Sql = N'CREATE USER ' + QUOTENAME(@UserName)
                + N' FOR LOGIN ' + QUOTENAME(@LoginSys)
                + N' WITH DEFAULT_SCHEMA=[dbo]';
            EXEC (@Sql);
        END;

        IF NOT EXISTS (
            SELECT 1
            FROM sys.database_role_members AS DRM
            INNER JOIN sys.database_principals AS R ON R.principal_id = DRM.role_principal_id
            INNER JOIN sys.database_principals AS M ON M.principal_id = DRM.member_principal_id
            WHERE R.name = @RoleDb AND M.name = @UserName
        )
        BEGIN
            SET @Sql = N'ALTER ROLE ' + QUOTENAME(@RoleDb) + N' ADD MEMBER ' + QUOTENAME(@UserName);
            EXEC (@Sql);
        END;

        SET @Message = N'Da tao tai khoan ung dung va SQL login/user.';
    END TRY
    BEGIN CATCH
        SET @Message = N'Da tao tai khoan ung dung. SQL login/user chua tao duoc: ' + ERROR_MESSAGE();
    END CATCH;

    SELECT
        @LOGINNAME AS LOGINNAME,
        @ROLE_NAME AS ROLE_NAME,
        RTRIM(@MAGV) AS MAGV,
        @Message AS MESSAGE;
END;
GO

IF OBJECT_ID('dbo.sp_ThiThu_PhatDe', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ThiThu_PhatDe;
GO

/****** Object:  StoredProcedure [dbo].[sp_ThiThu_PhatDe] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_ThiThu_PhatDe
    @MAMH NCHAR(5),
    @TRINHDO NCHAR(1),
    @SOCAU INT
AS
BEGIN
    SET NOCOUNT ON;

    SET @MAMH = UPPER(LTRIM(RTRIM(@MAMH)));
    SET @TRINHDO = UPPER(LTRIM(RTRIM(@TRINHDO)));

    IF @TRINHDO NOT IN ('A','B','C')
        THROW 50431, N'Trinh do chi nhan A, B hoac C.', 1;

    IF @SOCAU < 1 OR @SOCAU > 100
        THROW 50432, N'So cau thi thu phai tu 1 den 100.', 1;

    DECLARE
        @TRINHDO_THAP NCHAR(1) = CASE @TRINHDO WHEN 'A' THEN 'B' WHEN 'B' THEN 'C' ELSE NULL END,
        @SOCAU_THAP_TOIDA INT = CASE WHEN @TRINHDO = 'C' THEN 0 ELSE FLOOR(@SOCAU * 0.3) END,
        @CO_THAP INT = 0,
        @LAY_THAP INT = 0,
        @LAY_CHINH INT = @SOCAU;

    IF @TRINHDO_THAP IS NOT NULL
    BEGIN
        SELECT @CO_THAP = COUNT(*)
        FROM dbo.BoDe
        WHERE MAMH = @MAMH
          AND TRINHDO = @TRINHDO_THAP
          AND IS_DELETED = 0;

        SET @LAY_THAP = CASE WHEN @CO_THAP < @SOCAU_THAP_TOIDA THEN @CO_THAP ELSE @SOCAU_THAP_TOIDA END;
        SET @LAY_CHINH = @SOCAU - @LAY_THAP;
    END;

    IF (SELECT COUNT(*)
        FROM dbo.BoDe
        WHERE MAMH = @MAMH
          AND TRINHDO = @TRINHDO
          AND IS_DELETED = 0) < @LAY_CHINH
    BEGIN
        THROW 50433, N'Bo de chua du cau hoi de thi thu theo trinh do da chon.', 1;
    END;

    ;WITH CauChinh AS (
        SELECT TOP (@LAY_CHINH)
            CAUHOI, MAMH, TRINHDO, NOIDUNG, A, B, C, D, DAP_AN
        FROM dbo.BoDe
        WHERE MAMH = @MAMH
          AND TRINHDO = @TRINHDO
          AND IS_DELETED = 0
        ORDER BY NEWID()
    ),
    CauThap AS (
        SELECT TOP (@LAY_THAP)
            CAUHOI, MAMH, TRINHDO, NOIDUNG, A, B, C, D, DAP_AN
        FROM dbo.BoDe
        WHERE @TRINHDO_THAP IS NOT NULL
          AND MAMH = @MAMH
          AND TRINHDO = @TRINHDO_THAP
          AND IS_DELETED = 0
        ORDER BY NEWID()
    ),
    DeThi AS (
        SELECT * FROM CauChinh
        UNION ALL
        SELECT * FROM CauThap
    )
SELECT
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS THUTU,
        CAUHOI, MAMH, TRINHDO, NOIDUNG, A, B, C, D, DAP_AN
    FROM DeThi;
END;
GO

/* =================
   6. Question bank procedures aligned with application login accounts
   ================= */
CREATE OR ALTER PROCEDURE dbo.sp_4_5_BoDe_DanhSachCuaNguoiDung
    @LOGINNAME NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MAGV NCHAR(8), @IS_PGV BIT = 0;

    SELECT TOP 1
        @MAGV = TK.MAGV,
        @IS_PGV = CASE WHEN TK.ROLE_NAME = N'PGV' THEN 1 ELSE 0 END
    FROM dbo.TaiKhoan AS TK
    INNER JOIN dbo.GiaoVien AS GV ON GV.MAGV = TK.MAGV
    WHERE LOWER(LTRIM(RTRIM(TK.LOGINNAME))) = LOWER(LTRIM(RTRIM(@LOGINNAME)))
      AND TK.IS_ACTIVE = 1
      AND GV.IS_DELETED = 0
      AND TK.ROLE_NAME IN (N'GIANGVIEN', N'PGV');

    SELECT BD.CAUHOI, BD.MAMH, BD.TRINHDO, BD.NOIDUNG, BD.A, BD.B, BD.C, BD.D,
           BD.DAP_AN, BD.MAGV,
           LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN_GV
    FROM dbo.BoDe AS BD
    LEFT JOIN dbo.GiaoVien AS GV ON GV.MAGV = BD.MAGV
    WHERE BD.IS_DELETED = 0
      AND (@IS_PGV = 1 OR BD.MAGV = @MAGV)
    ORDER BY BD.CAUHOI DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_4_5_BoDe_DaXoaCuaNguoiDung
    @LOGINNAME NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MAGV NCHAR(8), @IS_PGV BIT = 0;

    SELECT TOP 1
        @MAGV = TK.MAGV,
        @IS_PGV = CASE WHEN TK.ROLE_NAME = N'PGV' THEN 1 ELSE 0 END
    FROM dbo.TaiKhoan AS TK
    INNER JOIN dbo.GiaoVien AS GV ON GV.MAGV = TK.MAGV
    WHERE LOWER(LTRIM(RTRIM(TK.LOGINNAME))) = LOWER(LTRIM(RTRIM(@LOGINNAME)))
      AND TK.IS_ACTIVE = 1
      AND TK.ROLE_NAME IN (N'GIANGVIEN', N'PGV');

    SELECT BD.CAUHOI, BD.MAMH, BD.TRINHDO, BD.NOIDUNG, BD.A, BD.B, BD.C, BD.D,
           BD.DAP_AN, BD.MAGV,
           LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN_GV,
           BD.DELETED_AT, BD.DELETED_BY
    FROM dbo.BoDe AS BD
    LEFT JOIN dbo.GiaoVien AS GV ON GV.MAGV = BD.MAGV
    WHERE BD.IS_DELETED = 1
      AND (@IS_PGV = 1 OR BD.MAGV = @MAGV)
    ORDER BY BD.DELETED_AT DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_4_5_BoDe_PhucHoi
    @LOGINNAME NVARCHAR(128),
    @CAUHOI INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MAGV NCHAR(8), @IS_PGV BIT = 0;

    SELECT TOP 1
        @MAGV = TK.MAGV,
        @IS_PGV = CASE WHEN TK.ROLE_NAME = N'PGV' THEN 1 ELSE 0 END
    FROM dbo.TaiKhoan AS TK
    INNER JOIN dbo.GiaoVien AS GV ON GV.MAGV = TK.MAGV
    WHERE LOWER(LTRIM(RTRIM(TK.LOGINNAME))) = LOWER(LTRIM(RTRIM(@LOGINNAME)))
      AND TK.IS_ACTIVE = 1
      AND TK.ROLE_NAME IN (N'GIANGVIEN', N'PGV');

    IF EXISTS (
        SELECT 1
        FROM dbo.BoDe AS BD
        WHERE BD.CAUHOI = @CAUHOI
          AND BD.IS_DELETED = 1
          AND (
              NOT EXISTS (SELECT 1 FROM dbo.MonHoc AS MH WHERE MH.MAMH = BD.MAMH AND MH.IS_DELETED = 0)
              OR NOT EXISTS (SELECT 1 FROM dbo.GiaoVien AS GV WHERE GV.MAGV = BD.MAGV AND GV.IS_DELETED = 0)
          )
    )
        THROW 50506, N'Mon hoc hoac giao vien cua cau hoi dang bi xoa. Hay phuc hoi du lieu lien quan truoc.', 1;

    UPDATE dbo.BoDe
    SET IS_DELETED = 0,
        DELETED_AT = NULL,
        DELETED_BY = NULL
    WHERE CAUHOI = @CAUHOI
      AND IS_DELETED = 1
      AND (@IS_PGV = 1 OR MAGV = @MAGV);

    IF @@ROWCOUNT = 0
        THROW 50507, N'Khong tim thay cau hoi da xoa de phuc hoi hoac ban khong co quyen phuc hoi.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_4_5_BoDe_Sua
    @LOGINNAME NVARCHAR(128),
    @CAUHOI INT,
    @MAMH NCHAR(5),
    @TRINHDO NCHAR(1),
    @NOIDUNG NVARCHAR(200),
    @A NVARCHAR(50),
    @B NVARCHAR(50),
    @C NVARCHAR(50),
    @D NVARCHAR(50),
    @DAP_AN NCHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MAGV NCHAR(8), @IS_PGV BIT = 0;

    SELECT TOP 1
        @MAGV = TK.MAGV,
        @IS_PGV = CASE WHEN TK.ROLE_NAME = N'PGV' THEN 1 ELSE 0 END
    FROM dbo.TaiKhoan AS TK
    INNER JOIN dbo.GiaoVien AS GV ON GV.MAGV = TK.MAGV
    WHERE LOWER(LTRIM(RTRIM(TK.LOGINNAME))) = LOWER(LTRIM(RTRIM(@LOGINNAME)))
      AND TK.IS_ACTIVE = 1
      AND GV.IS_DELETED = 0
      AND TK.ROLE_NAME IN (N'GIANGVIEN', N'PGV');

    IF @MAGV IS NULL
        THROW 50501, N'Khong xac dinh duoc giao vien tu login hien tai.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MonHoc WHERE MAMH = @MAMH AND IS_DELETED = 0)
        THROW 50503, N'Mon hoc khong ton tai hoac da bi xoa.', 1;

    UPDATE dbo.BoDe
    SET MAMH = UPPER(LTRIM(RTRIM(@MAMH))),
        TRINHDO = UPPER(LTRIM(RTRIM(@TRINHDO))),
        NOIDUNG = LTRIM(RTRIM(@NOIDUNG)),
        A = LTRIM(RTRIM(@A)),
        B = LTRIM(RTRIM(@B)),
        C = LTRIM(RTRIM(@C)),
        D = LTRIM(RTRIM(@D)),
        DAP_AN = UPPER(LTRIM(RTRIM(@DAP_AN)))
    WHERE CAUHOI = @CAUHOI
      AND IS_DELETED = 0
      AND (@IS_PGV = 1 OR MAGV = @MAGV);

    IF @@ROWCOUNT = 0
        THROW 50504, N'Khong tim thay cau hoi dang hoat dong de sua hoac ban khong co quyen sua.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_4_5_BoDe_Them
    @LOGINNAME NVARCHAR(128),
    @MAMH NCHAR(5),
    @TRINHDO NCHAR(1),
    @NOIDUNG NVARCHAR(200),
    @A NVARCHAR(50),
    @B NVARCHAR(50),
    @C NVARCHAR(50),
    @D NVARCHAR(50),
    @DAP_AN NCHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MAGV NCHAR(8);

    SELECT TOP 1 @MAGV = TK.MAGV
    FROM dbo.TaiKhoan AS TK
    INNER JOIN dbo.GiaoVien AS GV ON GV.MAGV = TK.MAGV
    WHERE LOWER(LTRIM(RTRIM(TK.LOGINNAME))) = LOWER(LTRIM(RTRIM(@LOGINNAME)))
      AND TK.IS_ACTIVE = 1
      AND GV.IS_DELETED = 0
      AND TK.ROLE_NAME IN (N'GIANGVIEN', N'PGV');

    IF @MAGV IS NULL
        THROW 50501, N'Khong xac dinh duoc giao vien tu login hien tai.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MonHoc WHERE MAMH = @MAMH AND IS_DELETED = 0)
        THROW 50502, N'Mon hoc khong ton tai hoac da bi xoa.', 1;

    INSERT INTO dbo.BoDe (MAMH, TRINHDO, NOIDUNG, A, B, C, D, DAP_AN, MAGV)
    VALUES (UPPER(LTRIM(RTRIM(@MAMH))), UPPER(LTRIM(RTRIM(@TRINHDO))), LTRIM(RTRIM(@NOIDUNG)),
            LTRIM(RTRIM(@A)), LTRIM(RTRIM(@B)), LTRIM(RTRIM(@C)), LTRIM(RTRIM(@D)),
            UPPER(LTRIM(RTRIM(@DAP_AN))), @MAGV);
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_4_5_BoDe_Xoa
    @LOGINNAME NVARCHAR(128),
    @CAUHOI INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MAGV NCHAR(8), @IS_PGV BIT = 0;

    SELECT TOP 1
        @MAGV = TK.MAGV,
        @IS_PGV = CASE WHEN TK.ROLE_NAME = N'PGV' THEN 1 ELSE 0 END
    FROM dbo.TaiKhoan AS TK
    INNER JOIN dbo.GiaoVien AS GV ON GV.MAGV = TK.MAGV
    WHERE LOWER(LTRIM(RTRIM(TK.LOGINNAME))) = LOWER(LTRIM(RTRIM(@LOGINNAME)))
      AND TK.IS_ACTIVE = 1
      AND GV.IS_DELETED = 0
      AND TK.ROLE_NAME IN (N'GIANGVIEN', N'PGV');

    IF @MAGV IS NULL
        THROW 50501, N'Khong xac dinh duoc giao vien tu login hien tai.', 1;

    UPDATE dbo.BoDe
    SET IS_DELETED = 1,
        DELETED_AT = SYSDATETIME(),
        DELETED_BY = @LOGINNAME
    WHERE CAUHOI = @CAUHOI
      AND IS_DELETED = 0
      AND (@IS_PGV = 1 OR MAGV = @MAGV);

    IF @@ROWCOUNT = 0
        THROW 50505, N'Khong tim thay cau hoi dang hoat dong de xoa hoac ban khong co quyen xoa.', 1;
END;
GO

/* =================
   7. Database role permissions
   ================= */
IF DATABASE_PRINCIPAL_ID(N'Sinhvien') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_BatDauThi TO Sinhvien;
    GRANT EXECUTE ON dbo.sp_LuuTamCauTraLoi TO Sinhvien;
    GRANT EXECUTE ON dbo.sp_NopBai TO Sinhvien;
    GRANT EXECUTE ON dbo.sp_TraCuuKetQua TO Sinhvien;
    GRANT SELECT ON dbo.v_4_6_LichThi TO Sinhvien;
    GRANT SELECT ON dbo.v_4_7_SinhVien_ThongTin TO Sinhvien;
    GRANT SELECT ON dbo.v_4_8_KetQuaThi TO Sinhvien;
END;
GO

IF DATABASE_PRINCIPAL_ID(N'Giangvien') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_DangKyThi TO Giangvien;
    GRANT EXECUTE ON dbo.sp_ThiThu_PhatDe TO Giangvien;
    GRANT EXECUTE ON dbo.sp_TraCuuKetQua TO Giangvien;
    GRANT EXECUTE ON dbo.sp_BangDiemMonHoc TO Giangvien;
    GRANT SELECT ON dbo.v_4_6_LichThi TO Giangvien;
    GRANT SELECT ON dbo.v_4_8_KetQuaThi TO Giangvien;
    GRANT SELECT ON dbo.v_4_9_BangDiem_Thi TO Giangvien;
END;
GO

IF DATABASE_PRINCIPAL_ID(N'PGV') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_DangKyThi TO PGV;
    GRANT EXECUTE ON dbo.sp_ThiThu_PhatDe TO PGV;
    GRANT EXECUTE ON dbo.sp_TraCuuKetQua TO PGV;
    GRANT EXECUTE ON dbo.sp_BangDiemMonHoc TO PGV;
    GRANT EXECUTE ON dbo.sp_4_11_TaoTaiKhoan TO PGV;
    GRANT EXECUTE ON dbo.sp_TTN_TuDongNopBaiHetGio TO PGV;
    GRANT SELECT ON dbo.v_4_6_LichThi TO PGV;
    GRANT SELECT ON dbo.v_4_7_SinhVien_ThongTin TO PGV;
    GRANT SELECT ON dbo.v_4_8_KetQuaThi TO PGV;
    GRANT SELECT ON dbo.v_4_9_BangDiem_Thi TO PGV;
    GRANT SELECT ON dbo.AuditLog TO PGV;
END;
GO

/* =================
   8. Direct table access restrictions
   Users must work through views and stored procedures, not base tables.
   ================= */
DECLARE @RoleName SYSNAME;
DECLARE @TableName SYSNAME;
DECLARE @Sql NVARCHAR(MAX);

DECLARE curRole CURSOR LOCAL FAST_FORWARD FOR
    SELECT R.RoleName
    FROM (VALUES (N'Sinhvien'), (N'Giangvien'), (N'PGV')) AS R(RoleName)
    WHERE DATABASE_PRINCIPAL_ID(R.RoleName) IS NOT NULL;

DECLARE curTable CURSOR LOCAL FAST_FORWARD FOR
    SELECT T.TableName
    FROM (VALUES
        (N'MonHoc'),
        (N'Lop'),
        (N'SinhVien'),
        (N'GiaoVien'),
        (N'BoDe'),
        (N'GiaoVien_DangKy'),
        (N'BangDiem'),
        (N'BaiThi'),
        (N'BaiThi_CauTraLoi'),
        (N'BaiThi_ChiTiet'),
        (N'TaiKhoan')
    ) AS T(TableName)
    WHERE OBJECT_ID(N'dbo.' + T.TableName, 'U') IS NOT NULL;

OPEN curRole;
FETCH NEXT FROM curRole INTO @RoleName;

WHILE @@FETCH_STATUS = 0
BEGIN
    OPEN curTable;
    FETCH NEXT FROM curTable INTO @TableName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Sql = N'DENY SELECT, INSERT, UPDATE, DELETE ON OBJECT::dbo.'
            + QUOTENAME(@TableName)
            + N' TO '
            + QUOTENAME(@RoleName)
            + N';';
        EXEC sys.sp_executesql @Sql;

        FETCH NEXT FROM curTable INTO @TableName;
    END;

    CLOSE curTable;
    FETCH NEXT FROM curRole INTO @RoleName;
END;

CLOSE curRole;
DEALLOCATE curRole;
DEALLOCATE curTable;
GO

/* Optional grants for management procedures that exist in the full database script. */
DECLARE @GrantRole SYSNAME;
DECLARE @ProcedureName SYSNAME;
DECLARE @GrantSql NVARCHAR(MAX);

DECLARE curGrant CURSOR LOCAL FAST_FORWARD FOR
    SELECT G.RoleName, G.ProcedureName
    FROM (VALUES
        (N'PGV', N'sp_ThemSinhVien'),
        (N'PGV', N'sp_SuaSinhVien'),
        (N'PGV', N'sp_XoaSinhVien'),
        (N'PGV', N'sp_4_2_MonHoc_DanhSach'),
        (N'PGV', N'sp_4_2_MonHoc_DaXoa'),
        (N'PGV', N'sp_4_2_MonHoc_PhucHoi'),
        (N'PGV', N'sp_4_2_MonHoc_Sua'),
        (N'PGV', N'sp_4_2_MonHoc_Them'),
        (N'PGV', N'sp_4_2_MonHoc_Tim'),
        (N'PGV', N'sp_4_2_MonHoc_Xoa'),
        (N'PGV', N'sp_4_3_Lop_DanhSach'),
        (N'PGV', N'sp_4_3_Lop_DaXoa'),
        (N'PGV', N'sp_4_3_Lop_PhucHoi'),
        (N'PGV', N'sp_4_3_Lop_Sua'),
        (N'PGV', N'sp_4_3_Lop_Them'),
        (N'PGV', N'sp_4_3_Lop_Tim'),
        (N'PGV', N'sp_4_3_Lop_Xoa'),
        (N'PGV', N'sp_4_3_SinhVien_DanhSachTheoLop'),
        (N'PGV', N'sp_4_3_SinhVien_DaXoa'),
        (N'PGV', N'sp_4_3_SinhVien_DaXoaTheoLop'),
        (N'PGV', N'sp_4_3_SinhVien_PhucHoi'),
        (N'PGV', N'sp_4_3_SinhVien_Sua'),
        (N'PGV', N'sp_4_3_SinhVien_Them'),
        (N'PGV', N'sp_4_3_SinhVien_Tim'),
        (N'PGV', N'sp_4_3_SinhVien_Xoa'),
        (N'PGV', N'sp_4_4_GiaoVien_DanhSach'),
        (N'PGV', N'sp_4_4_GiaoVien_DaXoa'),
        (N'PGV', N'sp_4_4_GiaoVien_PhucHoi'),
        (N'PGV', N'sp_4_4_GiaoVien_Sua'),
        (N'PGV', N'sp_4_4_GiaoVien_Them'),
        (N'PGV', N'sp_4_4_GiaoVien_Tim'),
        (N'PGV', N'sp_4_4_GiaoVien_Xoa'),
        (N'PGV', N'sp_4_5_BoDe_DanhSach'),
        (N'PGV', N'sp_4_5_BoDe_DanhSachCuaNguoiDung'),
        (N'PGV', N'sp_4_5_BoDe_DaXoaCuaNguoiDung'),
        (N'PGV', N'sp_4_5_BoDe_PhucHoi'),
        (N'PGV', N'sp_4_5_BoDe_Sua'),
        (N'PGV', N'sp_4_5_BoDe_Them'),
        (N'PGV', N'sp_4_5_BoDe_Tim'),
        (N'PGV', N'sp_4_5_BoDe_Xoa'),
        (N'Giangvien', N'sp_4_5_BoDe_DanhSachCuaNguoiDung'),
        (N'Giangvien', N'sp_4_5_BoDe_DaXoaCuaNguoiDung'),
        (N'Giangvien', N'sp_4_5_BoDe_PhucHoi'),
        (N'Giangvien', N'sp_4_5_BoDe_Sua'),
        (N'Giangvien', N'sp_4_5_BoDe_Them'),
        (N'Giangvien', N'sp_4_5_BoDe_Tim'),
        (N'Giangvien', N'sp_4_5_BoDe_Xoa'),
        (N'Giangvien', N'sp_4_6_DoiMatKhauGiangVien'),
        (N'PGV', N'sp_4_6_DoiMatKhauGiangVien')
    ) AS G(RoleName, ProcedureName)
    WHERE DATABASE_PRINCIPAL_ID(G.RoleName) IS NOT NULL
      AND OBJECT_ID(N'dbo.' + G.ProcedureName, 'P') IS NOT NULL;

OPEN curGrant;
FETCH NEXT FROM curGrant INTO @GrantRole, @ProcedureName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @GrantSql = N'GRANT EXECUTE ON OBJECT::dbo.'
        + QUOTENAME(@ProcedureName)
        + N' TO '
        + QUOTENAME(@GrantRole)
        + N';';
    EXEC sys.sp_executesql @GrantSql;

    FETCH NEXT FROM curGrant INTO @GrantRole, @ProcedureName;
END;

CLOSE curGrant;
DEALLOCATE curGrant;
GO

