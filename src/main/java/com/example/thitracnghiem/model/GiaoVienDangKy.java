package com.example.thitracnghiem.model;

import java.time.LocalDateTime;

import org.springframework.format.annotation.DateTimeFormat;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@Table(name = "GiaoVien_DangKy")
@IdClass(GiaoVienDangKyId.class)
public class GiaoVienDangKy {

    @Column(name = "MAGV", nullable = false, length = 8)
    private String maGv;

    @Id
    @Column(name = "MALOP", length = 15)
    private String maLop;

    @Id
    @Column(name = "MAMH", length = 5)
    private String maMh;

    @Column(name = "TRINHDO", length = 1)
    private String trinhDo;

    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    @Column(name = "NGAYTHI")
    private LocalDateTime ngayThi;

    @Id
    @Column(name = "LAN")
    private Short lan;

    @Column(name = "SOCAUTHI")
    private Short soCauThi;

    @Column(name = "THOIGIAN")
    private Short thoiGian;

    public String getMaGv() {
        return maGv;
    }

    public void setMaGv(String maGv) {
        this.maGv = maGv;
    }

    public String getMaLop() {
        return maLop;
    }

    public void setMaLop(String maLop) {
        this.maLop = maLop;
    }

    public String getMaMh() {
        return maMh;
    }

    public void setMaMh(String maMh) {
        this.maMh = maMh;
    }

    public String getTrinhDo() {
        return trinhDo;
    }

    public void setTrinhDo(String trinhDo) {
        this.trinhDo = trinhDo;
    }

    public LocalDateTime getNgayThi() {
        return ngayThi;
    }

    public void setNgayThi(LocalDateTime ngayThi) {
        this.ngayThi = ngayThi;
    }

    public Short getLan() {
        return lan;
    }

    public void setLan(Short lan) {
        this.lan = lan;
    }

    public Short getSoCauThi() {
        return soCauThi;
    }

    public void setSoCauThi(Short soCauThi) {
        this.soCauThi = soCauThi;
    }

    public Short getThoiGian() {
        return thoiGian;
    }

    public void setThoiGian(Short thoiGian) {
        this.thoiGian = thoiGian;
    }
}
