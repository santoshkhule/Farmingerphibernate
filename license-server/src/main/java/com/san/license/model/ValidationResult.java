package com.san.license.model;

/**
 * JSON response returned by GET /api/license/validate.
 * This endpoint always returns HTTP 200 — validity is expressed through the {@code valid} flag.
 */
public class ValidationResult {

    /** {@code true} if the license signature is intact and the license has not expired. */
    private boolean valid;

    /** Human-readable license type string (e.g. "ANNUAL"), or null if no license is loaded. */
    private String licenseType;

    /** Licensee name, or null if no license is loaded. */
    private String licensee;

    /** Issue date in ISO-8601 format, or null if no license is loaded. */
    private String issuedDate;

    /** Expiry date in ISO-8601 format, or "PERPETUAL", or null if no license is loaded. */
    private String expiryDate;

    /**
     * Days remaining until expiry.
     * {@code -1} for perpetual licenses; negative values other than -1 indicate expiry in the past.
     */
    private long daysRemaining;

    /** Human-readable status message. */
    private String message;

    // ------------------------------------------------------------------ //
    //  Constructors
    // ------------------------------------------------------------------ //

    public ValidationResult() {
    }

    // ------------------------------------------------------------------ //
    //  Getters & Setters
    // ------------------------------------------------------------------ //

    public boolean isValid() {
        return valid;
    }

    public void setValid(boolean valid) {
        this.valid = valid;
    }

    public String getLicenseType() {
        return licenseType;
    }

    public void setLicenseType(String licenseType) {
        this.licenseType = licenseType;
    }

    public String getLicensee() {
        return licensee;
    }

    public void setLicensee(String licensee) {
        this.licensee = licensee;
    }

    public String getIssuedDate() {
        return issuedDate;
    }

    public void setIssuedDate(String issuedDate) {
        this.issuedDate = issuedDate;
    }

    public String getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(String expiryDate) {
        this.expiryDate = expiryDate;
    }

    public long getDaysRemaining() {
        return daysRemaining;
    }

    public void setDaysRemaining(long daysRemaining) {
        this.daysRemaining = daysRemaining;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
