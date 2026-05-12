package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.ConfigSiteInformationService;
import com.san.farm.adminuser.entity.ConfigSiteInformationEntity;
import com.san.farm.util.Symbols;

/**
 * This servlet file Accept the request from configSiteInformation.jsp,perform db CRUD Operation on that data using ConfigSiteInformationService.java,
 * redirect back to the configSiteInformation.jsp 
 * @author santosh khule
 * @version 1.2
 * @since 15/11/2014
 */
public class ConfigSiteInformationController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(ConfigSiteInformationController.class);

	/**
	 * @see HttpServlet#service(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing ConfigSiteInformation request");
		try {
			//Variable Declaration
			int siteInfoId;
			String siteName=Symbols.EMPTY.getSymbol(),siteLocation=Symbols.EMPTY.getSymbol();;
			double siteArea=0.0;

			//Method Declaration
			ConfigSiteInformationService configSiteInformationService=new ConfigSiteInformationService();
			ConfigSiteInformationEntity configSiteInformationEntity=new ConfigSiteInformationEntity();

			if(request.getParameter("add")!=null || request.getParameter("edit")!=null){

				//Accept Request
				siteName=request.getParameter("siteName");
				siteLocation=request.getParameter("siteLocation");
				siteArea=Double.parseDouble(request.getParameter("siteArea"));

				//setValues
				configSiteInformationEntity.setSiteArea(siteArea);
				configSiteInformationEntity.setSiteLocation(siteLocation);
				configSiteInformationEntity.setSiteName(siteName);

				//insert operation
				if(request.getParameter("add")!=null){
					logger.info("Adding new site: name={}, location={}, area={}", siteName, siteLocation, siteArea);
					configSiteInformationService.saveSiteInformation(configSiteInformationEntity);
					logger.info("Site information added successfully");
				}
				//edit operation
				if(request.getParameter("edit")!=null){
					siteInfoId=Integer.parseInt(request.getParameter("siteInfoId"));
					configSiteInformationEntity.setSiteInfoId(siteInfoId);
					logger.info("Updating site information with id: {}", siteInfoId);
					configSiteInformationService.updateSiteInformation(configSiteInformationEntity);
					logger.info("Site information updated successfully");
				}
			}

			//delete operation
			if(request.getParameter("delete")!=null){
				siteInfoId=Integer.parseInt(request.getParameter("siteInfoId"));
				logger.info("Deleting site information with id: {}", siteInfoId);
				configSiteInformationService.deleteSiteInformation(siteInfoId);
				logger.info("Site information deleted successfully");
			}

			//bulk delete operation
			if(request.getParameter("deleteSelected")!=null){
				String[] ids=request.getParameterValues("deleteIds");
				if(ids!=null){
					logger.info("Bulk deleting {} site record(s)", ids.length);
					for(String id : ids){
						configSiteInformationService.deleteSiteInformation(Integer.parseInt(id));
						logger.info("Deleted site id: {}", id);
					}
				}
			}
		} catch (Exception exception) {
			logger.error("Error processing ConfigSiteInformation request", exception);
		} finally {
			logger.debug("Redirecting to configSiteInformation.jsp");
			response.sendRedirect("view/user/configuration.jsp?tab=site");
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
