# QuizWebapp - Hệ thống thi trắc nghiệm SQL Server

Đây là ứng dụng web thi trắc nghiệm cho môn **Hệ Quản Trị Cơ Sở Dữ Liệu**, xây dựng bằng Spring Boot, Thymeleaf và SQL Server. Điểm chính của dự án là đưa phần nghiệp vụ quan trọng xuống tầng database: bảng dữ liệu, view, function, stored procedure, trigger, audit, phân quyền, backup/restore và SQL Server Agent Job.

## Công nghệ sử dụng

- Java 21
- Spring Boot 4
- Spring MVC
- Spring Data JPA
- Thymeleaf
- SQL Server
- Maven

## Cấu trúc chính

- `src/main/java`: mã nguồn backend Spring Boot.
- `src/main/resources/templates`: giao diện Thymeleaf cho giảng viên và sinh viên.
- `src/main/resources/static`: CSS, JavaScript, hình ảnh.
- `src/main/resources/application.yml`: cấu hình kết nối SQL Server.
- `database/01_db_final_tao_database.sql`: tạo database tổng, bảng, dữ liệu mẫu, khóa, ràng buộc và index.
- `database/02_db_final_views_sp_triggers.sql`: tạo view, function, stored procedure, trigger, phân quyền, backup/restore và SQL Server Agent Job.

Hiện tại chỉ cần dùng **2 file trong thư mục `database/`** để dựng lại database đầy đủ.

## Yêu cầu môi trường

- Cài JDK 21.
- Cài Maven hoặc dùng Maven Wrapper nếu môi trường hỗ trợ.
- Cài SQL Server và SQL Server Management Studio.
- SQL Server đang chạy tại `localhost:1433` hoặc cập nhật lại chuỗi kết nối trong `application.yml`.
- Tài khoản SQL Server có quyền tạo database, tạo user/role, tạo procedure, trigger và job.

## Khởi tạo database

Mở SQL Server Management Studio và chạy theo đúng thứ tự:

1. Chạy file tạo database tổng:

```sql
:r .\database\01_db_final_tao_database.sql
```

2. Chạy file tạo nghiệp vụ database:

```sql
:r .\database\02_db_final_views_sp_triggers.sql
```

Nếu không dùng SQLCMD Mode trong SSMS, có thể mở từng file rồi bấm Execute theo đúng thứ tự trên.

Lưu ý:

- File `01_db_final_tao_database.sql` sẽ dừng nếu database `THI_TRAC_NGHIEM` đã tồn tại, nhằm tránh ghi đè nhầm dữ liệu.
- Nếu muốn dựng lại từ đầu, hãy backup dữ liệu cần giữ rồi drop database `THI_TRAC_NGHIEM` cũ trước khi chạy file 01.
- File 02 cần các bảng từ file 01, vì vậy không chạy file 02 trước.
- Phần SQL Server Agent Job trong file 02 cần SQL Server Agent và quyền phù hợp. Nếu máy không bật Agent, phần job có thể lỗi nhưng phần bảng, view, function, stored procedure và trigger vẫn là phần chính của database.

## Nội dung database đã triển khai

Database `THI_TRAC_NGHIEM` gồm các nhóm chức năng chính:

- Quản lý tài khoản giảng viên, phòng giáo vụ.
- Quản lý lớp, sinh viên, môn học, giảng viên.
- Quản lý ngân hàng câu hỏi.
- Đăng ký lịch thi theo lớp, môn, lần thi, trình độ, số câu và thời gian.
- Phát đề ngẫu nhiên theo lịch thi.
- Lưu tạm câu trả lời trong lúc sinh viên làm bài.
- Nộp bài, tự động chấm điểm và ghi bảng điểm.
- Tra cứu kết quả thi và chi tiết đáp án.
- Audit thay đổi dữ liệu quan trọng.
- Phân quyền truy cập qua role database.
- Backup, restore và job tự động nộp bài hết giờ.

Số lượng đối tượng chính trong 2 file database:

