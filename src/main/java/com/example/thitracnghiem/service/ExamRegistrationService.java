package com.example.thitracnghiem.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.example.thitracnghiem.model.GiaoVienDangKy;
import com.example.thitracnghiem.repository.BoDeRepository;
import com.example.thitracnghiem.repository.GiaoVienDangKyRepository;
import com.example.thitracnghiem.repository.GiaoVienRepository;
import com.example.thitracnghiem.repository.LopRepository;
import com.example.thitracnghiem.repository.MonHocRepository;
import com.example.thitracnghiem.support.SqlAuditContext;

@Service
public class ExamRegistrationService {

    private final GiaoVienDangKyRepository registrationRepository;
    private final GiaoVienRepository giaoVienRepository;
    private final LopRepository lopRepository;
    private final MonHocRepository monHocRepository;
    private final BoDeRepository boDeRepository;
    private final JdbcTemplate jdbcTemplate;
    private final SqlAuditContext auditContext;

    public ExamRegistrationService(
            GiaoVienDangKyRepository registrationRepository,
            GiaoVienRepository giaoVienRepository,
            LopRepository lopRepository,
            MonHocRepository monHocRepository,
            BoDeRepository boDeRepository,
            JdbcTemplate jdbcTemplate,
            SqlAuditContext auditContext
    ) {
        this.registrationRepository = registrationRepository;
        this.giaoVienRepository = giaoVienRepository;
        this.lopRepository = lopRepository;
        this.monHocRepository = monHocRepository;
        this.boDeRepository = boDeRepository;
        this.jdbcTemplate = jdbcTemplate;
        this.auditContext = auditContext;
    }

    public List<GiaoVienDangKy> findAll() {
        return registrationRepository.findAllOrdered();
    }

    public GiaoVienDangKy newForm() {
        GiaoVienDangKy form = new GiaoVienDangKy();
        form.setLan((short) 1);
        form.setTrinhDo("B");
        form.setSoCauThi((short) 10);
        form.setThoiGian((short) 15);
        form.setNgayThi(LocalDateTime.now().plusDays(1).withSecond(0).withNano(0));
        return form;
    }

    public GiaoVienDangKy findForEdit(String maLop, String maMh, Short lan) {
        GiaoVienDangKy registration = registrationRepository
                .findByMaLopAndMaMhAndLan(normalizeCode(maLop), normalizeCode(maMh), lan)
                .orElseGet(this::newForm);
        normalize(registration);
        return registration;
    }

    @Transactional
    public void save(GiaoVienDangKy registration) {
        save(registration, "UNKNOWN");
    }

    @Transactional
    public void save(GiaoVienDangKy registration, String appLogin) {
        normalize(registration);
        validate(registration);
        ensureNoScoreGenerated(registration);
        jdbcTemplate.update(
                auditContext.withAppLogin("EXEC dbo.sp_DangKyThi ?, ?, ?, ?, ?, ?, ?, ?"),
                auditContext.params(
                        appLogin,
                        registration.getMaGv(),
                        registration.getMaLop(),
                        registration.getMaMh(),
                        registration.getTrinhDo(),
                        registration.getNgayThi(),
                        registration.getLan(),
                        registration.getSoCauThi(),
                        registration.getThoiGian()
                )
        );
    }

    @Transactional
    public void delete(String maLop, String maMh, Short lan) {
        delete(maLop, maMh, lan, "UNKNOWN");
    }

    @Transactional
    public void delete(String maLop, String maMh, Short lan, String appLogin) {
        GiaoVienDangKy existing = findForEdit(maLop, maMh, lan);
        ensureNoScoreGenerated(existing);
        jdbcTemplate.update(
                auditContext.withAppLogin("""
                        DELETE FROM dbo.GiaoVien_DangKy
                        WHERE MALOP = ?
                          AND MAMH = ?
                          AND LAN = ?
                        """),
                auditContext.params(appLogin, normalizeCode(maLop), normalizeCode(maMh), lan)
        );
    }

