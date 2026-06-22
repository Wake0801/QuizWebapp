package com.example.thitracnghiem.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.thitracnghiem.model.BangDiem;
import com.example.thitracnghiem.model.BangDiemId;

public interface BangDiemRepository extends JpaRepository<BangDiem, BangDiemId> {

    boolean existsByMaSv(String maSv);

    boolean existsByMaSvAndMaMhAndLan(String maSv, String maMh, Short lan);

    List<BangDiem> findByMaSvOrderByMaMhAscLanAsc(String maSv);
}
