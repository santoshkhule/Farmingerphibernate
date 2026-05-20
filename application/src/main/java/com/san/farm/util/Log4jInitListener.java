package com.san.farm.util;

import java.io.File;
import java.io.IOException;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.apache.log4j.Logger;
import org.apache.log4j.LogManager;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.RollingFileAppender;

/**
 * Attaches a RollingFileAppender to the root Log4j logger at startup,
 * using the deployed app's real path so the log file lands inside the
 * application context folder. The file appender is added programmatically
 * because log4j.properties is read before this listener runs, making
 * ${webapp.root} substitution unreliable.
 */
public class Log4jInitListener implements ServletContextListener {

    private static final String WEBAPP_ROOT_KEY = "webapp.root";
    private static final String LOG_PATTERN = "%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n";

    @Override
    public void contextInitialized(ServletContextEvent event) {
        ServletContext context = event.getServletContext();
        String webAppRoot = context.getRealPath("/");
        System.setProperty(WEBAPP_ROOT_KEY, webAppRoot);

        new File(webAppRoot + "/logs").mkdirs();
        new File(webAppRoot + "/uploads").mkdirs();

        String logFile = webAppRoot + "/logs/farmingerERP.log";
        try {
            RollingFileAppender fileAppender = new RollingFileAppender(
                    new PatternLayout(LOG_PATTERN), logFile, true);
            fileAppender.setName("FILE");
            fileAppender.setMaxFileSize("10MB");
            fileAppender.setMaxBackupIndex(10);
            fileAppender.activateOptions();
            Logger.getRootLogger().addAppender(fileAppender);
            System.out.println("Log4jInitListener: file appender configured -> " + logFile);
        } catch (IOException e) {
            System.err.println("Log4jInitListener: failed to open log file " + logFile + " — " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        LogManager.shutdown();
        System.clearProperty(WEBAPP_ROOT_KEY);
    }
}
