USE [THI_TRAC_NGHIEM];
GO

SET NOCOUNT ON;

DECLARE @KetQuaTest TABLE (
    STT INT IDENTITY(1,1) PRIMARY KEY,
    TEN_TEST NVARCHAR(200) NOT NULL,
    KET_QUA NVARCHAR(20) NOT NULL,
    CHI_TIET NVARCHAR(1000) NULL
);

/* 1. Kiem tra function tinh diem */
BEGIN TRY
    IF dbo.fn_TinhDiemThi(8, 10) = 8.00
        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'fn_TinhDiemThi tinh diem theo thang 10', N'PASS', N'8/10 = 8.00');
    ELSE
        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'fn_TinhDiemThi tinh diem theo thang 10', N'FAIL', N'Ket qua khong bang 8.00');
END TRY
BEGIN CATCH
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'fn_TinhDiemThi tinh diem theo thang 10', N'FAIL', ERROR_MESSAGE());
END CATCH;

/* 2. Kiem tra phat de: du so cau va khong trung cau hoi */
BEGIN TRY
    DECLARE @MASV NCHAR(10), @MAMH NCHAR(5), @LAN SMALLINT, @SOCAUTHI SMALLINT;

    SELECT TOP 1
        @MASV = SV.MASV,
        @MAMH = GDK.MAMH,
        @LAN = GDK.LAN,
        @SOCAUTHI = GDK.SOCAUTHI
    FROM dbo.GiaoVien_DangKy AS GDK
    INNER JOIN dbo.SinhVien AS SV ON SV.MALOP = GDK.MALOP AND ISNULL(SV.IS_DELETED, 0) = 0
    WHERE GDK.NGAYTHI <= GETDATE()
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.BangDiem AS BD
          WHERE BD.MASV = SV.MASV
            AND BD.MAMH = GDK.MAMH
            AND BD.LAN = GDK.LAN
      )
    ORDER BY GDK.NGAYTHI DESC, GDK.MALOP, SV.MASV;

    IF @MASV IS NULL
    BEGIN
        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'sp_Thi_PhatDeNgauNhien phat de hop le', N'SKIP', N'Khong co lich thi dang mo va sinh vien chua co diem.');
    END
    ELSE
    BEGIN
        DECLARE @DeThi TABLE (
            CAUHOI INT,
            NOIDUNG NVARCHAR(200),
            A NVARCHAR(50),
            B NVARCHAR(50),
            C NVARCHAR(50),
            D NVARCHAR(50),
            DAP_AN_MOI NCHAR(1),
            THOIGIAN_THI SMALLINT,
            TRINHDO_LICH_THI NCHAR(1),
            TRINHDO_CAU NCHAR(1)
        );

        INSERT INTO @DeThi
        EXEC dbo.sp_Thi_PhatDeNgauNhien @MASV, @MAMH, @LAN;

        IF (SELECT COUNT(*) FROM @DeThi) = @SOCAUTHI
           AND (SELECT COUNT(DISTINCT CAUHOI) FROM @DeThi) = @SOCAUTHI
            INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
            VALUES (N'sp_Thi_PhatDeNgauNhien phat de hop le', N'PASS', CONCAT(N'So cau: ', @SOCAUTHI));
        ELSE
            INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
            VALUES (
                N'sp_Thi_PhatDeNgauNhien phat de hop le',
                N'FAIL',
                CONCAT(N'Tong cau=', (SELECT COUNT(*) FROM @DeThi), N', trung lap=', (SELECT COUNT(*) - COUNT(DISTINCT CAUHOI) FROM @DeThi))
            );
    END
END TRY
BEGIN CATCH
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'sp_Thi_PhatDeNgauNhien phat de hop le', N'FAIL', ERROR_MESSAGE());
END CATCH;

/* 3. Kiem tra trigger chan diem ngoai khoang 0-10 */
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM dbo.BangDiem)
    BEGIN
        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'trg_BangDiem_KiemTraDiem chan diem sai', N'SKIP', N'Chua co dong BangDiem de kiem tra.');
    END
    ELSE
    BEGIN
        BEGIN TRANSACTION;
            UPDATE TOP (1) dbo.BangDiem
            SET DIEM = 11;
        ROLLBACK TRANSACTION;

        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'trg_BangDiem_KiemTraDiem chan diem sai', N'FAIL', N'Cho phep cap nhat diem = 11.');
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'trg_BangDiem_KiemTraDiem chan diem sai', N'PASS', ERROR_MESSAGE());
END CATCH;

