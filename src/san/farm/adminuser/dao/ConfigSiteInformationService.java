package san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;

import san.farm.adminuser.entity.ConfigSiteInformationEntity;
import san.farm.util.HibernateUtil;

/**
 * Class Developed for Business Level Operation Fetching Objects from ConfigSiteInformationController.java
 * 
 * @author santosh Khule 
 * @version 1.2 
 * @since 14/11/2014
 */
public class ConfigSiteInformationService {
	/**
	 * Insert Operation:Fecthing Object from ConfigSiteInformationController.java Inserting values into siteInformation table
	 * 
	 * @param configSiteInformationEntity
	 * @return boolean
	 * */
	public boolean saveSiteInformation(ConfigSiteInformationEntity configSiteInformationEntity) {
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.save(configSiteInformationEntity);
			transaction.commit();
			flag = true;
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			exception.printStackTrace();
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
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.update(configSiteInformationEntity);
			transaction.commit();
			flag = true;
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			exception.printStackTrace();
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
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			ConfigSiteInformationEntity configSiteInformationEntity=(ConfigSiteInformationEntity)session.get(ConfigSiteInformationEntity.class, siteInfoId);
			session.delete(configSiteInformationEntity);
			transaction.commit();
			flag = true;
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			exception.printStackTrace();
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
		Session session = HibernateUtil.opensession();
		List<ConfigSiteInformationEntity> list=new ArrayList<ConfigSiteInformationEntity>();
		try {			
			list=session.createCriteria(ConfigSiteInformationEntity.class).list();				
		} catch (HibernateException exception) {			
			exception.printStackTrace();
		} finally {
			session.clear();
			session.close();
		}
		return list;
	}
	/**
	 * Fetch Operation:Fecthing Data from siteInformation table	By SiteInfoId	
	 * @return list
	 * */
	public ConfigSiteInformationEntity getSiteInfoBySiteInfoId(int siteInfoId) {		
		Session session = HibernateUtil.opensession();
		ConfigSiteInformationEntity siteInformationEntity=new ConfigSiteInformationEntity();
		try {			
			siteInformationEntity=(ConfigSiteInformationEntity)session.createCriteria(ConfigSiteInformationEntity.class).add(Restrictions.eq("siteInfoId",siteInfoId)).uniqueResult();				
		} catch (HibernateException exception) {			
			exception.printStackTrace();
		} finally {
			session.clear();
			session.close();
		}
		return siteInformationEntity;
	}
}
