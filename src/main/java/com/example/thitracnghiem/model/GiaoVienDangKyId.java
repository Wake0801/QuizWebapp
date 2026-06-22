package com.example.thitracnghiem.model;

import java.io.Serializable;
import java.util.Objects;

public class GiaoVienDangKyId implements Serializable {

    private String maLop;
    private String maMh;
    private Short lan;

    public GiaoVienDangKyId() {
    }

    public GiaoVienDangKyId(String maLop, String maMh, Short lan) {
        this.maLop = maLop;
        this.maMh = maMh;
        this.lan = lan;
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
        if (!(o instanceof GiaoVienDangKyId that)) {
            return false;
        }
        return Objects.equals(maLop, that.maLop)
                && Objects.equals(maMh, that.maMh)
                && Objects.equals(lan, that.lan);
    }

    @Override
    public int hashCode() {
        return Objects.hash(maLop, maMh, lan);
    }
}
