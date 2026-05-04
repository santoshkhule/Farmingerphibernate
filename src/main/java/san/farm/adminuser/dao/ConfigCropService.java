package san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;

import san.farm.adminuser.entity.ConfigCropEntity;
import san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 13/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from ConfigCropController.java
 */
public class ConfigCropService {
	/**
	 * Insert Operation:Fecthing Object from ConfigCropController.java Inserting values into userType User table
	 * @param ConfigCropEntity object
	 * @return boolean
	 */
	public boolean saveCrop(ConfigCropEntity configCropEntity){
		
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.save(configCropEntity);
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
	 * Update Operation:Fecthing Object from ConfigCropController.java Updating values into userType User table
	 * @param ConfigCropEntity object
	 * @return boolean
	 * 
	 **/
	public boolean updateCrop(ConfigCropEntity configCropEntity){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.update(configCropEntity);
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
	 * Delete Operation:Fecthing Object from ConfigCropController.java Deleting Data from userType User table
	 * @param ConfigCropEntity object
	 * @return boolean 
	 **/
	public boolean deleteCrop(int cropId){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			ConfigCropEntity configCropEntity=(ConfigCropEntity)session.get(ConfigCropEntity.class, cropId);
			session.delete(configCropEntity);
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
	public List<ConfigCropEntity> fetch(){
		List<ConfigCropEntity> list=new ArrayList<ConfigCropEntity>();
		Session session=HibernateUtil.opensession();
		try{
		//list=session.createQuery("from ConfigCropEntity").list();
		list=session.createCriteria(ConfigCropEntity.class).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return list;
	}
	/**
	 * Fetch Operation:Taking cropId from ConfigCropController.java and Fetching respective Data From DB 
	 * @return ConfigCropEntity	 
	 * */
	public ConfigCropEntity getCropIdByCropId(int cropId){
		ConfigCropEntity configCropEntity=new ConfigCropEntity();
		Session session=HibernateUtil.opensession();	
		try{
		configCropEntity=(ConfigCropEntity)session.createCriteria(ConfigCropEntity.class).add(Restrictions.eq("cropId", cropId)).uniqueResult();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return configCropEntity;
	}
}