/* 4. Kiem tra trigger chan lich thi trong qua khu */
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM dbo.GiaoVien_DangKy)
    BEGIN
        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'trg_GiaoVienDangKy_KiemTra chan ngay thi qua khu', N'SKIP', N'Chua co lich thi de kiem tra.');
    END
    ELSE
    BEGIN
        BEGIN TRANSACTION;
            UPDATE TOP (1) dbo.GiaoVien_DangKy
            SET NGAYTHI = DATEADD(DAY, -1, GETDATE());
        ROLLBACK TRANSACTION;

        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'trg_GiaoVienDangKy_KiemTra chan ngay thi qua khu', N'FAIL', N'Cho phep dat ngay thi trong qua khu.');
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'trg_GiaoVienDangKy_KiemTra chan ngay thi qua khu', N'PASS', ERROR_MESSAGE());
END CATCH;

/* 5. Kiem tra audit doc APP_LOGINNAME tu SESSION_CONTEXT */
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM dbo.TaiKhoan)
    BEGIN
        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'AuditLog ghi login ung dung', N'SKIP', N'Chua co tai khoan de kiem tra.');
    END
    ELSE
    BEGIN
        EXEC sys.sp_set_session_context @key = N'APP_LOGINNAME', @value = N'TEST_AUDIT';

        BEGIN TRANSACTION;
            UPDATE TOP (1) dbo.TaiKhoan
            SET IS_ACTIVE = IS_ACTIVE;

            IF EXISTS (
                SELECT 1
                FROM dbo.AuditLog
                WHERE APP_LOGINNAME = N'TEST_AUDIT'
                  AND OBJECT_NAME = N'TaiKhoan'
            )
                INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
                VALUES (N'AuditLog ghi login ung dung', N'PASS', N'APP_LOGINNAME = TEST_AUDIT');
            ELSE
                INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
                VALUES (N'AuditLog ghi login ung dung', N'FAIL', N'Khong tim thay audit theo APP_LOGINNAME.');
        ROLLBACK TRANSACTION;
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'AuditLog ghi login ung dung', N'FAIL', ERROR_MESSAGE());
END CATCH;

/* 6. Kiem tra cac doi tuong backup/restore va auto submit da duoc cai */
IF OBJECT_ID('dbo.sp_TTN_Backup_Full', 'P') IS NOT NULL
   AND OBJECT_ID('dbo.sp_TTN_Backup_Log', 'P') IS NOT NULL
   AND OBJECT_ID('dbo.sp_TTN_Backup_DanhSach', 'P') IS NOT NULL
   AND OBJECT_ID('dbo.sp_TTN_TuDongNopBaiHetGio', 'P') IS NOT NULL
BEGIN
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'Doi tuong quan tri CSDL bo sung', N'PASS', N'Backup full/log/danh sach va auto submit da ton tai.');
END
ELSE
BEGIN
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'Doi tuong quan tri CSDL bo sung', N'FAIL', N'Thieu procedure backup hoac auto submit.');
END;

/* 7. Kiem tra gioi han quyen truc tiep tren bang */
IF USER_ID(N'U_gv1') IS NULL
BEGIN
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'Chan truy cap truc tiep bang goc', N'SKIP', N'Khong ton tai database user U_gv1.');
END
ELSE
BEGIN
    BEGIN TRY
        EXECUTE AS USER = N'U_gv1';
        EXEC(N'SELECT TOP (1) MASV FROM dbo.SinhVien;');
        REVERT;

        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'Chan truy cap truc tiep bang goc', N'FAIL', N'U_gv1 van SELECT truc tiep duoc dbo.SinhVien.');
    END TRY
    BEGIN CATCH
        REVERT;
        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'Chan truy cap truc tiep bang goc', N'PASS', ERROR_MESSAGE());
    END CATCH;
END;

/* 8. Kiem tra user van doc duoc view duoc cap quyen */
IF USER_ID(N'U_gv1') IS NULL
BEGIN
    INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
    VALUES (N'Cho phep truy cap qua view', N'SKIP', N'Khong ton tai database user U_gv1.');
END
ELSE
BEGIN
    BEGIN TRY
        CREATE TABLE #ViewAccessProbe (DUMMY INT NOT NULL);
        EXECUTE AS USER = N'U_gv1';
        INSERT INTO #ViewAccessProbe(DUMMY)
        EXEC(N'SELECT TOP (1) 1 FROM dbo.v_4_6_LichThi;');
        REVERT;
        DROP TABLE #ViewAccessProbe;

        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'Cho phep truy cap qua view', N'PASS', N'U_gv1 SELECT duoc view v_4_6_LichThi.');
    END TRY
    BEGIN CATCH
        REVERT;
        IF OBJECT_ID('tempdb..#ViewAccessProbe') IS NOT NULL
            DROP TABLE #ViewAccessProbe;
        INSERT INTO @KetQuaTest(TEN_TEST, KET_QUA, CHI_TIET)
        VALUES (N'Cho phep truy cap qua view', N'FAIL', ERROR_MESSAGE());
    END CATCH;
END;

SELECT STT, TEN_TEST, KET_QUA, CHI_TIET
FROM @KetQuaTest
ORDER BY STT;
GO
