package com.example.thitracnghiem.service;

import com.example.thitracnghiem.dto.ScoreRow;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Service
public class ScoreExcelExportService {

    private static final DateTimeFormatter FILE_TIME = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss");

    public byte[] exportScoreBoard(List<ScoreRow> rows, String maLop, String maMh, Short lan) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            try (ZipOutputStream zip = new ZipOutputStream(out, StandardCharsets.UTF_8)) {
                addEntry(zip, "[Content_Types].xml", contentTypes());
                addEntry(zip, "_rels/.rels", rootRelationships());
                addEntry(zip, "xl/workbook.xml", workbook());
                addEntry(zip, "xl/_rels/workbook.xml.rels", workbookRelationships());
                addEntry(zip, "xl/styles.xml", styles());
                addEntry(zip, "xl/worksheets/sheet1.xml", worksheet(rows, maLop, maMh, lan));
            }
            return out.toByteArray();
        } catch (IOException ex) {
            throw new IllegalStateException("Không thể tạo file Excel bảng điểm.", ex);
        }
    }

    public String buildFileName(String maLop, String maMh, Short lan) {
        String lop = hasText(maLop) ? normalizeFilePart(maLop) : "tat-ca-lop";
        String mon = hasText(maMh) ? normalizeFilePart(maMh) : "tat-ca-mon";
        String lanText = lan == null ? "tat-ca-lan" : "lan-" + lan;
        return "bang-diem-" + lop + "-" + mon + "-" + lanText + "-" + LocalDateTime.now().format(FILE_TIME) + ".xlsx";
    }

    private String worksheet(List<ScoreRow> rows, String maLop, String maMh, Short lan) {
        StringBuilder xml = new StringBuilder(12000);
        xml.append(xmlHeader());
        xml.append("""
                <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
                <cols>
                    <col min="1" max="1" width="8" customWidth="1"/>
                    <col min="2" max="2" width="15" customWidth="1"/>
                    <col min="3" max="3" width="22" customWidth="1"/>
                    <col min="4" max="4" width="14" customWidth="1"/>
                    <col min="5" max="5" width="30" customWidth="1"/>
                    <col min="6" max="6" width="24" customWidth="1"/>
                    <col min="7" max="7" width="28" customWidth="1"/>
                    <col min="8" max="8" width="10" customWidth="1"/>
                    <col min="9" max="9" width="15" customWidth="1"/>
                    <col min="10" max="10" width="12" customWidth="1"/>
                    <col min="11" max="11" width="12" customWidth="1"/>
                </cols>
                <sheetData>
                """);

        appendRow(xml, 1, new Cell(1, "BẢNG ĐIỂM MÔN HỌC", 1));
        appendRow(xml, 2, new Cell(1, filterText(maLop, maMh, lan), 3));
        appendRow(xml, 3, new Cell(1, "Ngày xuất: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")), 3));

        appendRow(xml, 5,
                new Cell(1, "STT", 2),
                new Cell(2, "Mã SV", 2),
                new Cell(3, "Họ", 2),
                new Cell(4, "Tên", 2),
                new Cell(5, "Họ tên", 2),
                new Cell(6, "Lớp", 2),
                new Cell(7, "Môn", 2),
                new Cell(8, "Lần", 2),
                new Cell(9, "Ngày thi", 2),
                new Cell(10, "Điểm", 2),
                new Cell(11, "Điểm chữ", 2)
        );

        int excelRow = 6;
        for (int i = 0; i < rows.size(); i++) {
            ScoreRow row = rows.get(i);
            appendRow(xml, excelRow++,
                    numberCell(1, i + 1, 4),
                    new Cell(2, safe(row.getMaSv()), 4),
                    new Cell(3, safe(row.getHo()), 4),
                    new Cell(4, safe(row.getTen()), 4),
                    new Cell(5, safe(row.getHoTen()), 4),
                    new Cell(6, joinCodeName(row.getMaLop(), row.getTenLop()), 4),
                    new Cell(7, joinCodeName(row.getMaMh(), row.getTenMh()), 4),
                    row.getLan() == null ? new Cell(8, "", 4) : numberCell(8, row.getLan(), 4),
                    new Cell(9, row.getNgayThi() == null ? "" : row.getNgayThi().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")), 4),
                    row.getDiem() == null ? new Cell(10, "", 4) : decimalCell(10, row.getDiem(), 4),
                    new Cell(11, safe(row.getDiemChu()), 4)
            );
        }

        if (rows.isEmpty()) {
            appendRow(xml, 6, new Cell(1, "Chưa có dữ liệu bảng điểm phù hợp.", 4));
        }

        xml.append("</sheetData>");
        if (rows.isEmpty()) {
            xml.append("""
                    <mergeCells count="4">
                        <mergeCell ref="A1:K1"/>
                        <mergeCell ref="A2:K2"/>
                        <mergeCell ref="A3:K3"/>
                        <mergeCell ref="A6:K6"/>
                    </mergeCells>
                    """);
        } else {
            xml.append("""
                    <mergeCells count="3">
                        <mergeCell ref="A1:K1"/>
                        <mergeCell ref="A2:K2"/>
                        <mergeCell ref="A3:K3"/>
                    </mergeCells>
                    """);
        }
        xml.append("""
                <pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>
                </worksheet>
                """);
        return xml.toString();
    }

    private void appendRow(StringBuilder xml, int rowIndex, Cell... cells) {
        xml.append("<row r=\"").append(rowIndex).append("\">");
        for (Cell cell : cells) {
            xml.append(cell.toXml(rowIndex));
        }
        xml.append("</row>");
    }

    private Cell numberCell(int column, Number value, int style) {
        return new Cell(column, value, style, false);
    }

    private Cell decimalCell(int column, Double value, int style) {
        return new Cell(column, String.format(Locale.US, "%.2f", value), style, false);
    }

    private String filterText(String maLop, String maMh, Short lan) {
        String lop = hasText(maLop) ? maLop.trim().toUpperCase() : "Tất cả lớp";
        String mon = hasText(maMh) ? maMh.trim().toUpperCase() : "Tất cả môn";
        String lanText = lan == null ? "Tất cả lần" : "Lần " + lan;
        return "Lớp: " + lop + " | Môn: " + mon + " | " + lanText;
    }

    private String joinCodeName(String code, String name) {
        if (!hasText(code)) {
            return safe(name);
        }
        if (!hasText(name)) {
            return code.trim();
        }
        return code.trim() + " - " + name.trim();
    }

    private void addEntry(ZipOutputStream zip, String name, String content) throws IOException {
        zip.putNextEntry(new ZipEntry(name));
        zip.write(content.getBytes(StandardCharsets.UTF_8));
        zip.closeEntry();
    }

    private String contentTypes() {
        return xmlHeader() + """
                <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
                    <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
                    <Default Extension="xml" ContentType="application/xml"/>
                    <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
                    <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
                    <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
                </Types>
                """;
    }

    private String rootRelationships() {
        return xmlHeader() + """
                <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
                </Relationships>
                """;
    }

    private String workbook() {
        return xmlHeader() + """
                <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
                          xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
                    <sheets>
                        <sheet name="Bang diem" sheetId="1" r:id="rId1"/>
                    </sheets>
                </workbook>
                """;
    }

    private String workbookRelationships() {
        return xmlHeader() + """
                <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
                    <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
                </Relationships>
                """;
    }

    private String styles() {
        return xmlHeader() + """
                <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
                    <fonts count="3">
                        <font><sz val="11"/><name val="Segoe UI"/></font>
                        <font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Segoe UI"/></font>
                        <font><b/><sz val="16"/><color rgb="FF172033"/><name val="Segoe UI"/></font>
                    </fonts>
                    <fills count="3">
                        <fill><patternFill patternType="none"/></fill>
                        <fill><patternFill patternType="gray125"/></fill>
                        <fill><patternFill patternType="solid"><fgColor rgb="FFB51D32"/><bgColor indexed="64"/></patternFill></fill>
                    </fills>
                    <borders count="2">
                        <border><left/><right/><top/><bottom/><diagonal/></border>
                        <border>
                            <left style="thin"><color rgb="FFE4E7EC"/></left>
                            <right style="thin"><color rgb="FFE4E7EC"/></right>
                            <top style="thin"><color rgb="FFE4E7EC"/></top>
                            <bottom style="thin"><color rgb="FFE4E7EC"/></bottom>
                            <diagonal/>
                        </border>
                    </borders>
                    <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
                    <cellXfs count="5">
                        <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
                        <xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1"/>
                        <xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1">
                            <alignment horizontal="center" vertical="center"/>
                        </xf>
                        <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
                        <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1"/>
                    </cellXfs>
                </styleSheet>
                """;
    }

    private String xmlHeader() {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n";
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private String normalizeFilePart(String value) {
        return value.trim()
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9_-]+", "-")
                .replaceAll("-+", "-")
                .replaceAll("^-|-$", "");
    }

    private String escapeXml(String value) {
        return safe(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    private String columnName(int column) {
        StringBuilder name = new StringBuilder();
        int current = column;
        while (current > 0) {
            current--;
            name.insert(0, (char) ('A' + current % 26));
            current /= 26;
        }
        return name.toString();
    }

    private final class Cell {
        private final int column;
        private final Object value;
        private final int style;
        private final boolean text;

        private Cell(int column, Object value, int style) {
            this(column, value, style, true);
        }

        private Cell(int column, Object value, int style, boolean text) {
            this.column = column;
            this.value = value;
            this.style = style;
            this.text = text;
        }

        private String toXml(int row) {
            String ref = columnName(column) + row;
            if (!text) {
                return "<c r=\"" + ref + "\" s=\"" + style + "\"><v>" + value + "</v></c>";
            }
            return "<c r=\"" + ref + "\" s=\"" + style + "\" t=\"inlineStr\"><is><t>"
                    + escapeXml(String.valueOf(value))
                    + "</t></is></c>";
        }
    }
}
