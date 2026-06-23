/*
    ============================================================
    FILE 01 - TẠO DATABASE TỔNG TỪ db_final.sql
    Tạo database, bảng, dữ liệu mẫu, khóa, ràng buộc và index.
    Chạy file này trước file 02.
    ============================================================
*/

USE [master]
IF DB_ID(N'THI_TRAC_NGHIEM') IS NOT NULL
BEGIN
    RAISERROR(N'Database THI_TRAC_NGHIEM đã tồn tại. Hãy xóa database cũ nếu muốn tạo lại từ đầu.', 16, 1);
    SET NOEXEC ON;
END;
CREATE DATABASE [THI_TRAC_NGHIEM];
GO

USE [master]
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET COMPATIBILITY_LEVEL = 160
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET ARITHABORT OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET  ENABLE_BROKER 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET RECOVERY FULL 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET  MULTI_USER 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET DB_CHAINING OFF 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO

EXEC sys.sp_db_vardecimal_storage_format N'THI_TRAC_NGHIEM', N'ON'
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET QUERY_STORE = ON
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO

USE [master]
GO

ALTER DATABASE [THI_TRAC_NGHIEM] SET  READ_WRITE 
GO

USE [THI_TRAC_NGHIEM]
GO

/* ROLES VÀ DATABASE USERS
   Các user chỉ được tạo nếu server login tương ứng đã tồn tại.
   Điều này giúp script chạy được cả trên máy chưa tạo login sv/gv/pgv. */
IF SUSER_ID(N'sv') IS NOT NULL AND USER_ID(N'U_sv') IS NULL CREATE USER [U_sv] FOR LOGIN [sv] WITH DEFAULT_SCHEMA=[dbo];
IF SUSER_ID(N'pgv2') IS NOT NULL AND USER_ID(N'U_pgv2') IS NULL CREATE USER [U_pgv2] FOR LOGIN [pgv2] WITH DEFAULT_SCHEMA=[dbo];
IF SUSER_ID(N'pgv1') IS NOT NULL AND USER_ID(N'U_pgv1') IS NULL CREATE USER [U_pgv1] FOR LOGIN [pgv1] WITH DEFAULT_SCHEMA=[dbo];
IF SUSER_ID(N'gv2') IS NOT NULL AND USER_ID(N'U_gv2') IS NULL CREATE USER [U_gv2] FOR LOGIN [gv2] WITH DEFAULT_SCHEMA=[dbo];
IF SUSER_ID(N'gv1') IS NOT NULL AND USER_ID(N'U_gv1') IS NULL CREATE USER [U_gv1] FOR LOGIN [gv1] WITH DEFAULT_SCHEMA=[dbo];
IF DATABASE_PRINCIPAL_ID(N'Sinhvien') IS NULL CREATE ROLE [Sinhvien];
IF DATABASE_PRINCIPAL_ID(N'PGV') IS NULL CREATE ROLE [PGV];
IF DATABASE_PRINCIPAL_ID(N'Giangvien') IS NULL CREATE ROLE [Giangvien];
IF USER_ID(N'U_sv') IS NOT NULL AND IS_ROLEMEMBER(N'Sinhvien', N'U_sv') = 0 ALTER ROLE [Sinhvien] ADD MEMBER [U_sv];
IF USER_ID(N'U_pgv2') IS NOT NULL AND IS_ROLEMEMBER(N'PGV', N'U_pgv2') = 0 ALTER ROLE [PGV] ADD MEMBER [U_pgv2];
IF USER_ID(N'U_pgv1') IS NOT NULL AND IS_ROLEMEMBER(N'PGV', N'U_pgv1') = 0 ALTER ROLE [PGV] ADD MEMBER [U_pgv1];
IF USER_ID(N'U_gv2') IS NOT NULL AND IS_ROLEMEMBER(N'Giangvien', N'U_gv2') = 0 ALTER ROLE [Giangvien] ADD MEMBER [U_gv2];
IF USER_ID(N'U_gv1') IS NOT NULL AND IS_ROLEMEMBER(N'Giangvien', N'U_gv1') = 0 ALTER ROLE [Giangvien] ADD MEMBER [U_gv1];
GO

/* ============================================================
   PHẦN 1. TẠO BẢNG
   ============================================================ */