    private void validate(GiaoVienDangKy registration) {
        if (!StringUtils.hasText(registration.getMaGv())
                || !StringUtils.hasText(registration.getMaLop())
                || !StringUtils.hasText(registration.getMaMh())) {
            throw new IllegalArgumentException("Giáo viên, lớp và môn học không được để trống.");
        }
        if (!giaoVienRepository.existsById(registration.getMaGv())) {
            throw new IllegalArgumentException("Mã giáo viên không tồn tại.");
        }
        if (!lopRepository.existsById(registration.getMaLop())) {
            throw new IllegalArgumentException("Mã lớp không tồn tại.");
        }
        if (!monHocRepository.existsById(registration.getMaMh())) {
            throw new IllegalArgumentException("Mã môn học không tồn tại.");
        }
        if (!List.of("A", "B", "C").contains(registration.getTrinhDo())) {
            throw new IllegalArgumentException("Trình độ chỉ nhận A, B hoặc C.");
        }
        if (registration.getLan() == null || registration.getLan() < 1 || registration.getLan() > 2) {
            throw new IllegalArgumentException("Lần thi chỉ nhận giá trị 1 hoặc 2.");
        }
        if (registration.getSoCauThi() == null || registration.getSoCauThi() < 10 || registration.getSoCauThi() > 100) {
            throw new IllegalArgumentException("Số câu thi phải từ 10 đến 100.");
        }
        if (registration.getThoiGian() == null || registration.getThoiGian() < 5 || registration.getThoiGian() > 60) {
            throw new IllegalArgumentException("Thời gian thi phải từ 5 đến 60 phút.");
        }
        if (registration.getNgayThi() == null) {
            throw new IllegalArgumentException("Ngày thi không được để trống.");
        }
        validateQuestionBank(registration.getMaMh(), registration.getTrinhDo(), registration.getSoCauThi());
    }

    private void validateQuestionBank(String maMh, String trinhDo, short soCauThi) {
        String lowerLevel = lowerLevel(trinhDo);
        int minMain = lowerLevel == null ? soCauThi : (int) Math.ceil(soCauThi * 0.7);
        int maxLower = soCauThi - minMain;

        long mainCount = boDeRepository.countByMaMhAndTrinhDo(maMh, trinhDo);
        long lowerCount = lowerLevel == null ? 0 : boDeRepository.countByMaMhAndTrinhDo(maMh, lowerLevel);
        long usableLowerCount = Math.min(lowerCount, maxLower);

        if (mainCount < minMain || mainCount + usableLowerCount < soCauThi) {
            throw new IllegalArgumentException(
                    "Bộ đề chưa đủ câu: cần tối thiểu " + minMain
                            + " câu trình độ " + trinhDo
                            + (lowerLevel == null ? "." : " và có thể dùng tối đa " + maxLower + " câu trình độ " + lowerLevel + ".")
            );
        }
    }

    private void ensureNoScoreGenerated(GiaoVienDangKy registration) {
        Integer count = jdbcTemplate.queryForObject("""
                SELECT COUNT(1)
                FROM BangDiem BD
                INNER JOIN SinhVien SV ON SV.MASV = BD.MASV
                WHERE SV.MALOP = ?
                  AND BD.MAMH = ?
                  AND BD.LAN = ?
                """, Integer.class, registration.getMaLop(), registration.getMaMh(), registration.getLan());
        if (count != null && count > 0) {
            throw new IllegalArgumentException("Không thể thay đổi đăng ký thi đã phát sinh bảng điểm.");
        }
    }

    private void normalize(GiaoVienDangKy registration) {
        registration.setMaGv(normalizeCode(registration.getMaGv()));
        registration.setMaLop(normalizeCode(registration.getMaLop()));
        registration.setMaMh(normalizeCode(registration.getMaMh()));
        registration.setTrinhDo(normalizeCode(registration.getTrinhDo()));
    }

    private String lowerLevel(String level) {
        return switch (level) {
            case "A" -> "B";
            case "B" -> "C";
            default -> null;
        };
    }

    private String normalizeCode(String value) {
        return value == null ? null : value.trim().toUpperCase();
    }
}
