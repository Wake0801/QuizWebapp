package com.example.thitracnghiem.controller;

import java.io.IOException;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class AuthController {

    @GetMapping({"/", "/dang-nhap"})
    public String loginPage() {
        return "auth/login";
    }

    @GetMapping("/auth/img/{fileName:.+}")
    public ResponseEntity<Resource> authImage(@PathVariable String fileName) throws IOException {
        Resource resource = new ClassPathResource("templates/auth/img/" + fileName);
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }

        MediaType mediaType = switch (fileName.toLowerCase()) {
            case "logo.png" -> MediaType.IMAGE_PNG;
            case "background.jpg", "background.jpeg" -> MediaType.IMAGE_JPEG;
            default -> MediaType.APPLICATION_OCTET_STREAM;
        };

        return ResponseEntity
                .ok()
                .contentType(mediaType)
                .body(resource);
    }
}
