/*
    ============================================================
    FILE 02 - VIEW, FUNCTION, STORED PROCEDURE, TRIGGER, PHÂN QUYỀN
    Tổng hợp từ db_final.sql và các phần đã triển khai trong thư mục database.
    Chạy sau file 01_db_final_tao_database.sql.
    ============================================================

    MỤC ĐÍCH FILE
    - Dùng để tạo toàn bộ phần nghiệp vụ SQL Server sau khi file 01 đã tạo bảng.
    - File này tập trung vào các thành phần cần thuyết trình trong môn HQT CSDL:
      view, function, stored procedure, trigger, phân quyền, backup/restore và job.
    - Script đã dùng cú pháp DROP + CREATE để tương thích SQL Server 2014.

    NỘI DUNG ĐÃ TRIỂN KHAI
    1. FUNCTIONS
       - fn_4_1_LaPGV: kiểm tra login có thuộc role PGV trong bảng TaiKhoan.
       - fn_4_1_MatKhauDung: kiểm tra mật khẩu tài khoản ứng dụng.
       - fn_4_2_MonHocCoPhatSinh: kiểm tra môn học đã có câu hỏi/lịch thi/điểm.
       - fn_4_3_DemSinhVienTheoLop: đếm sinh viên theo lớp.
       - fn_4_4_DemCauHoiCuaGV: đếm số câu hỏi do một giảng viên soạn.
       - fn_4_5_CoQuyenSuaCauHoi: kiểm tra quyền sửa câu hỏi theo PGV/GV.
       - fn_4_5_DemCauHoiTheoMonTrinhDo: đếm câu hỏi theo môn và trình độ.
       - fn_DuSoCauThi: kiểm tra bộ đề đủ số câu theo quy tắc 70/30.
       - fn_KiemTraDieuKienThi: kiểm tra sinh viên đủ điều kiện thi.
       - fn_LayDiemCaoNhat: lấy điểm cao nhất của sinh viên trong một môn.
       - fn_TinhDiemThi: tính điểm thang 10 từ số câu đúng.

    2. VIEWS
       - vw_4_1_DangNhapGiaoVien: dữ liệu đăng nhập GV/PGV.
       - vw_4_1_DangNhapSinhVien: dữ liệu đăng nhập sinh viên.
       - vw_4_2_MonHoc: danh mục môn học còn hoạt động.
       - vw_4_3_Lop: danh sách lớp kèm số sinh viên.
       - vw_4_3_SinhVien, v_4_7_SinhVien_ThongTin: thông tin sinh viên kèm lớp.
       - v_4_6_LichThi: lịch thi kèm thông tin bộ đề.
       - vw_4_4_GiaoVien: danh sách giáo viên kèm số câu đã soạn.
       - vw_4_5_BoDe: ngân hàng câu hỏi kèm môn học/giảng viên.
       - v_4_8_KetQuaThi: chi tiết kết quả từng bài thi.
       - v_4_9_BangDiem_Thi: bảng điểm kèm điểm chữ.

    3. STORED PROCEDURES
       - Nhóm đăng nhập/tài khoản: sp_4_1_DangNhap,
         sp_4_1_KiemTraQuyenTaoTaiKhoan, sp_4_11_TaoTaiKhoan,
         sp_4_6_DoiMatKhauGiangVien.
       - Nhóm quản lý danh mục: sp_4_2_MonHoc_*, sp_4_3_Lop_*,
         sp_4_3_SinhVien_*, sp_4_4_GiaoVien_*.
       - Nhóm ngân hàng câu hỏi: sp_4_5_BoDe_* có kiểm tra quyền PGV/GV.
       - Nhóm thi trắc nghiệm: sp_DangKyThi, sp_Thi_PhatDeNgauNhien,
         sp_BatDauThi, sp_LuuTamCauTraLoi, sp_NopBai,
         sp_TraCuuKetQua, sp_BangDiemMonHoc, sp_ThiThu_PhatDe.
       - Nhóm quản trị CSDL: sp_TTN_Backup_*, sp_TTN_TuDongNopBaiHetGio.

    4. TRIGGERS
       - Trigger bảo vệ nghiệp vụ: không xóa lớp còn sinh viên, không xóa sinh viên
         đã có bài thi/điểm, kiểm tra lịch thi, kiểm tra điểm và câu trả lời.
       - Trigger audit: ghi lịch sử thay đổi GiaoVien_DangKy, BoDe, BangDiem,
         TaiKhoan vào AuditLog.

    5. PHÂN QUYỀN
       - Tạo/cấp quyền cho role Sinhvien, Giangvien, PGV.
       - Hạn chế truy cập trực tiếp bảng gốc, ưu tiên thao tác qua view/SP.

    6. BACKUP/RESTORE VÀ SQL SERVER AGENT JOB
       - Tạo thủ tục backup full, backup log, liệt kê backup.
       - Tạo thủ tục restore trong master để demo restore full/point-in-time.
       - Tạo job tự động nộp bài hết giờ nếu SQL Server Agent đang chạy.

    LƯU Ý KHI CHẠY
    - Chạy sau file 01_db_final_tao_database.sql.
    - Nếu chạy trên SQL Server 2014, file này dùng DROP + CREATE thay vì
      CREATE OR ALTER.
    - Nếu SQL Server Agent chưa chạy, phần tạo job sẽ được bỏ qua và chỉ in thông báo.
*/

