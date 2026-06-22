package com.example.thitracnghiem.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.thitracnghiem.model.GiaoVien;
import com.example.thitracnghiem.model.Lop;
import com.example.thitracnghiem.model.MonHoc;
import com.example.thitracnghiem.repository.GiaoVienRepository;
import com.example.thitracnghiem.repository.LopRepository;
import com.example.thitracnghiem.repository.MonHocRepository;

@Service
public class CatalogService {

    private final LopRepository lopRepository;
    private final MonHocRepository monHocRepository;
    private final GiaoVienRepository giaoVienRepository;

    public CatalogService(
            LopRepository lopRepository,
            MonHocRepository monHocRepository,
            GiaoVienRepository giaoVienRepository
    ) {
        this.lopRepository = lopRepository;
        this.monHocRepository = monHocRepository;
        this.giaoVienRepository = giaoVienRepository;
    }

    public List<Lop> findAllLop() {
        return lopRepository.findAllByOrderByMaLopAsc();
    }

    public List<MonHoc> findAllMonHoc() {
        return monHocRepository.findAllByOrderByMaMhAsc();
    }

    public List<GiaoVien> findAllGiaoVien() {
        return giaoVienRepository.findAllByOrderByTenAscHoAscMaGvAsc();
    }
}
