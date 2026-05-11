package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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
import com.san.farm.adminuser.dao.ConfigCropService;
import com.san.farm.adminuser.dao.ConfigFarmTaskService;
import com.san.farm.adminuser.dao.EmployeeInfoService;
import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import com.san.farm.adminuser.entity.ConfigCropEntity;
import com.san.farm.adminuser.entity.ConfigFarmTaskEntity;
import com.san.farm.adminuser.entity.EmployeeInfoEntity;
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

	private void doEditLoad(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing edit load request");
		Session hibSession = null;
		try {
			String radParam = request.getParameter("radAssignWorkId");
			if (radParam == null || radParam.trim().isEmpty()) {
				response.sendRedirect("view/user/01assignTaskToEmployeeViewAll.jsp");
				return;
			}
			int assignResourceId = Integer.parseInt(radParam.trim());
			hibSession = HibernateUtil.opensession();

			List<AssignEmployeeToFarmEntity> results = hibSession.createQuery(
				"SELECT DISTINCT a FROM AssignEmployeeToFarmEntity a " +
				"LEFT JOIN FETCH a.listFarmTaskEntities " +
				"WHERE a.assignResourceId = :id",
				AssignEmployeeToFarmEntity.class)
				.setParameter("id", assignResourceId)
				.getResultList();
			AssignEmployeeToFarmEntity assignment = results.isEmpty() ? null : results.get(0);

			EmployeeInfoService empService = new EmployeeInfoService();
			ConfigCropService cropService = new ConfigCropService();
			ConfigFarmTaskService taskService = new ConfigFarmTaskService();
			AssignCropToSiteService cropToSiteService = new AssignCropToSiteService();

			request.setAttribute("assignment", assignment);
			request.setAttribute("employees", empService.getListOfEmployee());
			request.setAttribute("crops", cropService.fetch());
			request.setAttribute("tasks", taskService.fetch());
			request.setAttribute("cropToSites", cropToSiteService.getListOFAssignCropToSite());

			if (assignment != null && assignment.getAssignWorkDate() != null) {
				SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
				request.setAttribute("formattedDate", sdf.format(assignment.getAssignWorkDate()));
			}

			logger.info("Assignment {} loaded for edit", assignResourceId);
		} catch (Exception ex) {
			logger.error("Error loading assignment for edit", ex);
		} finally {
			if (hibSession != null && hibSession.isOpen()) {
				hibSession.close();
			}
		}
		RequestDispatcher dispatcher = request.getRequestDispatcher("/view/user/assignTaskToEmployee.jsp");
		dispatcher.forward(request, response);
	}

	private void doUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing update assignment request");
		try {
			int assignResourceId = Integer.parseInt(request.getParameter("hdnAssignResourceId"));

			AssignResourceEmployeeToFarmService service = new AssignResourceEmployeeToFarmService();
			AssignEmployeeToFarmEntity assignment = service.getEmployeeToFarmById(assignResourceId);

			if (assignment != null) {
				assignment.setAssignWorkDate(Date.valueOf(
					FarmUtility.convertfrom_ddmmyyToyymmdd(request.getParameter("txtDate"))));
				assignment.setTypeOfWork(request.getParameter("selWorkType"));
				assignment.setAmount(Double.parseDouble(request.getParameter("txtAmount")));
				assignment.setAdvPayment(Double.parseDouble(request.getParameter("txtAdvPayment")));
				assignment.setWorkStatus(request.getParameter("selWorkStatus"));
				assignment.setComment(request.getParameter("txtComment"));

				EmployeeInfoService empService = new EmployeeInfoService();
				assignment.setEmployeeInfoEntity(empService.getEmployeeById(
					Integer.parseInt(request.getParameter("selEmpId"))));

				String cropToSiteParam = request.getParameter("selCropToSiteId");
				if (cropToSiteParam != null && !cropToSiteParam.equals("-1")) {
					AssignCropToSiteService cropToSiteService = new AssignCropToSiteService();
					assignment.setCropToSiteEntity(cropToSiteService.getAssignCropToSiteInfoByCropToSiteId(
						Integer.parseInt(cropToSiteParam)));
				}

				String cropIdParam = request.getParameter("selCropId");
				if (cropIdParam != null && !cropIdParam.equals("-1")) {
					ConfigCropService cropService = new ConfigCropService();
					assignment.setCropEntity(cropService.getCropIdByCropId(Integer.parseInt(cropIdParam)));
				}

				String[] taskIds = request.getParameterValues("selWork");
				List<ConfigFarmTaskEntity> taskList = new ArrayList<ConfigFarmTaskEntity>();
				if (taskIds != null) {
					ConfigFarmTaskService taskService = new ConfigFarmTaskService();
					for (String taskIdStr : taskIds) {
						ConfigFarmTaskEntity task = taskService.getFarmTaskIdByTaskId(Integer.parseInt(taskIdStr));
						if (task != null) taskList.add(task);
					}
				}
				assignment.setListFarmTaskEntities(taskList);

				service.updateEmployeeToFarm(assignment);
				logger.info("Assignment {} updated successfully", assignResourceId);
			}
		} catch (Exception ex) {
			logger.error("Error updating assignment", ex);
		} finally {
			response.sendRedirect("view/user/01assignTaskToEmployeeViewAll.jsp");
		}
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("sbtView") != null) {
			doView(request, response);
		} else if (request.getParameter("sbtEdit") != null) {
			doEditLoad(request, response);
		} else if (request.getParameter("sbtSave") != null) {
			doUpdate(request, response);
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
		} else if (request.getParameter("sbtEdit") != null) {
			doEditLoad(request, response);
		} else if (request.getParameter("sbtSave") != null) {
			doUpdate(request, response);
		} else {
			doProcess(request, response);
		}
	}

}
