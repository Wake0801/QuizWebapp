USE [THI_TRAC_NGHIEM]
GO

/*
    Triggers for the Thi Trac Nghiem project.
    Keep this file separate from db_thitracnghiem.sql so the DBMS-focused
    validation layer can be reviewed and tested independently.
*/

/* 1. Do not delete a class while it still has students. */
IF OBJECT_ID('dbo.trg_Lop_KhongXoaKhiConSinhVien', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Lop_KhongXoaKhiConSinhVien;
GO

/****** Object:  Trigger [dbo].[trg_Lop_KhongXoaKhiConSinhVien] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.trg_Lop_KhongXoaKhiConSinhVien
ON dbo.Lop
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted AS D
        INNER JOIN dbo.SinhVien AS SV ON SV.MALOP = D.MALOP
    )
    BEGIN
        THROW 54001, N'Khong the xoa lop vi van con sinh vien.', 1;
    END;

    DELETE L
    FROM dbo.Lop AS L
    INNER JOIN deleted AS D ON D.MALOP = L.MALOP;
END;
GO

/* 2. Do not delete a student that already has scores or stored exam attempts. */
IF OBJECT_ID('dbo.trg_SinhVien_KhongXoaKhiDaCoDiem', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_SinhVien_KhongXoaKhiDaCoDiem;
GO

/****** Object:  Trigger [dbo].[trg_SinhVien_KhongXoaKhiDaCoDiem] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.trg_SinhVien_KhongXoaKhiDaCoDiem
ON dbo.SinhVien
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted AS D
        INNER JOIN dbo.BangDiem AS BD ON BD.MASV = D.MASV
    )
    OR EXISTS (
        SELECT 1
        FROM deleted AS D
        INNER JOIN dbo.BaiThi AS BT ON BT.MASV = D.MASV
    )
    BEGIN
        THROW 54002, N'Khong the xoa sinh vien da co diem hoac bai thi.', 1;
    END;

    DELETE SV
    FROM dbo.SinhVien AS SV
    INNER JOIN deleted AS D ON D.MASV = SV.MASV;
END;
GO

/* 3. Validate exam registration before saving teacher registration rows. */
IF OBJECT_ID('dbo.trg_GiaoVienDangKy_KiemTraHopLe', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_GiaoVienDangKy_KiemTraHopLe;
GO

/****** Object:  Trigger [dbo].[trg_GiaoVienDangKy_KiemTraHopLe] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.trg_GiaoVienDangKy_KiemTraHopLe
ON dbo.GiaoVien_DangKy
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LAN NOT BETWEEN 1 AND 2
           OR SOCAUTHI NOT BETWEEN 10 AND 100
           OR THOIGIAN NOT BETWEEN 5 AND 60
           OR TRINHDO NOT IN ('A','B','C')
           OR NGAYTHI < GETDATE()
    )
    BEGIN
        THROW 54011, N'Dang ky thi khong hop le: kiem tra ngay thi, trinh do, lan, so cau va thoi gian.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        WHERE dbo.fn_DuSoCauThi(I.MAMH, I.TRINHDO, I.SOCAUTHI) = 0
    )
    BEGIN
        THROW 54012, N'Bo de khong du so cau theo quy tac toi thieu 70% cung trinh do.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        LEFT JOIN dbo.SinhVien AS SV ON SV.MALOP = I.MALOP
        WHERE SV.MASV IS NULL
    )
    BEGIN
        THROW 54013, N'Khong the dang ky thi cho lop chua co sinh vien.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        INNER JOIN dbo.SinhVien AS SV ON SV.MALOP = I.MALOP
        INNER JOIN dbo.BangDiem AS BD
            ON BD.MASV = SV.MASV
           AND BD.MAMH = I.MAMH
           AND BD.LAN = I.LAN
    )
    BEGIN
        THROW 54014, N'Khong the thay doi dang ky thi da phat sinh bang diem.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        INNER JOIN dbo.SinhVien AS SV ON SV.MALOP = I.MALOP
        INNER JOIN dbo.BaiThi AS BT
            ON BT.MASV = SV.MASV
           AND BT.MAMH = I.MAMH
           AND BT.LAN = I.LAN
    )
    BEGIN
        THROW 54015, N'Khong the thay doi dang ky thi da phat sinh bai thi.', 1;
    END;
END;
GO

/* 4. Validate score rows and keep BangDiem consistent with registrations. */
IF OBJECT_ID('dbo.trg_BangDiem_KiemTraHopLe', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_BangDiem_KiemTraHopLe;
GO

/****** Object:  Trigger [dbo].[trg_BangDiem_KiemTraHopLe] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.trg_BangDiem_KiemTraHopLe
ON dbo.BangDiem
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LAN NOT BETWEEN 1 AND 2
           OR DIEM < 0
           OR DIEM > 10
    )
    BEGIN
        THROW 54021, N'Bang diem khong hop le: lan thi phai 1-2 va diem phai tu 0 den 10.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        INNER JOIN dbo.SinhVien AS SV ON SV.MASV = I.MASV
        LEFT JOIN dbo.GiaoVien_DangKy AS GDK
            ON GDK.MALOP = SV.MALOP
           AND GDK.MAMH = I.MAMH
           AND GDK.LAN = I.LAN
        WHERE GDK.MAGV IS NULL
    )
    BEGIN
        THROW 54022, N'Khong the ghi diem neu sinh vien khong co lich thi tuong ung.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        INNER JOIN dbo.SinhVien AS SV ON SV.MASV = I.MASV
        INNER JOIN dbo.GiaoVien_DangKy AS GDK
            ON GDK.MALOP = SV.MALOP
           AND GDK.MAMH = I.MAMH
           AND GDK.LAN = I.LAN
        WHERE I.NGAYTHI < CAST(GDK.NGAYTHI AS DATE)
    )
    BEGIN
        THROW 54023, N'Ngay ghi diem khong duoc truoc ngay thi da dang ky.', 1;
    END;
END;
GO

/* 5. Validate stored answer details of an exam attempt. */
IF OBJECT_ID('dbo.trg_BaiThiCauTraLoi_KiemTraHopLe', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_BaiThiCauTraLoi_KiemTraHopLe;
GO

/****** Object:  Trigger [dbo].[trg_BaiThiCauTraLoi_KiemTraHopLe] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.trg_BaiThiCauTraLoi_KiemTraHopLe
ON dbo.BaiThi_CauTraLoi
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE THUTU <= 0
           OR MAMH IS NULL
           OR TRINHDO_CAU NOT IN ('A','B','C')
           OR NULLIF(LTRIM(RTRIM(NOIDUNG)), N'') IS NULL
           OR DAP_AN_DUNG NOT IN ('A','B','C','D')
           OR (DAP_AN_CHON IS NOT NULL AND DAP_AN_CHON NOT IN ('A','B','C','D'))
    )
    BEGIN
        THROW 54031, N'Chi tiet bai thi khong hop le: thu tu va dap an phai dung quy dinh.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        INNER JOIN dbo.BaiThi AS BT ON BT.MABT = I.MABT
        WHERE BT.TRANGTHAI <> 'DANG_THI'
    )
    BEGIN
        THROW 54032, N'Khong the thay doi cau tra loi cua bai thi da nop hoac da het gio.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted AS I
        INNER JOIN dbo.BaiThi AS BT ON BT.MABT = I.MABT
        WHERE I.MAMH <> BT.MAMH
    )
    BEGIN
        THROW 54033, N'Cau hoi trong bai thi phai thuoc dung mon thi.', 1;
    END;
END;
GO

/* 6. Audit changes on exam registrations. */
IF OBJECT_ID('dbo.trg_Audit_GiaoVienDangKy', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Audit_GiaoVienDangKy;
GO

CREATE TRIGGER dbo.trg_Audit_GiaoVienDangKy
ON dbo.GiaoVien_DangKy
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AuditLog(OBJECT_NAME, ACTION_NAME, KEY_VALUE, DESCRIPTION)
    SELECT
        N'GiaoVien_DangKy',
        CASE
            WHEN I.MALOP IS NOT NULL AND D.MALOP IS NOT NULL THEN N'UPDATE'
            WHEN I.MALOP IS NOT NULL THEN N'INSERT'
            ELSE N'DELETE'
        END,
        CONCAT(RTRIM(COALESCE(I.MALOP, D.MALOP)), N'|', RTRIM(COALESCE(I.MAMH, D.MAMH)), N'|', COALESCE(I.LAN, D.LAN)),
        CONCAT(N'MAGV=', RTRIM(COALESCE(I.MAGV, D.MAGV)), N'; SOCAU=', COALESCE(I.SOCAUTHI, D.SOCAUTHI), N'; THOIGIAN=', COALESCE(I.THOIGIAN, D.THOIGIAN))
    FROM inserted AS I
    FULL OUTER JOIN deleted AS D
        ON I.MALOP = D.MALOP
       AND I.MAMH = D.MAMH
       AND I.LAN = D.LAN;
END;
GO

/* 7. Audit changes on question bank. */
IF OBJECT_ID('dbo.trg_Audit_BoDe', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Audit_BoDe;
GO

CREATE TRIGGER dbo.trg_Audit_BoDe
ON dbo.BoDe
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AuditLog(OBJECT_NAME, ACTION_NAME, KEY_VALUE, DESCRIPTION)
    SELECT
        N'BoDe',
        CASE
            WHEN I.CAUHOI IS NOT NULL AND D.CAUHOI IS NOT NULL THEN N'UPDATE'
            WHEN I.CAUHOI IS NOT NULL THEN N'INSERT'
            ELSE N'DELETE'
        END,
        CONVERT(NVARCHAR(30), COALESCE(I.CAUHOI, D.CAUHOI)),
        CONCAT(N'MAMH=', RTRIM(COALESCE(I.MAMH, D.MAMH)), N'; TRINHDO=', RTRIM(COALESCE(I.TRINHDO, D.TRINHDO)), N'; DAP_AN=', RTRIM(COALESCE(I.DAP_AN, D.DAP_AN)))
    FROM inserted AS I
    FULL OUTER JOIN deleted AS D ON I.CAUHOI = D.CAUHOI;
END;
GO

/* 8. Audit score changes. */
IF OBJECT_ID('dbo.trg_Audit_BangDiem', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Audit_BangDiem;
GO

CREATE TRIGGER dbo.trg_Audit_BangDiem
ON dbo.BangDiem
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AuditLog(OBJECT_NAME, ACTION_NAME, KEY_VALUE, DESCRIPTION)
    SELECT
        N'BangDiem',
        CASE
            WHEN I.MASV IS NOT NULL AND D.MASV IS NOT NULL THEN N'UPDATE'
            WHEN I.MASV IS NOT NULL THEN N'INSERT'
            ELSE N'DELETE'
        END,
        CONCAT(RTRIM(COALESCE(I.MASV, D.MASV)), N'|', RTRIM(COALESCE(I.MAMH, D.MAMH)), N'|', COALESCE(I.LAN, D.LAN)),
        CONCAT(N'DIEM_CU=', COALESCE(CONVERT(NVARCHAR(30), D.DIEM), N'NULL'), N'; DIEM_MOI=', COALESCE(CONVERT(NVARCHAR(30), I.DIEM), N'NULL'))
    FROM inserted AS I
    FULL OUTER JOIN deleted AS D
        ON I.MASV = D.MASV
       AND I.MAMH = D.MAMH
       AND I.LAN = D.LAN;
END;
GO

/* 9. Audit account changes. */
IF OBJECT_ID('dbo.trg_Audit_TaiKhoan', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Audit_TaiKhoan;
GO

CREATE TRIGGER dbo.trg_Audit_TaiKhoan
ON dbo.TaiKhoan
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AuditLog(OBJECT_NAME, ACTION_NAME, KEY_VALUE, DESCRIPTION)
    SELECT
        N'TaiKhoan',
        CASE
            WHEN I.LOGINNAME IS NOT NULL AND D.LOGINNAME IS NOT NULL THEN N'UPDATE'
            WHEN I.LOGINNAME IS NOT NULL THEN N'INSERT'
            ELSE N'DELETE'
        END,
        COALESCE(I.LOGINNAME, D.LOGINNAME),
        CONCAT(N'ROLE=', COALESCE(I.ROLE_NAME, D.ROLE_NAME), N'; MAGV=', RTRIM(COALESCE(I.MAGV, D.MAGV)))
    FROM inserted AS I
    FULL OUTER JOIN deleted AS D ON I.LOGINNAME = D.LOGINNAME;
END;
GO

