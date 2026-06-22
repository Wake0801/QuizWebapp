package com.example.thitracnghiem.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.thitracnghiem.model.GiaoVienDangKy;
import com.example.thitracnghiem.model.GiaoVienDangKyId;

public interface GiaoVienDangKyRepository extends JpaRepository<GiaoVienDangKy, GiaoVienDangKyId> {

    @Query("""
            select dk
            from GiaoVienDangKy dk
            order by dk.ngayThi desc, dk.maLop, dk.maMh, dk.lan
            """)
    List<GiaoVienDangKy> findAllOrdered();

    Optional<GiaoVienDangKy> findByMaLopAndMaMhAndLan(String maLop, String maMh, Short lan);

    List<GiaoVienDangKy> findByMaLopOrderByNgayThiDescMaMhAscLanAsc(String maLop);

    @Query("""
            select dk
            from GiaoVienDangKy dk
            where dk.maLop = :maLop
              and not exists (
                  select bd
                  from BangDiem bd
                  where bd.maSv = :maSv
                    and bd.maMh = dk.maMh
                    and bd.lan = dk.lan
              )
            order by dk.ngayThi desc, dk.maMh, dk.lan
            """)
    List<GiaoVienDangKy> findAvailableForStudent(@Param("maSv") String maSv, @Param("maLop") String maLop);
}
