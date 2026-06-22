package com.example.thitracnghiem.service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.example.thitracnghiem.dto.ExamQuestion;
import com.example.thitracnghiem.dto.ExamResultData;
import com.example.thitracnghiem.dto.ExamResultDetail;
import com.example.thitracnghiem.dto.ExamResultSummary;
import com.example.thitracnghiem.dto.ExamSession;
import com.example.thitracnghiem.dto.ExamSubmitResult;
import com.example.thitracnghiem.model.GiaoVienDangKy;
import com.example.thitracnghiem.repository.GiaoVienDangKyRepository;
import com.example.thitracnghiem.repository.SinhVienRepository;
import com.example.thitracnghiem.support.SqlAuditContext;

@Service
public class ExamService {

    private static final String STATUS_IN_PROGRESS = "DANG_THI";

    private final JdbcTemplate jdbcTemplate;
    private final SinhVienRepository sinhVienRepository;
    private final GiaoVienDangKyRepository registrationRepository;
    private final SqlAuditContext auditContext;

    public ExamService(
            JdbcTemplate jdbcTemplate,
            SinhVienRepository sinhVienRepository,
            GiaoVienDangKyRepository registrationRepository,
            SqlAuditContext auditContext
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.sinhVienRepository = sinhVienRepository;
        this.registrationRepository = registrationRepository;
        this.auditContext = auditContext;
    }

    public List<GiaoVienDangKy> availableExams(String maSv) {
        if (!StringUtils.hasText(maSv)) {
            return List.of();
        }
        return sinhVienRepository.findById(normalizeCode(maSv))
                .map(sv -> registrationRepository.findAvailableForStudent(sv.getMaSv(), normalizeCode(sv.getMaLop())))
                .orElse(List.of());
    }

    @Transactional
    public ExamSession startExam(String maSv, String maMh, Short lan) {
        String normalizedMaSv = normalizeCode(maSv);
        String normalizedMaMh = normalizeCode(maMh);
        if (!StringUtils.hasText(normalizedMaSv) || !StringUtils.hasText(normalizedMaMh) || lan == null) {
            throw new IllegalArgumentException("Mã sinh viên, môn thi và lần thi không được để trống.");
        }

        Long attemptId = jdbcTemplate.queryForObject(
                "EXEC dbo.sp_BatDauThi ?, ?, ?",
                Long.class,
                normalizedMaSv,
                normalizedMaMh,
                lan
        );

        return loadAttempt(attemptId);
    }

