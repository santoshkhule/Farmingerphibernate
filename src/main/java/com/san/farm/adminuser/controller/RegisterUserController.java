package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.UserTypeService;
import com.san.farm.adminuser.entity.UserTypeEntity;
import com.san.farm.login.dao.LoginUserService;
import com.san.farm.login.entity.LoginUser;

/**
 * This servlet file Accept the request from registerUser.jsp perform db CRUD Operation on that data send
 * result back to the registerUser.jsp 
 * @author santosh khule
 * @version 1.2
 * @since 14/11/2014
 */

public class RegisterUserController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(RegisterUserController.class);
	private static final String ADMIN_TYPE = "Admin";

	private boolean isAdmin(LoginUser user) {
		return user != null && user.getUserTypeEntity() != null
				&& ADMIN_TYPE.equalsIgnoreCase(user.getUserTypeEntity().getUserType());
	}
       
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing RegisterUser request");
		String redirectUrl = "view/user/registerUser.jsp";
		try {
			LoginUserService loginUserService = new LoginUserService();

			// Delete handled separately — only needs loginUserId
			if (request.getParameter("delete") != null) {
				long loginUserId = Long.parseLong(request.getParameter("loginUserId"));
				LoginUser toDelete = loginUserService.getLoginUserInfoByLoginId(loginUserId);
				if (isAdmin(toDelete)) {
					logger.warn("Attempt to delete admin user with id: {} blocked", loginUserId);
					redirectUrl = "view/user/registerUser.jsp?err=admin_protected";
					return;
				}
				logger.info("Deleting user with id: {}", loginUserId);
				loginUserService.deleteLoginUser(loginUserId);
				logger.info("User deleted successfully");
				redirectUrl = "view/user/registerUser.jsp?msg=deleted";
				return;
			}

			String uname     = request.getParameter("username");
			String password  = request.getParameter("passwrd");
			String curPasswrd = request.getParameter("curPasswrd");

			if (request.getParameter("add") != null) {
				int userTypeId = Integer.parseInt(request.getParameter("selUserTypeId"));
				UserTypeEntity userTypeEntity = new UserTypeService().getUsertypeIdByUserTypeId(userTypeId);
				LoginUser loginUser = new LoginUser();
				loginUser.setUname(uname);
				loginUser.setPassword(password);
				loginUser.setUserTypeEntity(userTypeEntity);
				if (loginUserService.existsByUname(uname)) {
					logger.warn("Duplicate username rejected: {}", uname);
					redirectUrl = "view/user/registerUser.jsp?err=username_exists";
				} else {
					logger.info("Registering new user: {}", uname);
					loginUserService.saveLoginUser(loginUser);
					logger.info("User registered successfully");
					redirectUrl = "view/user/registerUser.jsp?msg=registered";
				}
			}

			if (request.getParameter("edit") != null) {
				long loginUserId = Long.parseLong(request.getParameter("loginUserId"));
				LoginUser existing = loginUserService.getLoginUserInfoByLoginId(loginUserId);
				logger.debug("Validating current password for loginUserId: {}", loginUserId);
				if (existing == null || !existing.getPassword().equals(curPasswrd)) {
					logger.warn("Password validation failed for loginUserId: {}", loginUserId);
					redirectUrl = "view/user/registerUser.jsp?err=wrong_pwd";
				} else if (isAdmin(existing)) {
					// Admin user: only password may change; username and user type are locked
					existing.setPassword(password);
					loginUserService.updateLoginUser(existing);
					logger.info("Admin user {} password updated successfully", loginUserId);
					redirectUrl = "view/user/registerUser.jsp?msg=updated";
				} else {
					// Non-admin: parse selUserTypeId and check for duplicate username
					int userTypeId = Integer.parseInt(request.getParameter("selUserTypeId"));
					UserTypeEntity userTypeEntity = new UserTypeService().getUsertypeIdByUserTypeId(userTypeId);
					LoginUser loginUser = new LoginUser();
					loginUser.setUname(uname);
					loginUser.setPassword(password);
					loginUser.setUserTypeEntity(userTypeEntity);
					if (loginUserService.existsByUnameExcludingId(uname, loginUserId)) {
						logger.warn("Duplicate username on edit rejected: {}", uname);
						redirectUrl = "view/user/registerUser.jsp?err=username_exists";
					} else {
						loginUser.setLoginUserId(loginUserId);
						loginUserService.updateLoginUser(loginUser);
						logger.info("User {} updated successfully", loginUserId);
						redirectUrl = "view/user/registerUser.jsp?msg=updated";
					}
				}
			}
		} catch (Exception ex) {
			logger.error("Error processing RegisterUser request", ex);
		} finally {
			logger.debug("Redirecting to: {}", redirectUrl);
			response.sendRedirect(redirectUrl);
		}
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

}
