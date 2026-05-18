package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignCropToSiteRefService;
import com.san.farm.adminuser.dao.AssignCropToSiteService;
import com.san.farm.adminuser.dao.ConfigCropService;
import com.san.farm.adminuser.dao.ConfigSiteInformationService;
import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.adminuser.entity.AssignCropToSiteRefEntity;
import com.san.farm.adminuser.entity.ConfigCropEntity;
import com.san.farm.adminuser.entity.ConfigSiteInformationEntity;
import com.san.farm.util.FarmUtility;

/**
 * This servlet file Accept the request from assignCropToSite.jsp,perform db
 * CRUD Operation on that data using AssignCropToSiteService.java, redirect back
 * to the assignCropToSite.jsp
 * 
 * @author santosh khule
 * @version 1.2
 * @since 21/11/2014
 */
public class AssignCropToSiteController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(AssignCropToSiteController.class);

	protected void doProcess(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing AssignCropToSite request");
		try {
			// variable Declaration
			int cropToSiteId = 0;
			int cropId = 0, siteInfoId = 0;
			Date cropAssignDate =null;
			String cropIdArr[]=null;
			if (null != request.getParameter("cropToSiteId") && !request.getParameter("cropToSiteId").equalsIgnoreCase("")) {
				cropToSiteId = Integer.parseInt(request.getParameter("cropToSiteId").trim());
			}
			if (null != request.getParameterValues("cropId")) {
				cropIdArr = request.getParameterValues("cropId");
			}
			if (null != request.getParameter("siteInfoId")) {
				siteInfoId = Integer.parseInt(request.getParameter("siteInfoId").trim());
			}
			if (null != request.getParameter("cropAssignDate")) {
				cropAssignDate = Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(request.getParameter("cropAssignDate")));
			}
			
			// Object Creation
			AssignCropToSiteService cropToSiteService = new AssignCropToSiteService();
			AssignCropToSiteRefService cropToSiteRefService=new AssignCropToSiteRefService();
			AssignCropToSiteEntity cropToSiteEntity = new AssignCropToSiteEntity();

			ConfigSiteInformationService informationService = new ConfigSiteInformationService();
			ConfigSiteInformationEntity siteInformationEntity = informationService.getSiteInfoBySiteInfoId(siteInfoId);			
			List<AssignCropToSiteRefEntity> cropToSiteRefEntities=new ArrayList<AssignCropToSiteRefEntity>();
			
			if(cropIdArr!=null){				
				ConfigCropService cropService = new ConfigCropService();								
				for(int i=0;i<cropIdArr.length;i++){							
					
					ConfigCropEntity cropEntity = cropService.getCropIdByCropId(Integer.parseInt(cropIdArr[i]));							
					AssignCropToSiteRefEntity cropToSiteRefEntity = new AssignCropToSiteRefEntity();
					
					cropToSiteRefEntity.setCropToSiteEntity(cropToSiteEntity);					
					cropToSiteRefEntity.setConfigCropEntity(cropEntity);
					cropToSiteRefEntities.add(cropToSiteRefEntity);
				}
			}
		
			// SetValues to Setter method of assignCropToSite object
			
			cropToSiteEntity.setSiteInformationEntity(siteInformationEntity);
			cropToSiteEntity.setCropAssignDate(cropAssignDate);
			cropToSiteEntity.setCropToSiteRefEntity(cropToSiteRefEntities);

			// insert operation
			if (null != request.getParameter("add")) {
				logger.info("Adding new crop assignment for siteId: {}, date: {}", siteInfoId, cropAssignDate);
				cropToSiteService.saveAssignCropToSite(cropToSiteEntity);
				logger.info("Crop assignment added successfully");
			}

			// Edit operation
			if (null != request.getParameter("edit")) {
				logger.info("Updating crop assignment with id: {}", cropToSiteId);
				cropToSiteRefService.deleteAssignCropToSiteRef(cropToSiteId);
				cropToSiteEntity.setAssignCroptoSiteId(cropToSiteId);
				cropToSiteService.updateAssignCropToSite(cropToSiteEntity);
				logger.info("Crop assignment updated successfully");
			}
					
			// Toggle Ready to Dispatch
			if (null != request.getParameter("toggleDispatch")) {
				logger.info("Toggling readyToDispatch for cropToSiteId: {}", cropToSiteId);
				cropToSiteService.toggleReadyToDispatch(cropToSiteId);
			}

			// Bulk delete operation
			if (null != request.getParameter("deleteSelected")) {
				String[] deleteIds = request.getParameterValues("deleteIds");
				if (deleteIds != null) {
					for (String idStr : deleteIds) {
						int delId = Integer.parseInt(idStr.trim());
						logger.info("Deleting crop assignment with id: {}", delId);
						cropToSiteRefService.deleteAssignCropToSiteRef(delId);
						cropToSiteService.deleteAssignCropToSite(delId);
					}
					logger.info("Bulk delete completed for {} records", deleteIds.length);
				}
			}
		} catch (Exception exception) {
			logger.error("Error processing AssignCropToSite request", exception);
		} finally {
			logger.debug("Redirecting to assignCropToSite.jsp");
			response.sendRedirect("view/user/assignCropToSite.jsp");
		}
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

}