/*
    ============================================================
    TÀI LIỆU CHÚ THÍCH CHI TIẾT CÁC FUNCTION, SP, TRIGGER
    ============================================================

    A. FUNCTIONS

    1. fn_4_1_LaPGV(@LOGINNAME)
       - Kiểm tra một tài khoản trong bảng TaiKhoan có phải PGV hay không.
       - Chỉ trả về 1 khi ROLE_NAME = PGV và tài khoản còn hoạt động.
       - Được dùng trong các SP cần kiểm tra quyền quản trị như tạo tài khoản.

    2. fn_4_1_MatKhauDung(@LOGINNAME, @MATKHAU)
       - Kiểm tra mật khẩu tài khoản ứng dụng của giảng viên/PGV.
       - So khớp LOGINNAME, MATKHAU và IS_ACTIVE.
       - Giúp gom logic kiểm tra mật khẩu tại tầng database.

    3. fn_4_2_MonHocCoPhatSinh(@MAMH)
       - Kiểm tra môn học đã được sử dụng trong câu hỏi, lịch thi, điểm hoặc bài thi chưa.
       - Nếu đã phát sinh thì không nên xóa cứng để tránh mất dữ liệu lịch sử.

    4. fn_4_3_DemSinhVienTheoLop(@MALOP)
       - Đếm số sinh viên còn hoạt động trong một lớp.
       - Dùng cho view danh sách lớp và kiểm tra lớp có sinh viên hay chưa.

    5. fn_4_4_DemCauHoiCuaGV(@MAGV)
       - Đếm số câu hỏi đang hoạt động do một giảng viên biên soạn.
       - Dùng để hiển thị thống kê trong phần quản lý giảng viên.

    6. fn_4_5_CoQuyenSuaCauHoi(@LOGINNAME, @CAUHOI)
       - Kiểm tra quyền sửa/xóa/phục hồi câu hỏi trong ngân hàng đề.
       - PGV được thao tác tất cả câu hỏi.
       - Giảng viên chỉ được thao tác câu hỏi do chính mình tạo.

    7. fn_4_5_DemCauHoiTheoMonTrinhDo(@MAMH, @TRINHDO)
       - Đếm số câu hỏi theo môn học và trình độ A/B/C.
       - Hỗ trợ kiểm tra nhanh ngân hàng đề trước khi đăng ký hoặc phát đề.

    8. fn_DuSoCauThi(@MAMH, @TRINHDO, @SOCAUTHI)
       - Kiểm tra bộ đề có đủ số câu để tạo đề thi hay không.
       - Với trình độ A/B: yêu cầu tối thiểu 70% câu cùng trình độ, phần còn lại có thể lấy trình độ thấp hơn.
       - Với trình độ C: chỉ lấy câu trình độ C.
       - Trigger đăng ký thi gọi function này để chặn tạo lịch thi khi ngân hàng đề chưa đủ.

    9. fn_KiemTraDieuKienThi(@MASV, @MAMH, @LAN)
       - Kiểm tra sinh viên có thuộc lớp đã đăng ký thi môn/lần thi đó không.
       - Kiểm tra sinh viên chưa có điểm ở môn/lần thi tương ứng.
       - Dùng để ngăn thi sai lịch hoặc thi lại lần đã có điểm.

    10. fn_LayDiemCaoNhat(@MASV, @MAMH)
        - Lấy điểm cao nhất của sinh viên trong một môn.
        - Phục vụ tra cứu kết quả học tập hoặc tổng hợp điểm.

    11. fn_TinhDiemThi(@SoCauDung, @TongCau)
        - Tính điểm theo thang 10 từ số câu đúng và tổng số câu.
        - Công thức: số câu đúng / tổng số câu * 10.
        - Được dùng khi nộp bài và chấm điểm để mọi nơi dùng cùng một công thức.

    B. STORED PROCEDURES

    1. Nhóm đăng nhập và tài khoản
       - sp_4_1_DangNhap:
         Xử lý đăng nhập cho PGV, GIANGVIEN và SINHVIEN. Với giảng viên/PGV,
         SP kiểm tra TaiKhoan, role và trạng thái hoạt động. Với sinh viên,
         SP kiểm tra mã sinh viên theo dữ liệu SinhVien. Kết quả trả về SUCCESS,
         MESSAGE và thông tin cần lưu vào session ứng dụng.

       - sp_4_1_KiemTraQuyenTaoTaiKhoan:
         Kiểm tra login hiện tại có quyền tạo tài khoản hay không. Quy tắc là
         chỉ PGV đang hoạt động mới được tạo tài khoản.

       - sp_4_11_TaoTaiKhoan:
         Cho PGV tạo tài khoản ứng dụng cho giảng viên hoặc PGV khác. SP kiểm tra
         người tạo có quyền PGV, login mới không trùng, role hợp lệ và MAGV tồn tại.
         Khi có quyền SQL Server phù hợp, SP còn tạo SQL login/user và gán role DB.

       - sp_4_6_DoiMatKhauGiangVien:
         Đổi mật khẩu cho tài khoản giảng viên/PGV. SP kiểm tra mật khẩu hiện tại,
         độ dài mật khẩu mới, mật khẩu mới khác mật khẩu cũ, sau đó cập nhật
         TaiKhoan.MATKHAU và SQL login nếu login tồn tại.

    2. Nhóm quản lý danh mục
       - sp_4_2_MonHoc_*:
         Quản lý môn học: danh sách, tìm kiếm, thêm, sửa, xóa mềm, xem đã xóa,
         phục hồi. Khi môn học đã phát sinh dữ liệu, hệ thống ưu tiên xóa mềm
         để bảo toàn lịch sử.

       - sp_4_3_Lop_*:
         Quản lý lớp: danh sách, tìm kiếm, thêm, sửa, xóa, phục hồi. Lớp là dữ liệu
         nền để quản lý sinh viên và đăng ký lịch thi.

       - sp_4_3_SinhVien_*:
         Quản lý sinh viên theo lớp: thêm, sửa, tìm, xóa mềm, phục hồi. Sinh viên
         đã có bài thi hoặc điểm cần được bảo vệ để không mất lịch sử thi.

       - sp_4_4_GiaoVien_*:
         Quản lý giảng viên: thêm, sửa, tìm, xóa mềm, phục hồi. Giảng viên có thể
         liên quan đến tài khoản, câu hỏi và lịch thi nên các thao tác xóa cần kiểm tra phát sinh.

    3. Nhóm ngân hàng câu hỏi
       - sp_4_5_BoDe_*:
         Quản lý câu hỏi trắc nghiệm: danh sách, tìm kiếm, thêm, sửa, xóa mềm,
         phục hồi và danh sách theo người dùng. Quy tắc quyền là PGV được thao tác
         toàn bộ, giảng viên chỉ thao tác câu hỏi của mình. SP kiểm tra môn học,
         trình độ, nội dung, đáp án A/B/C/D và đáp án đúng.

    4. Nhóm đăng ký thi và làm bài
       - sp_DangKyThi:
         Tạo hoặc cập nhật lịch thi cho một lớp. SP kiểm tra môn, lớp, giảng viên,
         lần thi, số câu, thời gian và bộ đề có đủ câu. Sau khi ghi dữ liệu, trigger
         trg_GiaoVienDangKy_KiemTraHopLe tiếp tục bảo vệ ở tầng DB.

       - sp_Thi_PhatDeNgauNhien:
         Phát đề ngẫu nhiên theo lịch thi. SP chọn câu không trùng, áp dụng quy tắc
         70/30 theo trình độ, xáo thứ tự đáp án A/B/C/D và tính lại đáp án đúng sau khi xáo.

       - sp_BatDauThi:
         Tạo phiên bài thi chính thức. Nếu sinh viên đã có bài DANG_THI thì trả lại
         bài cũ để tiếp tục làm. Nếu chưa có thì phát đề, tạo BaiThi và lưu từng câu
         vào BaiThi_CauTraLoi.

       - sp_LuuTamCauTraLoi:
         Lưu đáp án sinh viên chọn khi đang làm bài. SP chỉ cho lưu khi bài còn
         trạng thái DANG_THI và chưa quá thời gian kết thúc.

       - sp_NopBai:
         Kết thúc bài thi, đếm số câu đúng, tính điểm bằng fn_TinhDiemThi, cập nhật
         BaiThi và ghi BangDiem. Nếu quá giờ thì trạng thái bài thi là HET_GIO.

       - sp_TTN_TuDongNopBaiHetGio:
         Tự động tìm các bài DANG_THI đã quá KETTHUC_LUC, gọi sp_NopBai để nộp bài.
         Nếu có lỗi thì ghi AuditLog với APP_LOGINNAME = AUTO_TIMEOUT.

       - sp_ThiThu_PhatDe:
         Phát đề thi thử cho giảng viên/PGV. SP không tạo BaiThi và không ghi điểm,
         chỉ dùng để kiểm tra chất lượng ngân hàng đề.

    5. Nhóm kết quả và bảng điểm
       - sp_TraCuuKetQua:
         Trả về hai tập kết quả: thông tin tổng quan bài thi và chi tiết từng câu
         gồm đáp án sinh viên chọn, đáp án đúng.

       - sp_BangDiemMonHoc:
         Lập bảng điểm theo lớp, môn và lần thi. Dữ liệu dùng cho màn hình xem điểm
         và xuất báo cáo bảng điểm.

       - sp_ChamDiem:
         Tính số câu đúng và điểm của bài thi dựa trên BaiThi_CauTraLoi.

    6. Nhóm backup, restore và quản trị
       - sp_TTN_Backup_TaoDevice:
         Tạo backup device theo tên database.

       - sp_TTN_Backup_Full:
         Backup full database, kiểm tra bằng RESTORE VERIFYONLY và ghi lịch sử.

       - sp_TTN_Backup_Log:
         Backup transaction log để phục vụ restore theo thời điểm. Database cần dùng
         recovery model FULL hoặc BULK_LOGGED.

       - sp_TTN_Backup_DanhSach:
         Liệt kê lịch sử backup từ msdb.

       - master.dbo.sp_TTN_Restore_Full:
         Restore full backup, chuyển database sang SINGLE_USER rồi trả về MULTI_USER.

       - master.dbo.sp_TTN_Restore_PointInTime:
         Restore database về một thời điểm bằng full backup và log backup.

       - master.dbo.sp_TTN_Restore_SinhLenh:
         Sinh câu lệnh restore để kiểm tra hoặc demo trước khi chạy restore thật.

    C. TRIGGERS

    1. trg_Lop_KhongXoaKhiConSinhVien
       - Loại: INSTEAD OF DELETE trên bảng Lop.
       - Chặn xóa lớp nếu lớp vẫn còn sinh viên.
       - Nếu lớp không còn sinh viên thì trigger tự thực hiện DELETE.
       - Mục đích là bảo vệ quan hệ lớp - sinh viên.

    2. trg_SinhVien_KhongXoaKhiDaCoDiem
       - Loại: INSTEAD OF DELETE trên bảng SinhVien.
       - Chặn xóa sinh viên đã có BangDiem hoặc BaiThi.
       - Nếu sinh viên chưa phát sinh dữ liệu thi thì trigger mới cho xóa.
       - Mục đích là giữ lịch sử bài thi và điểm.

    3. trg_GiaoVienDangKy_KiemTraHopLe
       - Loại: AFTER INSERT, UPDATE trên bảng GiaoVien_DangKy.
       - Kiểm tra lần thi chỉ được 1 hoặc 2.
       - Kiểm tra số câu từ 10 đến 100, thời gian từ 5 đến 60 phút.
       - Kiểm tra trình độ chỉ thuộc A/B/C và ngày thi không nằm trong quá khứ.
       - Gọi fn_DuSoCauThi để đảm bảo bộ đề đủ câu theo quy tắc 70/30.
       - Không cho đăng ký thi cho lớp chưa có sinh viên.
       - Không cho sửa lịch thi nếu đã phát sinh BangDiem hoặc BaiThi.
       - Đây là trigger bảo vệ nghiệp vụ đăng ký thi quan trọng nhất.

    4. trg_BangDiem_KiemTraHopLe
       - Loại: AFTER INSERT, UPDATE trên bảng BangDiem.
       - Kiểm tra điểm nằm trong khoảng 0 đến 10.
       - Kiểm tra lần thi chỉ được 1 hoặc 2.
       - Chỉ cho ghi điểm khi sinh viên có lịch thi tương ứng theo lớp, môn và lần thi.
       - Không cho ngày ghi điểm trước ngày thi đã đăng ký.

    5. trg_BaiThiCauTraLoi_KiemTraHopLe
       - Loại: AFTER INSERT, UPDATE trên bảng BaiThi_CauTraLoi.
       - Kiểm tra thứ tự câu, môn học, trình độ câu, nội dung và đáp án hợp lệ.
       - Không cho sửa câu trả lời nếu bài thi đã nộp hoặc đã hết giờ.
       - Kiểm tra câu hỏi trong bài thi phải thuộc đúng môn của BaiThi.

    6. trg_Audit_GiaoVienDangKy
       - Ghi AuditLog khi thêm, sửa hoặc xóa lịch thi.
       - Audit lưu khóa MALOP|MAMH|LAN, giảng viên đăng ký, số câu và thời gian.
       - Dùng để truy vết thay đổi lịch thi.

    7. trg_Audit_BoDe
       - Ghi AuditLog khi thêm, sửa hoặc xóa câu hỏi trong BoDe.
       - Audit lưu mã câu hỏi, môn, trình độ và đáp án đúng.
       - Dùng để truy vết thay đổi ngân hàng câu hỏi.

    8. trg_Audit_BangDiem
       - Ghi AuditLog khi thêm, sửa hoặc xóa bảng điểm.
       - Audit lưu MASV|MAMH|LAN, điểm cũ và điểm mới.
       - Dùng để giải trình mọi thay đổi điểm.

    9. trg_Audit_TaiKhoan
       - Ghi AuditLog khi thêm, sửa hoặc xóa tài khoản.
       - Audit lưu LOGINNAME, role và MAGV liên quan.
       - Dùng để truy vết việc quản lý tài khoản giảng viên/PGV.
*/

