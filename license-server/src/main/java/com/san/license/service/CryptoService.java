package com.san.license.service;

import com.san.license.model.LicenseData;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

/**
 * Manages the RSA-2048 key pair used to sign and verify license files.
 *
 * <p>On first startup the key pair is generated and written to
 * {@code {license.data.dir}/private.key} (PKCS-8 Base64) and
 * {@code {license.data.dir}/public.key} (X.509 Base64).
 * On subsequent startups the keys are read from disk.</p>
 */
@Service
public class CryptoService {

    private static final Logger log = LoggerFactory.getLogger(CryptoService.class);

    private static final String KEY_ALGORITHM = "RSA";
    private static final String SIGNATURE_ALGORITHM = "SHA256withRSA";
    private static final int KEY_SIZE = 2048;

    @Value("${license.data.dir}")
    private String licenseDataDir;

    private PrivateKey privateKey;
    private PublicKey publicKey;

    // ------------------------------------------------------------------ //
    //  Initialisation
    // ------------------------------------------------------------------ //

    /**
     * Called by Spring after dependency injection.
     * Loads existing keys from disk or generates a fresh key pair.
     */
    @PostConstruct
    public void ensureKeyPair() {
        Path dir = Paths.get(licenseDataDir);
        Path privateKeyPath = dir.resolve("private.key");
        Path publicKeyPath  = dir.resolve("public.key");

        try {
            if (Files.exists(privateKeyPath) && Files.exists(publicKeyPath)) {
                log.info("Loading existing RSA key pair from {}", dir);
                loadKeys(privateKeyPath, publicKeyPath);
            } else {
                log.info("Generating new RSA-2048 key pair in {}", dir);
                generateAndSaveKeys(dir, privateKeyPath, publicKeyPath);
            }
        } catch (Exception e) {
            throw new IllegalStateException("Failed to initialise RSA key pair", e);
        }
    }

    // ------------------------------------------------------------------ //
    //  Public API
    // ------------------------------------------------------------------ //

    /**
     * Signs {@code canonicalData} with the server's private key.
     *
     * @param canonicalData pipe-separated canonical license string
     * @return Base64-encoded RSA-SHA256 signature
     */
    public String sign(String canonicalData) {
        try {
            Signature sig = Signature.getInstance(SIGNATURE_ALGORITHM);
            sig.initSign(privateKey);
            sig.update(canonicalData.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(sig.sign());
        } catch (Exception e) {
            throw new IllegalStateException("Failed to sign license data", e);
        }
    }

    /**
     * Verifies that {@code signature} (Base64) is a valid RSA-SHA256 signature
     * over {@code canonicalData} using the server's public key.
     */
    public boolean verify(String canonicalData, String signature) {
        try {
            Signature sig = Signature.getInstance(SIGNATURE_ALGORITHM);
            sig.initVerify(publicKey);
            sig.update(canonicalData.getBytes(StandardCharsets.UTF_8));
            byte[] sigBytes = Base64.getDecoder().decode(signature);
            return sig.verify(sigBytes);
        } catch (Exception e) {
            log.warn("Signature verification failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Builds the canonical pipe-separated string that is signed / verified.
     * Format: {@code licenseId|product|licensee|licenseType|issuedDate|expiryDate|maxUsers}
     */
    public String buildCanonical(LicenseData ld) {
        return String.join("|",
                ld.getLicenseId(),
                ld.getProduct(),
                ld.getLicensee(),
                ld.getLicenseType().name(),
                ld.getIssuedDate(),
                ld.getExpiryDate(),
                String.valueOf(ld.getMaxUsers()));
    }

    // ------------------------------------------------------------------ //
    //  Private helpers
    // ------------------------------------------------------------------ //

    private void loadKeys(Path privatePath, Path publicPath) throws Exception {
        KeyFactory kf = KeyFactory.getInstance(KEY_ALGORITHM);

        byte[] privBytes = Base64.getDecoder().decode(
                new String(Files.readAllBytes(privatePath), StandardCharsets.UTF_8).trim());
        privateKey = kf.generatePrivate(new PKCS8EncodedKeySpec(privBytes));

        byte[] pubBytes = Base64.getDecoder().decode(
                new String(Files.readAllBytes(publicPath), StandardCharsets.UTF_8).trim());
        publicKey = kf.generatePublic(new X509EncodedKeySpec(pubBytes));

        log.info("RSA key pair loaded successfully");
    }

    private void generateAndSaveKeys(Path dir, Path privatePath, Path publicPath)
            throws NoSuchAlgorithmException, IOException {

        Files.createDirectories(dir);

        KeyPairGenerator kpg = KeyPairGenerator.getInstance(KEY_ALGORITHM);
        kpg.initialize(KEY_SIZE, new SecureRandom());
        KeyPair kp = kpg.generateKeyPair();

        privateKey = kp.getPrivate();
        publicKey  = kp.getPublic();

        String encodedPriv = Base64.getEncoder().encodeToString(privateKey.getEncoded());
        String encodedPub  = Base64.getEncoder().encodeToString(publicKey.getEncoded());

        Files.write(privatePath, encodedPriv.getBytes(StandardCharsets.UTF_8));
        Files.write(publicPath,  encodedPub.getBytes(StandardCharsets.UTF_8));

        log.info("RSA-2048 key pair generated and saved to {}", dir);
    }
}
