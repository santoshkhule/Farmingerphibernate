package san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.ConfigCropService;
import san.farm.adminuser.entity.ConfigCropEntity;

/**
 * This servlet file Accept the request from configCrop.jsp,perform db CRUD Operation on that data using ConfigCropService.java,
 * redirect back to the configCrop.jsp 
 * @author santosh khule
 * @version 1.2
 * @since 16/11/2014
 */
public class ConfigCropController extends HttpServlet {
	private static final long serialVersionUID = 1L;       
	
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
				configCropService.saveCrop(configCropEntity);
			}
			
			//update Operation
			if(request.getParameter("edit")!=null){
				cropId=Integer.parseInt(request.getParameter("cropId"));
				configCropEntity.setCropId(cropId);
				configCropService.updateCrop(configCropEntity);
			}
		}
		
		//delete Operation
		if(request.getParameter("delete")!=null){
			cropId=Integer.parseInt(request.getParameter("cropId"));
			configCropService.deleteCrop(cropId);
		}
		response.sendRedirect("view/user/configCrop.jsp");		
		
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
