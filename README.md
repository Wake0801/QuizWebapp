# QuizWebapp - He thong thi trac nghiem SQL Server

Du an la ung dung thi trac nghiem cho mon He Quan Tri Co So Du Lieu, tap trung vao xu ly nghiep vu tai tang SQL Server: stored procedure, trigger, view, phan quyen, audit, backup va restore.

## Cau truc file DB

Thu muc `database/` chua cac file SQL bo sung cho phan HQT CSDL:

- `database/db_nghiepvu_thi.sql`: bo sung bang nghiep vu bai thi, view, function, stored procedure, index, phan quyen va chan truy cap truc tiep bang goc.
- `database/db_triggers_thi.sql`: trigger kiem tra rang buoc nghiep vu va audit thay doi du lieu.
- `database/db_backup_restore.sql`: procedure backup full, backup log, liet ke backup, restore full va restore theo thoi diem.
- `database/db_sql_agent_jobs.sql`: SQL Server Agent Job tu dong nop bai khi bai thi het gio.
- `database/db_test_cases.sql`: script kiem thu nhanh cac function, procedure, trigger, audit va quyen truy cap.

File `thitracnghiem_db.sql` la file DB tong tao schema va du lieu nen chay truoc cac file trong `database/`.

## Thu tu khoi tao database

Chay trong SQL Server Management Studio theo thu tu:

```sql
-- 1. Tao database tong, bang goc, du lieu mau
:r .\thitracnghiem_db.sql

-- 2. Them nghiep vu thi, SP, view, function, phan quyen
:r .\database\db_nghiepvu_thi.sql

-- 3. Them trigger kiem soat du lieu va audit
:r .\database\db_triggers_thi.sql

-- 4. Them backup/restore procedure
:r .\database\db_backup_restore.sql

-- 5. Tuy chon: tao SQL Server Agent Job tu dong nop bai het gio
:r .\database\db_sql_agent_jobs.sql

-- 6. Tuy chon: chay bo test DB
:r .\database\db_test_cases.sql
```

Neu khong dung SQLCMD Mode trong SSMS, co the mo tung file va execute theo dung thu tu tren.

## Nghiep vu CSDL da trien khai

### Dang ky thi

Procedure `sp_DangKyThi` cho giao vien/PGV tao hoac cap nhat lich thi theo lop, mon, lan thi. DB kiem tra lan thi chi duoc 1 hoac 2, so cau tu 10 den 100, thoi gian tu 5 den 60 phut va bo de phai du cau theo quy tac trinh do 70/30.

Trigger `trg_GiaoVienDangKy_KiemTraHopLe` tiep tuc bao ve o tang DB: khong cho lich thi qua khu, khong cho dang ky lop chua co sinh vien, khong cho sua lich da phat sinh bai thi hoac bang diem.

### Phat de va xao dap an

Procedure `sp_Thi_PhatDeNgauNhien` phat de theo lich thi cua sinh vien. Cau hoi duoc lay ngau nhien bang `ORDER BY NEWID()`. Voi trinh do A/B, DB lay toi thieu 70% cau dung trinh do va toi da 30% cau thap hon. Voi trinh do C, DB chi lay cau C.

Dap an A/B/C/D duoc xao rieng tung cau bang 24 hoan vi. DB tinh lai `DAP_AN_MOI` sau khi xao, nen dap an dung khong bi lech voi noi dung dap an.

### Bat dau thi va tiep tuc bai dang thi

Procedure `sp_BatDauThi` tao bai thi trong transaction. Neu sinh vien da co bai `DANG_THI`, DB tra ve lai `MABT` cu thay vi phat de moi. Vi vay neu dang thi bi ngat, dang nhap lai se tiep tuc bai dang lam va giu dung thoi gian con lai.

Bai thi duoc luu trong `BaiThi`, tung cau va dap an da xao duoc luu trong `BaiThi_CauTraLoi`.

### Luu dap an va nop bai

Procedure `sp_LuuTamCauTraLoi` luu dap an sinh vien chon. DB chi cho luu khi bai thi dang o trang thai `DANG_THI` va chua het gio.

Procedure `sp_NopBai` dem so cau dung, tinh diem bang `fn_TinhDiemThi`, ghi vao `BangDiem`, cap nhat trang thai `DA_NOP` hoac `HET_GIO`.

