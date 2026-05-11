package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.AssignVendorToProductEntity;
import com.san.farm.util.HibernateUtil;

public class AssignVendorToProductService {

	private static final Logger logger = LoggerFactory.getLogger(AssignVendorToProductService.class);

	public boolean save(AssignVendorToProductEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.save(entity);
			tx.commit();
			flag = true;
			logger.info("AssignVendorToProduct saved id={}", entity.getAssignVendorProductId());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error saving AssignVendorToProduct", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean update(AssignVendorToProductEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.update(entity);
			tx.commit();
			flag = true;
			logger.info("AssignVendorToProduct updated id={}", entity.getAssignVendorProductId());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error updating AssignVendorToProduct", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean delete(int id) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			AssignVendorToProductEntity entity =
				(AssignVendorToProductEntity) session.get(AssignVendorToProductEntity.class, id);
			if (entity != null) {
				session.delete(entity);
				tx.commit();
				flag = true;
				logger.info("AssignVendorToProduct deleted id={}", id);
			}
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error deleting AssignVendorToProduct id={}", id, e);
		} finally {
			session.close();
		}
		return flag;
	}

	@SuppressWarnings("unchecked")
	public List<AssignVendorToProductEntity> fetch() {
		List<AssignVendorToProductEntity> list = new ArrayList<AssignVendorToProductEntity>();
		Session session = HibernateUtil.opensession();
		try {
			list = session.createQuery(
				"FROM AssignVendorToProductEntity avp ORDER BY avp.vendorEntity.vendorName, avp.fertilizerEntity.fertilizerName")
				.list();
			logger.info("Retrieved {} AssignVendorToProduct records", list.size());
		} catch (HibernateException e) {
			logger.error("Error fetching AssignVendorToProduct list", e);
		} finally {
			session.close();
		}
		return list;
	}

	@SuppressWarnings("unchecked")
	public List<AssignVendorToProductEntity> fetchByVendor(int vendorId) {
		List<AssignVendorToProductEntity> list = new ArrayList<AssignVendorToProductEntity>();
		Session session = HibernateUtil.opensession();
		try {
			list = session.createQuery(
				"FROM AssignVendorToProductEntity avp WHERE avp.vendorEntity.vendorId = " + vendorId +
				" ORDER BY avp.fertilizerEntity.fertilizerName")
				.list();
			logger.info("Retrieved {} records for vendorId={}", list.size(), vendorId);
		} catch (HibernateException e) {
			logger.error("Error fetching AssignVendorToProduct for vendorId={}", vendorId, e);
		} finally {
			session.close();
		}
		return list;
	}
}
