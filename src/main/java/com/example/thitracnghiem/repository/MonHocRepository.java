package com.example.thitracnghiem.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.thitracnghiem.model.MonHoc;

public interface MonHocRepository extends JpaRepository<MonHoc, String> {

    List<MonHoc> findAllByOrderByMaMhAsc();
}
