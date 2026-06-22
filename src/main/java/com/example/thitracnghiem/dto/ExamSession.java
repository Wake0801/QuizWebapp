package com.example.thitracnghiem.dto;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ExamSession implements Serializable {

    private String maSv;
    private Long maBt;
    private String hoTenSinhVien;
    private String maLop;
    private String tenLop;
    private String maMh;
    private String tenMh;
    private Short lan;
    private Short thoiGian;
    private LocalDateTime batDauLuc;
    private LocalDateTime ketThucLuc;
    private long remainingSeconds;
    private String trangThai;
    private List<ExamQuestion> questions = new ArrayList<>();

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

    public String getHoTenSinhVien() {
        return hoTenSinhVien;
    }

    public void setHoTenSinhVien(String hoTenSinhVien) {
        this.hoTenSinhVien = hoTenSinhVien;
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

    public Short getThoiGian() {
        return thoiGian;
    }

    public void setThoiGian(Short thoiGian) {
        this.thoiGian = thoiGian;
    }

    public LocalDateTime getBatDauLuc() {
        return batDauLuc;
    }

    public void setBatDauLuc(LocalDateTime batDauLuc) {
        this.batDauLuc = batDauLuc;
    }

    public LocalDateTime getKetThucLuc() {
        return ketThucLuc;
    }

    public void setKetThucLuc(LocalDateTime ketThucLuc) {
        this.ketThucLuc = ketThucLuc;
    }

    public long getRemainingSeconds() {
        return remainingSeconds;
    }

    public void setRemainingSeconds(long remainingSeconds) {
        this.remainingSeconds = remainingSeconds;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public List<ExamQuestion> getQuestions() {
        return questions;
    }

    public void setQuestions(List<ExamQuestion> questions) {
        this.questions = questions;
    }
}
