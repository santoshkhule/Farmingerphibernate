package san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;

import san.farm.adminuser.entity.AssignCropToSiteEntity;
import san.farm.adminuser.entity.AssignCropToSiteRefEntity;
import san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 23/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from AssignCropToSiteController.java
 */
public class AssignCropToSiteRefService {
	/**
	 * Insert Operation:Fecthing Object from AssignCropToSiteController.java Inserting values into userType User table
	 * @param AssignCropToSiteEntity object
	 * @return boolean
	 */
	public boolean saveAssignCropToSiteRef(AssignCropToSiteRefEntity cropToSiteRefEntity){		
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.save(cropToSiteRefEntity);
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
	 * Update Operation:Fecthing Object from AssignCropToSiteRefController.java Updating values into userType User table
	 * @param AssignCropToSiteRefEntity object
	 * @return boolean
	 * 
	 **/
	public boolean updateAssignCropToSiteRef(AssignCropToSiteRefEntity cropToSiteRefEntity){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.update(cropToSiteRefEntity);
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
	 * Delete Operation:Fecthing Object from AssignCropToSiteRefController.java Deleting Data from userType User table
	 * @param AssignCropToSiteRefEntity object
	 * @return boolean 
	 **/
	public boolean deleteAssignCropToSiteRef(final int cropToSiteId){
		AssignCropToSiteService cropToSiteService=new AssignCropToSiteService();
		String qry="from AssignCropToSiteEntity where assignCroptoSiteId="+cropToSiteId;
		AssignCropToSiteEntity CropToSite=cropToSiteService.getAssignCropToSiteInfoBySiteIdDate(qry);		
		Session session=null;		
		boolean flag=false;			
			session=HibernateUtil.opensession();
			Transaction transaction=session.beginTransaction(); 			
			try{
				for(AssignCropToSiteRefEntity cropToSiteRefEntity1:CropToSite.getCropToSiteRefEntity()){							
					session.delete(cropToSiteRefEntity1);								
					transaction.commit();
					flag=true;
				}
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
	public List<AssignCropToSiteRefEntity> getListOFAssignCropToSiteRefBycropToSiteId(final int cropToSiteId){
		List<AssignCropToSiteRefEntity> listOFAssignCropToSiteRef=new ArrayList<AssignCropToSiteRefEntity>();
		Session session=HibernateUtil.opensession();
		//list=session.createQuery("from AssignCropToSiteEntity").list();
		try{
			listOFAssignCropToSiteRef=session.createQuery("from AssignCropToSiteRefEntity where AssignCropToSiteId="+cropToSiteId).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return listOFAssignCropToSiteRef;
	}
	/**
	 * Fetch Operation:Taking cropId from AssignCropToSiteController.java and Fetching respective Data From DB 
	 * @return cropToSiteRefEntity	 
	 * */
	public AssignCropToSiteRefEntity getAssignCropToSiteRefByAssignCropToSiteRefId(int assignCropToSiteRefId){
		AssignCropToSiteRefEntity cropToSiteRefEntity=new AssignCropToSiteRefEntity();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteRefEntity=(AssignCropToSiteRefEntity)session.createCriteria(AssignCropToSiteRefEntity.class).add(Restrictions.eq("assignCropToSiteRefId", assignCropToSiteRefId)).uniqueResult();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return cropToSiteRefEntity;
	}
}
