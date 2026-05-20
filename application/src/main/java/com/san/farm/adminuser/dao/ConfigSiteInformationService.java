package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.ConfigSiteInformationEntity;
import com.san.farm.util.HibernateUtil;

/**
 * Class Developed for Business Level Operation Fetching Objects from ConfigSiteInformationController.java
 *
 * @author santosh Khule
 * @version 1.2
 * @since 14/11/2014
 */
public class ConfigSiteInformationService {
	private static final Logger logger = LoggerFactory.getLogger(ConfigSiteInformationService.class);
	/**
	 * Insert Operation:Fecthing Object from ConfigSiteInformationController.java Inserting values into siteInformation table
	 *
	 * @param configSiteInformationEntity
	 * @return boolean
	 * */
	public boolean saveSiteInformation(ConfigSiteInformationEntity configSiteInformationEntity) {
		logger.debug("Saving ConfigSiteInformation entity");
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.save(configSiteInformationEntity);
			transaction.commit();
			flag = true;
			logger.info("SiteInformation saved successfully");
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error saving SiteInformation", exception);
		} finally {
			session.clear();
			session.close();
		}
		return flag;
	}

	/**
	 * Update Operation:Fecthing Object from AuthEmployeeInfoController.java Update values into siteInformation table
	 *
	 * @param configSiteInformationEntity
	 * @return boolean
	 * */
	public boolean updateSiteInformation(ConfigSiteInformationEntity configSiteInformationEntity) {
		logger.debug("Updating ConfigSiteInformation entity");
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.update(configSiteInformationEntity);
			transaction.commit();
			flag = true;
			logger.info("SiteInformation updated successfully");
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error updating SiteInformation", exception);
		} finally {
			session.clear();
			session.close();
		}
		return flag;
	}

	/**
	 * Delete Operation:Fecthing Object from AuthEmployeeInfoController.java, Deleting data from siteInformation table
	 *
	 * @param siteInfoId
	 * @return boolean
	 * */
	public boolean deleteSiteInformation(int siteInfoId) {
		logger.debug("Deleting ConfigSiteInformation with siteInfoId: {}", siteInfoId);
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			ConfigSiteInformationEntity configSiteInformationEntity=(ConfigSiteInformationEntity)session.get(ConfigSiteInformationEntity.class, siteInfoId);
			session.delete(configSiteInformationEntity);
			transaction.commit();
			flag = true;
			logger.info("SiteInformation deleted successfully for siteInfoId: {}", siteInfoId);
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error deleting SiteInformation for siteInfoId: {}", siteInfoId, exception);
		} finally {
			session.clear();
			session.close();
		}
		return flag;
	}
	/**
	 * Fetch Operation:Fecthing Data from siteInformation table
	 * @return list
	 * */
	public List<ConfigSiteInformationEntity> fetch() {
		logger.debug("Fetching all ConfigSiteInformation records");
		Session session = HibernateUtil.opensession();
		List<ConfigSiteInformationEntity> list=new ArrayList<ConfigSiteInformationEntity>();
		try {
			list=session.createCriteria(ConfigSiteInformationEntity.class).list();
			logger.info("Retrieved {} SiteInformation records", list.size());
		} catch (HibernateException exception) {
			logger.error("Error fetching SiteInformation list", exception);
		} finally {
			session.clear();
			session.close();
		}
		return list;
	}
	/**
	 * Fetch Operation:Fecthing Data from siteInformation table By SiteInfoId
	 * @return list
	 * */
	public ConfigSiteInformationEntity getSiteInfoBySiteInfoId(int siteInfoId) {
		logger.debug("Fetching ConfigSiteInformation by siteInfoId: {}", siteInfoId);
		Session session = HibernateUtil.opensession();
		ConfigSiteInformationEntity siteInformationEntity=new ConfigSiteInformationEntity();
		try {
			siteInformationEntity=(ConfigSiteInformationEntity)session.createCriteria(ConfigSiteInformationEntity.class).add(Restrictions.eq("siteInfoId",siteInfoId)).uniqueResult();
			logger.info("Retrieved SiteInformation for siteInfoId: {}", siteInfoId);
		} catch (HibernateException exception) {
			logger.error("Error fetching SiteInformation for siteInfoId: {}", siteInfoId, exception);
		} finally {
			session.clear();
			session.close();
		}
		return siteInformationEntity;
	}
}
