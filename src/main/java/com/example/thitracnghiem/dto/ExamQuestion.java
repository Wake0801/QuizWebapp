package com.example.thitracnghiem.dto;

import java.io.Serializable;

public class ExamQuestion implements Serializable {

    private Integer cauHoi;
    private String noiDung;
    private String a;
    private String b;
    private String c;
    private String d;
    private String dapAnDung;
    private String dapAnChon;
    private String trinhDoCau;

    public Integer getCauHoi() {
        return cauHoi;
    }

    public void setCauHoi(Integer cauHoi) {
        this.cauHoi = cauHoi;
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

    public String getDapAnDung() {
        return dapAnDung;
    }

    public void setDapAnDung(String dapAnDung) {
        this.dapAnDung = dapAnDung;
    }

    public String getDapAnChon() {
        return dapAnChon;
    }

    public void setDapAnChon(String dapAnChon) {
        this.dapAnChon = dapAnChon;
    }

    public String getTrinhDoCau() {
        return trinhDoCau;
    }

    public void setTrinhDoCau(String trinhDoCau) {
        this.trinhDoCau = trinhDoCau;
    }
}