USE [THI_TRAC_NGHIEM]
GO

/* ============================================================
   PHẦN 1. FUNCTIONS
   ============================================================ */

-- FUNCTION: kiểm tra login ứng dụng có phải PGV hay không.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_4_1_LaPGV]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_4_1_LaPGV];
GO

CREATE FUNCTION [dbo].[fn_4_1_LaPGV]
(
    @LOGINNAME NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @KQ BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM dbo.TaiKhoan
        WHERE LOGINNAME = @LOGINNAME
          AND ROLE_NAME = N'PGV'
          AND IS_ACTIVE = 1
    )
        SET @KQ = 1;

    RETURN @KQ;
END;
GO

-- FUNCTION: kiểm tra mật khẩu tài khoản ứng dụng có đúng không.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =========================================================
   3. FUNCTION
   ========================================================= */

IF OBJECT_ID(N'[dbo].[fn_4_1_MatKhauDung]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_4_1_MatKhauDung];
GO

CREATE FUNCTION [dbo].[fn_4_1_MatKhauDung]
(
    @LOGINNAME NVARCHAR(50),
    @MATKHAU NVARCHAR(255)
)
RETURNS BIT
AS
BEGIN
    DECLARE @KQ BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM dbo.TaiKhoan
        WHERE LOGINNAME = @LOGINNAME
          AND MATKHAU = @MATKHAU
          AND IS_ACTIVE = 1
    )
        SET @KQ = 1;

    RETURN @KQ;
END;
GO

-- FUNCTION: kiểm tra môn học đã phát sinh câu hỏi, lịch thi hoặc bảng điểm.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_4_2_MonHocCoPhatSinh]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_4_2_MonHocCoPhatSinh];
GO

CREATE FUNCTION [dbo].[fn_4_2_MonHocCoPhatSinh]
(
    @MAMH NCHAR(5)
)
RETURNS BIT
AS
BEGIN
    DECLARE @KQ BIT = 0;

    IF EXISTS (SELECT 1 FROM dbo.BoDe WHERE MAMH = @MAMH)
       OR EXISTS (SELECT 1 FROM dbo.GiaoVien_DangKy WHERE MAMH = @MAMH)
       OR EXISTS (SELECT 1 FROM dbo.BangDiem WHERE MAMH = @MAMH)
        SET @KQ = 1;

    RETURN @KQ;
END;
GO

-- FUNCTION: đếm số sinh viên theo lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_4_3_DemSinhVienTheoLop]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_4_3_DemSinhVienTheoLop];
GO

CREATE FUNCTION [dbo].[fn_4_3_DemSinhVienTheoLop]
(
    @MALOP NCHAR(15)
)
RETURNS INT
AS
BEGIN
    DECLARE @SL INT;

    SELECT @SL = COUNT(*)
    FROM dbo.SinhVien
    WHERE MALOP = @MALOP;

    RETURN ISNULL(@SL, 0);
END;
GO

-- FUNCTION: đếm số câu hỏi do một giáo viên soạn.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_4_4_DemCauHoiCuaGV]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_4_4_DemCauHoiCuaGV];
GO

CREATE FUNCTION [dbo].[fn_4_4_DemCauHoiCuaGV]
(
    @MAGV NCHAR(8)
)
RETURNS INT
AS
BEGIN
    DECLARE @SL INT;

    SELECT @SL = COUNT(*)
    FROM dbo.BoDe
    WHERE MAGV = @MAGV;

    RETURN ISNULL(@SL, 0);
END;
GO

-- FUNCTION: kiểm tra quyền sửa câu hỏi theo login/giáo viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_4_5_CoQuyenSuaCauHoi]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_4_5_CoQuyenSuaCauHoi];
GO

CREATE FUNCTION [dbo].[fn_4_5_CoQuyenSuaCauHoi]
(
    @LOGINNAME NVARCHAR(50),
    @CAUHOI INT
)
RETURNS BIT
AS
BEGIN
    DECLARE
        @KQ BIT = 0,
        @ROLE NVARCHAR(20),
        @MAGV NCHAR(8);

    SELECT
        @ROLE = ROLE_NAME,
        @MAGV = MAGV
    FROM dbo.TaiKhoan
    WHERE LOGINNAME = @LOGINNAME
      AND IS_ACTIVE = 1;

    IF @ROLE = N'PGV'
        SET @KQ = 1;

    IF @ROLE = N'GIANGVIEN'
       AND EXISTS (
            SELECT 1
            FROM dbo.BoDe
            WHERE CAUHOI = @CAUHOI
              AND MAGV = @MAGV
       )
        SET @KQ = 1;

    RETURN @KQ;
END;
GO

-- FUNCTION: đếm số câu hỏi theo môn và trình độ.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_4_5_DemCauHoiTheoMonTrinhDo]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_4_5_DemCauHoiTheoMonTrinhDo];
GO

CREATE FUNCTION [dbo].[fn_4_5_DemCauHoiTheoMonTrinhDo]
(
    @MAMH NCHAR(5),
    @TRINHDO CHAR(1)
)
RETURNS INT
AS
BEGIN
    DECLARE @SL INT;

    SELECT @SL = COUNT(*)
    FROM dbo.BoDe
    WHERE MAMH = @MAMH
      AND TRINHDO = @TRINHDO;

    RETURN ISNULL(@SL, 0);
END;
GO

-- FUNCTION: kiểm tra bộ đề đủ câu theo quy tắc 70/30.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_DuSoCauThi]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_DuSoCauThi];
GO

CREATE FUNCTION [dbo].[fn_DuSoCauThi] (
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

-- FUNCTION: kiểm tra sinh viên đủ điều kiện thi môn/lần đã chọn.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_KiemTraDieuKienThi]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_KiemTraDieuKienThi];
GO

CREATE FUNCTION [dbo].[fn_KiemTraDieuKienThi] (
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

-- FUNCTION: lấy điểm cao nhất của sinh viên trong một môn.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_LayDiemCaoNhat]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_LayDiemCaoNhat];
GO

CREATE FUNCTION [dbo].[fn_LayDiemCaoNhat] (
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

-- FUNCTION: tính điểm thang 10 từ số câu đúng và tổng số câu.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[fn_TinhDiemThi]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_TinhDiemThi];
GO

