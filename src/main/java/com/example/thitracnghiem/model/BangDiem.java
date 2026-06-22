package com.example.thitracnghiem.model;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@Table(name = "BangDiem")
@IdClass(BangDiemId.class)
public class BangDiem {

    @Id
    @Column(name = "MASV", length = 10)
    private String maSv;

    @Id
    @Column(name = "MAMH", length = 5)
    private String maMh;

    @Id
    @Column(name = "LAN")
    private Short lan;

    @Column(name = "NGAYTHI")
    private LocalDate ngayThi;

    @Column(name = "DIEM")
    private Double diem;

    public String getMaSv() {
        return maSv;
    }

    public void setMaSv(String maSv) {
        this.maSv = maSv;
    }

    public String getMaMh() {
        return maMh;
    }

    public void setMaMh(String maMh) {
        this.maMh = maMh;
    }

    public Short getLan() {
        return lan;
    }

    public void setLan(Short lan) {
        this.lan = lan;
    }

    public LocalDate getNgayThi() {
        return ngayThi;
    }

    public void setNgayThi(LocalDate ngayThi) {
        this.ngayThi = ngayThi;
    }

    public Double getDiem() {
        return diem;
    }

    public void setDiem(Double diem) {
        this.diem = diem;
    }
}
