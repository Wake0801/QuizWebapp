-- Tạo database
CREATE DATABASE THI_TRAC_NGHIEM;
GO

USE THI_TRAC_NGHIEM;
GO

-- a. Table Lop
CREATE TABLE Lop (
    MALOP NCHAR(15) PRIMARY KEY CHECK (MALOP = UPPER(MALOP)), -- mã lớp, chữ in
    TENLOP NVARCHAR(40) NOT NULL UNIQUE -- tên lớp, duy nhất
);
GO

-- b. Table MonHoc
CREATE TABLE MonHoc (
    MAMH NCHAR(5) PRIMARY KEY CHECK (MAMH = UPPER(MAMH)), -- mã môn, chữ in
    TENMH NVARCHAR(40) NOT NULL UNIQUE -- tên môn, duy nhất
);
GO

-- c. Table SinhVien
CREATE TABLE SinhVien (
    MASV NCHAR(8) PRIMARY KEY, -- mã sinh viên
    HO NVARCHAR(40), -- họ
    TEN NVARCHAR(10), -- tên
    NGAYSINH DATE, -- ngày sinh
    DIACHI NVARCHAR(100), -- địa chỉ
    MALOP NCHAR(15), -- mã lớp

    FOREIGN KEY (MALOP) REFERENCES Lop(MALOP) -- liên kết lớp
);
GO

-- d. Table GiaoVien
CREATE TABLE GiaoVien (
    MAGV NCHAR(8) PRIMARY KEY, -- mã giáo viên
    HO NVARCHAR(40), -- họ
    TEN NVARCHAR(10), -- tên
    SODTLL NCHAR(15), -- số điện thoại
    DIACHI NVARCHAR(50) -- địa chỉ
);
GO

-- e. Table GiaoVien_DangKy
CREATE TABLE GiaoVien_DangKy (
    MAGV NCHAR(8) NOT NULL, -- mã GV
    MALOP NCHAR(15) NOT NULL, -- mã lớp
    MAMH NCHAR(5) NOT NULL, -- mã môn
    TRINHDO NCHAR(1) CHECK (TRINHDO IN ('A','B','C')), -- trình độ
    NGAYTHI DATETIME DEFAULT GETDATE(), -- ngày thi
    LAN SMALLINT CHECK (LAN BETWEEN 1 AND 2), -- lần thi
    SOCAUTHI SMALLINT CHECK (SOCAUTHI BETWEEN 10 AND 100), -- số câu
    THOIGIAN SMALLINT CHECK (THOIGIAN BETWEEN 5 AND 60), -- thời gian (phút)

    PRIMARY KEY (MALOP, MAMH, LAN), -- khóa chính

    FOREIGN KEY (MAGV) REFERENCES GiaoVien(MAGV), -- liên kết GV
    FOREIGN KEY (MALOP) REFERENCES Lop(MALOP), -- liên kết lớp
    FOREIGN KEY (MAMH) REFERENCES MonHoc(MAMH) -- liên kết môn
);
GO

-- f. Table BoDe
CREATE TABLE BoDe (
    CAUHOI INT IDENTITY(1,1) PRIMARY KEY, -- mã câu hỏi tự tăng
    MAMH NCHAR(5), -- mã môn
    TRINHDO CHAR(1) CHECK (TRINHDO IN ('A','B','C')), -- trình độ
    NOIDUNG NVARCHAR(200), -- nội dung câu hỏi
    A NVARCHAR(50), -- đáp án A
    B NVARCHAR(50), -- đáp án B
    C NVARCHAR(50), -- đáp án C
    D NVARCHAR(50), -- đáp án D
    DAP_AN NCHAR(1) CHECK (DAP_AN IN ('A','B','C','D')), -- đáp án đúng
    MAGV NCHAR(8), -- mã GV

    FOREIGN KEY (MAMH) REFERENCES MonHoc(MAMH), -- liên kết môn
    FOREIGN KEY (MAGV) REFERENCES GiaoVien(MAGV) -- liên kết GV
);
GO

-- g. Table BangDiem
CREATE TABLE BangDiem (
    MASV NCHAR(8) NOT NULL, -- mã SV
    MAMH NCHAR(5) NOT NULL, -- mã môn
    LAN SMALLINT CHECK (LAN BETWEEN 1 AND 2), -- lần thi
    NGAYTHI DATE DEFAULT GETDATE(), -- ngày thi
    DIEM FLOAT CHECK (DIEM BETWEEN 0 AND 10), -- điểm

    PRIMARY KEY (MASV, MAMH, LAN), -- khóa chính

    FOREIGN KEY (MASV) REFERENCES SinhVien(MASV), -- liên kết SV
    FOREIGN KEY (MAMH) REFERENCES MonHoc(MAMH) -- liên kết môn
);
GO

