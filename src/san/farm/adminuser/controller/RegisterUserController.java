package san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.UserTypeService;
import san.farm.adminuser.entity.UserTypeEntity;
import san.farm.login.dao.LoginUserService;
import san.farm.login.entity.LoginUser;

/**
 * This servlet file Accept the request from registerUser.jsp perform db CRUD Operation on that data send
 * result back to the registerUser.jsp 
 * @author santosh khule
 * @version 1.2
 * @since 14/11/2014
 */

public class RegisterUserController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String uname=null,password=null,curPasswrd=null;
		int userTypeId=0;
		long loginUserId=0;
		boolean isValid=false,isCurPwdValid=false;
		uname=request.getParameter("emailId");
		password=request.getParameter("passwrd");
		userTypeId=Integer.parseInt(request.getParameter("selUserTypeId"));
		curPasswrd=request.getParameter("curPasswrd");
		
		UserTypeService userTypeService=new UserTypeService();
		UserTypeEntity userTypeEntity=userTypeService.getUsertypeIdByUserTypeId(userTypeId);
		
		LoginUserService loginUserService=new LoginUserService();
		LoginUser loginUser=new LoginUser();
		loginUser.setUname(uname);
		loginUser.setPassword(password);
		loginUser.setUserTypeEntity(userTypeEntity);
		
		//insert Operation
		if(null!=request.getParameter("add")){
			loginUserService.saveLoginUser(loginUser);
			
			/*EmployeeInfoService authEmployeeInfoService=new EmployeeInfoService();
			EmployeeInfoAuthEntity authEmployeeInfo=new EmployeeInfoAuthEntity();
			authEmployeeInfo.setLoginUser(loginUser);
			authEmployeeInfoService.saveAuthEmployeeInfo(authEmployeeInfo);*/
		}
		//update operation		
		if(null!=request.getParameter("edit")){
			LoginUser user=new LoginUser();
			loginUserId=Long.parseLong(request.getParameter("loginUserId"));
			user=loginUserService.getLoginUserInfoByLoginId(loginUserId);
			System.out.println("user.getPassword().equals(curPasswrd):==>"+user.getPassword()+" "+curPasswrd);
			if(user.getPassword().equals(curPasswrd)){
				System.out.println("Success");
				loginUser.setLoginUserId(loginUserId);
				loginUserService.updateLoginUser(loginUser);	
			}else{
				System.out.println("failed");
				isCurPwdValid=true;
			}					
		}
		//Delete Operation
		if(null!=request.getParameter("delete")){
			loginUserId=Long.parseLong(request.getParameter("loginUserId"));	
			loginUserService.deleteLoginUser(loginUserId);			
		}
		response.sendRedirect("view/user/registerUser.jsp?isValid="+isValid+"&isCurPwdValid="+isCurPwdValid);
		
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
