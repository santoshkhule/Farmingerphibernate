package san.farm.login.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;

import san.farm.login.entity.LoginUser;
import san.farm.util.HibernateUtil;

/**
 * Class Developed for Business Level Operation Fetching values from
 * LoginUserController.java
 * 
 * @author santosh Khule 
 * @version 1.2
 * @since 13/11/2014
 * 
 */

public class LoginUserService {

	/**
	 * Insert Operation:Fecthing Object from loginUserController.java Inserting
	 * values into login User table
	 * 
	 * @param loginUser
	 * @return boolean
	 * */
	public boolean saveLoginUser(LoginUser loginUser) {
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.save(loginUser);
			transaction.commit();
			flag = true;
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			exception.printStackTrace();
		} finally {
			session.clear();
			session.close();
		}

		return flag;
	}

	/**
	 * Updated Operation:Fecthing Object from loginUserController.java Updating
	 * values into login User table
	 * 
	 * @param loginUser
	 * @return boolean
	 * */
	public boolean updateLoginUser(LoginUser loginUser) {
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.update(loginUser);
			transaction.commit();
			flag = true;
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			exception.printStackTrace();
		} finally {
			session.clear();
			session.close();
		}

		return flag;
	}

	/**
	 * Delete Operation:Fecthing Object from loginUserController.java deleting
	 * values from login User table
	 * 
	 * @param loginUserId
	 * @return boolean
	 * */
	public boolean deleteLoginUser(long loginUserId) {
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			LoginUser loginUser=(LoginUser)session.get(LoginUser.class, loginUserId);
			session.delete(loginUser);
			transaction.commit();
			flag = true;
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			exception.printStackTrace();
		} finally {
			session.clear();
			session.close();
		}

		return flag;
	}

	/**
	 * Fetch Operation:Fecthing Data From DB
	 * 
	 * @return list
	 * */
	public List<LoginUser> fetch() {
		List<LoginUser> list = new ArrayList<LoginUser>();
		Session session = HibernateUtil.opensession();
		list = session.createCriteria(LoginUser.class).list();
		return list;
	}
	
	/**
	 * Fetch Operation:Fecthing Data From DB
	 * 
	 * @return list
	 * */
	public LoginUser getLoginUserInfoByLoginId(long loginUserId) {
		LoginUser loginUser=new LoginUser();
		Session session = HibernateUtil.opensession();
		loginUser =(LoginUser) session.createCriteria(LoginUser.class).add(Restrictions.eq("loginUserId", loginUserId)).uniqueResult();
		return loginUser;
	}
}
