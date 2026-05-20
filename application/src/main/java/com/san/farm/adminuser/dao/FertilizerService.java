package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.FertilizerEntity;
import com.san.farm.util.HibernateUtil;

public class FertilizerService {

	private static final Logger logger = LoggerFactory.getLogger(FertilizerService.class);

	public boolean save(FertilizerEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.save(entity);
			tx.commit();
			flag = true;
			logger.info("Fertilizer saved: {}", entity.getFertilizerName());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error saving Fertilizer", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean update(FertilizerEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.update(entity);
			tx.commit();
			flag = true;
			logger.info("Fertilizer updated id: {}", entity.getFertilizerId());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error updating Fertilizer", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean delete(int fertilizerId) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			FertilizerEntity entity = (FertilizerEntity) session.get(FertilizerEntity.class, fertilizerId);
			if (entity != null) {
				session.delete(entity);
				tx.commit();
				flag = true;
				logger.info("Fertilizer deleted id: {}", fertilizerId);
			}
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error deleting Fertilizer id: {}", fertilizerId, e);
		} finally {
			session.close();
		}
		return flag;
	}

	@SuppressWarnings("unchecked")
	public List<FertilizerEntity> fetch() {
		List<FertilizerEntity> list = new ArrayList<FertilizerEntity>();
		Session session = HibernateUtil.opensession();
		try {
			list = session.createQuery("from FertilizerEntity order by fertilizerName").list();
			logger.info("Retrieved {} Fertilizer records", list.size());
		} catch (HibernateException e) {
			logger.error("Error fetching Fertilizer list", e);
		} finally {
			session.close();
		}
		return list;
	}
}
