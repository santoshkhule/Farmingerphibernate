package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.EmployeeInfoEntity;
import com.san.farm.util.HibernateUtil;

/**
 * Class Developed for Business Level Operation Fetching Objects from AuthEmployeeInfoController.java
 * Date 13/11/2014
 *
 * @author santosh Khule
 * @version 1.2
 */
public class EmployeeInfoService {
	private static final Logger logger = LoggerFactory.getLogger(EmployeeInfoService.class);
	/**
	 * Insert Operation:Fecthing Object from AuthEmployeeInfoController.java Inserting values into login User table
	 *
	 * @param loginUser
	 * @return boolean
	 * */
	public boolean saveAuthEmployeeInfo(EmployeeInfoEntity employeeInfoEntity) {
		logger.debug("Saving EmployeeInfo entity");
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.save(employeeInfoEntity);
			transaction.commit();
			flag = true;
			logger.info("EmployeeInfo saved successfully");
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error saving EmployeeInfo", exception);
		} finally {
			session.clear();
			session.close();
		}
		return flag;
	}

	/**
	 * Update Operation:Fecthing Object from AuthEmployeeInfoController.java Update values into login User table
	 *
	 * @param loginUser
	 * @return boolean
	 * */
	public boolean updateAuthEmployeeInfo(EmployeeInfoEntity employeeInfoEntity) {
		logger.debug("Updating EmployeeInfo entity for id: {}", employeeInfoEntity.getEmployeeInfoId());
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.update(employeeInfoEntity);
			transaction.commit();
			flag = true;
			logger.info("EmployeeInfo updated successfully for id: {}", employeeInfoEntity.getEmployeeInfoId());
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error updating EmployeeInfo for id: {}", employeeInfoEntity.getEmployeeInfoId(), exception);
		} finally {
			session.clear();
			session.close();
		}
		return flag;
	}

	/**
	 * Delete Operation:Fecthing Object from AuthEmployeeInfoController.java, Deleting data from login User table
	 *
	 * @param employeeInfoEntity
	 * @return boolean
	 * */
	public boolean deleteAuthEmployeeInfo(EmployeeInfoEntity employeeInfoEntity) {
		logger.debug("Deleting EmployeeInfo for id: {}", employeeInfoEntity.getEmployeeInfoId());
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			EmployeeInfoEntity managed = (EmployeeInfoEntity) session.get(
					EmployeeInfoEntity.class, employeeInfoEntity.getEmployeeInfoId());
			if (managed != null) {
				session.delete(managed);
				transaction.commit();
				flag = true;
				logger.info("EmployeeInfo deleted successfully for id: {}", employeeInfoEntity.getEmployeeInfoId());
			} else {
				logger.warn("EmployeeInfo not found for id: {}", employeeInfoEntity.getEmployeeInfoId());
			}
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error deleting EmployeeInfo for id: {}", employeeInfoEntity.getEmployeeInfoId(), exception);
		} finally {
			session.clear();
			session.close();
		}
		return flag;
	}
	/**
	 * fetch Operation:Fecthing List Object from Database table
	 *
	 * @return listOfEmployee
	 * */
	public List<EmployeeInfoEntity> getListOfEmployee() {
		logger.debug("Fetching all EmployeeInfo records");
		List<EmployeeInfoEntity> listOfEmployee=new ArrayList<EmployeeInfoEntity>();
		Session session = HibernateUtil.opensession();
		try {
			listOfEmployee=session.createCriteria(EmployeeInfoEntity.class).list();
			logger.info("Retrieved {} EmployeeInfo records", listOfEmployee.size());
		} catch (HibernateException exception) {
			logger.error("Error fetching EmployeeInfo list", exception);
		} finally {
			session.clear();
			session.close();
		}
		return listOfEmployee;
	}
	/**
	 * fetch Operation:Fecthing Object from Database table By EmployeeId
	 *
	 * @return emplInfoEntity
	 * */
	public EmployeeInfoEntity getEmployeeById(int employeeInfoId) {
		logger.debug("Fetching EmployeeInfo by id: {}", employeeInfoId);
		EmployeeInfoEntity emplInfoEntity=new EmployeeInfoEntity();
		Session session = HibernateUtil.opensession();
		try {
			emplInfoEntity=(EmployeeInfoEntity)session.get(EmployeeInfoEntity.class, employeeInfoId);
			logger.info("Retrieved EmployeeInfo for id: {}", employeeInfoId);
		} catch (HibernateException exception) {
			logger.error("Error fetching EmployeeInfo for id: {}", employeeInfoId, exception);
		} finally {
			session.clear();
			session.close();
		}
		return emplInfoEntity;
	}
}