CREATE FUNCTION [dbo].[fn_TinhDiemThi] (
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

/* ============================================================
   PHẦN 2. VIEWS
   ============================================================ */

-- VIEW 4.1: dữ liệu đăng nhập cho PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =========================================================
   2. VIEW
   ========================================================= */

/* 4.1 - Dang nhap GV / PGV */
IF OBJECT_ID(N'[dbo].[vw_4_1_DangNhapGiaoVien]', N'V') IS NOT NULL
    DROP VIEW [dbo].[vw_4_1_DangNhapGiaoVien];
GO

CREATE VIEW [dbo].[vw_4_1_DangNhapGiaoVien]
AS
SELECT
    TK.LOGINNAME,
    TK.MATKHAU,
    TK.ROLE_NAME,
    RTRIM(TK.MAGV) AS MAGV,
    LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN,
    TK.IS_ACTIVE
FROM dbo.TaiKhoan TK
LEFT JOIN dbo.GiaoVien GV ON TK.MAGV = GV.MAGV
WHERE TK.ROLE_NAME IN (N'GIANGVIEN', N'PGV');
GO

-- VIEW 4.1: dữ liệu đăng nhập cho SINHVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 4.1 - Dang nhap sinh vien: lay tu bang SinhVien, KHONG lay TaiKhoan */
IF OBJECT_ID(N'[dbo].[vw_4_1_DangNhapSinhVien]', N'V') IS NOT NULL
    DROP VIEW [dbo].[vw_4_1_DangNhapSinhVien];
GO

CREATE VIEW [dbo].[vw_4_1_DangNhapSinhVien]
AS
SELECT
    RTRIM(SV.MASV) AS MASV,
    LTRIM(RTRIM(ISNULL(SV.HO, N'') + N' ' + ISNULL(SV.TEN, N''))) AS HOTEN,
    RTRIM(SV.MALOP) AS MALOP,
    L.TENLOP,
    N'SINHVIEN' AS ROLE_NAME
FROM dbo.SinhVien SV
LEFT JOIN dbo.Lop L ON SV.MALOP = L.MALOP;
GO

-- VIEW 4.2: danh mục môn học.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 4.2 */
IF OBJECT_ID(N'[dbo].[vw_4_2_MonHoc]', N'V') IS NOT NULL
    DROP VIEW [dbo].[vw_4_2_MonHoc];
GO

CREATE VIEW [dbo].[vw_4_2_MonHoc]
AS
SELECT
    RTRIM(MAMH) AS MAMH,
    TENMH
FROM dbo.MonHoc;
GO

-- VIEW 4.3: danh sách lớp kèm số sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 4.3 - Lop */
IF OBJECT_ID(N'[dbo].[vw_4_3_Lop]', N'V') IS NOT NULL
    DROP VIEW [dbo].[vw_4_3_Lop];
GO

CREATE VIEW [dbo].[vw_4_3_Lop]
AS
SELECT
    RTRIM(L.MALOP) AS MALOP,
    L.TENLOP,
    COUNT(SV.MASV) AS SO_SINH_VIEN
FROM dbo.Lop L
LEFT JOIN dbo.SinhVien SV ON L.MALOP = SV.MALOP
GROUP BY L.MALOP, L.TENLOP;
GO

-- VIEW 4.7: thông tin sinh viên kèm tên lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[v_4_7_SinhVien_ThongTin]', N'V') IS NOT NULL
    DROP VIEW [dbo].[v_4_7_SinhVien_ThongTin];
GO

CREATE VIEW [dbo].[v_4_7_SinhVien_ThongTin]
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

-- VIEW 4.3: danh sách sinh viên kèm lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 4.3 - Sinh vien */
IF OBJECT_ID(N'[dbo].[vw_4_3_SinhVien]', N'V') IS NOT NULL
    DROP VIEW [dbo].[vw_4_3_SinhVien];
GO

CREATE VIEW [dbo].[vw_4_3_SinhVien]
AS
SELECT
    RTRIM(SV.MASV) AS MASV,
    SV.HO,
    SV.TEN,
    LTRIM(RTRIM(ISNULL(SV.HO, N'') + N' ' + ISNULL(SV.TEN, N''))) AS HOTEN,
    SV.NGAYSINH,
    SV.DIACHI,
    RTRIM(SV.MALOP) AS MALOP,
    L.TENLOP
FROM dbo.SinhVien SV
LEFT JOIN dbo.Lop L ON SV.MALOP = L.MALOP;
GO

-- VIEW 4.6: lịch thi kèm số câu hiện có trong bộ đề.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[v_4_6_LichThi]', N'V') IS NOT NULL
    DROP VIEW [dbo].[v_4_6_LichThi];
GO

CREATE VIEW [dbo].[v_4_6_LichThi]
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

-- VIEW 4.4: danh sách giáo viên kèm số câu đã soạn.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 4.4 */
IF OBJECT_ID(N'[dbo].[vw_4_4_GiaoVien]', N'V') IS NOT NULL
    DROP VIEW [dbo].[vw_4_4_GiaoVien];
GO

CREATE VIEW [dbo].[vw_4_4_GiaoVien]
AS
SELECT
    RTRIM(GV.MAGV) AS MAGV,
    GV.HO,
    GV.TEN,
    LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN,
    GV.SODTLL,
    GV.DIACHI,
    COUNT(BD.CAUHOI) AS SO_CAU_DA_SOAN
FROM dbo.GiaoVien GV
LEFT JOIN dbo.BoDe BD ON GV.MAGV = BD.MAGV
GROUP BY GV.MAGV, GV.HO, GV.TEN, GV.SODTLL, GV.DIACHI;
GO

-- VIEW 4.8: xem lại chi tiết kết quả và từng câu đã thi.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[v_4_8_KetQuaThi]', N'V') IS NOT NULL
    DROP VIEW [dbo].[v_4_8_KetQuaThi];
GO

CREATE VIEW [dbo].[v_4_8_KetQuaThi]
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

-- VIEW 4.5: ngân hàng câu hỏi kèm môn học và giáo viên soạn.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 4.5 */
IF OBJECT_ID(N'[dbo].[vw_4_5_BoDe]', N'V') IS NOT NULL
    DROP VIEW [dbo].[vw_4_5_BoDe];
GO

CREATE VIEW [dbo].[vw_4_5_BoDe]
AS
SELECT
    BD.CAUHOI,
    RTRIM(BD.MAMH) AS MAMH,
    MH.TENMH,
    BD.TRINHDO,
    BD.NOIDUNG,
    BD.A,
    BD.B,
    BD.C,
    BD.D,
    BD.DAP_AN,
    RTRIM(BD.MAGV) AS MAGV,
    LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN_GV
FROM dbo.BoDe BD
JOIN dbo.MonHoc MH ON BD.MAMH = MH.MAMH
JOIN dbo.GiaoVien GV ON BD.MAGV = GV.MAGV;
GO

-- VIEW 4.9: bảng điểm thi kèm điểm chữ.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[v_4_9_BangDiem_Thi]', N'V') IS NOT NULL
    DROP VIEW [dbo].[v_4_9_BangDiem_Thi];
GO

CREATE VIEW [dbo].[v_4_9_BangDiem_Thi]
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

/* ============================================================
   PHẦN 3. STORED PROCEDURES
   ============================================================ */

-- SP 4.1: xử lý đăng nhập cho PGV, GIANGVIEN và SINHVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =========================================================
   5. STORED PROCEDURE
   ========================================================= */

/* -------------------- 4.1 DANG NHAP -------------------- */
IF OBJECT_ID(N'[dbo].[sp_4_1_DangNhap]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_1_DangNhap];
GO

CREATE PROCEDURE [dbo].[sp_4_1_DangNhap]
    @VAITRO NVARCHAR(20),
    @LOGIN_OR_MASV NVARCHAR(50),
    @MATKHAU NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SET @VAITRO = UPPER(LTRIM(RTRIM(ISNULL(@VAITRO, N''))));
    SET @LOGIN_OR_MASV = UPPER(LTRIM(RTRIM(ISNULL(@LOGIN_OR_MASV, N''))));
    SET @MATKHAU = LTRIM(RTRIM(ISNULL(@MATKHAU, N'')));

    /* PGV / GIANGVIEN: kiem tra trong TaiKhoan */
    IF @VAITRO IN (N'PGV', N'GIANGVIEN')
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM dbo.vw_4_1_DangNhapGiaoVien
            WHERE UPPER(LOGINNAME) = @LOGIN_OR_MASV
              AND MATKHAU = @MATKHAU
              AND ROLE_NAME = @VAITRO
              AND IS_ACTIVE = 1
        )
        BEGIN
            SELECT
                CAST(1 AS BIT) AS SUCCESS,
                N'Đăng nhập thành công.' AS MESSAGE,
                LOGINNAME,
                ROLE_NAME,
                MAGV,
                HOTEN
            FROM dbo.vw_4_1_DangNhapGiaoVien
            WHERE UPPER(LOGINNAME) = @LOGIN_OR_MASV
              AND MATKHAU = @MATKHAU
              AND ROLE_NAME = @VAITRO
              AND IS_ACTIVE = 1;
            RETURN;
        END;

        SELECT
            CAST(0 AS BIT) AS SUCCESS,
            N'Login hoặc password không đúng với vai trò đã chọn.' AS MESSAGE;
        RETURN;
    END;

    /* SINHVIEN: KHONG dung TaiKhoan. MASV + password mac dinh 123456 */
    IF @VAITRO = N'SINHVIEN'
    BEGIN
        IF @MATKHAU <> N'123456'
        BEGIN
            SELECT
                CAST(0 AS BIT) AS SUCCESS,
                N'Mật khẩu sinh viên không đúng.' AS MESSAGE;
            RETURN;
        END;

        IF EXISTS (
            SELECT 1
            FROM dbo.vw_4_1_DangNhapSinhVien
            WHERE UPPER(MASV) = @LOGIN_OR_MASV
        )
        BEGIN
            SELECT
                CAST(1 AS BIT) AS SUCCESS,
                N'Đăng nhập thành công.' AS MESSAGE,
                N'SINHVIEN' AS ROLE_NAME,
                MASV,
                HOTEN,
                MALOP,
                TENLOP
            FROM dbo.vw_4_1_DangNhapSinhVien
            WHERE UPPER(MASV) = @LOGIN_OR_MASV;
            RETURN;
        END;

        SELECT
            CAST(0 AS BIT) AS SUCCESS,
            N'Mã sinh viên không tồn tại.' AS MESSAGE;
        RETURN;
    END;

    SELECT
        CAST(0 AS BIT) AS SUCCESS,
        N'Vai trò đăng nhập không hợp lệ.' AS MESSAGE;
END;
GO

-- SP 4.1: kiểm tra tài khoản có quyền tạo tài khoản hay không.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_1_KiemTraQuyenTaoTaiKhoan]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_1_KiemTraQuyenTaoTaiKhoan];
GO

