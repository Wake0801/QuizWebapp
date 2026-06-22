package com.example.thitracnghiem.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.thitracnghiem.model.GiaoVien;

public interface GiaoVienRepository extends JpaRepository<GiaoVien, String> {

    List<GiaoVien> findAllByOrderByTenAscHoAscMaGvAsc();
}
