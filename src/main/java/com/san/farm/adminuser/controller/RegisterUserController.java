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
       
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing RegisterUser request");
		String uname=null,password=null,curPasswrd=null;
		int userTypeId=0;
		long loginUserId=0;
		boolean isValid=false,isCurPwdValid=false;
		try {
			uname=request.getParameter("emailId");
			password=request.getParameter("passwrd");
			userTypeId=Integer.parseInt(request.getParameter("selUserTypeId"));
			curPasswrd=request.getParameter("curPasswrd");

			UserTypeService userTypeService=new UserTypeService();
			UserTypeEntity userTypeEntity=userTypeService.getUsertypeIdByUserTypeId(userTypeId);

			LoginUserService loginUserService=new LoginUserService();
			LoginUser loginUser=new LoginUser();
			loginUser.setUname(uname);
			loginUser.setPassword(password);
			loginUser.setUserTypeEntity(userTypeEntity);

			//insert Operation
			if(null!=request.getParameter("add")){
				logger.info("Registering new user: {}", uname);
				loginUserService.saveLoginUser(loginUser);
				logger.info("User registered successfully");

				/*EmployeeInfoService authEmployeeInfoService=new EmployeeInfoService();
				EmployeeInfoAuthEntity authEmployeeInfo=new EmployeeInfoAuthEntity();
				authEmployeeInfo.setLoginUser(loginUser);
				authEmployeeInfoService.saveAuthEmployeeInfo(authEmployeeInfo);*/
			}
			//update operation
			if(null!=request.getParameter("edit")){
				LoginUser user=new LoginUser();
				loginUserId=Long.parseLong(request.getParameter("loginUserId"));
				user=loginUserService.getLoginUserInfoByLoginId(loginUserId);
				logger.debug("Validating current password for loginUserId: {}", loginUserId);
				if(user.getPassword().equals(curPasswrd)){
					logger.info("Password validation successful, updating user with id: {}", loginUserId);
					loginUser.setLoginUserId(loginUserId);
					loginUserService.updateLoginUser(loginUser);
					logger.info("User updated successfully");
				}else{
					logger.warn("Password validation failed for loginUserId: {}", loginUserId);
					isCurPwdValid=true;
				}
			}
			//Delete Operation
			if(null!=request.getParameter("delete")){
				loginUserId=Long.parseLong(request.getParameter("loginUserId"));
				logger.info("Deleting user with id: {}", loginUserId);
				loginUserService.deleteLoginUser(loginUserId);
				logger.info("User deleted successfully");
			}
		} catch (Exception exception) {
			logger.error("Error processing RegisterUser request", exception);
		} finally {
			logger.debug("Redirecting to registerUser.jsp");
			response.sendRedirect("view/user/registerUser.jsp?isValid="+isValid+"&isCurPwdValid="+isCurPwdValid);
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