CREATE PROCEDURE [dbo].[sp_4_1_KiemTraQuyenTaoTaiKhoan]
    @LOGINNAME NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF dbo.fn_4_1_LaPGV(@LOGINNAME) = 1
    BEGIN
        SELECT
            CAST(1 AS BIT) AS CAN_CREATE_ACCOUNT,
            N'Tài khoản có quyền tạo tài khoản.' AS MESSAGE;
        RETURN;
    END;

    SELECT
        CAST(0 AS BIT) AS CAN_CREATE_ACCOUNT,
        N'Chỉ giảng viên có role PGV mới được tạo tài khoản.' AS MESSAGE;
END;
GO

-- SP 4.11: PGV tạo tài khoản ứng dụng và SQL login/user.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_11_TaoTaiKhoan]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_11_TaoTaiKhoan];
GO

CREATE PROCEDURE [dbo].[sp_4_11_TaoTaiKhoan]
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

-- SP 4.2: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi môn học.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_2_MonHoc_DanhSach]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_2_MonHoc_DanhSach];
GO

CREATE PROCEDURE [dbo].[sp_4_2_MonHoc_DanhSach]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MAMH, TENMH
    FROM dbo.MonHoc
    WHERE IS_DELETED = 0
    ORDER BY MAMH;
END;
GO

-- SP 4.2: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi môn học.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_2_MonHoc_DaXoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_2_MonHoc_DaXoa];
GO

CREATE PROCEDURE [dbo].[sp_4_2_MonHoc_DaXoa]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MAMH, TENMH, DELETED_AT, DELETED_BY
    FROM dbo.MonHoc
    WHERE IS_DELETED = 1
    ORDER BY DELETED_AT DESC;
END;
GO

-- SP 4.2: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi môn học.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_2_MonHoc_PhucHoi]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_2_MonHoc_PhucHoi];
GO

CREATE PROCEDURE [dbo].[sp_4_2_MonHoc_PhucHoi]
    @MAMH NCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MAMH = UPPER(LTRIM(RTRIM(@MAMH)));

    UPDATE dbo.MonHoc
    SET IS_DELETED = 0,
        DELETED_AT = NULL,
        DELETED_BY = NULL
    WHERE MAMH = @MAMH AND IS_DELETED = 1;

    IF @@ROWCOUNT = 0
        THROW 50204, N'Khong tim thay mon hoc da xoa de phuc hoi.', 1;
END;
GO

-- SP 4.2: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi môn học.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_2_MonHoc_Sua]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_2_MonHoc_Sua];
GO

CREATE PROCEDURE [dbo].[sp_4_2_MonHoc_Sua]
    @MAMH NCHAR(5),
    @TENMH NVARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MAMH = UPPER(LTRIM(RTRIM(@MAMH)));
    SET @TENMH = LTRIM(RTRIM(@TENMH));

    UPDATE dbo.MonHoc
    SET TENMH = @TENMH
    WHERE MAMH = @MAMH AND IS_DELETED = 0;

    IF @@ROWCOUNT = 0
        THROW 50202, N'Khong tim thay mon hoc dang hoat dong de sua.', 1;
END;
GO

-- SP 4.2: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi môn học.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_2_MonHoc_Them]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_2_MonHoc_Them];
GO

CREATE PROCEDURE [dbo].[sp_4_2_MonHoc_Them]
    @MAMH NCHAR(5),
    @TENMH NVARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MAMH = UPPER(LTRIM(RTRIM(@MAMH)));
    SET @TENMH = LTRIM(RTRIM(@TENMH));

    IF EXISTS (SELECT 1 FROM dbo.MonHoc WHERE MAMH = @MAMH OR TENMH = @TENMH)
        THROW 50201, N'Mon hoc da ton tai. Neu da xoa, hay dung Phuc hoi.', 1;

    INSERT INTO dbo.MonHoc (MAMH, TENMH) VALUES (@MAMH, @TENMH);
END;
GO

-- SP 4.2: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi môn học.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_2_MonHoc_Tim]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_2_MonHoc_Tim];
GO

CREATE PROCEDURE [dbo].[sp_4_2_MonHoc_Tim]
    @KEYWORD NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET @KEYWORD = N'%' + LTRIM(RTRIM(ISNULL(@KEYWORD, N''))) + N'%';

    SELECT MAMH, TENMH
    FROM dbo.MonHoc
    WHERE IS_DELETED = 0
      AND (MAMH LIKE @KEYWORD OR TENMH LIKE @KEYWORD)
    ORDER BY MAMH;
END;
GO

-- SP 4.2: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi môn học.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_2_MonHoc_Xoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_2_MonHoc_Xoa];
GO

CREATE PROCEDURE [dbo].[sp_4_2_MonHoc_Xoa]
    @MAMH NCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MAMH = UPPER(LTRIM(RTRIM(@MAMH)));

    UPDATE dbo.MonHoc
    SET IS_DELETED = 1,
        DELETED_AT = SYSDATETIME(),
        DELETED_BY = ORIGINAL_LOGIN()
    WHERE MAMH = @MAMH AND IS_DELETED = 0;

    IF @@ROWCOUNT = 0
        THROW 50203, N'Khong tim thay mon hoc dang hoat dong de xoa.', 1;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_Lop_DanhSach]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_Lop_DanhSach];
GO

CREATE PROCEDURE [dbo].[sp_4_3_Lop_DanhSach]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT L.MALOP, L.TENLOP,
           COUNT(CASE WHEN SV.IS_DELETED = 0 THEN 1 END) AS SO_SINH_VIEN
    FROM dbo.Lop AS L
    LEFT JOIN dbo.SinhVien AS SV ON SV.MALOP = L.MALOP
    WHERE L.IS_DELETED = 0
    GROUP BY L.MALOP, L.TENLOP
    ORDER BY L.MALOP;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_Lop_DaXoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_Lop_DaXoa];
GO

CREATE PROCEDURE [dbo].[sp_4_3_Lop_DaXoa]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MALOP, TENLOP, DELETED_AT, DELETED_BY
    FROM dbo.Lop
    WHERE IS_DELETED = 1
    ORDER BY DELETED_AT DESC;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_Lop_PhucHoi]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_Lop_PhucHoi];
GO

CREATE PROCEDURE [dbo].[sp_4_3_Lop_PhucHoi]
    @MALOP NCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MALOP = UPPER(LTRIM(RTRIM(@MALOP)));

    UPDATE dbo.Lop
    SET IS_DELETED = 0,
        DELETED_AT = NULL,
        DELETED_BY = NULL
    WHERE MALOP = @MALOP AND IS_DELETED = 1;

    IF @@ROWCOUNT = 0
        THROW 50305, N'Khong tim thay lop da xoa de phuc hoi.', 1;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_Lop_Sua]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_Lop_Sua];
GO

CREATE PROCEDURE [dbo].[sp_4_3_Lop_Sua]
    @MALOP NCHAR(15),
    @TENLOP NVARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MALOP = UPPER(LTRIM(RTRIM(@MALOP)));
    SET @TENLOP = LTRIM(RTRIM(@TENLOP));

    UPDATE dbo.Lop
    SET TENLOP = @TENLOP
    WHERE MALOP = @MALOP AND IS_DELETED = 0;

    IF @@ROWCOUNT = 0
        THROW 50302, N'Khong tim thay lop dang hoat dong de sua.', 1;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_Lop_Them]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_Lop_Them];
GO

CREATE PROCEDURE [dbo].[sp_4_3_Lop_Them]
    @MALOP NCHAR(15),
    @TENLOP NVARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MALOP = UPPER(LTRIM(RTRIM(@MALOP)));
    SET @TENLOP = LTRIM(RTRIM(@TENLOP));

    IF EXISTS (SELECT 1 FROM dbo.Lop WHERE MALOP = @MALOP OR TENLOP = @TENLOP)
        THROW 50301, N'Lop da ton tai. Neu da xoa, hay dung Phuc hoi.', 1;

    INSERT INTO dbo.Lop (MALOP, TENLOP) VALUES (@MALOP, @TENLOP);
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_Lop_Tim]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_Lop_Tim];
GO

CREATE PROCEDURE [dbo].[sp_4_3_Lop_Tim]
    @KEYWORD NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET @KEYWORD = N'%' + LTRIM(RTRIM(ISNULL(@KEYWORD, N''))) + N'%';

    SELECT L.MALOP, L.TENLOP,
           COUNT(CASE WHEN SV.IS_DELETED = 0 THEN 1 END) AS SO_SINH_VIEN
    FROM dbo.Lop AS L
    LEFT JOIN dbo.SinhVien AS SV ON SV.MALOP = L.MALOP
    WHERE L.IS_DELETED = 0
      AND (L.MALOP LIKE @KEYWORD OR L.TENLOP LIKE @KEYWORD)
    GROUP BY L.MALOP, L.TENLOP
    ORDER BY L.MALOP;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi lớp.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_Lop_Xoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_Lop_Xoa];
