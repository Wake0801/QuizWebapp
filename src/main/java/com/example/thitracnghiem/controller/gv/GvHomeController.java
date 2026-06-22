package com.example.thitracnghiem.controller.gv;

import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class GvHomeController {

    private final ControllerSupport support;

    public GvHomeController(ControllerSupport support) {
        this.support = support;
    }

    @GetMapping("/gv/home")
    public String giaoVienHome(HttpSession session, Model model) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        support.addTeacherShell(model, session, "home", "Trang làm việc");

        return "auth/gv/home";
    }
}
