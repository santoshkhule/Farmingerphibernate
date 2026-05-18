package com.san.license.model;

/**
 * Full license record that is signed and persisted as license.json.
 * All date fields are stored as ISO-8601 strings (yyyy-MM-dd).
 * expiryDate may also hold the special value "PERPETUAL".
 */
public class LicenseData {

    /** UUID uniquely identifying this license grant. */
    private String licenseId;

    /** Product identifier (e.g. "SevakERP"). */
    private String product;

    /** Organisation / person the license is granted to. */
    private String licensee;

    /** Category of the license. */
    private LicenseType licenseType;

    /** Issue date in ISO-8601 format (yyyy-MM-dd). */
    private String issuedDate;

    /**
     * Expiry date in ISO-8601 format (yyyy-MM-dd),
     * or the literal string "PERPETUAL" for never-expiring licenses.
     */
    private String expiryDate;

    /** Maximum number of concurrent users permitted. */
    private int maxUsers;

    /** RSA-SHA256 signature over the canonical pipe-separated string, Base64-encoded. */
    private String signature;

    // ------------------------------------------------------------------ //
    //  Constructors
    // ------------------------------------------------------------------ //

    public LicenseData() {
    }

    // ------------------------------------------------------------------ //
    //  Getters & Setters
    // ------------------------------------------------------------------ //

    public String getLicenseId() {
        return licenseId;
    }

    public void setLicenseId(String licenseId) {
        this.licenseId = licenseId;
    }

    public String getProduct() {
        return product;
    }

    public void setProduct(String product) {
        this.product = product;
    }

    public String getLicensee() {
        return licensee;
    }

    public void setLicensee(String licensee) {
        this.licensee = licensee;
    }

    public LicenseType getLicenseType() {
        return licenseType;
    }

    public void setLicenseType(LicenseType licenseType) {
        this.licenseType = licenseType;
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

    public int getMaxUsers() {
        return maxUsers;
    }

    public void setMaxUsers(int maxUsers) {
        this.maxUsers = maxUsers;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }
}
