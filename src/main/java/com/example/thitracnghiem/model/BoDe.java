package com.example.thitracnghiem.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "BoDe")
public class BoDe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CAUHOI")
    private Integer cauHoi;

    @Column(name = "MAMH", length = 5)
    private String maMh;

    @Column(name = "TRINHDO", length = 1)
    private String trinhDo;

    @Column(name = "NOIDUNG", length = 200)
    private String noiDung;

    @Column(name = "A", length = 50)
    private String a;

    @Column(name = "B", length = 50)
    private String b;

    @Column(name = "C", length = 50)
    private String c;

    @Column(name = "D", length = 50)
    private String d;

    @Column(name = "DAP_AN", length = 1)
    private String dapAn;

    @Column(name = "MAGV", length = 8)
    private String maGv;

    public Integer getCauHoi() {
        return cauHoi;
    }

    public void setCauHoi(Integer cauHoi) {
        this.cauHoi = cauHoi;
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

    public String getNoiDung() {
        return noiDung;
    }

    public void setNoiDung(String noiDung) {
        this.noiDung = noiDung;
    }

    public String getA() {
        return a;
    }

    public void setA(String a) {
        this.a = a;
    }

    public String getB() {
        return b;
    }

    public void setB(String b) {
        this.b = b;
    }

    public String getC() {
        return c;
    }

    public void setC(String c) {
        this.c = c;
    }

    public String getD() {
        return d;
    }

    public void setD(String d) {
        this.d = d;
    }

    public String getDapAn() {
        return dapAn;
    }

    public void setDapAn(String dapAn) {
        this.dapAn = dapAn;
    }

    public String getMaGv() {
        return maGv;
    }

    public void setMaGv(String maGv) {
        this.maGv = maGv;
    }
}
