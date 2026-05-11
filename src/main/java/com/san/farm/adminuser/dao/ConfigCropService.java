package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.ConfigCropEntity;
import com.san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 13/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from ConfigCropController.java
 */
public class ConfigCropService {
	private static final Logger logger = LoggerFactory.getLogger(ConfigCropService.class);

	public boolean saveCrop(ConfigCropEntity configCropEntity){
		logger.debug("Saving ConfigCrop entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			session.save(configCropEntity);
			transaction.commit();
			flag=true;
			logger.info("Crop saved successfully");
		}catch(HibernateException exception){
			if(transaction!=null){ transaction.rollback(); }
			logger.error("Error saving crop", exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Update Operation:Fecthing Object from ConfigCropController.java Updating values into userType User table
	 * @param ConfigCropEntity object
	 * @return boolean
	 *
	 **/
	public boolean updateCrop(ConfigCropEntity configCropEntity){
		logger.debug("Updating ConfigCrop entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			session.update(configCropEntity);
			transaction.commit();
			flag=true;
			logger.info("Crop updated successfully");
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error updating crop", exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Delete Operation:Fecthing Object from ConfigCropController.java Deleting Data from userType User table
	 * @param ConfigCropEntity object
	 * @return boolean
	 **/
	public boolean deleteCrop(int cropId){
		logger.debug("Deleting ConfigCrop with cropId: {}", cropId);
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			ConfigCropEntity configCropEntity=(ConfigCropEntity)session.get(ConfigCropEntity.class, cropId);
			session.delete(configCropEntity);
			transaction.commit();
			flag=true;
			logger.info("Crop deleted successfully for cropId: {}", cropId);
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error deleting crop for cropId: {}", cropId, exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Fetch Operation:Fecthing Data From DB
	 * @return list
	 * */
	public List<ConfigCropEntity> fetch(){
		logger.debug("Fetching all ConfigCrop records");
		List<ConfigCropEntity> list=new ArrayList<ConfigCropEntity>();
		Session session=HibernateUtil.opensession();
		try{
			list=session.createCriteria(ConfigCropEntity.class).list();
			logger.info("Retrieved {} Crop records", list.size());
		}catch(HibernateException exception){
			logger.error("Error fetching Crop list", exception);
		}finally{
			session.close();
		}
		return list;
	}
	/**
	 * Fetch Operation:Taking cropId from ConfigCropController.java and Fetching respective Data From DB
	 * @return ConfigCropEntity
	 * */
	public ConfigCropEntity getCropIdByCropId(int cropId){
		logger.debug("Fetching ConfigCrop by cropId: {}", cropId);
		ConfigCropEntity configCropEntity=new ConfigCropEntity();
		Session session=HibernateUtil.opensession();
		try{
			configCropEntity=(ConfigCropEntity)session.createCriteria(ConfigCropEntity.class).add(Restrictions.eq("cropId", cropId)).uniqueResult();
			logger.info("Retrieved Crop for cropId: {}", cropId);
		}catch(HibernateException exception){
			logger.error("Error fetching Crop for cropId: {}", cropId, exception);
		}finally{
			session.close();
		}
		return configCropEntity;
	}
}
