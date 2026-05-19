package com.san.farm.license;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.net.*;
import java.util.Properties;

/**
 * Thin HTTP client that calls the Sevak License Server's validate endpoint.
 * Uses only JDK classes — no extra dependencies.
 *
 * Policy:
 *  - If license.server.url is not configured → check disabled, allow login.
 *  - If server responds with valid=false       → block login (expired/tampered).
 *  - If server is unreachable                 → block login (fail-closed).
 */
public class LicenseClient {

    private static final Logger log = LoggerFactory.getLogger(LicenseClient.class);
    private static final int TIMEOUT_MS = 2000;

    /** Calls the license server and returns a {@link LicenseStatus}. Thread-safe, stateless. */
    public static LicenseStatus check() {
        Properties config = readConfig();
        if (config == null) return LicenseStatus.noConfig();

        String baseUrl = config.getProperty("license.server.url", "").trim();
        if (baseUrl.isEmpty()) return LicenseStatus.noConfig();

        String apiKey  = config.getProperty("license.server.api.key", "").trim();
        String endpoint = baseUrl + "/api/license/validate";
        try {
            URL url = new URL(endpoint);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Accept", "application/json");
            if (!apiKey.isEmpty()) {
                conn.setRequestProperty("X-Api-Key", apiKey);
            }

            int code = conn.getResponseCode();
            if (code == 401) {
                log.warn("License server rejected API key (HTTP 401) at {}", endpoint);
                return LicenseStatus.invalid("License server rejected the API key — check license.server.api.key configuration.");
            }
            if (code != 200) {
                return LicenseStatus.invalid("License server returned HTTP " + code);
            }

            String body = readBody(conn.getInputStream());
            return parse(body);

        } catch (ConnectException | SocketTimeoutException e) {
            log.warn("License server unreachable at {}: {}", endpoint, e.getMessage());
            return LicenseStatus.unreachable();
        } catch (Exception e) {
            log.warn("License check failed: {}", e.getMessage());
            return LicenseStatus.unreachable();
        }
    }

    private static Properties readConfig() {
        try (InputStream in = LicenseClient.class.getClassLoader()
                .getResourceAsStream("application.properties")) {
            if (in == null) return null;
            Properties p = new Properties();
            p.load(in);
            String enabled = p.getProperty("license.server.enabled", "true").trim();
            if ("false".equalsIgnoreCase(enabled)) return null;
            return p;
        } catch (Exception e) {
            log.warn("Could not read application.properties for license config: {}", e.getMessage());
            return null;
        }
    }

    private static String readBody(InputStream in) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(in, "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) sb.append(line);
        return sb.toString();
    }

    private static LicenseStatus parse(String json) {
        boolean valid        = containsTrue(json, "valid");
        String  message      = extractStr(json, "message");
        String  licenseType  = extractStr(json, "licenseType");
        String  licensee     = extractStr(json, "licensee");
        String  expiryDate   = extractStr(json, "expiryDate");
        long    daysRemaining = extractLong(json, "daysRemaining");
        return LicenseStatus.of(valid, message, licenseType, licensee, expiryDate, daysRemaining);
    }

    private static boolean containsTrue(String json, String key) {
        return json.contains("\"" + key + "\":true")
            || json.contains("\"" + key + "\": true");
    }

    private static String extractStr(String json, String key) {
        for (String pattern : new String[]{"\"" + key + "\":\"", "\"" + key + "\": \""}) {
            int i = json.indexOf(pattern);
            if (i >= 0) {
                i += pattern.length();
                int j = json.indexOf('"', i);
                if (j >= 0) return json.substring(i, j);
            }
        }
        return null;
    }

    private static long extractLong(String json, String key) {
        for (String pattern : new String[]{"\"" + key + "\":", "\"" + key + "\": "}) {
            int i = json.indexOf(pattern);
            if (i >= 0) {
                i += pattern.length();
                while (i < json.length() && json.charAt(i) == ' ') i++;
                int j = i;
                while (j < json.length() && (Character.isDigit(json.charAt(j)) || json.charAt(j) == '-')) j++;
                if (j > i) {
                    try { return Long.parseLong(json.substring(i, j)); } catch (NumberFormatException ignored) {}
                }
            }
        }
        return 0;
    }
}
