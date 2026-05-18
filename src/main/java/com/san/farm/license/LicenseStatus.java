package com.san.farm.license;

/**
 * Result of a license server check. Returned by {@link LicenseClient#check()}.
 */
public class LicenseStatus {

    public final boolean valid;
    public final boolean unreachable;
    public final boolean noConfig;

    public final String message;
    public final String licenseType;
    public final String licensee;
    public final String expiryDate;
    public final long   daysRemaining;

    private LicenseStatus(boolean valid, boolean unreachable, boolean noConfig,
                          String message, String licenseType, String licensee,
                          String expiryDate, long daysRemaining) {
        this.valid         = valid;
        this.unreachable   = unreachable;
        this.noConfig      = noConfig;
        this.message       = message;
        this.licenseType   = licenseType;
        this.licensee      = licensee;
        this.expiryDate    = expiryDate;
        this.daysRemaining = daysRemaining;
    }

    static LicenseStatus noConfig() {
        return new LicenseStatus(true, false, true,
                "License check disabled (no server configured)",
                null, null, null, -1);
    }

    static LicenseStatus unreachable() {
        return new LicenseStatus(false, true, false,
                "License server is unreachable",
                null, null, null, 0);
    }

    static LicenseStatus invalid(String message) {
        return new LicenseStatus(false, false, false,
                message, null, null, null, 0);
    }

    static LicenseStatus of(boolean valid, String message, String licenseType,
                             String licensee, String expiryDate, long daysRemaining) {
        return new LicenseStatus(valid, false, false,
                message, licenseType, licensee, expiryDate, daysRemaining);
    }
}
