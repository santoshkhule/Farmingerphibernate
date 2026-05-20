package com.san.license.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.san.license.model.LicenseData;
import com.san.license.model.LicenseType;
import com.san.license.model.ValidationResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

/**
 * Core business logic for generating, storing, loading, and validating licenses.
 */
@Service
public class LicenseService {

    private static final Logger log = LoggerFactory.getLogger(LicenseService.class);

    /** Sentinel value stored in expiryDate for perpetual licenses. */
    private static final String PERPETUAL = "PERPETUAL";

    /** Product name embedded in every issued license. */
    private static final String PRODUCT = "SevakERP";

    /** Default maximum concurrent users for all license types. */
    private static final int DEFAULT_MAX_USERS = 50;

    @Value("${license.data.dir}")
    private String licenseDataDir;

    private final CryptoService cryptoService;
    private final ObjectMapper objectMapper;

    public LicenseService(CryptoService cryptoService) {
        this.cryptoService = cryptoService;
        this.objectMapper = new ObjectMapper();
        this.objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
    }

    // ------------------------------------------------------------------ //
    //  License generation
    // ------------------------------------------------------------------ //

    /**
     * Generates, signs, and returns a new {@link LicenseData} instance.
     *
     * <p>Duration rules:
     * <ul>
     *   <li>PERPETUAL  — no expiry (expiryDate = "PERPETUAL")</li>
     *   <li>TRIAL      — 15 days</li>
     *   <li>ANNUAL     — 365 days</li>
     *   <li>THREE_YEAR — 1 095 days</li>
     * </ul>
     * The {@code durationDays} parameter is ignored; the type determines the duration.
     * </p>
     *
     * @param licensee     organisation / person receiving the license
     * @param type         license category
     * @param durationDays ignored — duration is derived from {@code type}
     * @return signed {@link LicenseData}
     */
    public LicenseData generateLicense(String licensee, LicenseType type, int durationDays) {
        LocalDate issuedDate = LocalDate.now();

        String expiryDate;
        if (type == LicenseType.PERPETUAL) {
            expiryDate = PERPETUAL;
        } else {
            int days = resolveDefaultDays(type);
            expiryDate = issuedDate.plusDays(days).toString();
        }

        LicenseData ld = new LicenseData();
        ld.setLicenseId(UUID.randomUUID().toString());
        ld.setProduct(PRODUCT);
        ld.setLicensee(licensee.trim());
        ld.setLicenseType(type);
        ld.setIssuedDate(issuedDate.toString());
        ld.setExpiryDate(expiryDate);
        ld.setMaxUsers(DEFAULT_MAX_USERS);

        String canonical = cryptoService.buildCanonical(ld);
        ld.setSignature(cryptoService.sign(canonical));

        log.info("Generated {} license for '{}' expiring {}", type, licensee, expiryDate);
        return ld;
    }

    // ------------------------------------------------------------------ //
    //  Persistence
    // ------------------------------------------------------------------ //

    /**
     * Saves {@code ld} to {@code {license.data.dir}/license.json} as pretty-printed JSON.
     */
    public void saveLicense(LicenseData ld) {
        Path dir  = Paths.get(licenseDataDir);
        Path file = dir.resolve("license.json");
        try {
            Files.createDirectories(dir);
            objectMapper.writeValue(file.toFile(), ld);
            log.info("License saved to {}", file);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to save license.json", e);
        }
    }

    /**
     * Loads the active license from disk, or returns {@code null} if none exists.
     */
    public LicenseData loadLicense() {
        Path file = Paths.get(licenseDataDir, "license.json");
        if (!Files.exists(file)) {
            return null;
        }
        try {
            return objectMapper.readValue(file.toFile(), LicenseData.class);
        } catch (IOException e) {
            log.error("Failed to read license.json: {}", e.getMessage());
            return null;
        }
    }

    // ------------------------------------------------------------------ //
    //  Validation
    // ------------------------------------------------------------------ //

    /**
     * Loads and fully validates the active license.
     *
     * <p>Checks performed:
     * <ol>
     *   <li>License file exists.</li>
     *   <li>RSA signature is intact.</li>
     *   <li>License has not expired (not applicable for PERPETUAL).</li>
     * </ol>
     * </p>
     */
    public ValidationResult validate() {
        LicenseData ld = loadLicense();

        ValidationResult result = new ValidationResult();

        if (ld == null) {
            result.setValid(false);
            result.setMessage("No license loaded");
            result.setDaysRemaining(0);
            return result;
        }

        // Populate informational fields regardless of validity
        result.setLicenseType(ld.getLicenseType() != null ? ld.getLicenseType().name() : null);
        result.setLicensee(ld.getLicensee());
        result.setIssuedDate(ld.getIssuedDate());
        result.setExpiryDate(ld.getExpiryDate());

        // Verify signature
        String canonical = cryptoService.buildCanonical(ld);
        if (!cryptoService.verify(canonical, ld.getSignature())) {
            result.setValid(false);
            result.setMessage("License signature is invalid");
            result.setDaysRemaining(0);
            return result;
        }

        // Check expiry
        if (PERPETUAL.equalsIgnoreCase(ld.getExpiryDate())) {
            result.setValid(true);
            result.setDaysRemaining(-1);
            result.setMessage("License is valid (perpetual)");
            return result;
        }

        LocalDate expiry = LocalDate.parse(ld.getExpiryDate());
        long days = ChronoUnit.DAYS.between(LocalDate.now(), expiry);

        result.setDaysRemaining(days);

        if (days >= 0) {
            result.setValid(true);
            result.setMessage("License is valid — " + days + " day(s) remaining");
        } else {
            result.setValid(false);
            result.setMessage("License expired " + Math.abs(days) + " day(s) ago");
        }

        return result;
    }

    // ------------------------------------------------------------------ //
    //  Private helpers
    // ------------------------------------------------------------------ //

    private int resolveDefaultDays(LicenseType type) {
        switch (type) {
            case TRIAL:      return 15;
            case ANNUAL:     return 365;
            case THREE_YEAR: return 1095;
            default:         return 365;
        }
    }
}
