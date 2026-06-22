package com.example.thitracnghiem.dto;

import java.time.LocalDateTime;

public class ExamResultSummary {

    private Long maBt;
    private String maSv;
    private String hoTen;
    private String maLop;
    private String tenLop;
    private String maMh;
    private String tenMh;
    private Short lan;
    private LocalDateTime ngayThi;
    private int soCau;
    private int soCauDung;
    private double diem;

    public Long getMaBt() {
        return maBt;
    }

    public void setMaBt(Long maBt) {
        this.maBt = maBt;
    }

    public String getMaSv() {
        return maSv;
    }

    public void setMaSv(String maSv) {
        this.maSv = maSv;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public String getMaLop() {
        return maLop;
    }

    public void setMaLop(String maLop) {
        this.maLop = maLop;
    }

    public String getTenLop() {
        return tenLop;
    }

    public void setTenLop(String tenLop) {
        this.tenLop = tenLop;
    }

    public String getMaMh() {
        return maMh;
    }

    public void setMaMh(String maMh) {
        this.maMh = maMh;
    }

    public String getTenMh() {
        return tenMh;
    }

    public void setTenMh(String tenMh) {
        this.tenMh = tenMh;
    }

    public Short getLan() {
        return lan;
    }

    public void setLan(Short lan) {
        this.lan = lan;
    }

    public LocalDateTime getNgayThi() {
        return ngayThi;
    }

    public void setNgayThi(LocalDateTime ngayThi) {
        this.ngayThi = ngayThi;
    }

    public int getSoCau() {
        return soCau;
    }

    public void setSoCau(int soCau) {
        this.soCau = soCau;
    }

    public int getSoCauDung() {
        return soCauDung;
    }

    public void setSoCauDung(int soCauDung) {
        this.soCauDung = soCauDung;
    }

    public double getDiem() {
        return diem;
    }

    public void setDiem(double diem) {
        this.diem = diem;
    }
}
