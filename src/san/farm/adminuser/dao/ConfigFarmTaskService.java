package san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;

import san.farm.adminuser.entity.ConfigFarmTaskEntity;
import san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 16/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from ConfigFarmTaskController.java
 */
public class ConfigFarmTaskService {
	/**
	 * Insert Operation:Fecthing Object from ConfigFarmTaskController.java Inserting values into Farm Task User table
	 * @param ConfigFarmTaskEntity object
	 * @return boolean
	 */
	public boolean saveFarmTask(ConfigFarmTaskEntity configFarmTaskEntity){
		System.out.println("Inside Save User Type:====>>>>>>>>>>>>");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.save(configFarmTaskEntity);
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
	 * Update Operation:Fecthing Object from ConfigFarmTaskController.java Updating values into Farm Task User table
	 * @param ConfigFarmTaskEntity object
	 * @return boolean
	 * 
	 **/
	public boolean updateFarmTask(ConfigFarmTaskEntity configFarmTaskEntity){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.update(configFarmTaskEntity);
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
	 * Delete Operation:Fecthing Object from ConfigFarmTaskController.java Deleting Data from Farm Task User table
	 * @param ConfigFarmTaskEntity object
	 * @return boolean 
	 **/
	public boolean deleteFarmTask(int taskId){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			ConfigFarmTaskEntity configFarmTaskEntity=(ConfigFarmTaskEntity)session.get(ConfigFarmTaskEntity.class, taskId);
			session.delete(configFarmTaskEntity);
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
	public List<ConfigFarmTaskEntity> fetch(){
		List<ConfigFarmTaskEntity> list=new ArrayList<ConfigFarmTaskEntity>();
		Session session=HibernateUtil.opensession();
		try{
		list=session.createQuery("from ConfigFarmTaskEntity").list();
			//list=session.createCriteria(ConfigFarmTaskEntity.class).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return list;
		
	}
	/**
	 * Fetch Operation:Taking cropId from ConfigFarmTaskController.java and Fetching respective Data From DB 
	 * @return ConfigFarmTaskEntity	 
	 * */
	public ConfigFarmTaskEntity getFarmTaskIdByTaskId(int taskId){
		ConfigFarmTaskEntity configFarmTaskEntity=new ConfigFarmTaskEntity();
		Session session=HibernateUtil.opensession();	
		try{
			configFarmTaskEntity=(ConfigFarmTaskEntity)session.createCriteria(ConfigFarmTaskEntity.class).add(Restrictions.eq("taskId", taskId)).uniqueResult();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return configFarmTaskEntity;
	}
}
