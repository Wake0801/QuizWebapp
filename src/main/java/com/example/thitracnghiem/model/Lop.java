package com.example.thitracnghiem.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Lop")
public class Lop {

    @Id
    @Column(name = "MALOP", length = 15)
    private String maLop;

    @Column(name = "TENLOP", nullable = false, length = 40)
    private String tenLop;

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
}