/*
    sp_Thi_PhatDeNgauNhien
    - Phat de ngau nhien theo lich thi cua sinh vien.
    - Dam bao quy tac 70/30 theo trinh do.
    - Xao tron thu tu A/B/C/D va tinh lai dap an dung sau khi xao.
*/
IF OBJECT_ID('dbo.sp_Thi_PhatDeNgauNhien', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Thi_PhatDeNgauNhien;
GO

CREATE PROCEDURE dbo.sp_Thi_PhatDeNgauNhien
    @MASV NCHAR(8),
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
        @SoCauChinh INT,
        @SoCauPhu INT,
        @TrinhDoPhu NCHAR(1);

    SELECT @MALOP = SV.MALOP
    FROM dbo.SinhVien AS SV
    WHERE SV.MASV = @MASV;

    IF @MALOP IS NULL
        THROW 50001, N'Ma sinh vien khong ton tai.', 1;

    SELECT
        @TRINHDO = GDK.TRINHDO,
        @SOCAUTHI = GDK.SOCAUTHI,
        @THOIGIAN = GDK.THOIGIAN
    FROM dbo.GiaoVien_DangKy AS GDK
    WHERE GDK.MALOP = @MALOP
      AND GDK.MAMH = @MAMH
      AND GDK.LAN = @LAN;

    IF @TRINHDO IS NULL
        THROW 50002, N'Khong tim thay lich thi hop le cho sinh vien.', 1;

    SET @SoCauChinh = CEILING(0.7 * @SOCAUTHI);
    SET @SoCauPhu = @SOCAUTHI - @SoCauChinh;

    SET @TrinhDoPhu =
        CASE @TRINHDO
            WHEN 'A' THEN 'B'
            WHEN 'B' THEN 'C'
            ELSE NULL
        END;

    IF (
        SELECT COUNT(*)
        FROM dbo.BoDe AS BD
        WHERE BD.MAMH = @MAMH
          AND BD.TRINHDO = @TRINHDO
    ) < @SoCauChinh
    BEGIN
        THROW 50003, N'Khong du cau hoi cung trinh do cho ky thi nay.', 1;
    END;

    IF @SoCauPhu > 0
       AND (
            @TrinhDoPhu IS NULL
            OR (
                SELECT COUNT(*)
                FROM dbo.BoDe AS BD
                WHERE BD.MAMH = @MAMH
                  AND BD.TRINHDO = @TrinhDoPhu
            ) < @SoCauPhu
       )
    BEGIN
        THROW 50004, N'Khong du cau hoi bo sung theo quy tac 70/30.', 1;
    END;

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

    INSERT INTO @DeThi (
        CAUHOI, NOIDUNG, A_GOC, B_GOC, C_GOC, D_GOC, DAP_AN_GOC, DAP_AN_DUNG_NOIDUNG, CAP_DO_GOC
    )
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
        END AS DAP_AN_DUNG_NOIDUNG,
        X.TRINHDO
    FROM (
        SELECT TOP (@SoCauChinh)
            BD.CAUHOI,
            BD.NOIDUNG,
            BD.A,
            BD.B,
            BD.C,
            BD.D,
            BD.DAP_AN,
            BD.TRINHDO
        FROM dbo.BoDe AS BD
        WHERE BD.MAMH = @MAMH
          AND BD.TRINHDO = @TRINHDO
        ORDER BY NEWID()
    ) AS X;

    IF @SoCauPhu > 0
    BEGIN
        INSERT INTO @DeThi (
            CAUHOI, NOIDUNG, A_GOC, B_GOC, C_GOC, D_GOC, DAP_AN_GOC, DAP_AN_DUNG_NOIDUNG, CAP_DO_GOC
        )
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
            END AS DAP_AN_DUNG_NOIDUNG,
            Y.TRINHDO
        FROM (
            SELECT TOP (@SoCauPhu)
                BD.CAUHOI,
                BD.NOIDUNG,
                BD.A,
                BD.B,
                BD.C,
                BD.D,
                BD.DAP_AN,
                BD.TRINHDO
            FROM dbo.BoDe AS BD
            WHERE BD.MAMH = @MAMH
              AND BD.TRINHDO = @TrinhDoPhu
              AND NOT EXISTS (
                    SELECT 1
                    FROM @DeThi AS D
                    WHERE D.CAUHOI = BD.CAUHOI
              )
            ORDER BY NEWID()
        ) AS Y;
    END;

    ;WITH TronDapAn AS (
        SELECT
            D.CAUHOI,
            D.NOIDUNG,
            D.CAP_DO_GOC,
            D.DAP_AN_DUNG_NOIDUNG,
            O.PosMoi,
            O.NoiDungLuaChon
        FROM @DeThi AS D
        CROSS APPLY (
            SELECT
                ROW_NUMBER() OVER (ORDER BY NEWID()) AS PosMoi,
                V.NoiDungLuaChon
            FROM (VALUES (D.A_GOC), (D.B_GOC), (D.C_GOC), (D.D_GOC)) AS V(NoiDungLuaChon)
        ) AS O
    )
    SELECT
        Q.CAUHOI,
        Q.NOIDUNG,
        MAX(CASE WHEN Q.PosMoi = 1 THEN Q.NoiDungLuaChon END) AS A,
        MAX(CASE WHEN Q.PosMoi = 2 THEN Q.NoiDungLuaChon END) AS B,
        MAX(CASE WHEN Q.PosMoi = 3 THEN Q.NoiDungLuaChon END) AS C,
        MAX(CASE WHEN Q.PosMoi = 4 THEN Q.NoiDungLuaChon END) AS D,
        CASE
            WHEN MAX(CASE WHEN Q.PosMoi = 1 THEN Q.NoiDungLuaChon END) = MAX(Q.DAP_AN_DUNG_NOIDUNG) THEN 'A'
            WHEN MAX(CASE WHEN Q.PosMoi = 2 THEN Q.NoiDungLuaChon END) = MAX(Q.DAP_AN_DUNG_NOIDUNG) THEN 'B'
            WHEN MAX(CASE WHEN Q.PosMoi = 3 THEN Q.NoiDungLuaChon END) = MAX(Q.DAP_AN_DUNG_NOIDUNG) THEN 'C'
            ELSE 'D'
        END AS DAP_AN_MOI,
        @THOIGIAN AS THOIGIAN_THI,
        @TRINHDO AS TRINHDO_LICH_THI,
        Q.CAP_DO_GOC AS TRINHDO_CAU
    FROM TronDapAn AS Q
    GROUP BY Q.CAUHOI, Q.NOIDUNG, Q.CAP_DO_GOC
    ORDER BY NEWID();
END;
GO