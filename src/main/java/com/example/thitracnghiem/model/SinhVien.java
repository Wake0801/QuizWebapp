package com.example.thitracnghiem.model;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

@Entity
@Table(name = "SinhVien")
public class SinhVien {

    @Id
    @Column(name = "MASV", length = 10)
    private String maSv;

    @Column(name = "HO", length = 40)
    private String ho;

    @Column(name = "TEN", length = 10)
    private String ten;

    @Column(name = "NGAYSINH")
    private LocalDate ngaySinh;

    @Column(name = "DIACHI", length = 100)
    private String diaChi;

    @Column(name = "MALOP", length = 15)
    private String maLop;

    public String getMaSv() {
        return maSv;
    }

    public void setMaSv(String maSv) {
        this.maSv = maSv;
    }

    public String getHo() {
        return ho;
    }

    public void setHo(String ho) {
        this.ho = ho;
    }

    public String getTen() {
        return ten;
    }

    public void setTen(String ten) {
        this.ten = ten;
    }

    public LocalDate getNgaySinh() {
        return ngaySinh;
    }

    public void setNgaySinh(LocalDate ngaySinh) {
        this.ngaySinh = ngaySinh;
    }

    public String getDiaChi() {
        return diaChi;
    }

    public void setDiaChi(String diaChi) {
        this.diaChi = diaChi;
    }

    public String getMaLop() {
        return maLop;
    }

    public void setMaLop(String maLop) {
        this.maLop = maLop;
    }

    @Transient
    public String getHoTen() {
        return ((ho == null ? "" : ho.trim()) + " " + (ten == null ? "" : ten.trim())).trim();
    }
}
