package com.example.thitracnghiem.dto;

import java.util.ArrayList;
import java.util.List;

public class ExamResultData {

    private ExamResultSummary summary;
    private List<ExamResultDetail> details = new ArrayList<>();

    public ExamResultSummary getSummary() {
        return summary;
    }

    public void setSummary(ExamResultSummary summary) {
        this.summary = summary;
    }

    public List<ExamResultDetail> getDetails() {
        return details;
    }

    public void setDetails(List<ExamResultDetail> details) {
        this.details = details;
    }

    public boolean hasDetails() {
        return details != null && !details.isEmpty();
    }
}
