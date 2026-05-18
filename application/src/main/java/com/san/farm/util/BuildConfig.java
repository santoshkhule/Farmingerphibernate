package com.san.farm.util;

import java.io.InputStream;
import java.util.Properties;

/**
 * Build-time environment constants stamped into build.properties by Maven
 * resource filtering during {@code mvn package -P <profile>}.
 *
 * <p>Usage:
 * <pre>
 *   if (BuildConfig.IS_PROD) { ... }
 * </pre>
 * </p>
 */
public final class BuildConfig {

    /** Active environment name: {@code "dev"} or {@code "prod"}. */
    public static final String ENV;

    /** {@code true} when built with {@code -P prod}. */
    public static final boolean IS_PROD;

    /** {@code true} when built with {@code -P dev} (default). */
    public static final boolean IS_DEV;

    /**
     * {@code true} in DEV builds — the License Checks toggle is editable.
     * {@code false} in PROD builds — the toggle is locked to ENABLED and
     * cannot be changed via the UI or a crafted POST request.
     */
    public static final boolean LICENSE_UI_EDITABLE;

    static {
        Properties p = new Properties();
        try (InputStream in = BuildConfig.class.getClassLoader()
                .getResourceAsStream("build.properties")) {
            if (in != null) p.load(in);
        } catch (Exception ignored) {
            /* Fallback: treat missing file as dev build */
        }
        ENV                 = p.getProperty("build.env", "dev");
        IS_PROD             = "prod".equalsIgnoreCase(ENV);
        IS_DEV              = !IS_PROD;
        LICENSE_UI_EDITABLE = Boolean.parseBoolean(
                p.getProperty("license.ui.editable", "true"));
    }

    private BuildConfig() {}
}
