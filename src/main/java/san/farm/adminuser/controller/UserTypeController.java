package san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.UserTypeService;
import san.farm.adminuser.entity.UserTypeEntity;

/**
 * Servlet implementation class UserTypeController
 * 
 */
public class UserTypeController extends HttpServlet {
	private static final long serialVersionUID = 1L;       
	
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String userType=null;
		int userTypeId;
		userType=request.getParameter("userType");		
		//System.out.println("userType::==>"+userType);
		UserTypeService userTypeService=new UserTypeService();
		
		UserTypeEntity userTypeEntity=new UserTypeEntity();
		
		userTypeEntity.setUserType(userType);
		
		//insert Operation
		if(request.getParameter("add")!=null){
			userTypeService.saveUserType(userTypeEntity);
		}
		
		//update Operation
		if(request.getParameter("edit")!=null){
			userTypeId=Integer.parseInt(request.getParameter("userTypeId"));
			userTypeEntity.setUserTypeId(userTypeId);
			userTypeService.updateUserType(userTypeEntity);
		}
		
		//delete Operation
		if(request.getParameter("delete")!=null){
			userTypeId=Integer.parseInt(request.getParameter("userTypeId"));
			userTypeService.deleteUserType(userTypeId);
		}
		response.sendRedirect("view/user/userType.jsp");
		
		
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
