package com.example.thitracnghiem.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "MonHoc")
public class MonHoc {

    @Id
    @Column(name = "MAMH", length = 5)
    private String maMh;

    @Column(name = "TENMH", nullable = false, length = 40)
    private String tenMh;

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
}
