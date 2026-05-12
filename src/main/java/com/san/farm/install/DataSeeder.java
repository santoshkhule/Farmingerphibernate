package com.san.farm.install;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.login.entity.LoginUser;
import com.san.farm.util.HibernateUtil;

/**
 * Runs once at application startup.
 * Seeds the default admin user into the LOGINUSER table if it does not exist.
 *
 * Default credentials:  username = admin  /  password = admin
 * Change the password immediately after first login.
 */
public class DataSeeder implements ServletContextListener {

    private static final Logger logger = LoggerFactory.getLogger(DataSeeder.class);

    private static final String DEFAULT_ADMIN_USER = "admin";
    private static final String DEFAULT_ADMIN_PASS = "admin";

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("DataSeeder: running startup seed checks...");
        try {
            seedAdminUser();
        } catch (Exception e) {
            logger.error("DataSeeder: seed failed — application will continue but default admin may be missing", e);
        }
    }

    private void seedAdminUser() {
        Session session = HibernateUtil.opensession();
        Transaction tx = null;
        try {
            tx = session.beginTransaction();

            Long count = (Long) session.createQuery(
                "SELECT COUNT(u) FROM LoginUser u WHERE u.uname = :uname")
                .setParameter("uname", DEFAULT_ADMIN_USER)
                .uniqueResult();

            if (count == null || count == 0) {
                LoginUser admin = new LoginUser();
                admin.setUname(DEFAULT_ADMIN_USER);
                admin.setPassword(DEFAULT_ADMIN_PASS);
                session.save(admin);
                tx.commit();
                logger.info("DataSeeder: default admin user created " +
                    "(username='{}') — CHANGE THE PASSWORD AFTER FIRST LOGIN.", DEFAULT_ADMIN_USER);
            } else {
                tx.rollback();
                logger.info("DataSeeder: admin user already exists, skipping seed.");
            }

        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            logger.error("DataSeeder: error seeding admin user", e);
        } finally {
            session.close();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        /* nothing to clean up */
    }
}