    public ExamSession loadAttempt(Long attemptId) {
        AttemptHeader header = findAttemptHeader(attemptId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài thi."));

        if (!STATUS_IN_PROGRESS.equals(header.trangThai())) {
            throw new IllegalArgumentException("Bài thi này đã được nộp hoặc đã hết giờ.");
        }

        long remainingSeconds = remainingSeconds(header.ketThucLuc());
        if (remainingSeconds <= 0) {
            submitAttempt(attemptId, header.maSv());
            throw new IllegalArgumentException("Bài thi đã hết giờ, hệ thống đã tự động nộp bài.");
        }

        ExamSession session = new ExamSession();
        session.setMaBt(header.maBt());
        session.setMaSv(header.maSv());
        session.setHoTenSinhVien(header.hoTenSinhVien());
        session.setMaLop(header.maLop());
        session.setTenLop(header.tenLop());
        session.setMaMh(header.maMh());
        session.setTenMh(header.tenMh());
        session.setLan(header.lan());
        session.setThoiGian(header.thoiGian());
        session.setBatDauLuc(header.batDauLuc());
        session.setKetThucLuc(header.ketThucLuc());
        session.setRemainingSeconds(remainingSeconds);
        session.setTrangThai(header.trangThai());
        session.setQuestions(loadAttemptQuestions(attemptId));
        return session;
    }

    public ExamSession loadAttemptForStudent(Long attemptId, String maSv) {
        ExamSession session = loadAttempt(attemptId);
        if (!normalizeCode(session.getMaSv()).equals(normalizeCode(maSv))) {
            throw new IllegalArgumentException("Bài thi không thuộc sinh viên đang đăng nhập.");
        }
        return session;
    }

    public void saveAnswer(Long attemptId, Integer questionId, String answer) {
        if (attemptId == null || questionId == null) {
            throw new IllegalArgumentException("Thiếu mã bài thi hoặc mã câu hỏi.");
        }
        jdbcTemplate.update(
                "EXEC dbo.sp_LuuTamCauTraLoi ?, ?, ?",
                attemptId,
                questionId,
                normalizeAnswer(answer)
        );
    }

    public void saveAnswerForStudent(Long attemptId, String maSv, Integer questionId, String answer) {
        assertAttemptOwner(attemptId, maSv);
        saveAnswer(attemptId, questionId, answer);
    }

    @Transactional
    public ExamSubmitResult submit(Long attemptId, Map<Integer, String> answers) {
        if (attemptId == null) {
            throw new IllegalArgumentException("Thiếu mã bài thi.");
        }
        if (!isAttemptExpired(attemptId)) {
            for (Map.Entry<Integer, String> entry : answers.entrySet()) {
                try {
                    saveAnswer(attemptId, entry.getKey(), entry.getValue());
                } catch (DataAccessException ex) {
                    if (isAttemptExpired(attemptId)) {
                        break;
                    }
                    throw ex;
                }
            }
        }
        return submitAttempt(attemptId, null);
    }

    @Transactional
    public ExamSubmitResult submitForStudent(Long attemptId, String maSv, Map<Integer, String> answers) {
        assertAttemptOwner(attemptId, maSv);
        return submit(attemptId, answers, maSv);
    }

    @Transactional
    private ExamSubmitResult submit(Long attemptId, Map<Integer, String> answers, String appLogin) {
        if (attemptId == null) {
            throw new IllegalArgumentException("Thiếu mã bài thi.");
        }
        if (!isAttemptExpired(attemptId)) {
            for (Map.Entry<Integer, String> entry : answers.entrySet()) {
                try {
                    saveAnswer(attemptId, entry.getKey(), entry.getValue());
                } catch (DataAccessException ex) {
                    if (isAttemptExpired(attemptId)) {
                        break;
                    }
                    throw ex;
                }
            }
        }
        return submitAttempt(attemptId, appLogin);
    }

    public ExamResultData findResult(String maSv, String maMh, Short lan) {
        String normalizedMaSv = normalizeCode(maSv);
        String normalizedMaMh = normalizeCode(maMh);
        ExamResultData data = new ExamResultData();

        try {
            List<ExamResultSummary> summaries = jdbcTemplate.query(
                    """
                    SELECT TOP 1
                        BT.MABT,
                        BT.MASV,
                        RTRIM(LTRIM(ISNULL(SV.HO, N''))) + N' ' + RTRIM(LTRIM(ISNULL(SV.TEN, N''))) AS HOTEN,
                        SV.MALOP,
                        L.TENLOP,
                        BT.MAMH,
                        MH.TENMH,
                        BT.LAN,
                        BT.NGAYTHI,
                        BT.SOCAU,
                        BT.SOCAUDUNG,
                        BT.DIEM
                    FROM dbo.BaiThi BT
                    INNER JOIN dbo.SinhVien SV ON SV.MASV = BT.MASV
                    LEFT JOIN dbo.Lop L ON L.MALOP = SV.MALOP
                    INNER JOIN dbo.MonHoc MH ON MH.MAMH = BT.MAMH
                    WHERE BT.MASV = ?
                      AND BT.MAMH = ?
                      AND BT.LAN = ?
                    ORDER BY BT.MABT DESC
                    """,
                    ps -> {
                        ps.setString(1, normalizedMaSv);
                        ps.setString(2, normalizedMaMh);
                        ps.setShort(3, lan == null ? 0 : lan);
                    },
                    (rs, rowNum) -> {
                        ExamResultSummary summary = new ExamResultSummary();
                        summary.setMaBt(rs.getLong("MABT"));
                        summary.setMaSv(trim(rs.getString("MASV")));
                        summary.setHoTen(rs.getString("HOTEN"));
                        summary.setMaLop(trim(rs.getString("MALOP")));
                        summary.setTenLop(rs.getString("TENLOP"));
                        summary.setMaMh(trim(rs.getString("MAMH")));
                        summary.setTenMh(rs.getString("TENMH"));
                        summary.setLan(rs.getShort("LAN"));
                        summary.setNgayThi(rs.getTimestamp("NGAYTHI").toLocalDateTime());
                        summary.setSoCau(rs.getInt("SOCAU"));
                        summary.setSoCauDung(rs.getInt("SOCAUDUNG"));
                        summary.setDiem(rs.getDouble("DIEM"));
                        return summary;
                    }
            );

            if (!summaries.isEmpty()) {
                data.setSummary(summaries.get(0));
                data.setDetails(findResultDetails(summaries.get(0).getMaBt()));
                return data;
            }
        } catch (DataAccessException ignored) {
            // If the supporting attempt tables have not been installed yet, fall back to BangDiem.
        }

        data.setSummary(findScoreOnlyResult(normalizedMaSv, normalizedMaMh, lan).orElse(null));
        return data;
    }

    private Optional<AttemptHeader> findAttemptHeader(Long attemptId) {
        List<AttemptHeader> headers = jdbcTemplate.query(
                """
                SELECT
                    BT.MABT,
                    BT.MASV,
                    RTRIM(LTRIM(ISNULL(SV.HO, N''))) + N' ' + RTRIM(LTRIM(ISNULL(SV.TEN, N''))) AS HOTEN,
                    SV.MALOP,
                    L.TENLOP,
                    BT.MAMH,
                    MH.TENMH,
                    BT.LAN,
                    BT.BATDAU_LUC,
                    BT.KETTHUC_LUC,
                    BT.THOIGIAN,
                    BT.TRANGTHAI
                FROM dbo.BaiThi BT
                INNER JOIN dbo.SinhVien SV ON SV.MASV = BT.MASV
                LEFT JOIN dbo.Lop L ON L.MALOP = SV.MALOP
                INNER JOIN dbo.MonHoc MH ON MH.MAMH = BT.MAMH
                WHERE BT.MABT = ?
                """,
                ps -> ps.setLong(1, attemptId),
                (rs, rowNum) -> new AttemptHeader(
                        rs.getLong("MABT"),
                        trim(rs.getString("MASV")),
                        rs.getString("HOTEN"),
                        trim(rs.getString("MALOP")),
                        rs.getString("TENLOP"),
                        trim(rs.getString("MAMH")),
                        rs.getString("TENMH"),
                        rs.getShort("LAN"),
                        rs.getTimestamp("BATDAU_LUC").toLocalDateTime(),
                        rs.getTimestamp("KETTHUC_LUC") == null ? null : rs.getTimestamp("KETTHUC_LUC").toLocalDateTime(),
                        rs.getShort("THOIGIAN"),
                        rs.getString("TRANGTHAI")
                )
        );
        return headers.stream().findFirst();
    }

    private List<ExamQuestion> loadAttemptQuestions(Long attemptId) {
        return jdbcTemplate.query(
                """
                SELECT
                    CT.CAUHOI,
                    CT.NOIDUNG,
                    CT.A,
                    CT.B,
                    CT.C,
                    CT.D,
                    CT.DAP_AN_CHON,
                    CT.TRINHDO_CAU
                FROM dbo.BaiThi_CauTraLoi CT
                WHERE CT.MABT = ?
                ORDER BY CT.THUTU
                """,
                ps -> ps.setLong(1, attemptId),
                (rs, rowNum) -> {
                    ExamQuestion question = new ExamQuestion();
                    question.setCauHoi(rs.getInt("CAUHOI"));
                    question.setNoiDung(rs.getString("NOIDUNG"));
                    question.setA(rs.getString("A"));
                    question.setB(rs.getString("B"));
                    question.setC(rs.getString("C"));
                    question.setD(rs.getString("D"));
                    question.setDapAnChon(trim(rs.getString("DAP_AN_CHON")));
                    question.setTrinhDoCau(trim(rs.getString("TRINHDO_CAU")));
                    return question;
                }
        );
    }

    private ExamSubmitResult submitAttempt(Long attemptId, String appLogin) {
        String auditLogin = StringUtils.hasText(appLogin)
                ? normalizeCode(appLogin)
                : findAttemptHeader(attemptId).map(AttemptHeader::maSv).orElse("UNKNOWN");
        return jdbcTemplate.queryForObject(
                auditContext.withAppLogin("EXEC dbo.sp_NopBai ?"),
                (rs, rowNum) -> {
                    ExamSubmitResult result = new ExamSubmitResult();
                    result.setMaBt(rs.getLong("MABT"));
                    result.setSoCau(rs.getInt("SOCAU"));
                    result.setSoCauDung(rs.getInt("SOCAUDUNG"));
                    result.setDiem(rs.getDouble("DIEM"));
                    result.setMaSv(trim(rs.getString("MASV")));
                    result.setMaMh(trim(rs.getString("MAMH")));
                    result.setLan(rs.getShort("LAN"));
                    return result;
                },
                auditLogin,
                attemptId
        );
    }

    private boolean isAttemptExpired(Long attemptId) {
        return findAttemptHeader(attemptId)
                .map(header -> remainingSeconds(header.ketThucLuc()) <= 0)
                .orElse(false);
    }

    private void assertAttemptOwner(Long attemptId, String maSv) {
        if (attemptId == null || !StringUtils.hasText(maSv)) {
            throw new IllegalArgumentException("Thiếu thông tin bài thi hoặc sinh viên.");
        }
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(1) FROM dbo.BaiThi WHERE MABT = ? AND MASV = ?",
                Integer.class,
                attemptId,
                normalizeCode(maSv)
        );
        if (count == null || count == 0) {
            throw new IllegalArgumentException("Bài thi không thuộc sinh viên đang đăng nhập.");
        }
    }

