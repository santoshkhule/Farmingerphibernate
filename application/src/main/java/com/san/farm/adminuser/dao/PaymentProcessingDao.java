package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.PaymentProcessingEntity;
import com.san.farm.util.HibernateUtil;

	/**
	 * @author santosh Khule
	 * Date 30/12/2014
	 * @version 1.2
	 * Class Developed for Business Level Operation Fetching Objects from PaymentProcessingServlet.java
	 */
public class PaymentProcessingDao {
		private static final Logger logger = LoggerFactory.getLogger(PaymentProcessingDao.class);
		/**
		 * Insert Operation:Fecthing Object from PaymentProcessingServlet.java Inserting values into userType User table
		 * @param PaymentProcessingEntity object
		 * @return boolean
		 */
		public boolean saveSalaryTransaction(PaymentProcessingEntity salaryProcess){
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
		 * Update Operation:Fecthing Object from PaymentProcessingServlet.java Updating values into userType User table
		 * @param PaymentProcessingEntity object
		 * @return boolean
		 *
		 **/
		public boolean updateSalaryTransaction(PaymentProcessingEntity salaryProcess){
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
		 * Delete Operation:Fecthing Object from PaymentProcessingServlet.java Deleting Data from userType User table
		 * @param PaymentProcessingEntity object
		 * @return boolean
		 **/
		public boolean deleteSalaryTransaction(final int cropToSiteId){
			logger.debug("Deleting SalaryTransaction with id: {}", cropToSiteId);
			Session session=HibernateUtil.opensession();
			Transaction transaction=session.beginTransaction();
			boolean flag=false;
			try{
				PaymentProcessingEntity salaryProcess=(PaymentProcessingEntity)session.get(PaymentProcessingEntity.class, cropToSiteId);
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
		public List<PaymentProcessingEntity> getAllSalaryTransactionByAssignResourceId(final int assignResourceId){
			logger.debug("Fetching SalaryTransactions for assignResourceId: {}", assignResourceId);
			List<PaymentProcessingEntity> processingEntities=new ArrayList<PaymentProcessingEntity>();
			Session session=HibernateUtil.opensession();
			try{
				processingEntities=session.createQuery("from PaymentProcessingEntity where employeeToFarm.assignResourceId="+assignResourceId).list();
				logger.info("Retrieved {} SalaryTransaction records for assignResourceId: {}", processingEntities.size(), assignResourceId);
			}catch(HibernateException exception){
				logger.error("Error fetching SalaryTransactions for assignResourceId: {}", assignResourceId, exception);
			}finally{
				session.close();
			}
			return processingEntities;
		}

		public double getTotalSalaryPaidByAssignResourceId(final int assignResourceId){
			logger.debug("Fetching total salary paid for assignResourceId: {}", assignResourceId);
			double total = 0;
			Session session = HibernateUtil.opensession();
			try{
				Object result = session.createQuery(
					"SELECT SUM(sp.amount) FROM PaymentProcessingEntity sp " +
					"WHERE sp.employeeToFarm.assignResourceId = " + assignResourceId)
					.uniqueResult();
				if(result != null) total = ((Number) result).doubleValue();
			}catch(HibernateException exception){
				logger.error("Error fetching total salary paid for assignResourceId: {}", assignResourceId, exception);
			}finally{
				session.close();
			}
			return total;
		}

		public double getTotalSalaryPaidBySiteInfoId(final int siteInfoId){
			logger.debug("Fetching total salary paid for siteInfoId: {}", siteInfoId);
			double total = 0;
			Session session = HibernateUtil.opensession();
			try{
				Object result = session.createQuery(
					"SELECT SUM(sp.amount) FROM PaymentProcessingEntity sp " +
					"WHERE sp.employeeToFarm.cropToSiteEntity.siteInformationEntity.siteInfoId = " + siteInfoId)
					.uniqueResult();
				if(result != null) total = ((Number) result).doubleValue();
			}catch(HibernateException exception){
				logger.error("Error fetching total salary paid for siteInfoId: {}", siteInfoId, exception);
			}finally{
				session.close();
			}
			return total;
		}

		public double getTotalSalaryPaidByEmployeeInfoId(final int employeeInfoId){
			logger.debug("Fetching total salary paid for employeeInfoId: {}", employeeInfoId);
			double total = 0;
			Session session = HibernateUtil.opensession();
			try{
				Object result = session.createQuery(
					"SELECT SUM(sp.amount) FROM PaymentProcessingEntity sp " +
					"WHERE sp.employeeToFarm.employeeInfoEntity.employeeInfoId = " + employeeInfoId)
					.uniqueResult();
				if(result != null) total = ((Number) result).doubleValue();
				logger.debug("Total salary paid for employeeInfoId {}: {}", employeeInfoId, total);
			}catch(HibernateException exception){
				logger.error("Error fetching total salary paid for employeeInfoId: {}", employeeInfoId, exception);
			}finally{
				session.close();
			}
			return total;
		}
	}