- 12 bảng.
- 11 function.
- 11 view.
- 58 stored procedure.
- 9 trigger.

## Một số bảng quan trọng

- `GiaoVien`: lưu thông tin giảng viên.
- `TaiKhoan`: lưu tài khoản đăng nhập của giảng viên và phòng giáo vụ.
- `Lop`: lưu danh sách lớp.
- `SinhVien`: lưu thông tin sinh viên.
- `MonHoc`: lưu danh sách môn học.
- `GiaoVien_DangKy`: lưu lịch thi do giảng viên hoặc phòng giáo vụ đăng ký.
- `BoDe`: ngân hàng câu hỏi trắc nghiệm.
- `BaiThi`: lưu phiên làm bài của sinh viên.
- `BaiThi_CauTraLoi`: lưu từng câu hỏi, đáp án đúng và đáp án sinh viên chọn trong một bài thi.
- `BangDiem`: lưu điểm sau khi sinh viên nộp bài.
- `AuditLog`: lưu lịch sử thay đổi dữ liệu.
- `BackupRestoreHistory`: lưu lịch sử thao tác backup/restore.

## Stored procedure nghiệp vụ chính

- `sp_4_1_DangNhap`: xử lý đăng nhập theo vai trò sinh viên, giảng viên hoặc phòng giáo vụ.
- `sp_4_11_TaoTaiKhoan`: tạo tài khoản giảng viên/phòng giáo vụ.
- `sp_DangKyThi`: đăng ký hoặc cập nhật lịch thi.
- `sp_Thi_PhatDeNgauNhien`: phát đề thi ngẫu nhiên theo môn, trình độ và số câu.
- `sp_BatDauThi`: tạo phiên bài thi hoặc trả lại bài đang làm dở.
- `sp_LuuTamCauTraLoi`: lưu đáp án sinh viên chọn trong lúc làm bài.
- `sp_NopBai`: nộp bài, đếm số câu đúng, tính điểm và ghi vào `BangDiem`.
- `sp_TTN_TuDongNopBaiHetGio`: tự động nộp các bài thi đã hết thời gian.
- `sp_TraCuuKetQua`: xem kết quả và chi tiết từng câu của bài thi.
- `sp_BangDiemMonHoc`: xem bảng điểm theo lớp, môn và lần thi.
- `sp_ThiThu_PhatDe`: phát đề thi thử cho giảng viên.

Ngoài ra còn có các nhóm procedure CRUD cho môn học, lớp, sinh viên, giảng viên và bộ đề:

- `sp_4_2_MonHoc_*`
- `sp_4_3_Lop_*`
- `sp_4_3_SinhVien_*`
- `sp_4_4_GiaoVien_*`
- `sp_4_5_BoDe_*`

## Trigger chính

- `trg_Lop_KhongXoaKhiConSinhVien`: không cho xóa lớp nếu lớp còn sinh viên.
- `trg_SinhVien_KhongXoaKhiDaCoDiem`: không cho xóa sinh viên đã có điểm hoặc đã có bài thi.
- `trg_GiaoVienDangKy_KiemTraHopLe`: kiểm tra lịch thi hợp lệ trước khi lưu.
- `trg_BangDiem_KiemTraHopLe`: kiểm tra điểm nằm trong khoảng 0 đến 10 và phải có lịch thi tương ứng.
- `trg_BaiThiCauTraLoi_KiemTraHopLe`: kiểm tra chi tiết câu trả lời trong bài thi.
- `trg_Audit_GiaoVienDangKy`: ghi audit khi thêm, sửa, xóa lịch thi.
- `trg_Audit_BoDe`: ghi audit khi thay đổi ngân hàng câu hỏi.
- `trg_Audit_BangDiem`: ghi audit khi thay đổi bảng điểm.
- `trg_Audit_TaiKhoan`: ghi audit khi thay đổi tài khoản.

## Phân quyền database

Database có các role chính:

