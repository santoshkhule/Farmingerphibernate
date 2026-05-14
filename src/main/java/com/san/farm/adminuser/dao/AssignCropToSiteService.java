package com.san.farm.adminuser.dao;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 21/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from AssignCropToSiteController.java
 */
public class AssignCropToSiteService {
	private static final Logger logger = LoggerFactory.getLogger(AssignCropToSiteService.class);
	/**
	 * Insert Operation:Fecthing Object from AssignCropToSiteController.java Inserting values into userType User table
	 * @param AssignCropToSiteEntity object
	 * @return boolean
	 */
	public boolean saveAssignCropToSite(AssignCropToSiteEntity cropToSiteEntity){
		logger.debug("Saving AssignCropToSite entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.save(cropToSiteEntity);
			transaction.commit();
			flag=true;
			logger.info("AssignCropToSite saved successfully");
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error saving AssignCropToSite", exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Update Operation:Fecthing Object from AssignCropToSiteController.java Updating values into userType User table
	 * @param AssignCropToSiteEntity object
	 * @return boolean
	 * 
	 **/
	public boolean updateAssignCropToSite(AssignCropToSiteEntity cropToSiteEntity){
		logger.debug("Updating AssignCropToSite entity with id: {}", cropToSiteEntity);
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.update(cropToSiteEntity);
			transaction.commit();
			flag=true;
			logger.info("AssignCropToSite updated successfully");
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error updating AssignCropToSite", exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Delete Operation:Fecthing Object from AssignCropToSiteController.java Deleting Data from userType User table
	 * @param AssignCropToSiteEntity object
	 * @return boolean 
	 **/
	public boolean deleteAssignCropToSite(final int cropToSiteId){
		logger.debug("Deleting AssignCropToSite with id: {}", cropToSiteId);
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			AssignCropToSiteEntity cropToSiteEntity=(AssignCropToSiteEntity)session.get(AssignCropToSiteEntity.class, cropToSiteId);
			session.delete(cropToSiteEntity);
			transaction.commit();
			flag=true;
			logger.info("AssignCropToSite deleted successfully with id: {}", cropToSiteId);
		}catch(HibernateException exception){
			if(transaction!=null){
				transaction.rollback();
			}
			logger.error("Error deleting AssignCropToSite with id: {}", cropToSiteId, exception);
		}finally{
			session.close();
		}
		return flag;
	}
	/**
	 * Fetch Operation:Fecthing Data From DB 
	 * @return list	 
	 * */
	public List<AssignCropToSiteEntity> getListOFAssignCropToSite(){
		logger.debug("Fetching all AssignCropToSite records");
		List<AssignCropToSiteEntity> listOFAssignCropToSite=new ArrayList<AssignCropToSiteEntity>();
		Session session=HibernateUtil.opensession();
		try{
			List<AssignCropToSiteEntity> list = session
					.createQuery(
							"SELECT DISTINCT a FROM AssignCropToSiteEntity a " +
									"LEFT JOIN FETCH a.cropToSiteRefEntity",
							AssignCropToSiteEntity.class)
					.getResultList();
			logger.info("Retrieved {} AssignCropToSite records", list.size());
			return list;

		}catch(HibernateException exception){
			logger.error("Error fetching AssignCropToSite records", exception);
		}finally{
			session.close();
		}
		return listOFAssignCropToSite;
	}
	/**
	 * Fetch Operation:qry  from JSP file 
	 * @return cropToSiteEntity	 
	 * */
	public List<AssignCropToSiteEntity> getAssignCropToSiteInfoByFilter(String qry){
		logger.debug("Fetching AssignCropToSite with filter query");
		List<AssignCropToSiteEntity> cropToSiteList=new ArrayList<AssignCropToSiteEntity>();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteList=session.createQuery(qry).list();
			logger.info("Retrieved {} AssignCropToSite records with filter", cropToSiteList.size());
		}catch(HibernateException exception){
			logger.error("Error fetching AssignCropToSite with filter", exception);
		}finally{
			session.close();
		}
		return cropToSiteList;
	}
	/**
	 * Fetch Operation: qry  from JSP file
	 * @return cropToSiteEntity	 
	 * */
	public AssignCropToSiteEntity getAssignCropToSiteInfoBySiteIdDate(String qry){
		logger.debug("Fetching single AssignCropToSite record");
		AssignCropToSiteEntity cropToSiteEntity=new AssignCropToSiteEntity();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteEntity=(AssignCropToSiteEntity)session.createQuery(qry).uniqueResult();
			logger.info("Retrieved AssignCropToSite record successfully");
		}catch(HibernateException exception){
			logger.error("Error fetching AssignCropToSite record", exception);
		}finally{
			session.close();
		}
		return cropToSiteEntity;
	}
	/**
	 * Fetch Operation: AssignCropToSite record by cropTositeId
	 * @return cropToSiteEntity	 
	 * */
	public AssignCropToSiteEntity getAssignCropToSiteInfoByCropToSiteId(final int cropToSiteId){
		logger.debug("Fetching AssignCropToSite with id: {}", cropToSiteId);
		AssignCropToSiteEntity cropToSiteEntity=new AssignCropToSiteEntity();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteEntity=(AssignCropToSiteEntity)session.get(AssignCropToSiteEntity.class, cropToSiteId);
			logger.info("Retrieved AssignCropToSite with id: {}", cropToSiteId);
		}catch(HibernateException exception){
			logger.error("Error fetching AssignCropToSite with id: {}", cropToSiteId, exception);
		}finally{
			session.close();
		}
		return cropToSiteEntity;
	}
	/**
	 * Fetch Operation: Fetch object
	 * @return cropToSiteEntity
	 * */
	public AssignCropToSiteEntity getAssignCropToSiteInfoBySiteIdDateCropId(final int siteInfoId,final Date assignFarmDate,final int cropId){
		logger.debug("Fetching AssignCropToSite for siteId: {}, date: {}, cropId: {}", siteInfoId, assignFarmDate, cropId);
		AssignCropToSiteEntity cropToSiteEntity=new AssignCropToSiteEntity();
		Session session=HibernateUtil.opensession();
		try{
			String query="from AssignCropToSiteEntity where cropAssignDate='"+assignFarmDate+"' and siteInfoId="+siteInfoId;
			Query query2=session.createQuery(query);
			cropToSiteEntity=(AssignCropToSiteEntity)query2.uniqueResult();
			logger.info("Retrieved AssignCropToSite successfully");
		}catch(HibernateException exception){
			logger.error("Error fetching AssignCropToSite for siteId: {}, date: {}", siteInfoId, assignFarmDate, exception);
		}finally{
			session.close();
		}
		return cropToSiteEntity;
	}
	/**
	 * Toggle readyToDispatch flag for a site-crop allocation.
	 */
	public boolean toggleReadyToDispatch(int cropToSiteId) {
		logger.debug("Toggling readyToDispatch for id: {}", cropToSiteId);
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			Object result = session.createQuery(
				"SELECT a.readyToDispatch FROM AssignCropToSiteEntity a WHERE a.assignCroptoSiteId = :id")
				.setParameter("id", cropToSiteId).uniqueResult();
			boolean current = result != null && (Boolean) result;
			session.createQuery(
				"UPDATE AssignCropToSiteEntity SET readyToDispatch = :v WHERE assignCroptoSiteId = :id")
				.setParameter("v", !current).setParameter("id", cropToSiteId).executeUpdate();
			transaction.commit();
			logger.info("Toggled readyToDispatch to {} for id: {}", !current, cropToSiteId);
			return true;
		} catch (HibernateException ex) {
			if (transaction != null) transaction.rollback();
			logger.error("Error toggling readyToDispatch for id: {}", cropToSiteId, ex);
			return false;
		} finally {
			session.close();
		}
	}

	/**
	 * Fetch all site-crop allocations marked as ready to dispatch.
	 */
	public List<AssignCropToSiteEntity> getReadyToDispatch() {
		logger.debug("Fetching ready-to-dispatch records");
		Session session = HibernateUtil.opensession();
		try {
			List<AssignCropToSiteEntity> list = session.createQuery(
				"SELECT DISTINCT a FROM AssignCropToSiteEntity a " +
				"LEFT JOIN FETCH a.cropToSiteRefEntity " +
				"WHERE a.readyToDispatch = true",
				AssignCropToSiteEntity.class).getResultList();
			logger.info("Retrieved {} ready-to-dispatch records", list.size());
			return list;
		} catch (HibernateException ex) {
			logger.error("Error fetching ready-to-dispatch records", ex);
			return new ArrayList<AssignCropToSiteEntity>();
		} finally {
			session.close();
		}
	}

	/**
	 * Fetch Operation: testtttttttttttttingggggggggg
	 * @return cropToSiteEntity
	 * */
	public Object getTestAssignCropToSiteInfoBySiteIdDateCropId(final int siteInfoId,final Date assignFarmDate,final int cropId){
		logger.debug("Test fetching AssignCropToSite");
		Object cropToSiteEntity=new Object();
		Session session=HibernateUtil.opensession();
		try{
			String query="ACS.siteInformationEntity,ACSR.configCropEntity from AssignCropToSiteRefEntity ACSR,AssignCropToSiteEntity ACS where ACS.assignCroptoSiteId=5";
			Query query2=session.createQuery(query);
			cropToSiteEntity=(Object)query2.uniqueResult();
			logger.info("Test fetch successful");
		}catch(HibernateException exception){
			logger.error("Error in test fetch", exception);
		}finally{
			session.close();
		}
		return cropToSiteEntity;
	}
}
