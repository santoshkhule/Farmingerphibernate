package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.CategoryEntity;
import com.san.farm.util.HibernateUtil;

public class CategoryService {

	private static final Logger logger = LoggerFactory.getLogger(CategoryService.class);

	public boolean save(CategoryEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.save(entity);
			tx.commit();
			flag = true;
			logger.info("Category saved: {}", entity.getCategoryName());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error saving Category", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean update(CategoryEntity entity) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			session.update(entity);
			tx.commit();
			flag = true;
			logger.info("Category updated id: {}", entity.getCategoryId());
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error updating Category", e);
		} finally {
			session.close();
		}
		return flag;
	}

	public boolean delete(int categoryId) {
		Session session = HibernateUtil.opensession();
		Transaction tx = session.beginTransaction();
		boolean flag = false;
		try {
			CategoryEntity entity = (CategoryEntity) session.get(CategoryEntity.class, categoryId);
			if (entity != null) {
				session.delete(entity);
				tx.commit();
				flag = true;
				logger.info("Category deleted id: {}", categoryId);
			}
		} catch (HibernateException e) {
			if (tx != null) tx.rollback();
			logger.error("Error deleting Category id: {}", categoryId, e);
		} finally {
			session.close();
		}
		return flag;
	}

	@SuppressWarnings("unchecked")
	public List<CategoryEntity> fetch() {
		List<CategoryEntity> list = new ArrayList<CategoryEntity>();
		Session session = HibernateUtil.opensession();
		try {
			list = session.createQuery("from CategoryEntity order by categoryName").list();
			logger.info("Retrieved {} Category records", list.size());
		} catch (HibernateException e) {
			logger.error("Error fetching Category list", e);
		} finally {
			session.close();
		}
		return list;
	}
}
