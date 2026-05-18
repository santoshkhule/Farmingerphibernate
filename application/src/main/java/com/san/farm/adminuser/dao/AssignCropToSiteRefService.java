package com.san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.adminuser.entity.AssignCropToSiteRefEntity;
import com.san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 23/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from AssignCropToSiteController.java
 */
public class AssignCropToSiteRefService {
	private static final Logger logger = LoggerFactory.getLogger(AssignCropToSiteRefService.class);

	public boolean saveAssignCropToSiteRef(AssignCropToSiteRefEntity cropToSiteRefEntity){
		logger.debug("Saving AssignCropToSiteRef entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			session.save(cropToSiteRefEntity);
			transaction.commit();
			flag=true;
			logger.info("AssignCropToSiteRef saved successfully");
		}catch(HibernateException exception){
			if(transaction!=null){ transaction.rollback(); }
			logger.error("Error saving AssignCropToSiteRef", exception);
		}finally{
			session.close();
		}
		return flag;
	}

	public boolean updateAssignCropToSiteRef(AssignCropToSiteRefEntity cropToSiteRefEntity){
		logger.debug("Updating AssignCropToSiteRef entity");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction();
		boolean flag=false;
		try{
			session.update(cropToSiteRefEntity);
			transaction.commit();
			flag=true;
			logger.info("AssignCropToSiteRef updated successfully");
		}catch(HibernateException exception){
			if(transaction!=null){ transaction.rollback(); }
			logger.error("Error updating AssignCropToSiteRef", exception);
		}finally{
			session.close();
		}
		return flag;
	}

	public boolean deleteAssignCropToSiteRef(final int cropToSiteId){
		logger.debug("Deleting AssignCropToSiteRef records for cropToSiteId: {}", cropToSiteId);
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		boolean flag = false;
		try{
			session.createQuery(
				"DELETE FROM AssignCropToSiteRefEntity WHERE cropToSiteEntity.assignCroptoSiteId = " + cropToSiteId)
				.executeUpdate();
			transaction.commit();
			flag = true;
			logger.info("AssignCropToSiteRef records deleted for cropToSiteId: {}", cropToSiteId);
		}catch(HibernateException exception){
			if(transaction != null){ transaction.rollback(); }
			logger.error("Error deleting AssignCropToSiteRef for cropToSiteId: {}", cropToSiteId, exception);
		}finally{
			session.close();
		}
		return flag;
	}

	public List<AssignCropToSiteRefEntity> getListOFAssignCropToSiteRefBycropToSiteId(final int cropToSiteId){
		logger.debug("Fetching AssignCropToSiteRef list for cropToSiteId: {}", cropToSiteId);
		List<AssignCropToSiteRefEntity> listOFAssignCropToSiteRef=new ArrayList<AssignCropToSiteRefEntity>();
		Session session=HibernateUtil.opensession();
		try{
			listOFAssignCropToSiteRef=session.createQuery("from AssignCropToSiteRefEntity where AssignCropToSiteId="+cropToSiteId).list();
			logger.info("Retrieved {} AssignCropToSiteRef records", listOFAssignCropToSiteRef.size());
		}catch(HibernateException exception){
			logger.error("Error fetching AssignCropToSiteRef for cropToSiteId: {}", cropToSiteId, exception);
		}finally{
			session.close();
		}
		return listOFAssignCropToSiteRef;
	}

	public AssignCropToSiteRefEntity getAssignCropToSiteRefByAssignCropToSiteRefId(int assignCropToSiteRefId){
		logger.debug("Fetching AssignCropToSiteRef by id: {}", assignCropToSiteRefId);
		AssignCropToSiteRefEntity cropToSiteRefEntity=new AssignCropToSiteRefEntity();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteRefEntity=(AssignCropToSiteRefEntity)session.createCriteria(AssignCropToSiteRefEntity.class).add(Restrictions.eq("assignCropToSiteRefId", assignCropToSiteRefId)).uniqueResult();
			logger.info("Retrieved AssignCropToSiteRef with id: {}", assignCropToSiteRefId);
		}catch(HibernateException exception){
			logger.error("Error fetching AssignCropToSiteRef with id: {}", assignCropToSiteRefId, exception);
		}finally{
			session.close();
		}
		return cropToSiteRefEntity;
	}
}
