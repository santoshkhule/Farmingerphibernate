package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.SalaryProcessingEntity;
import com.san.farm.util.HibernateUtil;

	/**
	 * @author santosh Khule
	 * Date 30/12/2014
	 * @version 1.2
	 * Class Developed for Business Level Operation Fetching Objects from SalaryProcessingServlet.java
	 */
public class SalaryProcessingDao {
		private static final Logger logger = LoggerFactory.getLogger(SalaryProcessingDao.class);
		/**
		 * Insert Operation:Fecthing Object from SalaryProcessingServlet.java Inserting values into userType User table
		 * @param SalaryProcessingEntity object
		 * @return boolean
		 */
		public boolean saveSalaryTransaction(SalaryProcessingEntity salaryProcess){
			logger.debug("Saving SalaryProcessing entity");
			Session session=HibernateUtil.opensession();
			Transaction transaction=session.beginTransaction();
			boolean flag=false;
			try{
				session.save(salaryProcess);
				transaction.commit();
				flag=true;
				logger.info("SalaryTransaction saved successfully");
			}catch(HibernateException exception){
				if(transaction!=null){
					transaction.rollback();
				}
				logger.error("Error saving SalaryTransaction", exception);
			}finally{
				session.close();
			}
			return flag;
		}
		/**
		 * Update Operation:Fecthing Object from SalaryProcessingServlet.java Updating values into userType User table
		 * @param SalaryProcessingEntity object
		 * @return boolean
		 *
		 **/
		public boolean updateSalaryTransaction(SalaryProcessingEntity salaryProcess){
			logger.debug("Updating SalaryProcessing entity");
			Session session=HibernateUtil.opensession();
			Transaction transaction=session.beginTransaction();
			boolean flag=false;
			try{
				session.update(salaryProcess);
				transaction.commit();
				flag=true;
				logger.info("SalaryTransaction updated successfully");
			}catch(HibernateException exception){
				if(transaction!=null){
					transaction.rollback();
				}
				logger.error("Error updating SalaryTransaction", exception);
			}finally{
				session.close();
			}
			return flag;
		}
		/**
		 * Delete Operation:Fecthing Object from SalaryProcessingServlet.java Deleting Data from userType User table
		 * @param SalaryProcessingEntity object
		 * @return boolean
		 **/
		public boolean deleteSalaryTransaction(final int cropToSiteId){
			logger.debug("Deleting SalaryTransaction with id: {}", cropToSiteId);
			Session session=HibernateUtil.opensession();
			Transaction transaction=session.beginTransaction();
			boolean flag=false;
			try{
				SalaryProcessingEntity salaryProcess=(SalaryProcessingEntity)session.get(SalaryProcessingEntity.class, cropToSiteId);
				session.delete(salaryProcess);
				transaction.commit();
				flag=true;
				logger.info("SalaryTransaction deleted successfully for id: {}", cropToSiteId);
			}catch(HibernateException exception){
				if(transaction!=null){
					transaction.rollback();
				}
				logger.error("Error deleting SalaryTransaction for id: {}", cropToSiteId, exception);
			}finally{
				session.close();
			}
			return flag;
		}
		/**
		 * fetch Operation:Fetching All Data from  User table
		 * @param AssignResourceId
		 * @return list
		 **/

		@SuppressWarnings("unchecked")
		public List<SalaryProcessingEntity> getAllSalaryTransactionByAssignResourceId(final int assignResourceId){
			logger.debug("Fetching SalaryTransactions for assignResourceId: {}", assignResourceId);
			List<SalaryProcessingEntity> processingEntities=new ArrayList<SalaryProcessingEntity>();
			Session session=HibernateUtil.opensession();
			try{
				processingEntities=session.createQuery("from SalaryProcessingEntity where assignResourceId="+assignResourceId).list();
				logger.info("Retrieved {} SalaryTransaction records for assignResourceId: {}", processingEntities.size(), assignResourceId);
			}catch(HibernateException exception){
				logger.error("Error fetching SalaryTransactions for assignResourceId: {}", assignResourceId, exception);
			}finally{
				session.close();
			}
			return processingEntities;
		}
	}
