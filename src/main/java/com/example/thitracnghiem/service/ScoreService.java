package com.example.thitracnghiem.service;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.example.thitracnghiem.dto.ScoreRow;

@Service
public class ScoreService {

    private final JdbcTemplate jdbcTemplate;

    public ScoreService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<ScoreRow> findScoreBoard(String maLop, String maMh, Short lan) {
        StringBuilder sql = new StringBuilder("""
                SELECT
                    SV.MASV,
                    SV.HO,
                    SV.TEN,
                    RTRIM(LTRIM(ISNULL(SV.HO, N''))) + N' ' + RTRIM(LTRIM(ISNULL(SV.TEN, N''))) AS HOTEN,
                    SV.MALOP,
                    L.TENLOP,
                    BD.MAMH,
                    MH.TENMH,
                    BD.LAN,
                    BD.NGAYTHI,
                    BD.DIEM,
                    CASE
                        WHEN BD.DIEM IS NULL THEN N''
                        WHEN BD.DIEM >= 8.5 THEN N'A'
                        WHEN BD.DIEM >= 7.0 THEN N'B'
                        WHEN BD.DIEM >= 5.5 THEN N'C'
                        WHEN BD.DIEM >= 4.0 THEN N'D'
                        ELSE N'F'
                    END AS DIEM_CHU
                FROM dbo.SinhVien SV
                LEFT JOIN dbo.Lop L ON L.MALOP = SV.MALOP
                LEFT JOIN dbo.BangDiem BD ON BD.MASV = SV.MASV
                LEFT JOIN dbo.MonHoc MH ON MH.MAMH = BD.MAMH
                WHERE 1 = 1
                """);
        List<Object> params = new ArrayList<>();

        if (StringUtils.hasText(maLop)) {
            sql.append(" AND SV.MALOP = ?");
            params.add(normalizeCode(maLop));
        }
        if (StringUtils.hasText(maMh)) {
            sql.append(" AND BD.MAMH = ?");
            params.add(normalizeCode(maMh));
        }
        if (lan != null) {
            sql.append(" AND BD.LAN = ?");
            params.add(lan);
        }
        sql.append(" ORDER BY SV.TEN, SV.HO, SV.MASV, BD.MAMH, BD.LAN");

        return jdbcTemplate.query(
                sql.toString(),
                ps -> {
                    for (int i = 0; i < params.size(); i++) {
                        ps.setObject(i + 1, params.get(i));
                    }
                },
                (rs, rowNum) -> {
                    ScoreRow row = new ScoreRow();
                    row.setMaSv(trim(rs.getString("MASV")));
                    row.setHo(rs.getString("HO"));
                    row.setTen(rs.getString("TEN"));
                    row.setHoTen(rs.getString("HOTEN"));
                    row.setMaLop(trim(rs.getString("MALOP")));
                    row.setTenLop(rs.getString("TENLOP"));
                    row.setMaMh(trim(rs.getString("MAMH")));
                    row.setTenMh(rs.getString("TENMH"));
                    short lanValue = rs.getShort("LAN");
                    row.setLan(rs.wasNull() ? null : lanValue);
                    Date ngayThi = rs.getDate("NGAYTHI");
                    row.setNgayThi(ngayThi == null ? null : ngayThi.toLocalDate());
                    double diem = rs.getDouble("DIEM");
                    row.setDiem(rs.wasNull() ? null : diem);
                    row.setDiemChu(rs.getString("DIEM_CHU"));
                    return row;
                }
        );
    }

    private String normalizeCode(String value) {
        return value == null ? null : value.trim().toUpperCase();
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
