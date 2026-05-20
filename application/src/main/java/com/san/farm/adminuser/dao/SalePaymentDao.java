package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.SalePaymentEntity;
import com.san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * @version 1.0
 * DAO for SalePayment CRUD operations.
 */
public class SalePaymentDao {

    private static final Logger logger = LoggerFactory.getLogger(SalePaymentDao.class);

    public boolean save(SalePaymentEntity payment) {
        logger.debug("Saving SalePaymentEntity");
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            session.save(payment);
            transaction.commit();
            flag = true;
            logger.info("SalePayment saved successfully");
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error saving SalePayment", exception);
        } finally {
            session.close();
        }
        return flag;
    }

    public boolean update(SalePaymentEntity payment) {
        logger.debug("Updating SalePaymentEntity with id: {}", payment.getSalePaymentId());
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            session.update(payment);
            transaction.commit();
            flag = true;
            logger.info("SalePayment updated successfully for id: {}", payment.getSalePaymentId());
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error updating SalePayment for id: {}", payment.getSalePaymentId(), exception);
        } finally {
            session.close();
        }
        return flag;
    }

    public boolean delete(final int salePaymentId) {
        logger.debug("Deleting SalePayment with id: {}", salePaymentId);
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            SalePaymentEntity payment = (SalePaymentEntity) session.get(SalePaymentEntity.class, salePaymentId);
            session.delete(payment);
            transaction.commit();
            flag = true;
            logger.info("SalePayment deleted successfully for id: {}", salePaymentId);
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error deleting SalePayment for id: {}", salePaymentId, exception);
        } finally {
            session.close();
        }
        return flag;
    }

    @SuppressWarnings("unchecked")
    public List<SalePaymentEntity> getAllBySaleId(final int saleId) {
        logger.debug("Fetching SalePayments for saleId: {}", saleId);
        List<SalePaymentEntity> list = new ArrayList<SalePaymentEntity>();
        Session session = HibernateUtil.opensession();
        try {
            Query query = session.createQuery(
                "from SalePaymentEntity sp where sp.cropSaleEntity.saleId = :saleId order by sp.paymentDate");
            query.setParameter("saleId", saleId);
            list = query.list();
            logger.info("Retrieved {} SalePayment records for saleId: {}", list.size(), saleId);
        } catch (HibernateException exception) {
            logger.error("Error fetching SalePayments for saleId: {}", saleId, exception);
        } finally {
            session.close();
        }
        return list;
    }

    public double getTotalReceivedBySaleId(final int saleId) {
        logger.debug("Fetching total received for saleId: {}", saleId);
        double total = 0;
        Session session = HibernateUtil.opensession();
        try {
            Query query = session.createQuery(
                "SELECT SUM(sp.amountReceived) FROM SalePaymentEntity sp WHERE sp.cropSaleEntity.saleId = :saleId");
            query.setParameter("saleId", saleId);
            Object result = query.uniqueResult();
            if (result != null) total = ((Number) result).doubleValue();
            logger.debug("Total received for saleId {}: {}", saleId, total);
        } catch (HibernateException exception) {
            logger.error("Error fetching total received for saleId: {}", saleId, exception);
        } finally {
            session.close();
        }
        return total;
    }
}
