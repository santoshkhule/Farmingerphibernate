package san.farm.adminuser.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.AssignCropToSiteService;
import san.farm.adminuser.dao.AssignResourceEmployeeToFarmService;
import san.farm.adminuser.entity.AssignCropToSiteEntity;
import san.farm.util.FarmUtility;
import san.farm.util.Symbols;

@WebServlet("/AssignResourcesController")
public class AssignResourcesController extends HttpServlet {
	private static final long serialVersionUID = 1L;   
	
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out=response.getWriter();
			try{
			//Variable Initialization			
			int empInfoCnt=0,employeeInfoId=0,farmTaskId=0,siteInfoId=0,cropId=0,assignResourceId=0;
			double amount=0,advPayment=0;
			Date assignWorkDate=null,assignFarmDate=null;
			String typeOfWork=Symbols.EMPTY.getSymbol();
			String workStatus=Symbols.EMPTY.getSymbol();
			String comment=Symbols.EMPTY.getSymbol();			
			String[] arrFarmTaskId=null;			
			
			//System.out.println("<<====>>"+assignResourceId);
			if(request.getParameter("action")!=null){
				assignResourceId=Integer.parseInt(request.getParameter("assignResourceId"));
				AssignResourceEmployeeToFarmService resourceToFarm=new AssignResourceEmployeeToFarmService();
				resourceToFarm.deleteAssignResources(assignResourceId);
			}else{		
				empInfoCnt=Integer.parseInt(request.getParameter("hdnEmpInfoCnt"));
				siteInfoId=Integer.parseInt(request.getParameter("hdnSiteId"));
				cropId=Integer.parseInt(request.getParameter("hdnCropId"));
				assignFarmDate=Date.valueOf(request.getParameter("hdnDate"));
				AssignCropToSiteService cropToSiteService=new AssignCropToSiteService();
				AssignCropToSiteEntity cropToSiteEntity=new AssignCropToSiteEntity();
				//Get cropsAssignToFarmId 
				cropToSiteEntity=cropToSiteService.getAssignCropToSiteInfoBySiteIdDateCropId(siteInfoId, assignFarmDate, cropId);
				//System.out.println("=======>>"+siteInfoId+" "+assignFarmDate+" "+cropId+"<=========");
				for(int i=1;i<=empInfoCnt;i++){				
					employeeInfoId=Integer.parseInt(request.getParameter("selEmpName"+i));
					arrFarmTaskId=request.getParameterValues("selWork"+i);
					
					amount=Double.parseDouble(request.getParameter("txtAmount"+i));
					advPayment=Double.parseDouble(request.getParameter("txtAdvPayment"+i));
					
					assignWorkDate=Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(request.getParameter("txtDate"+i)));
					typeOfWork=request.getParameter("selWorkType"+i);
					workStatus=request.getParameter("selWorkStatus"+i);
					comment=request.getParameter("txtComment"+i);
					AssignResourceEmployeeToFarmController employeeToFarm=new AssignResourceEmployeeToFarmController();				
					employeeToFarm.assignEmployeeToFarm(employeeInfoId,arrFarmTaskId,amount,advPayment,assignWorkDate,typeOfWork,workStatus,comment,cropToSiteEntity);
					
				}	
			}
			}catch(Exception exception){
				exception.printStackTrace();
			}finally{
				/*out.print("Inserted Successfully");
				out.print("<script>");
				out.print("window.location='view/user/01assignTaskToEmployeeViewAll.jsp'");
				out.print("</script>");*/
				response.sendRedirect("view/user/01assignTaskToEmployeeViewAll.jsp");
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
