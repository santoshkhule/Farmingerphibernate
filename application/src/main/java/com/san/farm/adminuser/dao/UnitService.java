package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.UnitEntity;
import com.san.farm.util.HibernateUtil;

public class UnitService {

	private static final Logger logger = LoggerFactory.getLogger(UnitService.class);

	public boolean save(UnitEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.save(entity);
			tx.commit();
			flag = true;
			logger.info("Unit saved: {}", entity.getUnitName());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error saving Unit", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean update(UnitEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.update(entity);
			tx.commit();
			flag = true;
			logger.info("Unit updated id: {}", entity.getUnitId());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error updating Unit", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean delete(int unitId) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			UnitEntity entity = (UnitEntity) session.get(UnitEntity.class, unitId);
			if (entity != null) {
				session.delete(entity);
				tx.commit();
				flag = true;
				logger.info("Unit deleted id: {}", unitId);
			}
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error deleting Unit id: {}", unitId, e);
		} finally {
			session.close();
		}
		return flag;
	}

	@SuppressWarnings("unchecked")
	public List<UnitEntity> fetch() {
		List<UnitEntity> list = new ArrayList<UnitEntity>();
		Session session = HibernateUtil.opensession();
		try {
			list = session.createQuery("from UnitEntity order by unitName").list();
			logger.info("Retrieved {} Unit records", list.size());
		} catch (HibernateException e) {
			logger.error("Error fetching Unit list", e);
		} finally {
			session.close();
		}
		return list;
	}
}