GO

CREATE PROCEDURE [dbo].[sp_4_3_Lop_Xoa]
    @MALOP NCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MALOP = UPPER(LTRIM(RTRIM(@MALOP)));

    IF EXISTS (SELECT 1 FROM dbo.SinhVien WHERE MALOP = @MALOP AND IS_DELETED = 0)
        THROW 50303, N'Lop con sinh vien dang hoat dong. Hay xoa sinh vien truoc.', 1;

    UPDATE dbo.Lop
    SET IS_DELETED = 1,
        DELETED_AT = SYSDATETIME(),
        DELETED_BY = ORIGINAL_LOGIN()
    WHERE MALOP = @MALOP AND IS_DELETED = 0;

    IF @@ROWCOUNT = 0
        THROW 50304, N'Khong tim thay lop dang hoat dong de xoa.', 1;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_SinhVien_DanhSachTheoLop]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_SinhVien_DanhSachTheoLop];
GO

CREATE PROCEDURE [dbo].[sp_4_3_SinhVien_DanhSachTheoLop]
    @MALOP NCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MALOP = UPPER(LTRIM(RTRIM(@MALOP)));

    SELECT MASV, HO, TEN, LTRIM(RTRIM(ISNULL(HO, N'') + N' ' + ISNULL(TEN, N''))) AS HOTEN,
           NGAYSINH, DIACHI, MALOP
    FROM dbo.SinhVien
    WHERE MALOP = @MALOP AND IS_DELETED = 0
    ORDER BY TEN, HO, MASV;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_SinhVien_DaXoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_SinhVien_DaXoa];
GO

CREATE PROCEDURE [dbo].[sp_4_3_SinhVien_DaXoa]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MASV, HO, TEN, LTRIM(RTRIM(ISNULL(HO, N'') + N' ' + ISNULL(TEN, N''))) AS HOTEN,
           NGAYSINH, DIACHI, MALOP, DELETED_AT, DELETED_BY
    FROM dbo.SinhVien
    WHERE IS_DELETED = 1
    ORDER BY DELETED_AT DESC;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_SinhVien_DaXoaTheoLop]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_SinhVien_DaXoaTheoLop];
GO

CREATE PROCEDURE [dbo].[sp_4_3_SinhVien_DaXoaTheoLop]
    @MALOP NCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MALOP = UPPER(LTRIM(RTRIM(@MALOP)));

    SELECT MASV, HO, TEN, LTRIM(RTRIM(ISNULL(HO, N'') + N' ' + ISNULL(TEN, N''))) AS HOTEN,
           NGAYSINH, DIACHI, MALOP, DELETED_AT, DELETED_BY
    FROM dbo.SinhVien
    WHERE MALOP = @MALOP AND IS_DELETED = 1
    ORDER BY DELETED_AT DESC;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_SinhVien_PhucHoi]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_SinhVien_PhucHoi];
GO

CREATE PROCEDURE [dbo].[sp_4_3_SinhVien_PhucHoi]
    @MASV NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MASV = UPPER(LTRIM(RTRIM(@MASV)));

    IF EXISTS (
        SELECT 1
        FROM dbo.SinhVien AS SV
        WHERE SV.MASV = @MASV
          AND SV.IS_DELETED = 1
          AND NOT EXISTS (SELECT 1 FROM dbo.Lop AS L WHERE L.MALOP = SV.MALOP AND L.IS_DELETED = 0)
    )
        THROW 50316, N'Lop cua sinh vien dang bi xoa. Hay phuc hoi lop truoc.', 1;

    UPDATE dbo.SinhVien
    SET IS_DELETED = 0,
        DELETED_AT = NULL,
        DELETED_BY = NULL
    WHERE MASV = @MASV AND IS_DELETED = 1;

    IF @@ROWCOUNT = 0
        THROW 50317, N'Khong tim thay sinh vien da xoa de phuc hoi.', 1;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_SinhVien_Sua]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_SinhVien_Sua];
GO

CREATE PROCEDURE [dbo].[sp_4_3_SinhVien_Sua]
    @MASV NCHAR(8),
    @HO NVARCHAR(40),
    @TEN NVARCHAR(10),
    @NGAYSINH DATE,
    @DIACHI NVARCHAR(100),
    @MALOP NCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MASV = UPPER(LTRIM(RTRIM(@MASV)));
    SET @MALOP = UPPER(LTRIM(RTRIM(@MALOP)));

    IF NOT EXISTS (SELECT 1 FROM dbo.Lop WHERE MALOP = @MALOP AND IS_DELETED = 0)
        THROW 50313, N'Lop khong ton tai hoac da bi xoa.', 1;

    UPDATE dbo.SinhVien
    SET HO = LTRIM(RTRIM(@HO)),
        TEN = LTRIM(RTRIM(@TEN)),
        NGAYSINH = @NGAYSINH,
        DIACHI = @DIACHI,
        MALOP = @MALOP
    WHERE MASV = @MASV AND IS_DELETED = 0;

    IF @@ROWCOUNT = 0
        THROW 50314, N'Khong tim thay sinh vien dang hoat dong de sua.', 1;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_SinhVien_Them]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_SinhVien_Them];
GO

CREATE PROCEDURE [dbo].[sp_4_3_SinhVien_Them]
    @MASV NCHAR(8),
    @HO NVARCHAR(40),
    @TEN NVARCHAR(10),
    @NGAYSINH DATE,
    @DIACHI NVARCHAR(100),
    @MALOP NCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MASV = UPPER(LTRIM(RTRIM(@MASV)));
    SET @MALOP = UPPER(LTRIM(RTRIM(@MALOP)));

    IF EXISTS (SELECT 1 FROM dbo.SinhVien WHERE MASV = @MASV)
        THROW 50311, N'Sinh vien da ton tai. Neu da xoa, hay dung Phuc hoi.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Lop WHERE MALOP = @MALOP AND IS_DELETED = 0)
        THROW 50312, N'Lop khong ton tai hoac da bi xoa.', 1;

    INSERT INTO dbo.SinhVien (MASV, HO, TEN, NGAYSINH, DIACHI, MALOP)
    VALUES (@MASV, LTRIM(RTRIM(@HO)), LTRIM(RTRIM(@TEN)), @NGAYSINH, @DIACHI, @MALOP);
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_SinhVien_Tim]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_SinhVien_Tim];
GO

CREATE PROCEDURE [dbo].[sp_4_3_SinhVien_Tim]
    @KEYWORD NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET @KEYWORD = N'%' + LTRIM(RTRIM(ISNULL(@KEYWORD, N''))) + N'%';

    SELECT MASV, HO, TEN, LTRIM(RTRIM(ISNULL(HO, N'') + N' ' + ISNULL(TEN, N''))) AS HOTEN,
           NGAYSINH, DIACHI, MALOP
    FROM dbo.SinhVien
    WHERE IS_DELETED = 0
      AND (MASV LIKE @KEYWORD OR HO LIKE @KEYWORD OR TEN LIKE @KEYWORD)
    ORDER BY TEN, HO, MASV;
END;
GO

-- SP 4.3: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi sinh viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_3_SinhVien_Xoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_3_SinhVien_Xoa];
GO

CREATE PROCEDURE [dbo].[sp_4_3_SinhVien_Xoa]
    @MASV NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MASV = UPPER(LTRIM(RTRIM(@MASV)));

    UPDATE dbo.SinhVien
    SET IS_DELETED = 1,
        DELETED_AT = SYSDATETIME(),
        DELETED_BY = ORIGINAL_LOGIN()
    WHERE MASV = @MASV AND IS_DELETED = 0;

    IF @@ROWCOUNT = 0
        THROW 50315, N'Khong tim thay sinh vien dang hoat dong de xoa.', 1;
END;
GO

-- SP 4.4: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi giáo viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_4_GiaoVien_DanhSach]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_4_GiaoVien_DanhSach];
GO

CREATE PROCEDURE [dbo].[sp_4_4_GiaoVien_DanhSach]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT GV.MAGV, GV.HO, GV.TEN,
           LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN,
           GV.SODTLL, GV.DIACHI,
           COUNT(CASE WHEN BD.IS_DELETED = 0 THEN 1 END) AS SO_CAU_DA_SOAN
    FROM dbo.GiaoVien AS GV
    LEFT JOIN dbo.BoDe AS BD ON BD.MAGV = GV.MAGV
    WHERE GV.IS_DELETED = 0
    GROUP BY GV.MAGV, GV.HO, GV.TEN, GV.SODTLL, GV.DIACHI
    ORDER BY GV.MAGV;
END;
GO

-- SP 4.4: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi giáo viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_4_GiaoVien_DaXoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_4_GiaoVien_DaXoa];
GO

CREATE PROCEDURE [dbo].[sp_4_4_GiaoVien_DaXoa]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MAGV, HO, TEN, LTRIM(RTRIM(ISNULL(HO, N'') + N' ' + ISNULL(TEN, N''))) AS HOTEN,
           SODTLL, DIACHI, DELETED_AT, DELETED_BY
    FROM dbo.GiaoVien
    WHERE IS_DELETED = 1
    ORDER BY DELETED_AT DESC;
