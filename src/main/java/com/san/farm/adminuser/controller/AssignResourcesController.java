package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Session;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignCropToSiteService;
import com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService;
import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import com.san.farm.adminuser.entity.SalaryProcessingEntity;
import com.san.farm.util.FarmUtility;
import com.san.farm.util.HibernateUtil;
import com.san.farm.util.Symbols;

@WebServlet("/AssignResourcesController")
public class AssignResourcesController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(AssignResourcesController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing AssignResources request");
		try{
			//Variable Initialization
			int empInfoCnt=0,employeeInfoId=0,farmTaskId=0,siteInfoId=0,cropId=0,assignResourceId=0;
			double amount=0,advPayment=0;
			Date assignWorkDate=null,assignFarmDate=null;
			String typeOfWork=Symbols.EMPTY.getSymbol();
			String workStatus=Symbols.EMPTY.getSymbol();
			String comment=Symbols.EMPTY.getSymbol();			
			String[] arrFarmTaskId=null;			
			
			if(request.getParameter("action")!=null){
				assignResourceId=Integer.parseInt(request.getParameter("assignResourceId"));
				logger.info("Deleting assignment resource with id: {}", assignResourceId);
				AssignResourceEmployeeToFarmService resourceToFarm=new AssignResourceEmployeeToFarmService();
				resourceToFarm.deleteAssignResources(assignResourceId);
				logger.info("Assignment resource deleted successfully");
			}else{
				empInfoCnt=Integer.parseInt(request.getParameter("hdnEmpInfoCnt"));
				siteInfoId=Integer.parseInt(request.getParameter("hdnSiteId"));
				cropId=Integer.parseInt(request.getParameter("hdnCropId"));
				assignFarmDate=Date.valueOf(request.getParameter("hdnDate"));
				logger.debug("Processing {} employee assignments for siteId: {}, cropId: {}, date: {}", empInfoCnt, siteInfoId, cropId, assignFarmDate);

				AssignCropToSiteService cropToSiteService=new AssignCropToSiteService();
				AssignCropToSiteEntity cropToSiteEntity=new AssignCropToSiteEntity();
				//Get cropsAssignToFarmId 
				cropToSiteEntity=cropToSiteService.getAssignCropToSiteInfoBySiteIdDateCropId(siteInfoId, assignFarmDate, cropId);

				for(int i=1;i<=empInfoCnt;i++){
					employeeInfoId=Integer.parseInt(request.getParameter("selEmpName"+i));
					arrFarmTaskId=request.getParameterValues("selWork"+i);
					if(arrFarmTaskId==null){ arrFarmTaskId=new String[0]; }
					
					amount=Double.parseDouble(request.getParameter("txtAmount"+i));
					advPayment=Double.parseDouble(request.getParameter("txtAdvPayment"+i));
					
					assignWorkDate=Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(request.getParameter("txtDate"+i)));
					typeOfWork=request.getParameter("selWorkType"+i);
					workStatus=request.getParameter("selWorkStatus"+i);
					comment=request.getParameter("txtComment"+i);

					logger.debug("Assigning resources for employee {}, amount: {}", employeeInfoId, amount);
					AssignResourceEmployeeToFarmController employeeToFarm=new AssignResourceEmployeeToFarmController();
					employeeToFarm.assignEmployeeToFarm(employeeInfoId,arrFarmTaskId,amount,advPayment,assignWorkDate,typeOfWork,workStatus,comment,cropToSiteEntity,cropId);
					
				}
				logger.info("All employee assignments processed successfully");
			}
		}catch(Exception exception){
			logger.error("Error processing AssignResources request", exception);
		}finally{
			logger.debug("Redirecting to assignTaskToEmployeeViewAll.jsp");
			response.sendRedirect("view/user/01assignTaskToEmployeeViewAll.jsp");
		}
	}
    
	private void doView(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing view single assignment request");
		Session hibSession = null;
		try {
			String radParam = request.getParameter("radAssignWorkId");
			if (radParam == null || radParam.trim().isEmpty()) {
				response.sendRedirect("view/user/01assignTaskToEmployeeViewAll.jsp");
				return;
			}

			int assignWorkId = Integer.parseInt(radParam.trim());
			hibSession = HibernateUtil.opensession();

			List<AssignEmployeeToFarmEntity> results = hibSession.createQuery(
				"SELECT DISTINCT a FROM AssignEmployeeToFarmEntity a " +
				"LEFT JOIN FETCH a.listFarmTaskEntities " +
				"WHERE a.assignResourceId = :id",
				AssignEmployeeToFarmEntity.class)
				.setParameter("id", assignWorkId)
				.getResultList();
			AssignEmployeeToFarmEntity assignment = results.isEmpty() ? null : results.get(0);

			if (assignment != null) {
				List<SalaryProcessingEntity> salaryList = hibSession.createQuery(
					"FROM SalaryProcessingEntity s WHERE s.employeeToFarm.assignResourceId = :id",
					SalaryProcessingEntity.class)
					.setParameter("id", assignWorkId)
					.list();

				double ttlTransactionPaid = 0;
				for (SalaryProcessingEntity sal : salaryList) {
					ttlTransactionPaid += sal.getAmount();
				}

				double balanceAmount = assignment.getAmount() - (assignment.getAdvPayment() + ttlTransactionPaid);
				double excessAmount = 0;
				if (balanceAmount < 0) {
					excessAmount = -balanceAmount;
					balanceAmount = 0;
				}

				SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
				String formattedDate = assignment.getAssignWorkDate() != null
						? sdf.format(assignment.getAssignWorkDate()) : "";

				request.setAttribute("assignment", assignment);
				request.setAttribute("ttlTransactionPaid", ttlTransactionPaid);
				request.setAttribute("balanceAmount", balanceAmount);
				request.setAttribute("excessAmount", excessAmount);
				request.setAttribute("formattedDate", formattedDate);

				logger.info("Assignment {} loaded for view", assignWorkId);
			}
		} catch (Exception ex) {
			logger.error("Error loading assignment for view", ex);
		} finally {
			if (hibSession != null && hibSession.isOpen()) {
				hibSession.close();
			}
		}

		RequestDispatcher dispatcher = request.getRequestDispatcher("/view/user/assignTaskToEmployeeSingleView.jsp");
		dispatcher.forward(request, response);
	}

    /**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("sbtView") != null) {
			doView(request, response);
		} else {
			doProcess(request, response);
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("sbtView") != null) {
			doView(request, response);
		} else {
			doProcess(request, response);
		}
	}

}
