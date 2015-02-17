package san.farm.adminuser.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;

import san.farm.adminuser.entity.UserTypeEntity;
import san.farm.util.HibernateUtil;

/**
 * @author santosh Khule
 * Date 13/11/2014
 * @version 1.2
 * Class Developed for Business Level Operation Fetching Objects from UserTypeController.java
 */
public class UserTypeService {
	/**
	 * Insert Operation:Fecthing Object from UserTypeController.java Inserting values into userType User table
	 * @param UserTypeEntity object
	 * @return boolean
	 */
	public boolean saveUserType(UserTypeEntity userTypeEntity){
		System.out.println("Inside Save User Type:====>>>>>>>>>>>>");
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.save(userTypeEntity);
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
	 * Update Operation:Fecthing Object from UserTypeController.java Updating values into userType User table
	 * @param UserTypeEntity object
	 * @return boolean
	 * 
	 **/
	public boolean updateUserType(UserTypeEntity userTypeEntity){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			session.update(userTypeEntity);
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
	 * Delete Operation:Fecthing Object from UserTypeController.java Deleting Data from userType User table
	 * @param UserTypeEntity object
	 * @return boolean 
	 **/
	public boolean deleteUserType(int userTypeId){
		Session session=HibernateUtil.opensession();
		Transaction transaction=session.beginTransaction(); 
		boolean flag=false;
		try{
			UserTypeEntity userTypeEntity=(UserTypeEntity)session.get(UserTypeEntity.class, userTypeId);
			session.delete(userTypeEntity);
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
	public List<UserTypeEntity> fetch(){
		List<UserTypeEntity> list=new ArrayList<UserTypeEntity>();
		Session session=HibernateUtil.opensession();
		//list=session.createQuery("from UserTypeEntity").list();
		try{	
			list=session.createCriteria(UserTypeEntity.class).list();
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return list;
	}
	/**
	 * Fetch Operation:Taking userType Id from UserTypeController.java and Fetching respective Data From DB 
	 * @return UserTypeEntity	 
	 * */
	public UserTypeEntity getUsertypeIdByUserTypeId(int userTypeId){
		UserTypeEntity userTypeEntity=new UserTypeEntity();
		Session session=HibernateUtil.opensession();	
		try{			
			userTypeEntity=(UserTypeEntity)session.createCriteria(UserTypeEntity.class).add(Restrictions.eq("userTypeId", userTypeId)).uniqueResult();
		//UserTypeEntity=(UserTypeEntity)session.get(UserTypeEntity.class,userTypeId);
		}catch(HibernateException exception){			
			exception.printStackTrace();
		}finally{
			session.close();
		}
		return userTypeEntity;
	}
}
