package com.san.farm.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.PropertyResourceBundle;
import java.util.ResourceBundle;

/**
 * ResourceBundle.Control that reads .properties files as UTF-8.
 * Required because Java 8/11 classpath-mode still defaults to ISO-8859-1,
 * which cannot represent Devanagari (Hindi / Marathi) characters.
 */
public class UTF8Control extends ResourceBundle.Control {

    @Override
    public ResourceBundle newBundle(String baseName, Locale locale, String format,
            ClassLoader loader, boolean reload) throws IOException {

        String bundleName   = toBundleName(baseName, locale);
        String resourceName = toResourceName(bundleName, "properties");
        InputStream stream  = loader.getResourceAsStream(resourceName);
        if (stream == null) return null;
        try {
            return new PropertyResourceBundle(new InputStreamReader(stream, StandardCharsets.UTF_8));
        } finally {
            stream.close();
        }
    }
}
