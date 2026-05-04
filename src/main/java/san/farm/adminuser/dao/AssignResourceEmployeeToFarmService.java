package san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

import san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 01/12/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from AssignResourceEmployeeToFarmController.java
 */
public class AssignResourceEmployeeToFarmService {
	/**
	 * Insert Operation:Fecthing Object from AssignResourceEmployeeToFarmController.java Inserting values into userType User table
	 * @param AssignEmployeeToFarmEntity object
	 * @return boolean
	 */
	public boolean saveEmployeeToFarm(AssignEmployeeToFarmEntity employeeToFarm){		
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.save(employeeToFarm);
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
	 * Update Operation:Fecthing Object from AssignResourceEmployeeToFarmController.java Updating values into table
	 * @param AssignEmployeeToFarmEntity object
	 * @return boolean
	 * 
	 **/
	public boolean updateEmployeeToFarm(AssignEmployeeToFarmEntity employeeToFarm){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.update(employeeToFarm);
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
	 * Delete Operation:Fecthing Object from AssignResourceEmployeeToFarmController.java Deleting Data from table
	 * @param AssignEmployeeToFarmEntity object
	 * @return boolean 
	 **/
	public boolean deleteAssignResources(final int assignResourceId){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			AssignEmployeeToFarmEntity employeeToFarm=(AssignEmployeeToFarmEntity)session.get(AssignEmployeeToFarmEntity.class, assignResourceId);
			session.delete(employeeToFarm);
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
	 * Fetch Operation:Fecthing Data From DB called from 01assignTaskToEmployeeViewAll.jsp
	 * @return list	 
	 * */
	public List<AssignEmployeeToFarmEntity> getListOFEmployeeToFarm(){
		List<AssignEmployeeToFarmEntity> listOFEmployeeToFarm=new ArrayList<AssignEmployeeToFarmEntity>();
		Session session=HibernateUtil.opensession();		
		try{
			listOFEmployeeToFarm=session.createQuery("from AssignEmployeeToFarmEntity").list();
		//listOFEmployeeToFarm=session.createCriteria(AssignEmployeeToFarmEntity.class).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
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
		List<AssignEmployeeToFarmEntity> cropToSiteList=new ArrayList<AssignEmployeeToFarmEntity>();
		Session session=HibernateUtil.opensession();
		try{
			cropToSiteList=session.createQuery(qry).list();
			//cropToSiteList=session.createCriteria(AssignEmployeeToFarmEntity.class).add(Restrictions.eq("siteInfoId", siteId)).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
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
		AssignEmployeeToFarmEntity employeeToFarm=new AssignEmployeeToFarmEntity();
		Session session=HibernateUtil.opensession();
		try{
			employeeToFarm=(AssignEmployeeToFarmEntity)session.createQuery(qry).uniqueResult();			
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return employeeToFarm;
	}
	/**
	 * Fetch Operation:Fetching All Data From DB called from 01assignTaskToEmployeeViewAll.jsp 
	 * @return employeeToFarm	 
	 * *//*
	public List<AssignEmployeeToFarmEntity> getAllEmployeeToFarm(){
		List<AssignEmployeeToFarmEntity> employeeToFarmList=new ArrayList<AssignEmployeeToFarmEntity>();
		Session session=HibernateUtil.opensession();		
		try{
			String qry="from AssignEmployeeToFarmEntity";
			
			list=session.createQuery(qry).list();
			System.out.println(list.size());
			
			
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return employeeToFarmList;
	}*/
	
	/**
	 * Fetch Operation:Fecthing Data From DB called from 01assignTaskToEmployeeViewAll.jsp
	 * @return list	 
	 * */
	public List<AssignEmployeeToFarmEntity> getListOFEmployeeToFarmByQry(final String query){
		List<AssignEmployeeToFarmEntity> listOFEmployeeToFarm=new ArrayList<AssignEmployeeToFarmEntity>();
		Session session=HibernateUtil.opensession();		
		try{
			listOFEmployeeToFarm=session.createQuery(query).list();
		//listOFEmployeeToFarm=session.createCriteria(AssignEmployeeToFarmEntity.class).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return listOFEmployeeToFarm;
	}
}
