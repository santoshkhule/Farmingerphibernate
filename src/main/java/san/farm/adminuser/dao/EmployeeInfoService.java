package san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

import san.farm.adminuser.entity.EmployeeInfoEntity;
import san.farm.util.HibernateUtil;

/**
 * Class Developed for Business Level Operation Fetching Objects from AuthEmployeeInfoController.java
 * Date 13/11/2014
 * 
 * @author santosh Khule 
 * @version 1.2 
 */
public class EmployeeInfoService {
	/**
	 * Insert Operation:Fecthing Object from AuthEmployeeInfoController.java Inserting values into login User table
	 * 
	 * @param loginUser
	 * @return boolean
	 * */
	public boolean saveAuthEmployeeInfo(EmployeeInfoEntity employeeInfoEntity) {
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.save(employeeInfoEntity);
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
	 * Update Operation:Fecthing Object from AuthEmployeeInfoController.java Update values into login User table
	 * 
	 * @param loginUser
	 * @return boolean
	 * */
	public boolean updateAuthEmployeeInfo(EmployeeInfoEntity employeeInfoEntity) {
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.update(employeeInfoEntity);
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
	 * Delete Operation:Fecthing Object from AuthEmployeeInfoController.java, Deleting data from login User table
	 * 
	 * @param employeeInfoEntity
	 * @return boolean
	 * */
	public boolean deleteAuthEmployeeInfo(EmployeeInfoEntity employeeInfoEntity) {
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.update(employeeInfoEntity);
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
	 * fetch Operation:Fecthing List Object from Database table
	 * 	
	 * @return listOfEmployee
	 * */
	public List<EmployeeInfoEntity> getListOfEmployee () {
		List<EmployeeInfoEntity> listOfEmployee=new ArrayList<EmployeeInfoEntity>();
		Session session = HibernateUtil.opensession();		
		try {
			listOfEmployee=session.createCriteria(EmployeeInfoEntity.class).list();			
		} catch (HibernateException exception) {			
			System.out.println("Error while Fetching the Employee List"+exception.getMessage());
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
	public EmployeeInfoEntity getEmployeeById (int employeeInfoId) {
		EmployeeInfoEntity emplInfoEntity=new EmployeeInfoEntity();
		Session session = HibernateUtil.opensession();		
		try {
			emplInfoEntity=(EmployeeInfoEntity)session.get(EmployeeInfoEntity.class, employeeInfoId);			
		} catch (HibernateException exception) {			
			System.out.println("Error while Fetching the Employee By Id"+exception.getMessage());
		} finally {
			session.clear();
			session.close();
		}
		return emplInfoEntity;
	}
}
