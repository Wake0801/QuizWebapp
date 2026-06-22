package com.example.thitracnghiem.dto;

public class ExamSubmitResult {

    private Long maBt;
    private int soCau;
    private int soCauDung;
    private double diem;
    private String maSv;
    private String maMh;
    private Short lan;

    public Long getMaBt() {
        return maBt;
    }

    public void setMaBt(Long maBt) {
        this.maBt = maBt;
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
}
