package com.san.conf.service;

import com.san.conf.dao.SystemConfigDao;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.Properties;

public class SystemConfigService {

    private static final org.slf4j.Logger log = LoggerFactory.getLogger(SystemConfigService.class);
    private final SystemConfigDao dao = new SystemConfigDao();

    // ── Log Level ─────────────────────────────────────────────────────────────

    public String getRootLogLevel() {
        Level l = Logger.getRootLogger().getLevel();
        return l != null ? l.toString() : "INFO";
    }

    public String getAppLogLevel() {
        Level l = Logger.getLogger("com.san.farm").getEffectiveLevel();
        return l != null ? l.toString() : getRootLogLevel();
    }

    public void setRootLogLevel(String levelStr) {
        Level level = Level.toLevel(levelStr, Level.INFO);
        Logger.getRootLogger().setLevel(level);
        log.info("Root log level changed to {}", level);
    }

    public void setAppLogLevel(String levelStr) {
        Level level = Level.toLevel(levelStr, Level.INFO);
        Logger.getLogger("com.san.farm").setLevel(level);
        log.info("App log level (com.san.farm) changed to {}", level);
    }

    // ── DB / App Properties ────────────────────────────────────────────────────

    public Properties getDbProperties(String webappRoot) {
        return dao.loadAppProperties(webappRoot);
    }

    public void saveDbProperties(String webappRoot, Properties updates) throws IOException {
        dao.saveAppProperties(webappRoot, updates);
    }

    // ── Log File ──────────────────────────────────────────────────────────────

    public File getLogFile(String webappRoot) {
        return dao.getLogFile(webappRoot);
    }
}