    private long remainingSeconds(LocalDateTime endsAt) {
        if (endsAt == null) {
            return 0;
        }
        return Math.max(0, Duration.between(LocalDateTime.now(), endsAt).getSeconds());
    }

    private List<ExamResultDetail> findResultDetails(Long maBt) {
        if (maBt == null) {
            return List.of();
        }
        return jdbcTemplate.query(
                """
                SELECT
                    CT.THUTU,
                    CT.CAUHOI,
                    CT.NOIDUNG,
                    CT.A,
                    CT.B,
                    CT.C,
                    CT.D,
                    CT.DAP_AN_CHON,
                    CT.DAP_AN_DUNG
                FROM dbo.BaiThi_CauTraLoi CT
                WHERE CT.MABT = ?
                ORDER BY CT.THUTU
                """,
                ps -> ps.setLong(1, maBt),
                (rs, rowNum) -> {
                    ExamResultDetail detail = new ExamResultDetail();
                    detail.setThuTu(rs.getInt("THUTU"));
                    detail.setCauHoi(rs.getInt("CAUHOI"));
                    detail.setNoiDung(rs.getString("NOIDUNG"));
                    detail.setA(rs.getString("A"));
                    detail.setB(rs.getString("B"));
                    detail.setC(rs.getString("C"));
                    detail.setD(rs.getString("D"));
                    detail.setDapAnChon(trim(rs.getString("DAP_AN_CHON")));
                    detail.setDapAnDung(trim(rs.getString("DAP_AN_DUNG")));
                    return detail;
                }
        );
    }

