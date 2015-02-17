package san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.AssignCropToSiteRefService;
import san.farm.adminuser.dao.AssignCropToSiteService;
import san.farm.adminuser.dao.ConfigCropService;
import san.farm.adminuser.dao.ConfigSiteInformationService;
import san.farm.adminuser.entity.AssignCropToSiteEntity;
import san.farm.adminuser.entity.AssignCropToSiteRefEntity;
import san.farm.adminuser.entity.ConfigCropEntity;
import san.farm.adminuser.entity.ConfigSiteInformationEntity;
import san.farm.util.FarmUtility;

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

	protected void doProcess(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
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
			//cropToSiteRefService.deleteAssignCropToSiteRef(cropToSiteId);
			
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
					//cropToSiteRefService.saveAssignCropToSiteRef(cropToSiteRefEntity);					
				}
			}
		
			// SetValues to Setter method of assignCropToSite object
			
			cropToSiteEntity.setSiteInformationEntity(siteInformationEntity);
			cropToSiteEntity.setCropAssignDate(cropAssignDate);
			cropToSiteEntity.setCropToSiteRefEntity(cropToSiteRefEntities);
			// insert operation
			if (null != request.getParameter("add")) {
				cropToSiteService.saveAssignCropToSite(cropToSiteEntity);
			}
			// Edit operation
			if (null != request.getParameter("edit")) {
				/*AssignCropToSiteEntity cropToSiteEntity2=cropToSiteService.getAssignCropToSiteInfoByCropToSiteId(cropToSiteId);
				cropToSiteEntity2.setCropToSiteRefEntity(null);*/
				cropToSiteRefService.deleteAssignCropToSiteRef(cropToSiteId);
				cropToSiteEntity.setAssignCroptoSiteId(cropToSiteId);
			//	cropToSiteRefService.deleteAssignCropToSiteRef(cropToSiteId);
				cropToSiteService.updateAssignCropToSite(cropToSiteEntity);
			}
					
			// Delete Operation
			if (null != request.getParameter("delete")) {
				cropToSiteService.deleteAssignCropToSite(cropToSiteId);
			}
		} catch (Exception exception) {
			exception.printStackTrace();
		} finally {
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
