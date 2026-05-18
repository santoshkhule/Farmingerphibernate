package com.san.conf.dao;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.*;

public class SystemConfigDao {

    private static final Logger log = LoggerFactory.getLogger(SystemConfigDao.class);

    public Properties loadAppProperties(String webappRoot) {
        Properties p = new Properties();
        File f = getAppPropsFile(webappRoot);
        if (f != null) {
            try (InputStream in = new FileInputStream(f)) {
                p.load(in);
            } catch (IOException e) {
                log.error("Cannot load application.properties from {}", f.getAbsolutePath(), e);
            }
        }
        return p;
    }

    /**
     * Saves only the supplied keys back to application.properties, preserving
     * all comment lines and key ordering that already exist in the file.
     */
    public void saveAppProperties(String webappRoot, Properties updates) throws IOException {
        File f = getAppPropsFile(webappRoot);
        if (f == null)
            throw new IOException("application.properties not found under WEB-INF/classes/");

        List<String> lines = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(f), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) lines.add(line);
        }

        List<String> result = new ArrayList<>();
        for (String line : lines) {
            String trimmed = line.trim();
            if (trimmed.startsWith("#") || trimmed.isEmpty()) {
                result.add(line);
                continue;
            }
            int eq = line.indexOf('=');
            if (eq > 0) {
                String key = line.substring(0, eq).trim();
                if (updates.containsKey(key)) {
                    result.add(key + "=" + updates.getProperty(key));
                    continue;
                }
            }
            result.add(line);
        }

        try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(f), "UTF-8"))) {
            for (String line : result) {
                bw.write(line);
                bw.newLine();
            }
        }
        log.info("application.properties saved to {}", f.getAbsolutePath());
    }

    public File getAppPropsFile(String webappRoot) {
        File f = new File(webappRoot, "WEB-INF/classes/application.properties");
        return f.exists() ? f : null;
    }

    public File getLogFile(String webappRoot) {
        return new File(webappRoot, "logs/farmingerERP.log");
    }
}
