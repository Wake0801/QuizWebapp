package com.example.thitracnghiem.controller.sv;

import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class StudentHomeController {

    private final ControllerSupport support;

    public StudentHomeController(ControllerSupport support) {
        this.support = support;
    }

    @GetMapping("/sv/home")
    public String sinhVienHome(HttpSession session, Model model) {
        if (!support.isStudent(session)) {
            return "redirect:/login";
        }

        model.addAttribute("hoten", session.getAttribute("HOTEN"));
        model.addAttribute("masv", session.getAttribute("MASV"));
        model.addAttribute("malop", session.getAttribute("MALOP"));
        model.addAttribute("tenlop", session.getAttribute("TENLOP"));
        model.addAttribute("role", session.getAttribute("ROLE_NAME"));

        return "auth/sv/home_sv";
    }
}
