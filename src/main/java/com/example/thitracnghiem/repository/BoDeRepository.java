package com.example.thitracnghiem.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.thitracnghiem.model.BoDe;

public interface BoDeRepository extends JpaRepository<BoDe, Integer> {

    long countByMaMhAndTrinhDo(String maMh, String trinhDo);
}
