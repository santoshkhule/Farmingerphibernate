package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.Hibernate;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import com.san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 01/12/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from AssignResourceEmployeeToFarmController.java
 */
public class AssignResourceEmployeeToFarmService {
	private static final Logger logger = LoggerFactory.getLogger(AssignResourceEmployeeToFarmService.class);

	public boolean saveEmployeeToFarm(AssignEmployeeToFarmEntity employeeToFarm){
		logger.debug("Saving AssignEmployeeToFarm entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			session.save(employeeToFarm);
			transaction.commit();
			flag=true;
			logger.info("AssignEmployeeToFarm saved successfully");
		}catch(HibernateException exception){
			if(transaction!=null){ transaction.rollback(); }
			logger.error("Error saving AssignEmployeeToFarm", exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Update Operation:Fecthing Object from AssignResourceEmployeeToFarmController.java Updating values into table
	 * @param AssignEmployeeToFarmEntity object
	 * @return boolean
	 *
	 **/
	public boolean updateEmployeeToFarm(AssignEmployeeToFarmEntity employeeToFarm){
		logger.debug("Updating AssignEmployeeToFarm entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			session.update(employeeToFarm);
			transaction.commit();
			flag=true;
			logger.info("AssignEmployeeToFarm updated successfully");
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error updating AssignEmployeeToFarm", exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Delete Operation:Fecthing Object from AssignResourceEmployeeToFarmController.java Deleting Data from table
	 * @param AssignEmployeeToFarmEntity object
	 * @return boolean
	 **/
	public boolean deleteAssignResources(final int assignResourceId){
		logger.debug("Deleting AssignEmployeeToFarm with assignResourceId: {}", assignResourceId);
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			// Delete child salary records first to avoid FK constraint violation
			session.createQuery(
				"DELETE FROM PaymentProcessingEntity s WHERE s.employeeToFarm.assignResourceId = :id")
				.setParameter("id", assignResourceId)
				.executeUpdate();

			AssignEmployeeToFarmEntity employeeToFarm=(AssignEmployeeToFarmEntity)session.get(AssignEmployeeToFarmEntity.class, assignResourceId);
			if(employeeToFarm != null){
				session.delete(employeeToFarm);
			}
			transaction.commit();
			flag=true;
			logger.info("AssignEmployeeToFarm deleted successfully for assignResourceId: {}", assignResourceId);
		}catch(Exception exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error deleting AssignEmployeeToFarm for assignResourceId: {}", assignResourceId, exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Fetch Operation:Fecthing Data From DB called from 01assignTaskToEmployeeViewAll.jsp
	 * @return list
	 * */
	public List<AssignEmployeeToFarmEntity> getListOFEmployeeToFarm(){
		logger.debug("Fetching all AssignEmployeeToFarm records");
		List<AssignEmployeeToFarmEntity> listOFEmployeeToFarm=new ArrayList<AssignEmployeeToFarmEntity>();
		Session session=HibernateUtil.opensession();
		try{
			listOFEmployeeToFarm=session.createQuery("from AssignEmployeeToFarmEntity").list();
			for(AssignEmployeeToFarmEntity entity:listOFEmployeeToFarm){
				Hibernate.initialize(entity.getListFarmTaskEntities());
			}
			logger.info("Retrieved {} AssignEmployeeToFarm records", listOFEmployeeToFarm.size());
		}catch(HibernateException exception){
			logger.error("Error fetching AssignEmployeeToFarm list", exception);
		}finally{
			session.close();
		}
		return listOFEmployeeToFarm;
	}

	/**
	 * Fetch Operation:Fetching list Data From DB
	 * @return employeeToFarm
	 * */
	public List<AssignEmployeeToFarmEntity> getEmployeeToFarmInfoByFilter(String qry){
		logger.debug("Fetching AssignEmployeeToFarm list by filter query");
		List<AssignEmployeeToFarmEntity> cropToSiteList=new ArrayList<AssignEmployeeToFarmEntity>();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteList=session.createQuery(qry).list();
			for(AssignEmployeeToFarmEntity entity:cropToSiteList){
				Hibernate.initialize(entity.getListFarmTaskEntities());
			}
			logger.info("Retrieved {} AssignEmployeeToFarm records by filter", cropToSiteList.size());
		}catch(HibernateException exception){
			logger.error("Error fetching AssignEmployeeToFarm by filter", exception);
		}finally{
			session.close();
		}
		return cropToSiteList;
	}
	/**
	 * Fetch Operation:Fetching Data From DB
	 * @return employeeToFarm
	 * */
	public AssignEmployeeToFarmEntity getEmployeeToFarmInfoByEmployeeInfoIdDate(String qry){
		logger.debug("Fetching single AssignEmployeeToFarm by query");
		AssignEmployeeToFarmEntity employeeToFarm=new AssignEmployeeToFarmEntity();
		Session session=HibernateUtil.opensession();
		try{
			employeeToFarm=(AssignEmployeeToFarmEntity)session.createQuery(qry).uniqueResult();
			logger.info("Retrieved AssignEmployeeToFarm record by query");
		}catch(HibernateException exception){
			logger.error("Error fetching AssignEmployeeToFarm by query", exception);
		}finally{
			session.close();
		}
		return employeeToFarm;
	}
	/**
	 * Fetch by primary key — safe load by PK using session.get()
	 * @param assignResourceId primary key
	 * @return entity or null
	 */
	public AssignEmployeeToFarmEntity getEmployeeToFarmById(final int assignResourceId){
		logger.debug("Fetching AssignEmployeeToFarm by id: {}", assignResourceId);
		Session session = HibernateUtil.opensession();
		AssignEmployeeToFarmEntity entity = null;
		try{
			entity = (AssignEmployeeToFarmEntity) session.get(AssignEmployeeToFarmEntity.class, assignResourceId);
			if(entity != null){
				Hibernate.initialize(entity.getListFarmTaskEntities());
			}
			logger.info("Retrieved AssignEmployeeToFarm for id: {}", assignResourceId);
		}catch(HibernateException exception){
			logger.error("Error fetching AssignEmployeeToFarm by id: {}", assignResourceId, exception);
		}finally{
			session.close();
		}
		return entity;
	}

	/**
	 * Fetch Operation:Fecthing Data From DB called from 01assignTaskToEmployeeViewAll.jsp
	 * @return list
	 * */
	/**
	 * Returns [totalAmount, totalAdvPayment] summed across all assignments for an employee.
	 * Index 0 = total amount to pay, index 1 = total advance paid.
	 */
	public double[] getTotalAmountAndAdvByEmployeeInfoId(final int employeeInfoId){
		logger.debug("Fetching total amount and advance for employeeInfoId: {}", employeeInfoId);
		double[] result = {0, 0};
		Session session = HibernateUtil.opensession();
		try{
			Object[] row = (Object[]) session.createQuery(
				"SELECT SUM(aef.amount), SUM(aef.advPayment) FROM AssignEmployeeToFarmEntity aef " +
				"WHERE aef.employeeInfoEntity.employeeInfoId = " + employeeInfoId)
				.uniqueResult();
			if(row != null){
				if(row[0] != null) result[0] = ((Number) row[0]).doubleValue();
				if(row[1] != null) result[1] = ((Number) row[1]).doubleValue();
			}
			logger.debug("Employee {} — totalAmount: {}, totalAdv: {}", employeeInfoId, result[0], result[1]);
		}catch(HibernateException exception){
			logger.error("Error fetching total amount/adv for employeeInfoId: {}", employeeInfoId, exception);
		}finally{
			session.close();
		}
		return result;
	}

	public List<AssignEmployeeToFarmEntity> getListBySiteInfoId(final int siteInfoId){
		return getListOFEmployeeToFarmByQry(
			"FROM AssignEmployeeToFarmEntity aef WHERE aef.cropToSiteEntity.siteInformationEntity.siteInfoId = " + siteInfoId
		);
	}

	public List<AssignEmployeeToFarmEntity> getListByEmployeeInfoId(final int employeeInfoId){
		return getListOFEmployeeToFarmByQry(
			"FROM AssignEmployeeToFarmEntity aef WHERE aef.employeeInfoEntity.employeeInfoId = " + employeeInfoId
		);
	}

	public List<AssignEmployeeToFarmEntity> getListOFEmployeeToFarmByQry(final String query){
		logger.debug("Fetching AssignEmployeeToFarm list by query");
		List<AssignEmployeeToFarmEntity> listOFEmployeeToFarm=new ArrayList<AssignEmployeeToFarmEntity>();
		Session session=HibernateUtil.opensession();
		try{
			listOFEmployeeToFarm=session.createQuery(query).list();
			for(AssignEmployeeToFarmEntity entity:listOFEmployeeToFarm){
				Hibernate.initialize(entity.getListFarmTaskEntities());
			}
			logger.info("Retrieved {} AssignEmployeeToFarm records by query", listOFEmployeeToFarm.size());
		}catch(HibernateException exception){
			logger.error("Error fetching AssignEmployeeToFarm list by query", exception);
		}finally{
			session.close();
		}
		return listOFEmployeeToFarm;
	}
}
