package san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.ConfigFarmTaskService;
import san.farm.adminuser.entity.ConfigFarmTaskEntity;
import san.farm.util.Symbols;

/**
 * This servlet file Accept the request from configFarmTask.jsp,perform db CRUD Operation on that data using ConfigFarmTaskService.java,
 * redirect back to the configFarmTask.jsp 
 * @author santosh khule
 * @version 1.2
 * @since 16/11/2014
 */
public class ConfigFarmTaskController extends HttpServlet {
	private static final long serialVersionUID = 1L;       
	
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
				configCropService.saveFarmTask(configFarmTaskEntity);
			}
			
			//update Operation
			if(request.getParameter("edit")!=null){
				taskId=Integer.parseInt(request.getParameter("taskId"));
				configFarmTaskEntity.setTaskId(taskId);
				configCropService.updateFarmTask(configFarmTaskEntity);
			}
		}
		
		//delete Operation
		if(request.getParameter("delete")!=null){
			taskId=Integer.parseInt(request.getParameter("taskId"));
			configCropService.deleteFarmTask(taskId);
		}
		response.sendRedirect("view/user/configFarmTask.jsp");		
		
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
