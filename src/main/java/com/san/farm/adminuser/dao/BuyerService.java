package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.BuyerEntity;
import com.san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * @version 1.0
 * DAO for Buyer CRUD operations.
 */
public class BuyerService {

    private static final Logger logger = LoggerFactory.getLogger(BuyerService.class);

    public boolean save(BuyerEntity buyer) {
        logger.debug("Saving BuyerEntity");
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            session.save(buyer);
            transaction.commit();
            flag = true;
            logger.info("Buyer saved successfully");
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error saving Buyer", exception);
        } finally {
            session.close();
        }
        return flag;
    }

    public boolean update(BuyerEntity buyer) {
        logger.debug("Updating BuyerEntity with id: {}", buyer.getBuyerId());
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            session.update(buyer);
            transaction.commit();
            flag = true;
            logger.info("Buyer updated successfully for id: {}", buyer.getBuyerId());
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error updating Buyer for id: {}", buyer.getBuyerId(), exception);
        } finally {
            session.close();
        }
        return flag;
    }

    public boolean delete(final int buyerId) {
        logger.debug("Deleting Buyer with id: {}", buyerId);
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            BuyerEntity buyer = (BuyerEntity) session.get(BuyerEntity.class, buyerId);
            session.delete(buyer);
            transaction.commit();
            flag = true;
            logger.info("Buyer deleted successfully for id: {}", buyerId);
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error deleting Buyer for id: {}", buyerId, exception);
        } finally {
            session.close();
        }
        return flag;
    }

    @SuppressWarnings("unchecked")
    public List<BuyerEntity> getAll() {
        logger.debug("Fetching all Buyer records");
        List<BuyerEntity> list = new ArrayList<BuyerEntity>();
        Session session = HibernateUtil.opensession();
        try {
            list = session.createQuery("from BuyerEntity order by buyerName").list();
            logger.info("Retrieved {} Buyer records", list.size());
        } catch (HibernateException exception) {
            logger.error("Error fetching Buyer list", exception);
        } finally {
            session.close();
        }
        return list;
    }

    public BuyerEntity getById(final int buyerId) {
        logger.debug("Fetching Buyer with id: {}", buyerId);
        BuyerEntity buyer = null;
        Session session = HibernateUtil.opensession();
        try {
            buyer = (BuyerEntity) session.get(BuyerEntity.class, buyerId);
            logger.info("Retrieved Buyer for id: {}", buyerId);
        } catch (HibernateException exception) {
            logger.error("Error fetching Buyer for id: {}", buyerId, exception);
        } finally {
            session.close();
        }
        return buyer;
    }
}
