package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.UserTypeEntity;
import com.san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 13/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from UserTypeController.java
 */
public class UserTypeService {
	private static final Logger logger = LoggerFactory.getLogger(UserTypeService.class);
	/**
	 * Insert Operation:Fecthing Object from UserTypeController.java Inserting values into userType User table
	 * @param UserTypeEntity object
	 * @return boolean
	 */
	public boolean saveUserType(UserTypeEntity userTypeEntity){
		logger.debug("Saving UserType entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			session.save(userTypeEntity);
			transaction.commit();
			flag=true;
			logger.info("UserType saved successfully");
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error saving UserType", exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Update Operation:Fecthing Object from UserTypeController.java Updating values into userType User table
	 * @param UserTypeEntity object
	 * @return boolean
	 *
	 **/
	public boolean updateUserType(UserTypeEntity userTypeEntity){
		logger.debug("Updating UserType entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			session.update(userTypeEntity);
			transaction.commit();
			flag=true;
			logger.info("UserType updated successfully");
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error updating UserType", exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Delete Operation:Fecthing Object from UserTypeController.java Deleting Data from userType User table
	 * @param UserTypeEntity object
	 * @return boolean
	 **/
	public boolean deleteUserType(int userTypeId){
		logger.debug("Deleting UserType with userTypeId: {}", userTypeId);
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			UserTypeEntity userTypeEntity=(UserTypeEntity)session.get(UserTypeEntity.class, userTypeId);
			session.delete(userTypeEntity);
			transaction.commit();
			flag=true;
			logger.info("UserType deleted successfully for userTypeId: {}", userTypeId);
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error deleting UserType for userTypeId: {}", userTypeId, exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Fetch Operation:Fecthing Data From DB
	 * @return list
	 * */
	public List<UserTypeEntity> fetch(){
		logger.debug("Fetching all UserType records");
		List<UserTypeEntity> list=new ArrayList<UserTypeEntity>();
		Session session=HibernateUtil.opensession();
		try{
			list=session.createCriteria(UserTypeEntity.class).list();
			logger.info("Retrieved {} UserType records", list.size());
		}catch(HibernateException exception){
			logger.error("Error fetching UserType list", exception);
		}finally{
			session.close();
		}
		return list;
	}
	/**
	 * Fetch Operation:Taking userType Id from UserTypeController.java and Fetching respective Data From DB
	 * @return UserTypeEntity
	 * */
	public UserTypeEntity getUsertypeIdByUserTypeId(int userTypeId){
		logger.debug("Fetching UserType by userTypeId: {}", userTypeId);
		UserTypeEntity userTypeEntity=new UserTypeEntity();
		Session session=HibernateUtil.opensession();
		try{
			userTypeEntity=(UserTypeEntity)session.createCriteria(UserTypeEntity.class).add(Restrictions.eq("userTypeId", userTypeId)).uniqueResult();
			logger.info("Retrieved UserType for userTypeId: {}", userTypeId);
		}catch(HibernateException exception){
			logger.error("Error fetching UserType for userTypeId: {}", userTypeId, exception);
		}finally{
			session.close();
		}
		return userTypeEntity;
	}
}
