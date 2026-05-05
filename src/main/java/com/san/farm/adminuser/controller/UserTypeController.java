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

/**
 * Servlet implementation class UserTypeController
 * 
 */
public class UserTypeController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(UserTypeController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing UserType request");
		try {
			String userType=null;
			int userTypeId;
			userType=request.getParameter("userType");
			logger.debug("userType: {}", userType);
			UserTypeService userTypeService=new UserTypeService();

			UserTypeEntity userTypeEntity=new UserTypeEntity();

			userTypeEntity.setUserType(userType);

			//insert Operation
			if(request.getParameter("add")!=null){
				logger.info("Adding new user type: {}", userType);
				userTypeService.saveUserType(userTypeEntity);
				logger.info("User type added successfully");
			}

			//update Operation
			if(request.getParameter("edit")!=null){
				userTypeId=Integer.parseInt(request.getParameter("userTypeId"));
				userTypeEntity.setUserTypeId(userTypeId);
				logger.info("Updating user type with id: {}", userTypeId);
				userTypeService.updateUserType(userTypeEntity);
				logger.info("User type updated successfully");
			}

			//delete Operation
			if(request.getParameter("delete")!=null){
				userTypeId=Integer.parseInt(request.getParameter("userTypeId"));
				logger.info("Deleting user type with id: {}", userTypeId);
				userTypeService.deleteUserType(userTypeId);
				logger.info("User type deleted successfully");
			}
		} catch (Exception exception) {
			logger.error("Error processing UserType request", exception);
		} finally {
			logger.debug("Redirecting to userType.jsp");
			response.sendRedirect("view/user/userType.jsp");
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