    private Optional<ExamResultSummary> findScoreOnlyResult(String maSv, String maMh, Short lan) {
        List<ExamResultSummary> summaries = jdbcTemplate.query(
                """
                SELECT TOP 1
                    CAST(NULL AS BIGINT) AS MABT,
                    BD.MASV,
                    RTRIM(LTRIM(ISNULL(SV.HO, N''))) + N' ' + RTRIM(LTRIM(ISNULL(SV.TEN, N''))) AS HOTEN,
                    SV.MALOP,
                    L.TENLOP,
                    BD.MAMH,
                    MH.TENMH,
                    BD.LAN,
                    CAST(BD.NGAYTHI AS DATETIME) AS NGAYTHI,
                    0 AS SOCAU,
                    0 AS SOCAUDUNG,
                    BD.DIEM
                FROM dbo.BangDiem BD
                INNER JOIN dbo.SinhVien SV ON SV.MASV = BD.MASV
                LEFT JOIN dbo.Lop L ON L.MALOP = SV.MALOP
                INNER JOIN dbo.MonHoc MH ON MH.MAMH = BD.MAMH
                WHERE BD.MASV = ?
                  AND BD.MAMH = ?
                  AND BD.LAN = ?
                """,
                ps -> {
                    ps.setString(1, maSv);
                    ps.setString(2, maMh);
                    ps.setShort(3, lan == null ? 0 : lan);
                },
                (rs, rowNum) -> {
                    ExamResultSummary summary = new ExamResultSummary();
                    summary.setMaBt(null);
                    summary.setMaSv(trim(rs.getString("MASV")));
                    summary.setHoTen(rs.getString("HOTEN"));
                    summary.setMaLop(trim(rs.getString("MALOP")));
                    summary.setTenLop(rs.getString("TENLOP"));
                    summary.setMaMh(trim(rs.getString("MAMH")));
                    summary.setTenMh(rs.getString("TENMH"));
                    summary.setLan(rs.getShort("LAN"));
                    summary.setNgayThi(rs.getTimestamp("NGAYTHI").toLocalDateTime());
                    summary.setSoCau(rs.getInt("SOCAU"));
                    summary.setSoCauDung(rs.getInt("SOCAUDUNG"));
                    summary.setDiem(rs.getDouble("DIEM"));
                    return summary;
                }
        );
        return summaries.stream().findFirst();
    }

