package com.example.thitracnghiem.controller.gv;

import com.example.thitracnghiem.model.GiaoVienDangKy;
import com.example.thitracnghiem.service.CatalogService;
import com.example.thitracnghiem.service.ExamRegistrationService;
import com.example.thitracnghiem.support.ControllerSupport;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/gv")
public class ExamRegistrationController {

    private final ExamRegistrationService examRegistrationService;
    private final CatalogService catalogService;
    private final ControllerSupport support;

    public ExamRegistrationController(
            ExamRegistrationService examRegistrationService,
            CatalogService catalogService,
            ControllerSupport support
    ) {
        this.examRegistrationService = examRegistrationService;
        this.catalogService = catalogService;
        this.support = support;
    }

    @GetMapping("/dang-ky-thi")
    public String page(
            @RequestParam(required = false) String maLop,
            @RequestParam(required = false) String maMh,
            @RequestParam(required = false) Short lan,
            HttpSession session,
            Model model
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        boolean editingRegistration = maLop != null && maMh != null && lan != null;
        GiaoVienDangKy form = !editingRegistration
                ? examRegistrationService.newForm()
                : examRegistrationService.findForEdit(maLop, maMh, lan);
        if (!"PGV".equals(session.getAttribute("ROLE_NAME"))) {
            form.setMaGv(support.toStr(session.getAttribute("MAGV")));
        }

        support.addTeacherShell(model, session, "dang-ky-thi", "Đăng ký thi");
        model.addAttribute("registrationForm", form);
        model.addAttribute("editingRegistration", editingRegistration);
        try {
            model.addAttribute("registrations", examRegistrationService.findAll());
            model.addAttribute("teachers", catalogService.findAllGiaoVien());
            model.addAttribute("classes", catalogService.findAllLop());
            model.addAttribute("subjects", catalogService.findAllMonHoc());
        } catch (RuntimeException ex) {
            model.addAttribute("registrations", List.of());
            model.addAttribute("teachers", List.of());
            model.addAttribute("classes", List.of());
            model.addAttribute("subjects", List.of());
            model.addAttribute("error", "Không thể tải dữ liệu đăng ký thi: " + ex.getMessage());
        }
        return "auth/gv/dang-ky-thi";
    }

    @PostMapping("/dang-ky-thi")
    public String save(
            @ModelAttribute("registrationForm") GiaoVienDangKy registration,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        try {
            if (!"PGV".equals(session.getAttribute("ROLE_NAME"))) {
                registration.setMaGv(support.toStr(session.getAttribute("MAGV")));
            }
            examRegistrationService.save(registration, support.toStr(session.getAttribute("LOGINNAME")));
            redirectAttributes.addFlashAttribute("success", "Đã lưu đăng ký thi.");
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/gv/dang-ky-thi";
    }

    @PostMapping("/dang-ky-thi/xoa")
    public String delete(
            @RequestParam String maLop,
            @RequestParam String maMh,
            @RequestParam Short lan,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {
        if (!support.isTeacher(session)) {
            return "redirect:/login";
        }

        try {
            examRegistrationService.delete(maLop, maMh, lan, support.toStr(session.getAttribute("LOGINNAME")));
            redirectAttributes.addFlashAttribute("success", "Đã xóa đăng ký thi.");
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/gv/dang-ky-thi";
    }
}
