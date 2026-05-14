package com.san.farm.install;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.UserTypeEntity;
import com.san.farm.login.entity.LoginUser;
import com.san.farm.util.HibernateUtil;

/**
 * Runs once at application startup.
 * Seeds reference / default data into the database if not already present.
 *
 * Seeded data
 *   USERTYPE  : Admin
 *   LOGINUSER : admin / admin  (linked to the Admin user type)
 *
 * Change the admin password immediately after first login.
 */
public class DataSeeder implements ServletContextListener {

    private static final Logger logger = LoggerFactory.getLogger(DataSeeder.class);

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("DataSeeder: running startup seed checks...");
        Session session = HibernateUtil.opensession();
        Transaction tx = null;
        try {
            tx = session.beginTransaction();

            UserTypeEntity adminType = seedUserType(session, "Admin");
            seedLoginUser(session, "admin", "admin", adminType);

            seedUserType(session, "Owner");
            seedUserType(session, "Farm Manager");
            seedUserType(session, "Site Supervisor");
            seedUserType(session, "Accountant");
            seedUserType(session, "Field Worker");
            seedUserType(session, "Viewer");

            tx.commit();
            logger.info("DataSeeder: seed checks complete.");
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            logger.error("DataSeeder: seed failed — app continues but default data may be missing", e);
        } finally {
            session.close();
        }
    }

    /** Inserts the given user type if it does not already exist, then returns it. */
    @SuppressWarnings("unchecked")
    private UserTypeEntity seedUserType(Session session, String typeName) {
        UserTypeEntity existing = (UserTypeEntity) session.createQuery(
            "FROM UserTypeEntity WHERE userType = :type")
            .setParameter("type", typeName)
            .uniqueResult();

        if (existing == null) {
            UserTypeEntity ut = new UserTypeEntity();
            ut.setUserType(typeName);
            session.save(ut);
            logger.info("DataSeeder: inserted user type '{}'", typeName);
            return ut;
        }

        logger.info("DataSeeder: user type '{}' already exists (id={}), skipping.", typeName, existing.getUserTypeId());
        return existing;
    }

    /** Inserts the given login user if it does not already exist. */
    private void seedLoginUser(Session session, String uname, String password, UserTypeEntity userType) {
        Long count = (Long) session.createQuery(
            "SELECT COUNT(u) FROM LoginUser u WHERE u.uname = :uname")
            .setParameter("uname", uname)
            .uniqueResult();

        if (count == null || count == 0) {
            LoginUser user = new LoginUser();
            user.setUname(uname);
            user.setPassword(password);
            user.setUserTypeEntity(userType);
            session.save(user);
            logger.info("DataSeeder: inserted login user '{}' — CHANGE PASSWORD AFTER FIRST LOGIN.", uname);
        } else {
            logger.info("DataSeeder: login user '{}' already exists, skipping.", uname);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        /* nothing to clean up */
    }
}
