package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.VendorEntity;
import com.san.farm.util.HibernateUtil;

public class VendorService {

	private static final Logger logger = LoggerFactory.getLogger(VendorService.class);

	public boolean save(VendorEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.save(entity);
			tx.commit();
			flag = true;
			logger.info("Vendor saved: {}", entity.getVendorName());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error saving Vendor", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean update(VendorEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.update(entity);
			tx.commit();
			flag = true;
			logger.info("Vendor updated id: {}", entity.getVendorId());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error updating Vendor", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean delete(int vendorId) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			VendorEntity entity = (VendorEntity) session.get(VendorEntity.class, vendorId);
			if (entity != null) {
				session.delete(entity);
				tx.commit();
				flag = true;
				logger.info("Vendor deleted id: {}", vendorId);
			}
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error deleting Vendor id: {}", vendorId, e);
		} finally {
			session.close();
		}
		return flag;
	}

	@SuppressWarnings("unchecked")
	public List<VendorEntity> fetch() {
		List<VendorEntity> list = new ArrayList<VendorEntity>();
		Session session = HibernateUtil.opensession();
		try {
			list = session.createQuery("from VendorEntity order by vendorName").list();
			logger.info("Retrieved {} Vendor records", list.size());
		} catch (HibernateException e) {
			logger.error("Error fetching Vendor list", e);
		} finally {
			session.close();
		}
		return list;
	}
}
