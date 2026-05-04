package san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.AssignResourceEmployeeToFarmService;
import san.farm.adminuser.dao.SalaryProcessingDao;
import san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import san.farm.adminuser.entity.SalaryProcessingEntity;
import san.farm.util.FarmUtility;
import san.farm.util.Symbols;

/**
 * Servlet implementation class SalaryProcessingServlet
 */
@WebServlet("/SalaryProcessingServlet")
public class SalaryProcessingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	@Override
	public void init() throws ServletException {
		System.out.println("Inside Salary Process Servlet");
	}
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		 int salaryProcessId=0,assignResourceId=0;
		 double amount=0.0;
		 Date date=null;
		 String paymentType=Symbols.EMPTY.getSymbol(), bankName=Symbols.EMPTY.getSymbol();
		 String accountNumber=Symbols.EMPTY.getSymbol();
		 String comment=Symbols.EMPTY.getSymbol();
		 if(request.getParameter("amount")!=null){
			 amount=Double.parseDouble(request.getParameter("amount"));
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
		 String qry="from AssignEmployeeToFarmEntity where assignResourceId="+assignResourceId;
		 AssignEmployeeToFarmEntity employeeToFarm=employeeToFarmService.getEmployeeToFarmInfoByEmployeeInfoIdDate(qry);
		 
		 SalaryProcessingEntity salaryProcess=new SalaryProcessingEntity();
		 salaryProcess.setAccountNumber(accountNumber);
		 salaryProcess.setAmount(amount);
		 salaryProcess.setBankName(bankName);
		 salaryProcess.setComment(comment);
		 salaryProcess.setDate(date);
		 salaryProcess.setPaymentType(paymentType);
		 salaryProcess.setEmployeeToFarm(employeeToFarm);		
		 SalaryProcessingDao salaryProcessingDao=new SalaryProcessingDao();
		 if(request.getParameter("sbtPayAmount")!=null){
			 salaryProcessingDao.saveSalaryTransaction(salaryProcess);
		 }
		 if(request.getParameter("sbtUpdateAmount")!=null){
			 salaryProcess.setSalaryProcessId(salaryProcessId);
			 salaryProcessingDao.updateSalaryTransaction(salaryProcess);
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