-- BẢNG GIAOVIEN: lưu thông tin giảng viên/PGV, có cờ xóa mềm IS_DELETED.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GiaoVien](
	[MAGV] [nchar](8) NOT NULL,
	[HO] [nvarchar](40) NULL,
	[TEN] [nvarchar](10) NULL,
	[SODTLL] [nchar](15) NULL,
	[DIACHI] [nvarchar](50) NULL,
	[IS_DELETED] [bit] NOT NULL,
	[DELETED_AT] [datetime2](0) NULL,
	[DELETED_BY] [sysname] NULL,
 CONSTRAINT [PK_GiaoVien] PRIMARY KEY CLUSTERED 
(
	[MAGV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG TAIKHOAN: lưu tài khoản ứng dụng cho PGV/GIANGVIEN, liên kết với GiaoVien.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaiKhoan](
	[LOGINNAME] [nvarchar](50) NOT NULL,
	[MATKHAU] [nvarchar](255) NOT NULL,
	[ROLE_NAME] [nvarchar](20) NOT NULL,
	[MAGV] [nchar](8) NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[CREATED_AT] [datetime] NOT NULL,
 CONSTRAINT [PK_TaiKhoan] PRIMARY KEY CLUSTERED 
(
	[LOGINNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG LOP: danh mục lớp sinh viên, mã lớp viết hoa, có xóa mềm.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lop](
	[MALOP] [nchar](15) NOT NULL,
	[TENLOP] [nvarchar](40) NOT NULL,
	[IS_DELETED] [bit] NOT NULL,
	[DELETED_AT] [datetime2](0) NULL,
	[DELETED_BY] [sysname] NULL,
 CONSTRAINT [PK_Lop] PRIMARY KEY CLUSTERED 
(
	[MALOP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG SINHVIEN: danh sách sinh viên thuộc lớp, dùng cho đăng nhập sinh viên và thi.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SinhVien](
	[MASV] [nchar](10) NOT NULL,
	[HO] [nvarchar](40) NULL,
	[TEN] [nvarchar](10) NULL,
	[NGAYSINH] [date] NULL,
	[DIACHI] [nvarchar](100) NULL,
	[MALOP] [nchar](15) NULL,
	[IS_DELETED] [bit] NOT NULL,
	[DELETED_AT] [datetime2](0) NULL,
	[DELETED_BY] [sysname] NULL
) ON [PRIMARY]
GO

-- BẢNG MONHOC: danh mục môn học thi trắc nghiệm, mã môn viết hoa.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonHoc](
	[MAMH] [nchar](5) NOT NULL,
	[TENMH] [nvarchar](40) NOT NULL,
	[IS_DELETED] [bit] NOT NULL,
	[DELETED_AT] [datetime2](0) NULL,
	[DELETED_BY] [sysname] NULL,
 CONSTRAINT [PK_MonHoc] PRIMARY KEY CLUSTERED 
(
	[MAMH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG GIAOVIEN_DANGKY: lịch thi do giáo viên đăng ký cho lớp, môn, trình độ, lần thi.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GiaoVien_DangKy](
	[MAGV] [nchar](8) NOT NULL,
	[MALOP] [nchar](15) NOT NULL,
	[MAMH] [nchar](5) NOT NULL,
	[TRINHDO] [nchar](1) NOT NULL,
	[NGAYTHI] [datetime] NOT NULL,
	[LAN] [smallint] NOT NULL,
	[SOCAUTHI] [smallint] NOT NULL,
	[THOIGIAN] [smallint] NOT NULL,
 CONSTRAINT [PK_GiaoVien_DangKy] PRIMARY KEY CLUSTERED 
(
	[MALOP] ASC,
	[MAMH] ASC,
	[LAN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG BODE: ngân hàng câu hỏi trắc nghiệm, có trình độ A/B/C và đáp án đúng.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BoDe](
	[MAMH] [nchar](5) NOT NULL,
	[CAUHOI] [int] IDENTITY(1,1) NOT NULL,
	[TRINHDO] [char](1) NOT NULL,
	[NOIDUNG] [nvarchar](200) NULL,
	[A] [nvarchar](50) NULL,
	[B] [nvarchar](50) NULL,
	[C] [nvarchar](50) NULL,
	[D] [nvarchar](50) NULL,
	[DAP_AN] [nchar](1) NOT NULL,
	[MAGV] [nchar](8) NOT NULL,
	[IS_DELETED] [bit] NOT NULL,
	[DELETED_AT] [datetime2](0) NULL,
	[DELETED_BY] [sysname] NULL,
 CONSTRAINT [PK_BoDe] PRIMARY KEY CLUSTERED 
(
	[CAUHOI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG BAITHI_CAUTRALOI: snapshot từng câu hỏi đã phát, đáp án đã xáo và đáp án sinh viên chọn.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BaiThi_CauTraLoi](
	[MABT] [bigint] NOT NULL,
	[CAUHOI] [int] NOT NULL,
	[THUTU] [smallint] NOT NULL,
	[MAMH] [nchar](5) NOT NULL,
	[TRINHDO_CAU] [nchar](1) NOT NULL,
	[NOIDUNG] [nvarchar](200) NOT NULL,
	[A] [nvarchar](50) NULL,
	[B] [nvarchar](50) NULL,
	[C] [nvarchar](50) NULL,
	[D] [nvarchar](50) NULL,
	[DAP_AN_DUNG] [nchar](1) NOT NULL,
	[DAP_AN_CHON] [nchar](1) NULL,
 CONSTRAINT [PK_BaiThi_CauTraLoi] PRIMARY KEY CLUSTERED 
(
	[MABT] ASC,
	[CAUHOI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG BAITHI: thông tin tổng quát một bài làm của sinh viên, thời gian, trạng thái, điểm.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BaiThi](
	[MABT] [bigint] IDENTITY(1,1) NOT NULL,
	[MASV] [nchar](10) NOT NULL,
	[MAMH] [nchar](5) NOT NULL,
	[LAN] [smallint] NOT NULL,
	[NGAYTHI] [datetime] NOT NULL,
	[BATDAU_LUC] [datetime] NOT NULL,
	[KETTHUC_LUC] [datetime] NULL,
	[NOPBAI_LUC] [datetime] NULL,
	[THOIGIAN] [smallint] NOT NULL,
	[SOCAU] [smallint] NOT NULL,
	[SOCAUDUNG] [smallint] NOT NULL,
	[DIEM] [decimal](4, 2) NOT NULL,
	[TRANGTHAI] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MABT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG BANGDIEM: điểm cuối cùng của sinh viên theo môn và lần thi.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BangDiem](
	[MASV] [nchar](10) NOT NULL,
	[MAMH] [nchar](5) NOT NULL,
	[LAN] [smallint] NOT NULL,
	[NGAYTHI] [date] NOT NULL,
	[DIEM] [float] NOT NULL
) ON [PRIMARY]
GO

-- BẢNG AUDITLOG: nhật ký thay đổi dữ liệu quan trọng do trigger audit ghi lại.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditLog](
	[AUDIT_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[EVENT_TIME] [datetime2](0) NOT NULL,
	[DB_LOGIN] [sysname] NOT NULL,
	[DB_USER_NAME] [sysname] NOT NULL,
	[APP_LOGINNAME] [nvarchar](128) NULL,
	[OBJECT_NAME] [sysname] NOT NULL,
	[ACTION_NAME] [nvarchar](20) NOT NULL,
	[KEY_VALUE] [nvarchar](300) NULL,
	[DESCRIPTION] [nvarchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[AUDIT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- BẢNG BACKUPRESTOREHISTORY: lịch sử backup/restore phục vụ phần quản trị CSDL.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BackupRestoreHistory](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ACTION_NAME] [nvarchar](30) NOT NULL,
	[DATABASE_NAME] [sysname] NOT NULL,
	[BACKUP_TYPE] [nvarchar](20) NULL,
	[FILE_PATH] [nvarchar](4000) NULL,
	[DEVICE_NAME] [sysname] NULL,
	[RESTORE_TO] [datetime2](0) NULL,
	[EXECUTED_BY] [sysname] NOT NULL,
	[EXECUTED_AT] [datetime2](0) NOT NULL,
	[NOTE] [nvarchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/* ============================================================
   PHẦN 2. DỮ LIỆU MẪU / DỮ LIỆU HIỆN CÓ TỪ db_final.sql
   ============================================================ */

SET IDENTITY_INSERT [dbo].[AuditLog] ON 

INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (3, CAST(N'2026-06-23T09:35:54.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'TaiKhoan', N'INSERT', N'pgv2', N'ROLE=PGV; MAGV=GV000004')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (4, CAST(N'2026-06-23T09:57:54.0000000' AS DateTime2), N'sa', N'dbo', N'gv1', N'TaiKhoan', N'UPDATE', N'gv1', N'ROLE=GIANGVIEN; MAGV=GV000001')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (5, CAST(N'2026-06-23T10:18:47.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'46', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (6, CAST(N'2026-06-23T10:18:48.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'45', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (7, CAST(N'2026-06-23T10:18:49.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'44', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (8, CAST(N'2026-06-23T10:18:50.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'43', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (9, CAST(N'2026-06-23T10:18:50.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'42', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (10, CAST(N'2026-06-23T10:18:50.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'41', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (11, CAST(N'2026-06-23T10:18:51.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'40', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (12, CAST(N'2026-06-23T10:18:51.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'39', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (13, CAST(N'2026-06-23T10:18:51.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'38', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (14, CAST(N'2026-06-23T10:18:52.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'UPDATE', N'37', N'MAMH=CTDL; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (15, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'47', N'MAMH=HQT; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (16, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'48', N'MAMH=HQT; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (17, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'49', N'MAMH=HQT; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (18, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'50', N'MAMH=HQT; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (19, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'51', N'MAMH=HQT; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (20, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'52', N'MAMH=HQT; TRINHDO=B; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (21, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'53', N'MAMH=HQT; TRINHDO=B; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (22, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'54', N'MAMH=HQT; TRINHDO=B; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (23, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'55', N'MAMH=HQT; TRINHDO=B; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (24, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'56', N'MAMH=HQT; TRINHDO=B; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (25, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'57', N'MAMH=HQT; TRINHDO=B; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (26, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'58', N'MAMH=HQT; TRINHDO=C; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (27, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'59', N'MAMH=HQT; TRINHDO=C; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (28, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'60', N'MAMH=HQT; TRINHDO=C; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (29, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'61', N'MAMH=HQT; TRINHDO=C; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (30, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'62', N'MAMH=HQT; TRINHDO=C; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (31, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'63', N'MAMH=HQT; TRINHDO=C; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (32, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'64', N'MAMH=HQT; TRINHDO=A; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (33, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'65', N'MAMH=HQT; TRINHDO=B; DAP_AN=A')
INSERT [dbo].[AuditLog] ([AUDIT_ID], [EVENT_TIME], [DB_LOGIN], [DB_USER_NAME], [APP_LOGINNAME], [OBJECT_NAME], [ACTION_NAME], [KEY_VALUE], [DESCRIPTION]) VALUES (34, CAST(N'2026-06-23T10:22:55.0000000' AS DateTime2), N'sa', N'dbo', N'pgv1', N'BoDe', N'INSERT', N'66', N'MAMH=HQT; TRINHDO=C; DAP_AN=A')
SET IDENTITY_INSERT [dbo].[AuditLog] OFF
GO

INSERT [dbo].[BangDiem] ([MASV], [MAMH], [LAN], [NGAYTHI], [DIEM]) VALUES (N'SV000001  ', N'CSDL ', 1, CAST(N'2026-06-14' AS Date), 8)
INSERT [dbo].[BangDiem] ([MASV], [MAMH], [LAN], [NGAYTHI], [DIEM]) VALUES (N'SV000002  ', N'CSDL ', 1, CAST(N'2026-06-14' AS Date), 7)
INSERT [dbo].[BangDiem] ([MASV], [MAMH], [LAN], [NGAYTHI], [DIEM]) VALUES (N'SV000003  ', N'CTDL ', 1, CAST(N'2026-06-16' AS Date), 9)
GO

SET IDENTITY_INSERT [dbo].[BoDe] ON 

INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 1, N'A', N'Câu hỏi CSDL trình độ A số 1?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 2, N'A', N'Câu hỏi CSDL trình độ A số 2?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 3, N'A', N'Câu hỏi CSDL trình độ A số 3?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 4, N'A', N'Câu hỏi CSDL trình độ A số 4?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 5, N'A', N'Câu hỏi CSDL trình độ A số 5?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 6, N'A', N'Câu hỏi CSDL trình độ A số 6?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 7, N'A', N'Câu hỏi CSDL trình độ A số 7?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 8, N'A', N'Câu hỏi CSDL trình độ A số 8?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 9, N'A', N'Câu hỏi CSDL trình độ A số 9?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 10, N'A', N'Câu hỏi CSDL trình độ A số 10?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 11, N'A', N'Câu hỏi CSDL trình độ A số 11?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 12, N'A', N'Câu hỏi CSDL trình độ A số 12?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 13, N'B', N'Câu hỏi CSDL trình độ B số 1?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 14, N'B', N'Câu hỏi CSDL trình độ B số 2?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 15, N'B', N'Câu hỏi CSDL trình độ B số 3?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 16, N'B', N'Câu hỏi CSDL trình độ B số 4?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 17, N'B', N'Câu hỏi CSDL trình độ B số 5?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 18, N'B', N'Câu hỏi CSDL trình độ B số 6?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 19, N'B', N'Câu hỏi CSDL trình độ B số 7?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 20, N'B', N'Câu hỏi CSDL trình độ B số 8?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 21, N'B', N'Câu hỏi CSDL trình độ B số 9?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 22, N'B', N'Câu hỏi CSDL trình độ B số 10?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 23, N'B', N'Câu hỏi CSDL trình độ B số 11?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 24, N'B', N'Câu hỏi CSDL trình độ B số 12?', N'Đáp án sai A', N'Đáp án đúng B', N'Đáp án sai C', N'Đáp án sai D', N'B', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 25, N'C', N'Câu hỏi CSDL trình độ C số 1?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 26, N'C', N'Câu hỏi CSDL trình độ C số 2?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 27, N'C', N'Câu hỏi CSDL trình độ C số 3?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 28, N'C', N'Câu hỏi CSDL trình độ C số 4?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 29, N'C', N'Câu hỏi CSDL trình độ C số 5?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 30, N'C', N'Câu hỏi CSDL trình độ C số 6?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 31, N'C', N'Câu hỏi CSDL trình độ C số 7?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 32, N'C', N'Câu hỏi CSDL trình độ C số 8?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 33, N'C', N'Câu hỏi CSDL trình độ C số 9?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 34, N'C', N'Câu hỏi CSDL trình độ C số 10?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 35, N'C', N'Câu hỏi CSDL trình độ C số 11?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', 36, N'C', N'Câu hỏi CSDL trình độ C số 12?', N'Đáp án sai A', N'Đáp án sai B', N'Đáp án đúng C', N'Đáp án sai D', N'C', N'GV000001', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 37, N'A', N'Câu hỏi CTDL trình độ A số 1?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:52.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 38, N'A', N'Câu hỏi CTDL trình độ A số 2?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:51.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 39, N'A', N'Câu hỏi CTDL trình độ A số 3?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:51.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 40, N'A', N'Câu hỏi CTDL trình độ A số 4?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:51.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 41, N'A', N'Câu hỏi CTDL trình độ A số 5?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:50.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 42, N'A', N'Câu hỏi CTDL trình độ A số 6?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:50.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 43, N'A', N'Câu hỏi CTDL trình độ A số 7?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:50.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 44, N'A', N'Câu hỏi CTDL trình độ A số 8?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:49.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 45, N'A', N'Câu hỏi CTDL trình độ A số 9?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:48.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', 46, N'A', N'Câu hỏi CTDL trình độ A số 10?', N'Đáp án đúng A', N'Đáp án sai B', N'Đáp án sai C', N'Đáp án sai D', N'A', N'GV000002', 1, CAST(N'2026-06-23T10:18:47.0000000' AS DateTime2), N'pgv1')
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 47, N'A', N'DBMS là viết tắt của khái niệm nào?', N'Database Management System', N'Data Backup Main Server', N'Digital Base Memory Set', N'Database Mapping Service', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 48, N'A', N'Ngôn ngữ SQL dùng chủ yếu để làm gì?', N'Quản lý dữ liệu quan hệ', N'Thiết kế giao diện', N'Biên dịch chương trình', N'Quản lý file ảnh', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 49, N'A', N'Lệnh SELECT trong SQL dùng để làm gì?', N'Truy vấn dữ liệu', N'Xóa bảng', N'Tạo login', N'Sao lưu ổ đĩa', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 50, N'A', N'Khóa chính có đặc điểm quan trọng nào?', N'Duy nhất và không null', N'Luôn là chuỗi', N'Cho phép trùng', N'Chỉ dùng cho view', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 51, N'A', N'Khóa ngoại dùng để thể hiện điều gì?', N'Quan hệ giữa các bảng', N'Tốc độ CPU', N'Dung lượng log', N'Tên database', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 52, N'B', N'Chuẩn hóa dữ liệu giúp giảm vấn đề nào?', N'Dư thừa dữ liệu', N'Tăng khóa chính', N'Mất index', N'Tăng số login', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 53, N'B', N'Transaction trong CSDL cần đảm bảo nhóm tính chất nào?', N'ACID', N'CRUD', N'HTTP', N'JSON', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 54, N'B', N'Tính Atomicity trong transaction nghĩa là gì?', N'Tất cả hoặc không gì cả', N'Luôn chạy song song', N'Không cần khóa', N'Tự tạo index', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 55, N'B', N'Lệnh COMMIT dùng để làm gì?', N'Xác nhận giao dịch', N'Hủy giao dịch', N'Tạo bảng', N'Xóa database', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 56, N'B', N'Lệnh ROLLBACK dùng để làm gì?', N'Hủy thay đổi trong giao dịch', N'Tăng kích thước bảng', N'Tạo khóa ngoại', N'Cấp quyền user', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 57, N'B', N'Index trong SQL Server thường giúp gì?', N'Tăng tốc truy vấn', N'Mã hóa mật khẩu', N'Tạo dữ liệu mẫu', N'Đổi tên server', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 58, N'C', N'Deadlock xảy ra khi nào?', N'Các giao dịch chờ khóa lẫn nhau', N'Database không có bảng', N'User nhập sai mật khẩu', N'Query không có WHERE', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 59, N'C', N'Stored procedure là gì?', N'Khối lệnh SQL lưu trong DB', N'Một loại bảng vật lý', N'Một file ảnh', N'Một cổng mạng', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 60, N'C', N'Trigger thường được kích hoạt khi nào?', N'Khi có INSERT UPDATE DELETE', N'Khi mở trình duyệt', N'Khi tắt máy chủ', N'Khi tạo file CSV', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 61, N'C', N'View trong SQL Server là gì?', N'Bảng ảo từ câu SELECT', N'Bản sao vật lý luôn có dữ liệu', N'Một loại login', N'Một file backup', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 62, N'C', N'GRANT trong SQL dùng để làm gì?', N'Cấp quyền', N'Thu hồi quyền', N'Xóa dữ liệu', N'Khóa tài khoản Windows', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 63, N'C', N'DENY trong SQL Server có ý nghĩa gì?', N'Từ chối quyền rõ ràng', N'Tạo quyền mặc định', N'Sao lưu log', N'Mở khóa bảng', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 64, N'A', N'Backup database dùng để làm gì?', N'Phục hồi khi sự cố', N'Tăng số câu hỏi', N'Xóa dữ liệu cũ', N'Tạo view mới', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 65, N'B', N'Recovery model FULL hỗ trợ tốt cho kiểu restore nào?', N'Restore theo thời điểm', N'Chỉ restore file ảnh', N'Không cần log', N'Chỉ restore bảng', N'A', N'GV000003', 0, NULL, NULL)
INSERT [dbo].[BoDe] ([MAMH], [CAUHOI], [TRINHDO], [NOIDUNG], [A], [B], [C], [D], [DAP_AN], [MAGV], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', 66, N'C', N'Audit log thường dùng để ghi nhận điều gì?', N'Ai thay đổi dữ liệu và lúc nào', N'Màu giao diện', N'Dung lượng RAM', N'Số lần mở trình duyệt', N'A', N'GV000003', 0, NULL, NULL)
SET IDENTITY_INSERT [dbo].[BoDe] OFF
GO

INSERT [dbo].[GiaoVien] ([MAGV], [HO], [TEN], [SODTLL], [DIACHI], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'GV000001', N'Lê Văn', N'Cường', N'0900000001     ', N'TP.HCM', 0, NULL, NULL)
INSERT [dbo].[GiaoVien] ([MAGV], [HO], [TEN], [SODTLL], [DIACHI], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'GV000002', N'Phạm Thị', N'Dung', N'0900000002     ', N'Hà Nội', 0, NULL, NULL)
INSERT [dbo].[GiaoVien] ([MAGV], [HO], [TEN], [SODTLL], [DIACHI], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'GV000003', N'Nguyễn Văn', N'Minh', N'0900000003     ', N'Đà Nẵng', 0, NULL, NULL)
INSERT [dbo].[GiaoVien] ([MAGV], [HO], [TEN], [SODTLL], [DIACHI], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'GV000004', N'Nguyễn Minh', N'Quân', N'0903169054     ', N'xxxx', 0, NULL, NULL)
GO

INSERT [dbo].[GiaoVien_DangKy] ([MAGV], [MALOP], [MAMH], [TRINHDO], [NGAYTHI], [LAN], [SOCAUTHI], [THOIGIAN]) VALUES (N'GV000001', N'D21CQCN01      ', N'CSDL ', N'A', CAST(N'2026-06-14T08:00:00.000' AS DateTime), 1, 10, 10)
INSERT [dbo].[GiaoVien_DangKy] ([MAGV], [MALOP], [MAMH], [TRINHDO], [NGAYTHI], [LAN], [SOCAUTHI], [THOIGIAN]) VALUES (N'GV000001', N'D21CQCN01      ', N'CSDL ', N'B', CAST(N'2026-06-15T08:00:00.000' AS DateTime), 2, 10, 10)
INSERT [dbo].[GiaoVien_DangKy] ([MAGV], [MALOP], [MAMH], [TRINHDO], [NGAYTHI], [LAN], [SOCAUTHI], [THOIGIAN]) VALUES (N'GV000002', N'D21CQCN02      ', N'CTDL ', N'A', CAST(N'2026-06-16T08:00:00.000' AS DateTime), 1, 10, 15)
GO

INSERT [dbo].[Lop] ([MALOP], [TENLOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'D21CQCN01      ', N'Công nghệ thông tin 1', 0, NULL, NULL)
INSERT [dbo].[Lop] ([MALOP], [TENLOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'D21CQCN02      ', N'Công nghệ thông tin 2', 0, NULL, NULL)
INSERT [dbo].[Lop] ([MALOP], [TENLOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'D21HTTT01      ', N'Hệ thống thông tin 1', 0, NULL, NULL)
INSERT [dbo].[Lop] ([MALOP], [TENLOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'E22CQCNTT01-N  ', N'Công nghệ thông tin 01 - N', 0, NULL, NULL)
INSERT [dbo].[Lop] ([MALOP], [TENLOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'E22CQCNTT02-N  ', N'Công nghệ thông tin 02 - N', 0, NULL, NULL)
INSERT [dbo].[Lop] ([MALOP], [TENLOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'E23CQCN01-N    ', N'E23 Công nghệ thông tin 01', 0, NULL, NULL)
GO

INSERT [dbo].[MonHoc] ([MAMH], [TENMH], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CSDL ', N'Cơ sở dữ liệu', 0, NULL, NULL)
INSERT [dbo].[MonHoc] ([MAMH], [TENMH], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'CTDL ', N'Cấu trúc dữ liệu', 0, NULL, NULL)
INSERT [dbo].[MonHoc] ([MAMH], [TENMH], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'HQT  ', N'Hệ quan trị cơ sở dự liệu', 0, NULL, NULL)
INSERT [dbo].[MonHoc] ([MAMH], [TENMH], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'TTNT ', N'Trí tuệ nhân tạo', 0, NULL, NULL)
GO

INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'SV000001  ', N'Nguyễn Văn', N'An', CAST(N'2004-01-01' AS Date), N'TP.HCM', N'D21CQCN01      ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'SV000002  ', N'Trần Thị', N'Bình', CAST(N'2004-02-02' AS Date), N'Hà Nội', N'D21CQCN01      ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'SV000003  ', N'Lê Quốc', N'Huy', CAST(N'2004-03-03' AS Date), N'Đà Nẵng', N'D21CQCN02      ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'SV000004  ', N'Phạm Ngọc', N'Linh', CAST(N'2004-04-04' AS Date), N'Cần Thơ', N'D21HTTT01      ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDT002', N'Nguyễn Thành', N'An', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCAT002', N'Phạm Văn', N'An', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCAT003', N'Tạ Quang', N'An', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN004', N'Lý Trọng', N'Ân', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDK006', N'Phùng Hoàng', N'Anh', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCAT007', N'Lê Quốc', N'Bảo', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN011', N'Nguyễn Vũ', N'Chinh', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCI004', N'Phạm Thái Hoàng', N'Đạo', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCAT017', N'Nguyễn Hải', N'Đông', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN122', N'Phạm Minh', N'Đức', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDT010', N'Hoàng Minh', N'Duy', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN026', N'Trần Tuấn', N'Hải', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDT025', N'Nguyễn Trọng Nhật', N'Hoàng', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCVT039', N'Đỗ Việt', N'Hùng', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN132', N'Trần Phi', N'Hùng', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCI018', N'Phạm Nguyễn Quốc', N'Huy', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCAT026', N'Trần Quốc', N'Huy', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCAT028', N'Nguyễn Minh', N'Hy', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN138', N'Trần Minh', N'Khang', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN041', N'Hạ Tiến', N'Khoa', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN141', N'Huỳnh Bá Anh', N'Khoa', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN043', N'Bùi Mạnh', N'Khôi', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN049', N'Mai Hoàng', N'Long', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN050', N'Vũ Kim', N'Long', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDT038', N'Đặng Nhật', N'Nam', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN058', N'Vũ Hoàng', N'Phát', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN069', N'Đặng Phước Trường', N'Sinh', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN172', N'Nguyễn Thanh', N'Tâm', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCI034', N'Nguyễn Quốc', N'Thái', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN184', N'Nguyễn Đoàn Công', N'Tiến', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDT072', N'Lại Phúc', N'Tuấn', NULL, NULL, N'E22CQCNTT01-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCI010', N'Trần Công', N'Hậu', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCVT037', N'Ngô Việt', N'Hoàng', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN137', N'Sỳ', N'Hưng', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN133', N'Đỗ Minh Bảo', N'Huy', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDK032', N'Trương Tuấn', N'Huy', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCVT054', N'Lê Tự Minh', N'Lợi', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCVT052', N'Nguyễn Bảo', N'Long', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCAT042', N'Nguyễn Lê Bảo', N'Phong', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDK071', N'Nguyễn Minh', N'Quân', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCVT076', N'Nguyễn Văn', N'Quang', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCI033', N'Uông Ngọc', N'Sơn', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDK078', N'Đinh Trí', N'Tài', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCVT085', N'Lâm Thiên', N'Tân', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN174', N'Nguyễn Duy', N'Tân', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN076', N'Cao Duy', N'Thái', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN077', N'Nguyễn Duy', N'Thái', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCI035', N'Lữ Tất', N'Thành', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN078', N'Trần Nguyễn Sơn', N'Thành', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDT063', N'Nguyễn Hiếu', N'Thiên', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCVT093', N'Hàng Gia', N'Thịnh', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCVT099', N'Vũ Phạm Minh', N'Thức', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN185', N'Nguyễn Phúc', N'Toàn', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN186', N'Đặng Thị Bích', N'Trâm', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN188', N'Huỳnh Hữu', N'Trí', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN093', N'Đỗ Văn', N'Tú', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCAT066', N'Trần Anh', N'Tuấn', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCCN196', N'Lê Trang Hoàng', N'Vinh', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
INSERT [dbo].[SinhVien] ([MASV], [HO], [TEN], [NGAYSINH], [DIACHI], [MALOP], [IS_DELETED], [DELETED_AT], [DELETED_BY]) VALUES (N'N22DCDK095', N'Phạm Lâm Bảo', N'Vinh', NULL, NULL, N'E22CQCNTT02-N  ', 0, NULL, NULL)
GO

INSERT [dbo].[TaiKhoan] ([LOGINNAME], [MATKHAU], [ROLE_NAME], [MAGV], [IS_ACTIVE], [CREATED_AT]) VALUES (N'gv1', N'1234567', N'GIANGVIEN', N'GV000001', 1, CAST(N'2026-06-14T10:22:49.663' AS DateTime))
INSERT [dbo].[TaiKhoan] ([LOGINNAME], [MATKHAU], [ROLE_NAME], [MAGV], [IS_ACTIVE], [CREATED_AT]) VALUES (N'gv2', N'123456', N'GIANGVIEN', N'GV000002', 1, CAST(N'2026-06-14T10:22:49.663' AS DateTime))
INSERT [dbo].[TaiKhoan] ([LOGINNAME], [MATKHAU], [ROLE_NAME], [MAGV], [IS_ACTIVE], [CREATED_AT]) VALUES (N'pgv1', N'123456', N'PGV', N'GV000003', 1, CAST(N'2026-06-14T10:37:38.360' AS DateTime))
INSERT [dbo].[TaiKhoan] ([LOGINNAME], [MATKHAU], [ROLE_NAME], [MAGV], [IS_ACTIVE], [CREATED_AT]) VALUES (N'pgv2', N'123456', N'PGV', N'GV000004', 1, CAST(N'2026-06-23T09:35:54.477' AS DateTime))
GO

/* ============================================================
   PHẦN 3. INDEX, DEFAULT, FOREIGN KEY, CHECK CONSTRAINT
   ============================================================ */

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_AuditLog_Object_Time]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_AuditLog_Object_Time] ON [dbo].[AuditLog]
(
	[OBJECT_NAME] ASC,
	[EVENT_TIME] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_BackupRestoreHistory_Time]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_BackupRestoreHistory_Time] ON [dbo].[BackupRestoreHistory]
(
	[EXECUTED_AT] DESC,
	[ACTION_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [UQ_BaiThi_MASV_MAMH_LAN]    Script Date: 6/23/2026 5:21:00 PM ******/
ALTER TABLE [dbo].[BaiThi] ADD  CONSTRAINT [UQ_BaiThi_MASV_MAMH_LAN] UNIQUE NONCLUSTERED 
(
	[MASV] ASC,
	[MAMH] ASC,
	[LAN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_BaiThi_MASV_MAMH_LAN]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_BaiThi_MASV_MAMH_LAN] ON [dbo].[BaiThi]
(
	[MASV] ASC,
	[MAMH] ASC,
	[LAN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_BaiThi_TrangThai_KetThuc]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_BaiThi_TrangThai_KetThuc] ON [dbo].[BaiThi]
(
	[TRANGTHAI] ASC,
	[KETTHUC_LUC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_BangDiem_MAMH_LAN]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_BangDiem_MAMH_LAN] ON [dbo].[BangDiem]
(
	[MAMH] ASC,
	[LAN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [UQ_BoDe_MAMH_NOIDUNG]    Script Date: 6/23/2026 5:21:00 PM ******/
ALTER TABLE [dbo].[BoDe] ADD  CONSTRAINT [UQ_BoDe_MAMH_NOIDUNG] UNIQUE NONCLUSTERED 
(
	[MAMH] ASC,
	[NOIDUNG] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_BoDe_MAMH_TRINHDO]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_BoDe_MAMH_TRINHDO] ON [dbo].[BoDe]
(
	[MAMH] ASC,
	[TRINHDO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_GiaoVien_DangKy_NgayThi]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_GiaoVien_DangKy_NgayThi] ON [dbo].[GiaoVien_DangKy]
(
	[MALOP] ASC,
	[MAMH] ASC,
	[LAN] ASC,
	[NGAYTHI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_GVDK_MALOP_MAMH_LAN]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_GVDK_MALOP_MAMH_LAN] ON [dbo].[GiaoVien_DangKy]
(
	[MALOP] ASC,
	[MAMH] ASC,
	[LAN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [UQ_Lop_TENLOP]    Script Date: 6/23/2026 5:21:00 PM ******/
ALTER TABLE [dbo].[Lop] ADD  CONSTRAINT [UQ_Lop_TENLOP] UNIQUE NONCLUSTERED 
(
	[TENLOP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [UQ_MonHoc_TENMH]    Script Date: 6/23/2026 5:21:00 PM ******/
ALTER TABLE [dbo].[MonHoc] ADD  CONSTRAINT [UQ_MonHoc_TENMH] UNIQUE NONCLUSTERED 
(
	[TENMH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_SinhVien_MALOP]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_SinhVien_MALOP] ON [dbo].[SinhVien]
(
	[MALOP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_SinhVien_MALOP_TEN]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE NONCLUSTERED INDEX [IX_SinhVien_MALOP_TEN] ON [dbo].[SinhVien]
(
	[MALOP] ASC,
	[TEN] ASC,
	[HO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [UX_SinhVien_MASV]    Script Date: 6/23/2026 5:21:00 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_SinhVien_MASV] ON [dbo].[SinhVien]
(
	[MASV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AuditLog] ADD  CONSTRAINT [DF_AuditLog_EventTime]  DEFAULT (sysdatetime()) FOR [EVENT_TIME]
GO

ALTER TABLE [dbo].[AuditLog] ADD  CONSTRAINT [DF_AuditLog_DbLogin]  DEFAULT (original_login()) FOR [DB_LOGIN]
GO

ALTER TABLE [dbo].[AuditLog] ADD  CONSTRAINT [DF_AuditLog_DbUser]  DEFAULT (user_name()) FOR [DB_USER_NAME]
GO

ALTER TABLE [dbo].[AuditLog] ADD  CONSTRAINT [DF_AuditLog_AppLogin]  DEFAULT (CONVERT([nvarchar](128),session_context(N'APP_LOGINNAME'))) FOR [APP_LOGINNAME]
GO

ALTER TABLE [dbo].[BackupRestoreHistory] ADD  CONSTRAINT [DF_BackupRestoreHistory_ExecutedBy]  DEFAULT (original_login()) FOR [EXECUTED_BY]
GO

ALTER TABLE [dbo].[BackupRestoreHistory] ADD  CONSTRAINT [DF_BackupRestoreHistory_ExecutedAt]  DEFAULT (sysdatetime()) FOR [EXECUTED_AT]
GO

ALTER TABLE [dbo].[BaiThi] ADD  DEFAULT (getdate()) FOR [NGAYTHI]
GO

ALTER TABLE [dbo].[BaiThi] ADD  DEFAULT (getdate()) FOR [BATDAU_LUC]
GO

ALTER TABLE [dbo].[BaiThi] ADD  DEFAULT ((0)) FOR [THOIGIAN]
GO

ALTER TABLE [dbo].[BaiThi] ADD  DEFAULT ('DANG_THI') FOR [TRANGTHAI]
GO

ALTER TABLE [dbo].[BangDiem] ADD  CONSTRAINT [DF_BangDiem_NGAYTHI]  DEFAULT (getdate()) FOR [NGAYTHI]
GO

ALTER TABLE [dbo].[BoDe] ADD  CONSTRAINT [DF_BoDe_IsDeleted]  DEFAULT ((0)) FOR [IS_DELETED]
GO

ALTER TABLE [dbo].[GiaoVien] ADD  CONSTRAINT [DF_GiaoVien_IsDeleted]  DEFAULT ((0)) FOR [IS_DELETED]
GO

ALTER TABLE [dbo].[GiaoVien_DangKy] ADD  CONSTRAINT [DF_GVDK_NGAYTHI]  DEFAULT (getdate()) FOR [NGAYTHI]
GO

ALTER TABLE [dbo].[Lop] ADD  CONSTRAINT [DF_Lop_IsDeleted]  DEFAULT ((0)) FOR [IS_DELETED]
GO

ALTER TABLE [dbo].[MonHoc] ADD  CONSTRAINT [DF_MonHoc_IsDeleted]  DEFAULT ((0)) FOR [IS_DELETED]
GO

ALTER TABLE [dbo].[SinhVien] ADD  CONSTRAINT [DF_SinhVien_IsDeleted]  DEFAULT ((0)) FOR [IS_DELETED]
GO

ALTER TABLE [dbo].[TaiKhoan] ADD  CONSTRAINT [DF_TaiKhoan_IS_ACTIVE]  DEFAULT ((1)) FOR [IS_ACTIVE]
GO

ALTER TABLE [dbo].[TaiKhoan] ADD  CONSTRAINT [DF_TaiKhoan_CREATED_AT]  DEFAULT (getdate()) FOR [CREATED_AT]
GO

ALTER TABLE [dbo].[BaiThi]  WITH CHECK ADD  CONSTRAINT [FK_BaiThi_MonHoc] FOREIGN KEY([MAMH])
REFERENCES [dbo].[MonHoc] ([MAMH])
GO

ALTER TABLE [dbo].[BaiThi] CHECK CONSTRAINT [FK_BaiThi_MonHoc]
GO

ALTER TABLE [dbo].[BaiThi]  WITH CHECK ADD  CONSTRAINT [FK_BaiThi_SinhVien] FOREIGN KEY([MASV])
REFERENCES [dbo].[SinhVien] ([MASV])
GO

ALTER TABLE [dbo].[BaiThi] CHECK CONSTRAINT [FK_BaiThi_SinhVien]
GO

ALTER TABLE [dbo].[BaiThi_CauTraLoi]  WITH CHECK ADD  CONSTRAINT [FK_BaiThi_CauTraLoi_BaiThi] FOREIGN KEY([MABT])
REFERENCES [dbo].[BaiThi] ([MABT])
GO

ALTER TABLE [dbo].[BaiThi_CauTraLoi] CHECK CONSTRAINT [FK_BaiThi_CauTraLoi_BaiThi]
GO

ALTER TABLE [dbo].[BaiThi_CauTraLoi]  WITH CHECK ADD  CONSTRAINT [FK_BaiThi_CauTraLoi_BoDe] FOREIGN KEY([CAUHOI])
REFERENCES [dbo].[BoDe] ([CAUHOI])
GO

ALTER TABLE [dbo].[BaiThi_CauTraLoi] CHECK CONSTRAINT [FK_BaiThi_CauTraLoi_BoDe]
GO

ALTER TABLE [dbo].[BoDe]  WITH CHECK ADD  CONSTRAINT [FK_BoDe_GiaoVien] FOREIGN KEY([MAGV])
REFERENCES [dbo].[GiaoVien] ([MAGV])
GO

ALTER TABLE [dbo].[BoDe] CHECK CONSTRAINT [FK_BoDe_GiaoVien]
GO

ALTER TABLE [dbo].[BoDe]  WITH CHECK ADD  CONSTRAINT [FK_BoDe_MonHoc] FOREIGN KEY([MAMH])
REFERENCES [dbo].[MonHoc] ([MAMH])
GO

ALTER TABLE [dbo].[BoDe] CHECK CONSTRAINT [FK_BoDe_MonHoc]
GO

ALTER TABLE [dbo].[GiaoVien_DangKy]  WITH CHECK ADD  CONSTRAINT [FK_GVDK_GiaoVien] FOREIGN KEY([MAGV])
REFERENCES [dbo].[GiaoVien] ([MAGV])
GO

ALTER TABLE [dbo].[GiaoVien_DangKy] CHECK CONSTRAINT [FK_GVDK_GiaoVien]
GO

ALTER TABLE [dbo].[GiaoVien_DangKy]  WITH CHECK ADD  CONSTRAINT [FK_GVDK_Lop] FOREIGN KEY([MALOP])
REFERENCES [dbo].[Lop] ([MALOP])
GO

ALTER TABLE [dbo].[GiaoVien_DangKy] CHECK CONSTRAINT [FK_GVDK_Lop]
GO

ALTER TABLE [dbo].[GiaoVien_DangKy]  WITH CHECK ADD  CONSTRAINT [FK_GVDK_MonHoc] FOREIGN KEY([MAMH])
REFERENCES [dbo].[MonHoc] ([MAMH])
GO

ALTER TABLE [dbo].[GiaoVien_DangKy] CHECK CONSTRAINT [FK_GVDK_MonHoc]
GO

ALTER TABLE [dbo].[SinhVien]  WITH CHECK ADD  CONSTRAINT [FK_SinhVien_Lop] FOREIGN KEY([MALOP])
REFERENCES [dbo].[Lop] ([MALOP])
GO

ALTER TABLE [dbo].[SinhVien] CHECK CONSTRAINT [FK_SinhVien_Lop]
GO

ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD  CONSTRAINT [FK_TaiKhoan_GiaoVien] FOREIGN KEY([MAGV])
REFERENCES [dbo].[GiaoVien] ([MAGV])
GO

ALTER TABLE [dbo].[TaiKhoan] CHECK CONSTRAINT [FK_TaiKhoan_GiaoVien]
GO

ALTER TABLE [dbo].[BaiThi]  WITH CHECK ADD CHECK  (([DIEM]>=(0) AND [DIEM]<=(10)))
GO

ALTER TABLE [dbo].[BaiThi]  WITH CHECK ADD CHECK  (([LAN]>=(1) AND [LAN]<=(2)))
GO

ALTER TABLE [dbo].[BaiThi]  WITH CHECK ADD CHECK  (([SOCAU]>(0)))
GO

ALTER TABLE [dbo].[BaiThi]  WITH CHECK ADD CHECK  (([SOCAUDUNG]>=(0)))
GO

ALTER TABLE [dbo].[BaiThi]  WITH CHECK ADD CHECK  (([THOIGIAN]>=(0) AND [THOIGIAN]<=(60)))
GO

ALTER TABLE [dbo].[BaiThi]  WITH CHECK ADD CHECK  (([TRANGTHAI]='HET_GIO' OR [TRANGTHAI]='DA_NOP' OR [TRANGTHAI]='DANG_THI'))
GO

ALTER TABLE [dbo].[BaiThi_CauTraLoi]  WITH CHECK ADD CHECK  (([DAP_AN_DUNG]='D' OR [DAP_AN_DUNG]='C' OR [DAP_AN_DUNG]='B' OR [DAP_AN_DUNG]='A'))
GO

ALTER TABLE [dbo].[BaiThi_CauTraLoi]  WITH CHECK ADD CHECK  (([DAP_AN_CHON] IS NULL OR ([DAP_AN_CHON]='D' OR [DAP_AN_CHON]='C' OR [DAP_AN_CHON]='B' OR [DAP_AN_CHON]='A')))
GO

ALTER TABLE [dbo].[BangDiem]  WITH CHECK ADD  CONSTRAINT [CK_BangDiem_DIEM] CHECK  (([DIEM]>=(0) AND [DIEM]<=(10)))
GO

ALTER TABLE [dbo].[BangDiem] CHECK CONSTRAINT [CK_BangDiem_DIEM]
GO

ALTER TABLE [dbo].[BangDiem]  WITH CHECK ADD  CONSTRAINT [CK_BangDiem_LAN] CHECK  (([LAN]>=(1) AND [LAN]<=(2)))
GO

ALTER TABLE [dbo].[BangDiem] CHECK CONSTRAINT [CK_BangDiem_LAN]
GO

ALTER TABLE [dbo].[BoDe]  WITH CHECK ADD  CONSTRAINT [CK_BoDe_DAP_AN] CHECK  (([DAP_AN]=N'D' OR [DAP_AN]=N'C' OR [DAP_AN]=N'B' OR [DAP_AN]=N'A'))
GO

ALTER TABLE [dbo].[BoDe] CHECK CONSTRAINT [CK_BoDe_DAP_AN]
GO

ALTER TABLE [dbo].[BoDe]  WITH CHECK ADD  CONSTRAINT [CK_BoDe_TRINHDO] CHECK  (([TRINHDO]='C' OR [TRINHDO]='B' OR [TRINHDO]='A'))
GO

ALTER TABLE [dbo].[BoDe] CHECK CONSTRAINT [CK_BoDe_TRINHDO]
GO

ALTER TABLE [dbo].[GiaoVien_DangKy]  WITH CHECK ADD  CONSTRAINT [CK_GVDK_LAN] CHECK  (([LAN]>=(1) AND [LAN]<=(2)))
GO

ALTER TABLE [dbo].[GiaoVien_DangKy] CHECK CONSTRAINT [CK_GVDK_LAN]
GO

ALTER TABLE [dbo].[GiaoVien_DangKy]  WITH CHECK ADD  CONSTRAINT [CK_GVDK_SOCAUTHI] CHECK  (([SOCAUTHI]>=(10) AND [SOCAUTHI]<=(100)))
GO

ALTER TABLE [dbo].[GiaoVien_DangKy] CHECK CONSTRAINT [CK_GVDK_SOCAUTHI]
GO

ALTER TABLE [dbo].[GiaoVien_DangKy]  WITH CHECK ADD  CONSTRAINT [CK_GVDK_THOIGIAN] CHECK  (([THOIGIAN]>=(5) AND [THOIGIAN]<=(60)))
GO

ALTER TABLE [dbo].[GiaoVien_DangKy] CHECK CONSTRAINT [CK_GVDK_THOIGIAN]
GO

ALTER TABLE [dbo].[GiaoVien_DangKy]  WITH CHECK ADD  CONSTRAINT [CK_GVDK_TRINHDO] CHECK  (([TRINHDO]=N'C' OR [TRINHDO]=N'B' OR [TRINHDO]=N'A'))
GO

ALTER TABLE [dbo].[GiaoVien_DangKy] CHECK CONSTRAINT [CK_GVDK_TRINHDO]
GO

ALTER TABLE [dbo].[Lop]  WITH CHECK ADD  CONSTRAINT [CK_Lop_MALOP_Upper] CHECK  ((([MALOP]) collate Latin1_General_BIN2=(upper([MALOP])) collate Latin1_General_BIN2))
GO

ALTER TABLE [dbo].[Lop] CHECK CONSTRAINT [CK_Lop_MALOP_Upper]
GO

ALTER TABLE [dbo].[MonHoc]  WITH CHECK ADD  CONSTRAINT [CK_MonHoc_MAMH_Upper] CHECK  ((([MAMH]) collate Latin1_General_BIN2=(upper([MAMH])) collate Latin1_General_BIN2))
GO

ALTER TABLE [dbo].[MonHoc] CHECK CONSTRAINT [CK_MonHoc_MAMH_Upper]
GO

ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD  CONSTRAINT [CK_TaiKhoan_MAGV] CHECK  ((([ROLE_NAME]=N'GIANGVIEN' OR [ROLE_NAME]=N'PGV') AND [MAGV] IS NOT NULL))
GO

ALTER TABLE [dbo].[TaiKhoan] CHECK CONSTRAINT [CK_TaiKhoan_MAGV]
GO

ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD  CONSTRAINT [CK_TaiKhoan_ROLE] CHECK  (([ROLE_NAME]=N'GIANGVIEN' OR [ROLE_NAME]=N'PGV'))
GO

ALTER TABLE [dbo].[TaiKhoan] CHECK CONSTRAINT [CK_TaiKhoan_ROLE]
GO

SET NOEXEC OFF;
