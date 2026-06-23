# QuizWebapp

Ứng dụng web thi trắc nghiệm sử dụng Spring Boot, Thymeleaf và SQL Server. Dự án quản lý ngân hàng câu hỏi, lịch thi, làm bài, chấm điểm và tra cứu kết quả thi.

## Công nghệ

- Java 21
- Spring Boot 4
- Spring MVC
- Spring Data JPA
- Thymeleaf
- SQL Server
- Maven

## Cấu trúc thư mục

```text
.
├── database/
│   ├── 01_db_final_tao_database.sql
│   └── 02_db_final_views_sp_triggers.sql
├── src/main/java/
├── src/main/resources/
│   ├── application.yml
│   ├── static/
│   └── templates/
├── pom.xml
└── README.md
```

## Chức năng chính

- Đăng nhập theo vai trò.
- Quản lý môn học, lớp, sinh viên và giảng viên.
- Quản lý ngân hàng câu hỏi trắc nghiệm.
- Đăng ký lịch thi theo lớp, môn học và lần thi.
- Sinh viên làm bài thi trực tuyến.
- Lưu câu trả lời trong quá trình làm bài.
- Nộp bài và chấm điểm tự động.
- Xem kết quả thi và bảng điểm.
- Xử lý nghiệp vụ database bằng view, function, stored procedure và trigger.

## Database

Thư mục `database/` chỉ cần 2 file để dựng lại cơ sở dữ liệu:

- `01_db_final_tao_database.sql`: tạo database, bảng, dữ liệu mẫu, khóa, ràng buộc và index.
- `02_db_final_views_sp_triggers.sql`: tạo view, function, stored procedure, trigger, phân quyền và các thành phần database bổ sung.

Chạy trong SQL Server Management Studio theo thứ tự:

```sql
:r .\database\01_db_final_tao_database.sql
:r .\database\02_db_final_views_sp_triggers.sql
```

Nếu không dùng SQLCMD Mode, có thể mở từng file và Execute theo đúng thứ tự trên.

Lưu ý:

- File 01 sẽ dừng nếu database `THI_TRAC_NGHIEM` đã tồn tại.
- Nếu muốn dựng lại từ đầu, cần tự backup dữ liệu cần giữ rồi xóa database cũ trước.
- File 02 phải chạy sau file 01 vì cần các bảng đã được tạo trước.
- Một số phần như SQL Server Agent Job hoặc restore procedure có thể yêu cầu quyền SQL Server cao hơn tùy môi trường.

## Cấu hình môi trường

Ứng dụng đọc thông tin kết nối database từ biến môi trường. Không commit tài khoản hoặc mật khẩu SQL Server thật lên repository.

File cấu hình:

```text
src/main/resources/application.yml
```

Các biến môi trường cần thiết:

```powershell
$env:DB_URL="jdbc:sqlserver://localhost:1433;databaseName=THI_TRAC_NGHIEM;encrypt=true;trustServerCertificate=true"
$env:DB_USERNAME="<sql_username>"
$env:DB_PASSWORD="<sql_password>"
```

## Chạy ứng dụng

Cài dependencies và chạy ứng dụng:

```powershell
mvn spring-boot:run
```

Sau khi chạy thành công, mở:

```text
http://localhost:8080
```

Kiểm tra build:

```powershell
mvn test
```

## Ghi chú bảo mật

- Không đưa mật khẩu SQL Server, chuỗi kết nối thật hoặc file backup database lên GitHub.
- Không dùng tài khoản quản trị SQL Server cho môi trường triển khai thật.
- Nên cấu hình tài khoản database riêng cho ứng dụng và cấp quyền theo nhu cầu sử dụng.

