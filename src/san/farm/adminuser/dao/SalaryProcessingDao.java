package san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

import san.farm.adminuser.entity.SalaryProcessingEntity;
import san.farm.util.HibernateUtil;

	/**
	 * @author santosh Khule
	 * Date 30/12/2014
	 * @version 1.2
	 * Class Developed for Business Level Operation Fetching Objects from SalaryProcessingServlet.java
	 */
public class SalaryProcessingDao {
		/**
		 * Insert Operation:Fecthing Object from SalaryProcessingServlet.java Inserting values into userType User table
		 * @param SalaryProcessingEntity object
		 * @return boolean
		 */
		public boolean saveSalaryTransaction(SalaryProcessingEntity salaryProcess){			
			Session session=HibernateUtil.opensession();
			Transaction transaction=session.beginTransaction(); 
			boolean flag=false;
			try{
				session.save(salaryProcess);
				transaction.commit();
				flag=true;
			}catch(HibernateException exception){
				if(transaction!=null){
					transaction.rollback();
				}
				exception.printStackTrace();
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
			Session session=HibernateUtil.opensession();
			Transaction transaction=session.beginTransaction(); 
			boolean flag=false;
			try{
				session.update(salaryProcess);
				transaction.commit();
				flag=true;
			}catch(HibernateException exception){
				if(transaction!=null){
					transaction.rollback();
				}
				exception.printStackTrace();
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
			Session session=HibernateUtil.opensession();
			Transaction transaction=session.beginTransaction(); 
			boolean flag=false;
			try{
				SalaryProcessingEntity salaryProcess=(SalaryProcessingEntity)session.get(SalaryProcessingEntity.class, cropToSiteId);
				session.delete(salaryProcess);
				transaction.commit();
				flag=true;
			}catch(HibernateException exception){
				if(transaction!=null){
					transaction.rollback();
				}
				exception.printStackTrace();
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
			List<SalaryProcessingEntity> processingEntities=new ArrayList<SalaryProcessingEntity>();
			Session session=HibernateUtil.opensession();			
			try{
				processingEntities=session.createQuery("from SalaryProcessingEntity where assignResourceId="+assignResourceId).list();				
			}catch(HibernateException exception){				
				exception.printStackTrace();
			}finally{
				session.close();
			}
			return processingEntities;
		}
	}
