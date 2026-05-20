package com.san.license.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.san.license.model.LicenseData;
import com.san.license.model.LicenseType;
import com.san.license.model.ValidationResult;
import com.san.license.service.LicenseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * Browser-facing admin UI for generating, uploading, downloading, and
 * inspecting Sevak ERP licenses.
 */
@Controller
@RequestMapping("/admin")
public class AdminController {

    private static final Logger log = LoggerFactory.getLogger(AdminController.class);

    @Value("${license.data.dir}")
    private String licenseDataDir;

    private final LicenseService licenseService;
    private final ObjectMapper objectMapper;

    public AdminController(LicenseService licenseService) {
        this.licenseService = licenseService;
        this.objectMapper = new ObjectMapper();
    }

    // ------------------------------------------------------------------ //
    //  GET /admin — dashboard
    // ------------------------------------------------------------------ //

    @GetMapping
    public String adminDashboard(Model model) {
        ValidationResult result = licenseService.validate();
        model.addAttribute("validationResult", result);
        model.addAttribute("licenseTypes", LicenseType.values());
        return "admin";
    }

    // ------------------------------------------------------------------ //
    //  POST /admin/generate — create and activate a new license
    // ------------------------------------------------------------------ //

    @PostMapping("/generate")
    public String generateLicense(
            @RequestParam("licensee") String licensee,
            @RequestParam("licenseType") String licenseTypeStr,
            @RequestParam(value = "durationDays", defaultValue = "0") int durationDays,
            RedirectAttributes redirectAttributes) {

        if (licensee == null || licensee.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "Licensee name must not be empty.");
            return "redirect:/admin";
        }

        try {
            LicenseType type = LicenseType.valueOf(licenseTypeStr.toUpperCase());
            LicenseData ld = licenseService.generateLicense(licensee, type, durationDays);
            licenseService.saveLicense(ld);

            log.info("Admin generated and activated a {} license for '{}'", type, licensee);
            redirectAttributes.addFlashAttribute("successMessage",
                    "License generated and activated successfully for: " + licensee);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Unknown license type: " + licenseTypeStr);
        } catch (Exception e) {
            log.error("License generation failed", e);
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Failed to generate license: " + e.getMessage());
        }

        return "redirect:/admin";
    }

    // ------------------------------------------------------------------ //
    //  POST /admin/upload — accept an externally produced license file
    // ------------------------------------------------------------------ //

    @PostMapping("/upload")
    public String uploadLicense(
            @RequestParam("file") MultipartFile file,
            RedirectAttributes redirectAttributes) {

        if (file == null || file.isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "No file selected for upload.");
            return "redirect:/admin";
        }

        try {
            // Validate that the uploaded file is a valid LicenseData JSON before saving
            LicenseData uploaded = objectMapper.readValue(file.getBytes(), LicenseData.class);
            if (uploaded == null || uploaded.getLicenseId() == null) {
                throw new IOException("Uploaded file does not appear to be a valid license file.");
            }

            Path targetDir  = Paths.get(licenseDataDir);
            Path targetFile = targetDir.resolve("license.json");
            Files.createDirectories(targetDir);

            // Write the raw uploaded bytes to preserve formatting
            Files.copy(file.getInputStream(), targetFile, StandardCopyOption.REPLACE_EXISTING);

            log.info("Admin uploaded license for '{}' (id={})", uploaded.getLicensee(), uploaded.getLicenseId());
            redirectAttributes.addFlashAttribute("successMessage",
                    "License file uploaded and activated successfully.");
        } catch (IOException e) {
            log.error("License upload failed", e);
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Upload failed — ensure the file is a valid license JSON: " + e.getMessage());
        }

        return "redirect:/admin";
    }

    // ------------------------------------------------------------------ //
    //  GET /admin/download — serve license.json as a file attachment
    // ------------------------------------------------------------------ //

    @GetMapping("/download")
    public ResponseEntity<Resource> downloadLicense() {
        Path licenseFile = Paths.get(licenseDataDir, "license.json");

        if (!Files.exists(licenseFile)) {
            return ResponseEntity.notFound().build();
        }

        Resource resource = new FileSystemResource(licenseFile.toFile());
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"license.json\"")
                .body(resource);
    }

}
