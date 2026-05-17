package com.san.farm.install;

import java.util.ArrayList;
import java.util.List;

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
 *   USERTYPE  : Admin, Owner, Farm Manager, Site Supervisor, Accountant, Field Worker, Viewer
 *   LOGINUSER : admin / admin  (assigned all 7 user types)
 *
 * Change the admin password immediately after first login.
 */
public class DataSeeder implements ServletContextListener {

    private static final Logger logger = LoggerFactory.getLogger(DataSeeder.class);

    private static final String[] ALL_TYPES = {
        "Admin", "Owner", "Farm Manager", "Site Supervisor",
        "Accountant", "Field Worker", "Viewer"
    };

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("DataSeeder: running startup seed checks...");
        Session session = HibernateUtil.opensession();
        Transaction tx = null;
        try {
            tx = session.beginTransaction();

            List<UserTypeEntity> allTypesList = new ArrayList<UserTypeEntity>();
            for (String typeName : ALL_TYPES) {
                allTypesList.add(seedUserType(session, typeName));
            }

            seedAdminUser(session, "admin", "admin", allTypesList);

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

    /**
     * Seeds the admin login user.
     * If the user exists: updates its types to all types.
     * If the user does not exist: creates it with all types.
     */
    @SuppressWarnings("unchecked")
    private void seedAdminUser(Session session, String uname, String password, List<UserTypeEntity> allTypesList) {
        LoginUser existing = (LoginUser) session.createQuery(
            "FROM LoginUser WHERE uname = :uname")
            .setParameter("uname", uname)
            .uniqueResult();

        if (existing == null) {
            LoginUser user = new LoginUser();
            user.setUname(uname);
            user.setPassword(password);
            user.setUserTypes(allTypesList);
            session.save(user);
            logger.info("DataSeeder: inserted login user '{}' with all {} types — CHANGE PASSWORD AFTER FIRST LOGIN.", uname, allTypesList.size());
        } else {
            existing.setUserTypes(allTypesList);
            session.merge(existing);
            logger.info("DataSeeder: login user '{}' already exists — updated user types to all {} types.", uname, allTypesList.size());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        /* nothing to clean up */
    }
}
