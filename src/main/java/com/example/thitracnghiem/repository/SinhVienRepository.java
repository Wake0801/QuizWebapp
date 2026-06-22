package com.example.thitracnghiem.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.thitracnghiem.model.SinhVien;

public interface SinhVienRepository extends JpaRepository<SinhVien, String> {

    List<SinhVien> findAllByOrderByMaLopAscTenAscHoAscMaSvAsc();

    List<SinhVien> findByMaLopOrderByTenAscHoAscMaSvAsc(String maLop);

    @Query("""
            select sv
            from SinhVien sv
            where lower(sv.maSv) like lower(concat('%', :keyword, '%'))
               or lower(coalesce(sv.ho, '')) like lower(concat('%', :keyword, '%'))
               or lower(coalesce(sv.ten, '')) like lower(concat('%', :keyword, '%'))
               or lower(coalesce(sv.maLop, '')) like lower(concat('%', :keyword, '%'))
            order by sv.maLop, sv.ten, sv.ho, sv.maSv
            """)
    List<SinhVien> search(@Param("keyword") String keyword);
}
