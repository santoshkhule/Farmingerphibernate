package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService;
import com.san.farm.adminuser.dao.PaymentProcessingDao;
import com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import com.san.farm.adminuser.entity.PaymentProcessingEntity;
import com.san.farm.util.FarmUtility;
import com.san.farm.util.Symbols;

/**
 \* Servlet implementation class PaymentProcessingServlet
 */
@WebServlet("/PaymentProcessingServlet")
public class PaymentProcessingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(PaymentProcessingServlet.class);

	@Override
	public void init() throws ServletException {
		logger.info("PaymentProcessingServlet initialized");
	}
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		logger.debug("Processing SalaryProcessing request");
		try {
			int salaryProcessId=0,assignResourceId=0;
			double amount=0.0;
			Date date=null;
			String paymentType=Symbols.EMPTY.getSymbol(), bankName=Symbols.EMPTY.getSymbol();
			String accountNumber=Symbols.EMPTY.getSymbol();
			String comment=Symbols.EMPTY.getSymbol();
			if(request.getParameter("txtAmount")!=null && !request.getParameter("txtAmount").isEmpty()){
				amount=Double.parseDouble(request.getParameter("txtAmount"));
			}
			if(request.getParameter("txtDate")!=null){
				date=Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(request.getParameter("txtDate")));
			}
			if(request.getParameter("paymentType")!=null){
				paymentType=request.getParameter("paymentType");
			}
			if(request.getParameter("bankName")!=null){
				bankName=request.getParameter("bankName");
			}
			if(request.getParameter("accountNO")!=null){
				accountNumber=request.getParameter("accountNO");
			}
			if(request.getParameter("comment")!=null){
				comment=request.getParameter("comment");
			}
			if(request.getParameter("assignResourceId")!=null){
				assignResourceId=Integer.parseInt(request.getParameter("assignResourceId"));
			}
			if(request.getParameter("salaryProcessId")!=null && !request.getParameter("salaryProcessId").equalsIgnoreCase("")){
				salaryProcessId=Integer.parseInt(request.getParameter("salaryProcessId"));
			}

			AssignResourceEmployeeToFarmService employeeToFarmService=new AssignResourceEmployeeToFarmService();
			AssignEmployeeToFarmEntity employeeToFarm=employeeToFarmService.getEmployeeToFarmById(assignResourceId);

			PaymentProcessingEntity salaryProcess=new PaymentProcessingEntity();
			salaryProcess.setAccountNumber(accountNumber);
			salaryProcess.setAmount(amount);
			salaryProcess.setBankName(bankName);
			salaryProcess.setComment(comment);
			salaryProcess.setDate(date);
			salaryProcess.setPaymentType(paymentType);
			salaryProcess.setEmployeeToFarm(employeeToFarm);
			PaymentProcessingDao salaryProcessingDao=new PaymentProcessingDao();
			if(request.getParameter("sbtPayAmount")!=null){
				logger.info("Saving salary transaction for assignResourceId: {}, amount: {}", assignResourceId, amount);
				salaryProcessingDao.saveSalaryTransaction(salaryProcess);
				logger.info("Salary transaction saved successfully");
			}
			if(request.getParameter("sbtUpdateAmount")!=null){
				salaryProcess.setSalaryProcessId(salaryProcessId);
				logger.info("Updating salary transaction with id: {}, amount: {}", salaryProcessId, amount);
				salaryProcessingDao.updateSalaryTransaction(salaryProcess);
				logger.info("Salary transaction updated successfully");
			}
			if(request.getParameter("sbtDelete")!=null){
				logger.info("Deleting salary transaction with id: {}", salaryProcessId);
				salaryProcessingDao.deleteSalaryTransaction(salaryProcessId);
				logger.info("Salary transaction deleted successfully");
			}
			response.sendRedirect(request.getContextPath() + "/view/user/02employeePaymentProcess.jsp?assignResourceId=" + assignResourceId);
		} catch (Exception exception) {
			logger.error("Error processing SalaryProcessing request", exception);
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
