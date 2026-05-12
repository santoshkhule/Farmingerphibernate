package com.san.farm.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HibernateUtil {

    private static final Logger logger = LoggerFactory.getLogger(HibernateUtil.class);
    public static SessionFactory factory;

    static {
        try {
            Properties app = loadAppProperties();

            factory = new Configuration()
                .configure()   // loads hibernate.cfg.xml (entity mappings only)
                .setProperty("hibernate.connection.driver_class", require(app, "db.driver"))
                .setProperty("hibernate.connection.url",          require(app, "db.url"))
                .setProperty("hibernate.connection.username",     app.getProperty("db.username", ""))
                .setProperty("hibernate.connection.password",     app.getProperty("db.password", ""))
                .setProperty("hibernate.dialect",                 require(app, "hibernate.dialect"))
                .setProperty("hibernate.hbm2ddl.auto",           app.getProperty("hibernate.hbm2ddl.auto", "update"))
                .setProperty("hibernate.show_sql",                app.getProperty("hibernate.show_sql",   "false"))
                .setProperty("hibernate.format_sql",              app.getProperty("hibernate.format_sql", "false"))
                .buildSessionFactory();

            logger.info("SessionFactory initialised — url={}", app.getProperty("db.url"));
        } catch (Throwable th) {
            logger.error("Failed to create SessionFactory: {}", th.getMessage(), th);
            throw new ExceptionInInitializerError(th);
        }
    }

    private static Properties loadAppProperties() throws IOException {
        Properties props = new Properties();
        try (InputStream is = HibernateUtil.class.getClassLoader()
                .getResourceAsStream("application.properties")) {
            if (is != null) {
                props.load(is);
                logger.info("Loaded application.properties from classpath");
            } else {
                throw new IOException(
                    "application.properties not found on classpath. " +
                    "Copy install/application.properties.example to " +
                    "src/main/resources/application.properties and configure it.");
            }
        }
        return props;
    }

    private static String require(Properties p, String key) {
        String v = p.getProperty(key);
        if (v == null || v.trim().isEmpty())
            throw new IllegalStateException(
                "Required property '" + key + "' is missing in application.properties");
        return v.trim();
    }

    public static Session opensession() {
        return factory.openSession();
    }
}
