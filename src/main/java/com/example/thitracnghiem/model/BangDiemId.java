package com.example.thitracnghiem.model;

import java.io.Serializable;
import java.util.Objects;

public class BangDiemId implements Serializable {

    private String maSv;
    private String maMh;
    private Short lan;

    public BangDiemId() {
    }

    public BangDiemId(String maSv, String maMh, Short lan) {
        this.maSv = maSv;
        this.maMh = maMh;
        this.lan = lan;
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

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof BangDiemId that)) {
            return false;
        }
        return Objects.equals(maSv, that.maSv)
                && Objects.equals(maMh, that.maMh)
                && Objects.equals(lan, that.lan);
    }

    @Override
    public int hashCode() {
        return Objects.hash(maSv, maMh, lan);
    }
}
