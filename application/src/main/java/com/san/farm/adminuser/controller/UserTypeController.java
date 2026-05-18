package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.net.URLEncoder;

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
		String redirectUrl = "view/user/registerUser.jsp?tab=userTypes";
		try {
			String userType = request.getParameter("userType");
			logger.debug("userType: {}", userType);
			UserTypeService userTypeService = new UserTypeService();
			UserTypeEntity userTypeEntity = new UserTypeEntity();
			userTypeEntity.setUserType(userType);

			// insert Operation
			if (request.getParameter("add") != null) {
				if (userTypeService.existsByName(userType)) {
					logger.warn("Duplicate user type rejected: {}", userType);
					redirectUrl = "view/user/registerUser.jsp?tab=userTypes&error=duplicate"
						+ "&errVal=" + URLEncoder.encode(userType.trim(), "UTF-8");
				} else {
					logger.info("Adding new user type: {}", userType);
					userTypeService.saveUserType(userTypeEntity);
					logger.info("User type added successfully");
				}
			}

			// update Operation
			if (request.getParameter("edit") != null) {
				int userTypeId = Integer.parseInt(request.getParameter("userTypeId"));
				userTypeEntity.setUserTypeId(userTypeId);
				logger.info("Updating user type with id: {}", userTypeId);
				userTypeService.updateUserType(userTypeEntity);
				logger.info("User type updated successfully");
			}

			// delete single Operation
			if (request.getParameter("delete") != null) {
				int userTypeId = Integer.parseInt(request.getParameter("userTypeId"));
				logger.info("Deleting user type with id: {}", userTypeId);
				userTypeService.deleteUserType(userTypeId);
				logger.info("User type deleted successfully");
			}

			// delete selected (bulk) Operation
			if (request.getParameter("deleteSelected") != null) {
				String[] ids = request.getParameterValues("deleteIds");
				if (ids != null) {
					logger.info("Bulk deleting {} user type(s)", ids.length);
					for (String id : ids) {
						userTypeService.deleteUserType(Integer.parseInt(id));
					}
				}
			}
		} catch (Exception exception) {
			logger.error("Error processing UserType request", exception);
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
