package com.san.license.controller;

import com.san.license.model.ValidationResult;
import com.san.license.service.LicenseService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST API consumed by the Sevak ERP application to check license status.
 *
 * <p>This endpoint ALWAYS returns HTTP 200. Validity is communicated through
 * the {@code valid} boolean in the JSON response body — 4xx/5xx are never
 * returned so the calling application can treat any network success as a
 * meaningful response.</p>
 */
@RestController
@RequestMapping("/api/license")
public class LicenseApiController {

    private final LicenseService licenseService;

    public LicenseApiController(LicenseService licenseService) {
        this.licenseService = licenseService;
    }

    /**
     * Validates the currently active license and returns the result as JSON.
     *
     * <p>Example success response:
     * <pre>
     * {
     *   "valid": true,
     *   "licenseType": "ANNUAL",
     *   "licensee": "Acme Corp",
     *   "issuedDate": "2026-05-18",
     *   "expiryDate": "2027-05-18",
     *   "daysRemaining": 365,
     *   "message": "License is valid — 365 day(s) remaining"
     * }
     * </pre>
     * </p>
     *
     * <p>Example "no license" response:
     * <pre>
     * { "valid": false, "message": "No license loaded", "daysRemaining": 0 }
     * </pre>
     * </p>
     */
    @GetMapping("/validate")
    public ResponseEntity<ValidationResult> validate() {
        ValidationResult result = licenseService.validate();
        // Always return 200 — the client reads the "valid" flag
        return ResponseEntity.ok(result);
    }
}
