package com.example.thitracnghiem.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.thitracnghiem.model.Lop;

public interface LopRepository extends JpaRepository<Lop, String> {

    List<Lop> findAllByOrderByMaLopAsc();
}
