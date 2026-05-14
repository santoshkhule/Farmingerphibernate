package com.san.farm.login.dao;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.login.entity.LoginUser;
import com.san.farm.util.HibernateUtil;

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
	private static final Logger logger = LoggerFactory.getLogger(LoginUserService.class);

	/**
	 * Insert Operation:Fecthing Object from loginUserController.java Inserting
	 * values into login User table
	 *
	 * @param loginUser
	 * @return boolean
	 * */
	public boolean saveLoginUser(LoginUser loginUser) {
		logger.debug("Saving LoginUser entity");
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.save(loginUser);
			transaction.commit();
			flag = true;
			logger.info("LoginUser saved successfully");
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error saving LoginUser", exception);
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
		logger.debug("Updating LoginUser entity");
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			session.update(loginUser);
			transaction.commit();
			flag = true;
			logger.info("LoginUser updated successfully");
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error updating LoginUser", exception);
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
		logger.debug("Deleting LoginUser with loginUserId: {}", loginUserId);
		boolean flag = false;
		Session session = HibernateUtil.opensession();
		Transaction transaction = session.beginTransaction();
		try {
			LoginUser loginUser=(LoginUser)session.get(LoginUser.class, loginUserId);
			session.delete(loginUser);
			transaction.commit();
			flag = true;
			logger.info("LoginUser deleted successfully for loginUserId: {}", loginUserId);
		} catch (HibernateException exception) {
			if (transaction != null) {
				transaction.rollback();
			}
			logger.error("Error deleting LoginUser for loginUserId: {}", loginUserId, exception);
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
		logger.debug("Fetching all LoginUser records");
		List<LoginUser> list = new ArrayList<LoginUser>();
		Session session = HibernateUtil.opensession();
		try {
			list = session.createCriteria(LoginUser.class).list();
			logger.info("Retrieved {} LoginUser records", list.size());
		} catch (HibernateException exception) {
			logger.error("Error fetching LoginUser list", exception);
		} finally {
			session.clear();
			session.close();
		}
		return list;
	}

	/**
	 * Fetch Operation:Fecthing Data From DB
	 *
	 * @return list
	 * */
	public LoginUser getLoginUserInfoByLoginId(long loginUserId) {
		logger.debug("Fetching LoginUser by loginUserId: {}", loginUserId);
		LoginUser loginUser=new LoginUser();
		Session session = HibernateUtil.opensession();
		try {
			loginUser = (LoginUser) session.createCriteria(LoginUser.class).add(Restrictions.eq("loginUserId", loginUserId)).uniqueResult();
			logger.info("Retrieved LoginUser for loginUserId: {}", loginUserId);
		} catch (HibernateException exception) {
			logger.error("Error fetching LoginUser for loginUserId: {}", loginUserId, exception);
		} finally {
			session.clear();
			session.close();
		}
		return loginUser;
	}

	public boolean existsByUname(String uname) {
		logger.debug("Checking existence of uname: {}", uname);
		Session session = HibernateUtil.opensession();
		try {
			Long count = (Long) session.createQuery(
				"SELECT COUNT(u) FROM LoginUser u WHERE u.uname = :uname")
				.setParameter("uname", uname)
				.uniqueResult();
			return count != null && count > 0;
		} catch (HibernateException ex) {
			logger.error("Error checking uname existence: {}", uname, ex);
			return false;
		} finally {
			session.close();
		}
	}

	public boolean existsByUnameExcludingId(String uname, long excludeLoginUserId) {
		logger.debug("Checking existence of uname: {} excluding loginUserId: {}", uname, excludeLoginUserId);
		Session session = HibernateUtil.opensession();
		try {
			Long count = (Long) session.createQuery(
				"SELECT COUNT(u) FROM LoginUser u WHERE u.uname = :uname AND u.loginUserId != :id")
				.setParameter("uname", uname)
				.setParameter("id", excludeLoginUserId)
				.uniqueResult();
			return count != null && count > 0;
		} catch (HibernateException ex) {
			logger.error("Error checking uname existence excluding id {}: {}", excludeLoginUserId, uname, ex);
			return false;
		} finally {
			session.close();
		}
	}

	public LoginUser authenticate(String uname, String password) {
		logger.debug("Authenticating user: {}", uname);
		Session session = HibernateUtil.opensession();
		try {
			LoginUser user = (LoginUser) session.createCriteria(LoginUser.class)
					.add(Restrictions.eq("uname", uname))
					.add(Restrictions.eq("password", password))
					.uniqueResult();
			if (user != null) {
				logger.info("Authentication successful for user: {}", uname);
			} else {
				logger.warn("Authentication failed for user: {}", uname);
			}
			return user;
		} catch (HibernateException exception) {
			logger.error("Error during authentication for user: {}", uname, exception);
			return null;
		} finally {
			session.clear();
			session.close();
		}
	}
}
