package san.farm.adminuser.dao;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import san.farm.adminuser.entity.AssignCropToSiteEntity;
import san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 21/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from AssignCropToSiteController.java
 */
public class AssignCropToSiteService {
	/**
	 * Insert Operation:Fecthing Object from AssignCropToSiteController.java Inserting values into userType User table
	 * @param AssignCropToSiteEntity object
	 * @return boolean
	 */
	public boolean saveAssignCropToSite(AssignCropToSiteEntity cropToSiteEntity){
		/*System.out.println("Inside Save User Type:====>>>>>>>>>>>>");*/
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.save(cropToSiteEntity);
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
	 * Update Operation:Fecthing Object from AssignCropToSiteController.java Updating values into userType User table
	 * @param AssignCropToSiteEntity object
	 * @return boolean
	 * 
	 **/
	public boolean updateAssignCropToSite(AssignCropToSiteEntity cropToSiteEntity){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.update(cropToSiteEntity);
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
	 * Delete Operation:Fecthing Object from AssignCropToSiteController.java Deleting Data from userType User table
	 * @param AssignCropToSiteEntity object
	 * @return boolean 
	 **/
	public boolean deleteAssignCropToSite(final int cropToSiteId){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			AssignCropToSiteEntity cropToSiteEntity=(AssignCropToSiteEntity)session.get(AssignCropToSiteEntity.class, cropToSiteId);
			session.delete(cropToSiteEntity);
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
	 * Fetch Operation:Fecthing Data From DB 
	 * @return list	 
	 * */
	public List<AssignCropToSiteEntity> getListOFAssignCropToSite(){
		List<AssignCropToSiteEntity> listOFAssignCropToSite=new ArrayList<AssignCropToSiteEntity>();
		Session session=HibernateUtil.opensession();
		//list=session.createQuery("from AssignCropToSiteEntity").list();
		try{
			listOFAssignCropToSite=session.createQuery("from AssignCropToSiteEntity").list();
		//listOFAssignCropToSite=session.createCriteria(AssignCropToSiteEntity.class).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
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
		List<AssignCropToSiteEntity> cropToSiteList=new ArrayList<AssignCropToSiteEntity>();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteList=session.createQuery(qry).list();
			//cropToSiteList=session.createCriteria(AssignCropToSiteEntity.class).add(Restrictions.eq("siteInfoId", siteId)).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
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
		AssignCropToSiteEntity cropToSiteEntity=new AssignCropToSiteEntity();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteEntity=(AssignCropToSiteEntity)session.createQuery(qry).uniqueResult();
			//cropToSiteList=session.createCriteria(AssignCropToSiteEntity.class).add(Restrictions.eq("siteInfoId", siteId)).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
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
		AssignCropToSiteEntity cropToSiteEntity=new AssignCropToSiteEntity();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteEntity=(AssignCropToSiteEntity)session.get(AssignCropToSiteEntity.class, cropToSiteId);			
		}catch(HibernateException exception){			
			exception.printStackTrace();
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
		AssignCropToSiteEntity cropToSiteEntity=new AssignCropToSiteEntity();		
		Session session=HibernateUtil.opensession();
		try{
			String query="from AssignCropToSiteEntity where cropAssignDate='"+assignFarmDate+"' and siteInfoId="+siteInfoId;
			Query query2=session.createQuery(query);
			cropToSiteEntity=(AssignCropToSiteEntity)query2.uniqueResult();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return cropToSiteEntity;
	}
	/**
	 * Fetch Operation: testtttttttttttttingggggggggg
	 * @return cropToSiteEntity
	 * */
	public Object getTestAssignCropToSiteInfoBySiteIdDateCropId(final int siteInfoId,final Date assignFarmDate,final int cropId){
		Object cropToSiteEntity=new Object();		
		Session session=HibernateUtil.opensession();
		try{
			String query="ACS.siteInformationEntity,ACSR.configCropEntity from AssignCropToSiteRefEntity ACSR,AssignCropToSiteEntity ACS where ACS.assignCroptoSiteId=5";
			//String query="ACS.siteInformationEntity,ACSR.configCropEntity from AssignCropToSiteRefEntity ACSR,AssignCropToSiteEntity ACS where ACS.cropAssignDate='"+assignFarmDate+"' and ACS.siteInfoId="+siteInfoId+" and ACS.assignCroptoSiteId=ACSR.cropToSiteEntity.getassignCroptoSiteId";
			Query query2=session.createQuery(query);
			cropToSiteEntity=(Object)query2.uniqueResult();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return cropToSiteEntity;
	}
}