- `Sinhvien`: làm bài thi, lưu đáp án, nộp bài, xem kết quả.
- `Giangvien`: quản lý câu hỏi của mình, đăng ký thi, xem điểm, thi thử.
- `PGV`: quản trị dữ liệu, tạo tài khoản, xem audit, backup.

Script database có cấp quyền thông qua stored procedure và view, đồng thời hạn chế thao tác trực tiếp trên bảng gốc đối với các role ứng dụng.

## Backup, restore và job tự động

File `02_db_final_views_sp_triggers.sql` có các procedure backup/restore:

- `sp_TTN_Backup_TaoDevice`
- `sp_TTN_Backup_Full`
- `sp_TTN_Backup_Log`
- `sp_TTN_Backup_DanhSach`
- `master.dbo.sp_TTN_Restore_Full`
- `master.dbo.sp_TTN_Restore_PointInTime`
- `master.dbo.sp_TTN_Restore_SinhLenh`

File này cũng tạo SQL Server Agent Job gọi `sp_TTN_TuDongNopBaiHetGio` theo chu kỳ để tự động nộp các bài thi quá thời gian.

## Cấu hình kết nối database

File cấu hình nằm tại:

```text
src/main/resources/application.yml
```

Mặc định ứng dụng dùng:

```yaml
spring:
  datasource:
    url: jdbc:sqlserver://localhost:1433;databaseName=THI_TRAC_NGHIEM;encrypt=true;trustServerCertificate=true
    username: sa
    password: 1234
```

Có thể đổi cấu hình bằng biến môi trường:

```powershell
$env:DB_URL="jdbc:sqlserver://localhost:1433;databaseName=THI_TRAC_NGHIEM;encrypt=true;trustServerCertificate=true"
$env:DB_USERNAME="sa"
$env:DB_PASSWORD="mat_khau_sql_server"
```

## Chạy ứng dụng

Chạy bằng Maven:

```powershell
mvn spring-boot:run
```

Sau khi chạy thành công, mở trình duyệt:

```text
http://localhost:8080
```

Build hoặc kiểm tra nhanh:

```powershell
mvn test
```

## Tài khoản mẫu

Tài khoản giảng viên/phòng giáo vụ có trong dữ liệu mẫu:

| Vai trò | Tài khoản | Mật khẩu |
| --- | --- | --- |
| PGV | `pgv1` | `123456` |
| PGV | `pgv2` | `123456` |
| Giảng viên | `gv1` | `1234567` |
| Giảng viên | `gv2` | `123456` |

Sinh viên đăng nhập bằng mã sinh viên, mật khẩu mặc định:

```text
123456
```

Ví dụ mã sinh viên có trong dữ liệu mẫu:

- `SV000001`
- `SV000002`
- `SV000003`
- `N22DCDT002`
- `N22DCAT002`

## Luồng sử dụng cơ bản

1. Phòng giáo vụ hoặc giảng viên đăng nhập.
2. Quản lý môn học, lớp, sinh viên, giảng viên nếu cần.
3. Thêm hoặc chỉnh sửa câu hỏi trong ngân hàng đề.
4. Đăng ký lịch thi cho lớp.
5. Sinh viên đăng nhập bằng mã sinh viên.
6. Sinh viên vào phòng thi, bắt đầu làm bài.
7. Hệ thống phát đề ngẫu nhiên, lưu câu trả lời, nộp bài và chấm điểm.
8. Giảng viên/phòng giáo vụ xem bảng điểm và kết quả chi tiết.

## Ghi chú khi báo cáo

Khi thuyết trình phần Hệ Quản Trị Cơ Sở Dữ Liệu, nên tập trung vào:

- Thiết kế bảng và ràng buộc khóa.
- Cách stored procedure kiểm soát nghiệp vụ thay vì xử lý toàn bộ ở Java.
- Trigger kiểm tra dữ liệu và ghi audit.
- View hỗ trợ đăng nhập, tra cứu và báo cáo.
- Phân quyền role để người dùng thao tác qua SP/view.
- Backup/restore và job tự động nộp bài hết giờ.