END;
GO

-- SP 4.4: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi giáo viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_4_GiaoVien_PhucHoi]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_4_GiaoVien_PhucHoi];
GO

CREATE PROCEDURE [dbo].[sp_4_4_GiaoVien_PhucHoi]
    @MAGV NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MAGV = UPPER(LTRIM(RTRIM(@MAGV)));

    UPDATE dbo.GiaoVien
    SET IS_DELETED = 0,
        DELETED_AT = NULL,
        DELETED_BY = NULL
    WHERE MAGV = @MAGV AND IS_DELETED = 1;

    IF @@ROWCOUNT = 0
        THROW 50405, N'Khong tim thay giao vien da xoa de phuc hoi.', 1;
END;
GO

-- SP 4.4: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi giáo viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_4_GiaoVien_Sua]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_4_GiaoVien_Sua];
GO

CREATE PROCEDURE [dbo].[sp_4_4_GiaoVien_Sua]
    @MAGV NCHAR(8),
    @HO NVARCHAR(40),
    @TEN NVARCHAR(10),
    @SODTLL NCHAR(15),
    @DIACHI NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MAGV = UPPER(LTRIM(RTRIM(@MAGV)));

    UPDATE dbo.GiaoVien
    SET HO = LTRIM(RTRIM(@HO)),
        TEN = LTRIM(RTRIM(@TEN)),
        SODTLL = @SODTLL,
        DIACHI = @DIACHI
    WHERE MAGV = @MAGV AND IS_DELETED = 0;

    IF @@ROWCOUNT = 0
        THROW 50402, N'Khong tim thay giao vien dang hoat dong de sua.', 1;
END;
GO

-- SP 4.4: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi giáo viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_4_GiaoVien_Them]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_4_GiaoVien_Them];
GO

CREATE PROCEDURE [dbo].[sp_4_4_GiaoVien_Them]
    @MAGV NCHAR(8),
    @HO NVARCHAR(40),
    @TEN NVARCHAR(10),
    @SODTLL NCHAR(15),
    @DIACHI NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MAGV = UPPER(LTRIM(RTRIM(@MAGV)));

    IF EXISTS (SELECT 1 FROM dbo.GiaoVien WHERE MAGV = @MAGV)
        THROW 50401, N'Giao vien da ton tai. Neu da xoa, hay dung Phuc hoi.', 1;

    INSERT INTO dbo.GiaoVien (MAGV, HO, TEN, SODTLL, DIACHI)
    VALUES (@MAGV, LTRIM(RTRIM(@HO)), LTRIM(RTRIM(@TEN)), @SODTLL, @DIACHI);
END;
GO

-- SP 4.4: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi giáo viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_4_GiaoVien_Tim]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_4_GiaoVien_Tim];
GO

CREATE PROCEDURE [dbo].[sp_4_4_GiaoVien_Tim]
    @KEYWORD NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET @KEYWORD = N'%' + LTRIM(RTRIM(ISNULL(@KEYWORD, N''))) + N'%';

    SELECT GV.MAGV, GV.HO, GV.TEN,
           LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN,
           GV.SODTLL, GV.DIACHI,
           COUNT(CASE WHEN BD.IS_DELETED = 0 THEN 1 END) AS SO_CAU_DA_SOAN
    FROM dbo.GiaoVien AS GV
    LEFT JOIN dbo.BoDe AS BD ON BD.MAGV = GV.MAGV
    WHERE GV.IS_DELETED = 0
      AND (
          GV.MAGV LIKE @KEYWORD
          OR GV.HO LIKE @KEYWORD
          OR GV.TEN LIKE @KEYWORD
          OR GV.SODTLL LIKE @KEYWORD
      )
    GROUP BY GV.MAGV, GV.HO, GV.TEN, GV.SODTLL, GV.DIACHI
    ORDER BY GV.MAGV;
END;
GO

-- SP 4.4: nghiệp vụ thêm/sửa/xóa/tìm/phục hồi giáo viên.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_4_GiaoVien_Xoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_4_GiaoVien_Xoa];
GO

CREATE PROCEDURE [dbo].[sp_4_4_GiaoVien_Xoa]
    @MAGV NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    SET @MAGV = UPPER(LTRIM(RTRIM(@MAGV)));

    IF EXISTS (SELECT 1 FROM dbo.BoDe WHERE MAGV = @MAGV AND IS_DELETED = 0)
        THROW 50403, N'Giao vien con cau hoi dang hoat dong. Hay xoa cau hoi truoc.', 1;

    UPDATE dbo.GiaoVien
    SET IS_DELETED = 1,
        DELETED_AT = SYSDATETIME(),
        DELETED_BY = ORIGINAL_LOGIN()
    WHERE MAGV = @MAGV AND IS_DELETED = 0;

    IF @@ROWCOUNT = 0
        THROW 50404, N'Khong tim thay giao vien dang hoat dong de xoa.', 1;
END;
GO

-- SP 4.5: nghiệp vụ ngân hàng câu hỏi, có phân quyền PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* -------------------- 4.5 BO DE -------------------- */
IF OBJECT_ID(N'[dbo].[sp_4_5_BoDe_DanhSach]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_5_BoDe_DanhSach];
GO

CREATE PROCEDURE [dbo].[sp_4_5_BoDe_DanhSach]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.vw_4_5_BoDe ORDER BY CAUHOI;
END;
GO

-- SP 4.5: nghiệp vụ ngân hàng câu hỏi, có phân quyền PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =================
   6. Question bank procedures aligned with application login accounts
   ================= */
IF OBJECT_ID(N'[dbo].[sp_4_5_BoDe_DanhSachCuaNguoiDung]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_5_BoDe_DanhSachCuaNguoiDung];
GO

CREATE PROCEDURE [dbo].[sp_4_5_BoDe_DanhSachCuaNguoiDung]
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

-- SP 4.5: nghiệp vụ ngân hàng câu hỏi, có phân quyền PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_5_BoDe_DaXoaCuaNguoiDung]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_5_BoDe_DaXoaCuaNguoiDung];
GO

CREATE PROCEDURE [dbo].[sp_4_5_BoDe_DaXoaCuaNguoiDung]
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

-- SP 4.5: nghiệp vụ ngân hàng câu hỏi, có phân quyền PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_5_BoDe_PhucHoi]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_5_BoDe_PhucHoi];
GO

CREATE PROCEDURE [dbo].[sp_4_5_BoDe_PhucHoi]
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

-- SP 4.5: nghiệp vụ ngân hàng câu hỏi, có phân quyền PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_5_BoDe_Sua]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_5_BoDe_Sua];
GO

CREATE PROCEDURE [dbo].[sp_4_5_BoDe_Sua]
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

-- SP 4.5: nghiệp vụ ngân hàng câu hỏi, có phân quyền PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_5_BoDe_Them]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_5_BoDe_Them];
GO

CREATE PROCEDURE [dbo].[sp_4_5_BoDe_Them]
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

-- SP 4.5: nghiệp vụ ngân hàng câu hỏi, có phân quyền PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_5_BoDe_Tim]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_5_BoDe_Tim];
GO

CREATE PROCEDURE [dbo].[sp_4_5_BoDe_Tim]
    @KEYWORD NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET @KEYWORD = N'%' + LTRIM(RTRIM(ISNULL(@KEYWORD, N''))) + N'%';

    SELECT BD.CAUHOI, BD.MAMH, BD.TRINHDO, BD.NOIDUNG, BD.A, BD.B, BD.C, BD.D,
           BD.DAP_AN, BD.MAGV,
           LTRIM(RTRIM(ISNULL(GV.HO, N'') + N' ' + ISNULL(GV.TEN, N''))) AS HOTEN_GV
    FROM dbo.BoDe AS BD
    LEFT JOIN dbo.GiaoVien AS GV ON GV.MAGV = BD.MAGV
    WHERE BD.IS_DELETED = 0
      AND (
          CONVERT(NVARCHAR(20), BD.CAUHOI) LIKE @KEYWORD
          OR BD.MAMH LIKE @KEYWORD
          OR BD.NOIDUNG LIKE @KEYWORD
          OR GV.HO LIKE @KEYWORD
          OR GV.TEN LIKE @KEYWORD
      )
    ORDER BY BD.CAUHOI DESC;
END;
GO

-- SP 4.5: nghiệp vụ ngân hàng câu hỏi, có phân quyền PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_4_5_BoDe_Xoa]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_5_BoDe_Xoa];
GO

CREATE PROCEDURE [dbo].[sp_4_5_BoDe_Xoa]
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

-- SP 4.6: đổi mật khẩu tài khoản PGV/GIANGVIEN.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    Update script: sua chuc nang doi mat khau giao vien/PGV.

    Van de cu:
    - App dang nhap bang dbo.TaiKhoan.MATKHAU.
    - Procedure cu chi ALTER LOGIN SQL Server, khong cap nhat TaiKhoan.MATKHAU.

    Cach chay:
    - Chay file nay tren database THI_TRAC_NGHIEM bang tai khoan co quyen ALTER PROCEDURE.
