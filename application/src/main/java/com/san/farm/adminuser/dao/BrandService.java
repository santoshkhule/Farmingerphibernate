package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.BrandEntity;
import com.san.farm.util.HibernateUtil;

public class BrandService {

	private static final Logger logger = LoggerFactory.getLogger(BrandService.class);

	public boolean saveBrand(BrandEntity brand) {
		logger.debug("Saving Brand entity");
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.save(brand);
			tx.commit();
			flag = true;
			logger.info("Brand saved successfully");
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error saving Brand", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean updateBrand(BrandEntity brand) {
		logger.debug("Updating Brand entity");
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.update(brand);
			tx.commit();
			flag = true;
			logger.info("Brand updated successfully");
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error updating Brand", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean deleteBrand(int brandId) {
		logger.debug("Deleting Brand with id: {}", brandId);
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			BrandEntity brand = (BrandEntity) session.get(BrandEntity.class, brandId);
			if (brand != null) {
				session.delete(brand);
				tx.commit();
				flag = true;
				logger.info("Brand deleted successfully for id: {}", brandId);
			}
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error deleting Brand for id: {}", brandId, e);
		} finally {
			session.close();
		}
		return flag;
	}

	@SuppressWarnings("unchecked")
	public List<BrandEntity> fetch() {
		logger.debug("Fetching all Brand records");
		List<BrandEntity> list = new ArrayList<BrandEntity>();
		Session session = HibernateUtil.opensession();
		try {
			list = session.createQuery("from BrandEntity order by brandName").list();
			logger.info("Retrieved {} Brand records", list.size());
		} catch (HibernateException e) {
			logger.error("Error fetching Brand list", e);
		} finally {
			session.close();
		}
		return list;
	}
}
