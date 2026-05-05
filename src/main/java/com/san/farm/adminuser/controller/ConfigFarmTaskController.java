package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.ConfigFarmTaskService;
import com.san.farm.adminuser.entity.ConfigFarmTaskEntity;
import com.san.farm.util.Symbols;

/**
 * This servlet file Accept the request from configFarmTask.jsp,perform db CRUD Operation on that data using ConfigFarmTaskService.java,
 * redirect back to the configFarmTask.jsp 
 * @author santosh khule
 * @version 1.2
 * @since 16/11/2014
 */
public class ConfigFarmTaskController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(ConfigFarmTaskController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing ConfigFarmTask request");
		try {
			//variable Declaration
			String taskName=Symbols.EMPTY.getSymbol();;
			int taskId;
			ConfigFarmTaskService configCropService=new ConfigFarmTaskService();

			if(request.getParameter("add")!=null || request.getParameter("edit")!=null){

				//Declare ConfigFarmTaskEntity class object and setValues to setter method
				ConfigFarmTaskEntity configFarmTaskEntity=new ConfigFarmTaskEntity();
				taskName=request.getParameter("taskName");
				configFarmTaskEntity.setTaskName(taskName);

				//insert Operation
				if(request.getParameter("add")!=null){
					logger.info("Adding new farm task: {}", taskName);
					configCropService.saveFarmTask(configFarmTaskEntity);
					logger.info("Farm task added successfully");
				}

				//update Operation
				if(request.getParameter("edit")!=null){
					taskId=Integer.parseInt(request.getParameter("taskId"));
					configFarmTaskEntity.setTaskId(taskId);
					logger.info("Updating farm task with id: {}", taskId);
					configCropService.updateFarmTask(configFarmTaskEntity);
					logger.info("Farm task updated successfully");
				}
			}

			//delete Operation
			if(request.getParameter("delete")!=null){
				taskId=Integer.parseInt(request.getParameter("taskId"));
				logger.info("Deleting farm task with id: {}", taskId);
				configCropService.deleteFarmTask(taskId);
				logger.info("Farm task deleted successfully");
			}
		} catch (Exception exception) {
			logger.error("Error processing ConfigFarmTask request", exception);
		} finally {
			logger.debug("Redirecting to configFarmTask.jsp");
			response.sendRedirect("view/user/configFarmTask.jsp");
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