*/

IF OBJECT_ID(N'[dbo].[sp_4_6_DoiMatKhauGiangVien]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_4_6_DoiMatKhauGiangVien];
GO

CREATE PROCEDURE [dbo].[sp_4_6_DoiMatKhauGiangVien]
    @LOGINNAME NVARCHAR(128),
    @CURRENT_PASSWORD NVARCHAR(128),
    @NEW_PASSWORD NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    SET @LOGINNAME = LTRIM(RTRIM(ISNULL(@LOGINNAME, N'')));
    SET @CURRENT_PASSWORD = LTRIM(RTRIM(ISNULL(@CURRENT_PASSWORD, N'')));
    SET @NEW_PASSWORD = LTRIM(RTRIM(ISNULL(@NEW_PASSWORD, N'')));

    IF @LOGINNAME = N''
        THROW 50601, N'Loginname khong hop le.', 1;

    IF NULLIF(@CURRENT_PASSWORD, N'') IS NULL OR NULLIF(@NEW_PASSWORD, N'') IS NULL
        THROW 50602, N'Vui long nhap day du mat khau hien tai va mat khau moi.', 1;

    IF LEN(@NEW_PASSWORD) < 6 OR LEN(@NEW_PASSWORD) > 128
        THROW 50603, N'Mat khau moi phai tu 6 den 128 ky tu.', 1;

    IF @CURRENT_PASSWORD = @NEW_PASSWORD
        THROW 50604, N'Mat khau moi phai khac mat khau hien tai.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.TaiKhoan
        WHERE LOGINNAME = @LOGINNAME
          AND MATKHAU = @CURRENT_PASSWORD
          AND ROLE_NAME IN (N'PGV', N'GIANGVIEN')
          AND IS_ACTIVE = 1
    )
        THROW 50606, N'Mat khau hien tai khong dung.', 1;

    UPDATE dbo.TaiKhoan
    SET MATKHAU = @NEW_PASSWORD
    WHERE LOGINNAME = @LOGINNAME
      AND MATKHAU = @CURRENT_PASSWORD
      AND ROLE_NAME IN (N'PGV', N'GIANGVIEN')
      AND IS_ACTIVE = 1;

    IF @@ROWCOUNT = 0
        THROW 50607, N'Khong cap nhat duoc mat khau tai khoan ung dung.', 1;

    IF EXISTS (
        SELECT 1
        FROM sys.server_principals
        WHERE name = @LOGINNAME
          AND type = 'S'
          AND is_disabled = 0
    )
    BEGIN
        DECLARE @Sql NVARCHAR(MAX) =
            N'ALTER LOGIN ' + QUOTENAME(@LOGINNAME)
            + N' WITH PASSWORD = N'''
            + REPLACE(@NEW_PASSWORD, '''', '''''')
            + N''', CHECK_POLICY = OFF;';

        EXEC sys.sp_executesql @Sql;
    END;
END;
GO

-- SP 4.9: in/xem bảng điểm theo lớp, môn và lần thi.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_BangDiemMonHoc]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_BangDiemMonHoc];
GO

CREATE PROCEDURE [dbo].[sp_BangDiemMonHoc]
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

-- SP 4.7: tạo bài thi chính thức, lưu đề đã xáo vào BaiThi_CauTraLoi.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_BatDauThi]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_BatDauThi];
GO

CREATE PROCEDURE [dbo].[sp_BatDauThi]
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

-- SP: helper chấm lại điểm trong BaiThi.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_ChamDiem]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ChamDiem];
GO

CREATE PROCEDURE [dbo].[sp_ChamDiem]
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

-- SP 4.6: giáo viên đăng ký/cập nhật lịch thi, kiểm tra bộ đề 70/30.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_DangKyThi]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_DangKyThi];
GO

CREATE PROCEDURE [dbo].[sp_DangKyThi]
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

-- SP 4.7: lưu tạm đáp án sinh viên chọn trong quá trình làm bài.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_LuuTamCauTraLoi]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_LuuTamCauTraLoi];
GO

CREATE PROCEDURE [dbo].[sp_LuuTamCauTraLoi]
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

-- SP 4.7: nộp bài, chấm điểm và ghi BangDiem.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_NopBai]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_NopBai];
GO

CREATE PROCEDURE [dbo].[sp_NopBai]
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

-- PROCEDURE: sp_SuaSinhVien
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_SuaSinhVien]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_SuaSinhVien];
GO

CREATE PROCEDURE [dbo].[sp_SuaSinhVien]
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

-- PROCEDURE: sp_ThemSinhVien
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_ThemSinhVien]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ThemSinhVien];
GO

CREATE PROCEDURE [dbo].[sp_ThemSinhVien]
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

-- SP 4.7: phát đề ngẫu nhiên, không trùng câu và xáo A/B/C/D.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_Thi_PhatDeNgauNhien]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_Thi_PhatDeNgauNhien];
GO

CREATE PROCEDURE [dbo].[sp_Thi_PhatDeNgauNhien]
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

-- SP: giáo viên thi thử, phát đề nhưng không ghi điểm.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_ThiThu_PhatDe]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ThiThu_PhatDe];
GO

CREATE PROCEDURE [dbo].[sp_ThiThu_PhatDe]
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

-- SP 4.8: tra cứu kết quả và chi tiết bài thi.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_TraCuuKetQua]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_TraCuuKetQua];
GO

CREATE PROCEDURE [dbo].[sp_TraCuuKetQua]
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

-- SP BACKUP: tạo backup device DEVICE_TENCSDL.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_TTN_Backup_TaoDevice]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_TTN_Backup_TaoDevice];
GO

CREATE PROCEDURE [dbo].[sp_TTN_Backup_TaoDevice]
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

-- SP BACKUP: sao lưu full database và verify.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_TTN_Backup_Full]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_TTN_Backup_Full];
GO

CREATE PROCEDURE [dbo].[sp_TTN_Backup_Full]
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

-- SP BACKUP: sao lưu transaction log để restore theo thời điểm.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_TTN_Backup_Log]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_TTN_Backup_Log];
GO

CREATE PROCEDURE [dbo].[sp_TTN_Backup_Log]
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

-- SP BACKUP: liệt kê lịch sử backup từ msdb.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_TTN_Backup_DanhSach]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_TTN_Backup_DanhSach];
GO

CREATE PROCEDURE [dbo].[sp_TTN_Backup_DanhSach]
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

-- SP 4.7: tự động nộp các bài đã quá thời gian.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_TTN_TuDongNopBaiHetGio]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_TTN_TuDongNopBaiHetGio];
GO

CREATE PROCEDURE [dbo].[sp_TTN_TuDongNopBaiHetGio]
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

-- PROCEDURE: sp_XoaSinhVien
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[sp_XoaSinhVien]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_XoaSinhVien];
GO

CREATE PROCEDURE [dbo].[sp_XoaSinhVien]
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

/* ============================================================
   PHẦN 4. TRIGGERS KIỂM SOÁT NGHIỆP VỤ VÀ AUDIT
   Nguồn: database/db_triggers_thi.sql
   ============================================================ */

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

/* ============================================================
   PHẦN 5. PHÂN QUYỀN DATABASE
   Nguồn: cuối database/db_nghiepvu_thi.sql
   ============================================================ */

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

/* ============================================================
   PHẦN 6. RESTORE VÀ QUYỀN BACKUP/RESTORE
   Nguồn: database/db_backup_restore.sql
   ============================================================ */

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

/* ============================================================
   PHẦN 7. SQL SERVER AGENT JOB TỰ ĐỘNG NỘP BÀI HẾT GIỜ
   Nguồn: database/db_sql_agent_jobs.sql
   ============================================================ */

USE [msdb];
GO

/*
    Optional SQL Server Agent jobs for THI_TRAC_NGHIEM.
    Run this file after db_nghiepvu_thi.sql only on editions that support SQL Server Agent.
*/

DECLARE
    @JobId UNIQUEIDENTIFIER,
    @JobName SYSNAME = N'TTN_TuDongNopBaiHetGio',
    @DatabaseName SYSNAME = N'THI_TRAC_NGHIEM',
    @ScheduleName SYSNAME = N'TTN_Moi_1_Phut_Kiem_Tra_Het_Gio';

IF NOT EXISTS (
    SELECT 1
    FROM master.dbo.sysprocesses
    WHERE program_name LIKE N'SQLAgent%'
)
BEGIN
    PRINT N'SQL Server Agent chua chay, bo qua buoc tao job TTN_TuDongNopBaiHetGio.';
END
ELSE
BEGIN
    IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = @JobName)
    BEGIN
        EXEC msdb.dbo.sp_delete_job @job_name = @JobName, @delete_unused_schedule = 1;
    END;

    EXEC msdb.dbo.sp_add_job
        @job_name = @JobName,
        @enabled = 1,
        @description = N'Tu dong nop cac bai thi da het gio trong he thong thi trac nghiem.',
        @category_name = N'[Uncategorized (Local)]',
        @owner_login_name = NULL,
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
END;
GO
