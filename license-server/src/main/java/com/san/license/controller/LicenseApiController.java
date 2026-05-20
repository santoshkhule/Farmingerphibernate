package com.san.license.controller;

import com.san.license.model.ValidationResult;
import com.san.license.service.LicenseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST API consumed by the Sevak ERP application to check license status.
 *
 * <p>When {@code license.api.key} is set in {@code application.properties}, callers
 * must supply a matching {@code X-Api-Key} header — requests without it receive
 * HTTP 401.  When {@code license.api.key} is empty the endpoint is open (backward
 * compatible with deployments that do not use API key auth).</p>
 *
 * <p>On success this endpoint always returns HTTP 200; validity is communicated
 * through the {@code valid} boolean in the JSON body.</p>
 */
@RestController
@RequestMapping("/api/license")
public class LicenseApiController {

    private static final Logger log = LoggerFactory.getLogger(LicenseApiController.class);

    @Value("${license.api.key:}")
    private String configuredApiKey;

    private final LicenseService licenseService;

    public LicenseApiController(LicenseService licenseService) {
        this.licenseService = licenseService;
    }

    @GetMapping("/validate")
    public ResponseEntity<?> validate(
            @RequestHeader(value = "X-Api-Key", defaultValue = "") String apiKey) {

        if (!configuredApiKey.isEmpty() && !configuredApiKey.equals(apiKey)) {
            log.warn("Rejected /api/license/validate — invalid or missing X-Api-Key");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("{\"error\":\"Invalid or missing X-Api-Key header.\"}");
        }

        ValidationResult result = licenseService.validate();
        return ResponseEntity.ok(result);
    }
}
