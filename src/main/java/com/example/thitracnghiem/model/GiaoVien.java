package com.example.thitracnghiem.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

@Entity
@Table(name = "GiaoVien")
public class GiaoVien {

    @Id
    @Column(name = "MAGV", length = 8)
    private String maGv;

    @Column(name = "HO", length = 40)
    private String ho;

    @Column(name = "TEN", length = 10)
    private String ten;

    @Column(name = "SODTLL", length = 15)
    private String soDtll;

    @Column(name = "DIACHI", length = 50)
    private String diaChi;

    public String getMaGv() {
        return maGv;
    }

    public void setMaGv(String maGv) {
        this.maGv = maGv;
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

    public String getSoDtll() {
        return soDtll;
    }

    public void setSoDtll(String soDtll) {
        this.soDtll = soDtll;
    }

    public String getDiaChi() {
        return diaChi;
    }

    public void setDiaChi(String diaChi) {
        this.diaChi = diaChi;
    }

    @Transient
    public String getHoTen() {
        return ((ho == null ? "" : ho.trim()) + " " + (ten == null ? "" : ten.trim())).trim();
    }
}
