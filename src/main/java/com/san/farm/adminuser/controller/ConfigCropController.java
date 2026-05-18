package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.ConfigCropService;
import com.san.farm.adminuser.entity.ConfigCropEntity;

/**
 * This servlet file Accept the request from crop.jsp,perform db CRUD Operation on that data using ConfigCropService.java,
 * redirect back to the masterData.jsp
 * @author santosh khule
 * @version 1.2
 * @since 16/11/2014
 */
public class ConfigCropController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(ConfigCropController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing ConfigCrop request");
		try {
			//variable Declaration
			String cropName=null;
			int cropId;
			ConfigCropService configCropService=new ConfigCropService();

			if(request.getParameter("add")!=null || request.getParameter("edit")!=null){

				//Declare ConfigCropEntity class object and setValues to setter method
				ConfigCropEntity configCropEntity=new ConfigCropEntity();
				cropName=request.getParameter("cropName");

				configCropEntity.setCropName(cropName);

				//insert Operation
				if(request.getParameter("add")!=null){
					logger.info("Adding new crop: {}", cropName);
					configCropService.saveCrop(configCropEntity);
					logger.info("Crop added successfully");
				}

				//update Operation
				if(request.getParameter("edit")!=null){
					cropId=Integer.parseInt(request.getParameter("cropId"));
					configCropEntity.setCropId(cropId);
					logger.info("Updating crop with id: {}", cropId);
					configCropService.updateCrop(configCropEntity);
					logger.info("Crop updated successfully");
				}
			}

			//delete Operation
			if(request.getParameter("delete")!=null){
				cropId=Integer.parseInt(request.getParameter("cropId"));
				logger.info("Deleting crop with id: {}", cropId);
				configCropService.deleteCrop(cropId);
				logger.info("Crop deleted successfully");
			}

			//bulk delete Operation
			if(request.getParameter("deleteSelected")!=null){
				String[] ids=request.getParameterValues("deleteIds");
				if(ids!=null){
					logger.info("Bulk deleting {} crop(s)", ids.length);
					for(String id : ids){
						configCropService.deleteCrop(Integer.parseInt(id));
						logger.info("Deleted crop id: {}", id);
					}
				}
			}
		} catch (Exception exception) {
			logger.error("Error processing ConfigCrop request", exception);
		} finally {
			logger.debug("Redirecting to masterData.jsp?tab=crop");
			response.sendRedirect("view/user/masterData.jsp?tab=crop");
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