    public Map<Integer, String> extractAnswers(Map<String, String> params) {
        Map<Integer, String> answers = new java.util.HashMap<>();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            String key = entry.getKey();
            if (key.startsWith("answers[") && key.endsWith("]")) {
                String idPart = key.substring("answers[".length(), key.length() - 1);
                try {
                    answers.put(Integer.valueOf(idPart), normalizeAnswer(entry.getValue()));
                } catch (NumberFormatException ignored) {
                    // Ignore malformed answer keys from the request.
                }
            }
        }
        return answers;
    }

    public List<String> unansweredQuestionNumbers(ExamSession session, Map<Integer, String> answers) {
        List<String> missing = new ArrayList<>();
        if (session == null || session.getQuestions() == null) {
            return missing;
        }
        for (int i = 0; i < session.getQuestions().size(); i++) {
            ExamQuestion question = session.getQuestions().get(i);
            if (!StringUtils.hasText(answers.get(question.getCauHoi()))) {
                missing.add(String.valueOf(i + 1));
            }
        }
        return missing;
    }

    private String normalizeCode(String value) {
        return value == null ? null : value.trim().toUpperCase();
    }

    private String normalizeAnswer(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        String normalized = value.trim().toUpperCase();
        return List.of("A", "B", "C", "D").contains(normalized) ? normalized : null;
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private record AttemptHeader(
            Long maBt,
            String maSv,
            String hoTenSinhVien,
            String maLop,
            String tenLop,
            String maMh,
            String tenMh,
            Short lan,
            LocalDateTime batDauLuc,
            LocalDateTime ketThucLuc,
            Short thoiGian,
            String trangThai
    ) {
    }

}
