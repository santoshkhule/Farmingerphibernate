package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.SiteProductAllocationEntity;
import com.san.farm.util.HibernateUtil;

public class SiteProductAllocationService {

    private static final Logger logger = LoggerFactory.getLogger(SiteProductAllocationService.class);

    public boolean save(SiteProductAllocationEntity entity) {
        Session session = HibernateUtil.opensession();
        Transaction tx = session.beginTransaction();
        boolean flag = false;
        try {
            session.save(entity);
            tx.commit();
            flag = true;
            logger.info("SiteProductAllocation saved, allocationId={}", entity.getAllocationId());
        } catch (HibernateException e) {
            if (tx != null) tx.rollback();
            logger.error("Error saving SiteProductAllocation", e);
        } finally {
            session.close();
        }
        return flag;
    }

    public boolean delete(int allocationId) {
        Session session = HibernateUtil.opensession();
        Transaction tx = session.beginTransaction();
        boolean flag = false;
        try {
            SiteProductAllocationEntity entity =
                (SiteProductAllocationEntity) session.get(SiteProductAllocationEntity.class, allocationId);
            if (entity != null) {
                session.delete(entity);
                tx.commit();
                flag = true;
                logger.info("SiteProductAllocation deleted, allocationId={}", allocationId);
            }
        } catch (HibernateException e) {
            if (tx != null) tx.rollback();
            logger.error("Error deleting SiteProductAllocation id={}", allocationId, e);
        } finally {
            session.close();
        }
        return flag;
    }

    @SuppressWarnings("unchecked")
    public List<SiteProductAllocationEntity> getByCropToSiteId(int cropToSiteId) {
        List<SiteProductAllocationEntity> list = new ArrayList<SiteProductAllocationEntity>();
        Session session = HibernateUtil.opensession();
        try {
            list = session.createQuery(
                "FROM SiteProductAllocationEntity spa WHERE spa.cropToSite.assignCroptoSiteId = " + cropToSiteId +
                " ORDER BY spa.allocationDate DESC")
                .list();
            logger.info("Retrieved {} allocations for cropToSiteId={}", list.size(), cropToSiteId);
        } catch (HibernateException e) {
            logger.error("Error fetching allocations for cropToSiteId={}", cropToSiteId, e);
        } finally {
            session.close();
        }
        return list;
    }
}