Procedure `sp_TTN_TuDongNopBaiHetGio` xu ly cac bai thi da qua `KETTHUC_LUC` nhung chua nop. File `db_sql_agent_jobs.sql` tao job chay moi 1 phut de goi procedure nay.

### Tra cuu ket qua va bang diem

Procedure `sp_TraCuuKetQua` tra ve thong tin tong quan bai thi va chi tiet tung cau tra loi.

Procedure `sp_BangDiemMonHoc` tra bang diem theo lop, mon, lan thi. Chuc nang export Excel tren web lay du lieu tu luong nay.

View `v_4_8_KetQuaThi` va `v_4_9_BangDiem_Thi` ho tro xem ket qua, dap an va diem chu.

## Trigger va audit

File `database/db_triggers_thi.sql` gom cac trigger chinh:

- `trg_Lop_KhongXoaKhiConSinhVien`: khong cho xoa lop khi con sinh vien.
- `trg_SinhVien_KhongXoaKhiDaCoDiem`: khong cho xoa sinh vien da co diem hoac bai thi.
- `trg_GiaoVienDangKy_KiemTraHopLe`: kiem tra lich thi hop le.
- `trg_BangDiem_KiemTraHopLe`: chan diem ngoai khoang 0-10 va chan ghi diem khi khong co lich thi.
- `trg_BaiThiCauTraLoi_KiemTraHopLe`: chan sua cau tra loi khi bai da nop/het gio.
- `trg_Audit_GiaoVienDangKy`: ghi audit lich thi.
- `trg_Audit_BoDe`: ghi audit ngan hang cau hoi.
- `trg_Audit_BangDiem`: ghi audit thay doi diem.
- `trg_Audit_TaiKhoan`: ghi audit thay doi tai khoan.

Bang `AuditLog` luu thoi diem, SQL login, database user, login ung dung `APP_LOGINNAME`, bang bi tac dong, hanh dong va mo ta chi tiet.

## Phan quyen CSDL

He thong dung cac role:

- `Sinhvien`: duoc bat dau thi, luu dap an, nop bai, xem ket qua qua SP/view.
- `Giangvien`: duoc dang ky thi, thi thu, xem bang diem, quan ly cau hoi cua minh.
- `PGV`: co quyen quan tri cao hon, tao tai khoan, xem audit, chay backup.

Script nghiep vu co `DENY SELECT, INSERT, UPDATE, DELETE` truc tiep tren cac bang goc cho cac role ung dung. Nguoi dung phai thao tac qua stored procedure va view da duoc cap quyen.

## Backup va restore

File `database/db_backup_restore.sql` tao:

- `BackupRestoreHistory`: luu lich su backup/restore.
- `sp_TTN_Backup_TaoDevice`: tao backup device.
- `sp_TTN_Backup_Full`: backup full database va verify bang `RESTORE VERIFYONLY`.
- `sp_TTN_Backup_Log`: backup transaction log de phuc vu restore theo thoi diem.
- `sp_TTN_Backup_DanhSach`: liet ke backup tu `msdb`.
- `master.dbo.sp_TTN_Restore_Full`: restore full backup.
- `master.dbo.sp_TTN_Restore_PointInTime`: restore ve mot thoi diem bang full backup va log backup.
- `master.dbo.sp_TTN_Restore_SinhLenh`: sinh cau lenh restore de demo an toan.

Vi du backup:

```sql
EXEC dbo.sp_TTN_Backup_TaoDevice;
EXEC dbo.sp_TTN_Backup_Full;
EXEC dbo.sp_TTN_Backup_DanhSach;
```

Muon restore theo thoi diem, database can dung recovery model `FULL` va phai co log backup:

```sql
ALTER DATABASE [THI_TRAC_NGHIEM] SET RECOVERY FULL;
EXEC dbo.sp_TTN_Backup_Full;
EXEC dbo.sp_TTN_Backup_Log;
```

## Chay ung dung

Cap nhat ket noi SQL Server trong `src/main/resources/application.yml`, sau do chay:

```powershell
mvn spring-boot:run
```

Build/test nhanh:

```powershell
mvn test
```

