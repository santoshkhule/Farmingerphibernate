package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.CropSaleEntity;
import com.san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * @version 1.0
 * DAO for CropSale CRUD operations.
 */
public class CropSaleDao {

    private static final Logger logger = LoggerFactory.getLogger(CropSaleDao.class);

    public boolean save(CropSaleEntity cropSale) {
        logger.debug("Saving CropSaleEntity");
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            session.save(cropSale);
            transaction.commit();
            flag = true;
            logger.info("CropSale saved successfully");
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error saving CropSale", exception);
        } finally {
            session.close();
        }
        return flag;
    }

    public boolean update(CropSaleEntity cropSale) {
        logger.debug("Updating CropSaleEntity with id: {}", cropSale.getSaleId());
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            session.update(cropSale);
            transaction.commit();
            flag = true;
            logger.info("CropSale updated successfully for id: {}", cropSale.getSaleId());
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error updating CropSale for id: {}", cropSale.getSaleId(), exception);
        } finally {
            session.close();
        }
        return flag;
    }

    public boolean delete(final int saleId) {
        logger.debug("Deleting CropSale with id: {}", saleId);
        Session session = HibernateUtil.opensession();
        Transaction transaction = session.beginTransaction();
        boolean flag = false;
        try {
            CropSaleEntity cropSale = (CropSaleEntity) session.get(CropSaleEntity.class, saleId);
            session.delete(cropSale);
            transaction.commit();
            flag = true;
            logger.info("CropSale deleted successfully for id: {}", saleId);
        } catch (HibernateException exception) {
            if (transaction != null) { transaction.rollback(); }
            logger.error("Error deleting CropSale for id: {}", saleId, exception);
        } finally {
            session.close();
        }
        return flag;
    }

    @SuppressWarnings("unchecked")
    public List<CropSaleEntity> getAll() {
        logger.debug("Fetching all CropSale records");
        List<CropSaleEntity> list = new ArrayList<CropSaleEntity>();
        Session session = HibernateUtil.opensession();
        try {
            list = session.createQuery("from CropSaleEntity order by saleDate desc").list();
            logger.info("Retrieved {} CropSale records", list.size());
        } catch (HibernateException exception) {
            logger.error("Error fetching CropSale list", exception);
        } finally {
            session.close();
        }
        return list;
    }

    public CropSaleEntity getById(final int saleId) {
        logger.debug("Fetching CropSale with id: {}", saleId);
        CropSaleEntity cropSale = null;
        Session session = HibernateUtil.opensession();
        try {
            cropSale = (CropSaleEntity) session.get(CropSaleEntity.class, saleId);
            logger.info("Retrieved CropSale for id: {}", saleId);
        } catch (HibernateException exception) {
            logger.error("Error fetching CropSale for id: {}", saleId, exception);
        } finally {
            session.close();
        }
        return cropSale;
    }

    /**
     * Fetch all CropSale records for a given site allocation and financial year.
     * fyYear is the start year of the FY (e.g. 2024 for FY 2024-25, April 2024 - March 2025).
     */
    @SuppressWarnings("unchecked")
    public List<CropSaleEntity> getAllBySiteAndFY(final int assignCroptoSiteId, final int fyYear) {
        logger.debug("Fetching CropSale for site {} and FY starting {}", assignCroptoSiteId, fyYear);
        List<CropSaleEntity> list = new ArrayList<CropSaleEntity>();
        Session session = HibernateUtil.opensession();
        try {
            String fromDate = fyYear + "-04-01";
            String toDate   = (fyYear + 1) + "-03-31";
            Query query = session.createQuery(
                "from CropSaleEntity cs where cs.assignCropToSiteEntity.assignCroptoSiteId = :siteId " +
                "and cs.saleDate between :fromDate and :toDate order by cs.saleDate");
            query.setParameter("siteId",   assignCroptoSiteId);
            query.setParameter("fromDate", java.sql.Date.valueOf(fromDate));
            query.setParameter("toDate",   java.sql.Date.valueOf(toDate));
            list = query.list();
            logger.info("Retrieved {} CropSale records for site {} FY {}", list.size(), assignCroptoSiteId, fyYear);
        } catch (HibernateException exception) {
            logger.error("Error fetching CropSale for site {} FY {}", assignCroptoSiteId, fyYear, exception);
        } finally {
            session.close();
        }
        return list;
    }
}
