package san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.ConfigSiteInformationService;
import san.farm.adminuser.entity.ConfigSiteInformationEntity;
import san.farm.util.Symbols;

/**
 * This servlet file Accept the request from configSiteInformation.jsp,perform db CRUD Operation on that data using ConfigSiteInformationService.java,
 * redirect back to the configSiteInformation.jsp 
 * @author santosh khule
 * @version 1.2
 * @since 15/11/2014
 */
public class ConfigSiteInformationController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	/**
	 * @see HttpServlet#service(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
				configSiteInformationService.saveSiteInformation(configSiteInformationEntity);
			}
			//edit operation
			if(request.getParameter("edit")!=null){
				siteInfoId=Integer.parseInt(request.getParameter("siteInfoId"));
				configSiteInformationEntity.setSiteInfoId(siteInfoId);
				configSiteInformationService.updateSiteInformation(configSiteInformationEntity);
			}
		}
		
		//delete operation
		if(request.getParameter("delete")!=null){			
			siteInfoId=Integer.parseInt(request.getParameter("siteInfoId"));			
			configSiteInformationService.deleteSiteInformation(siteInfoId);
		}
		response.sendRedirect("view/user/configSiteInformation.jsp");
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
