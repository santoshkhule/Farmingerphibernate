package san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import san.farm.adminuser.dao.EmployeeInfoService;
import san.farm.adminuser.entity.EmployeeInfoEntity;
import san.farm.util.FarmConstants;
import san.farm.util.FarmUtility;
import san.farm.util.MyFileRenamePolicy;
import san.farm.util.Symbols;

import com.oreilly.servlet.MultipartRequest;

/**
 * This servlet file Accept the request from employeeInfo.jsp perform db CRUD
 * Operation on that data send result back to the viewAllEmployee.jsp
 * 
 * @author santosh khule
 * @version 1.2
 * @since 20/11/2014
 */
public class EmployeeInfoController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doProcess(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		try{
			MyFileRenamePolicy objFileRenamePolicy=new MyFileRenamePolicy();
			
			MultipartRequest mrequest=new MultipartRequest(request, FarmConstants.getInstance().getFarmProperty("path.name"),
					
			Integer.parseInt(FarmConstants.getInstance().getFarmProperty("filesize")), objFileRenamePolicy);
			// variable Declaration
			String firstName = Symbols.EMPTY.getSymbol(), lastName = Symbols.EMPTY.getSymbol(), middleName = Symbols.EMPTY.getSymbol(), contactNo1 = Symbols.EMPTY.getSymbol(), contactNo2 = Symbols.EMPTY.getSymbol(), comment = Symbols.EMPTY.getSymbol();
			String emailId = Symbols.EMPTY.getSymbol(),localAddress = Symbols.EMPTY.getSymbol(), permanantAddress = Symbols.EMPTY.getSymbol(), bankName = Symbols.EMPTY.getSymbol(), accountNumber = Symbols.EMPTY.getSymbol(), panCardNo = Symbols.EMPTY.getSymbol();
			int employeeInfoId =0;
			Date birthDate=null;
			String empPicPath = FarmUtility.uploadedFilesCSV(mrequest);
			if (null != mrequest.getParameter("firstName")) {
				firstName = mrequest.getParameter("firstName");
			}
			if (null != mrequest.getParameter("middleName")) {
				middleName = mrequest.getParameter("middleName");
			}
			if (null != mrequest.getParameter("lastName")) {
				lastName = mrequest.getParameter("lastName");
			}
			if (null != mrequest.getParameter("contactNo1")) {
				contactNo1 = mrequest.getParameter("contactNo1");
			}
			if (null != mrequest.getParameter("contactNo2")) {
				contactNo2 = mrequest.getParameter("contactNo2");
			}
			if (null != mrequest.getParameter("emailId")) {
				emailId = mrequest.getParameter("emailId");
			}
			if (null != mrequest.getParameter("birthDate")) {				
				birthDate=Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(mrequest.getParameter("birthDate")));				
			}
			if (null != mrequest.getParameter("localAddress")) {
				localAddress = mrequest.getParameter("localAddress");
			}
			if (null != mrequest.getParameter("permanantAddress")) {
				permanantAddress = mrequest.getParameter("permanantAddress");
			}
			if (null != mrequest.getParameter("bankName")) {
				bankName = mrequest.getParameter("bankName");
			}
			if (null != mrequest.getParameter("accountNumber")) {
				accountNumber = mrequest.getParameter("accountNumber");
			}
			if (null != mrequest.getParameter("comment")) {
				comment = mrequest.getParameter("comment");
			}
			if (null != mrequest.getParameter("panCardNo")) {
				panCardNo = mrequest.getParameter("panCardNo");
			}
			if (null != mrequest.getParameter("employeeInfoId") && !mrequest.getParameter("employeeInfoId").equalsIgnoreCase("")) {
				employeeInfoId =Integer.parseInt(mrequest.getParameter("employeeInfoId"));
			}
			
			//create Object
			EmployeeInfoService employeeInfoService = new EmployeeInfoService();
			EmployeeInfoEntity employeeInfoEntity = new EmployeeInfoEntity();
			
			//setValues To the object
			employeeInfoEntity.setFirstName(firstName);
			employeeInfoEntity.setMiddleName(middleName);
			employeeInfoEntity.setLastName(lastName);
			employeeInfoEntity.setContactNo1(contactNo1);
			employeeInfoEntity.setContactNo2(contactNo2);
			employeeInfoEntity.setEmailId(emailId);
			employeeInfoEntity.setBirthDate(birthDate);
			employeeInfoEntity.setLocalAddress(localAddress);
			employeeInfoEntity.setPerAddress(permanantAddress);
			employeeInfoEntity.setBankName(bankName);
			employeeInfoEntity.setAccountNumber(accountNumber);
			employeeInfoEntity.setComment(comment);
			employeeInfoEntity.setPanCardNo(panCardNo);
			employeeInfoEntity.setEmpPicPath(empPicPath);
			
			//Insert Operation
			if (null != mrequest.getParameter("add")) {
				employeeInfoService.saveAuthEmployeeInfo(employeeInfoEntity);
			}
			//Edit Operation
			if (null != mrequest.getParameter("edit")) {
				employeeInfoEntity.setEmployeeInfoId(employeeInfoId);
				employeeInfoService.updateAuthEmployeeInfo(employeeInfoEntity);
			}
			//Delete Operation
			if (null != mrequest.getParameter("delete")) {
				employeeInfoEntity.setEmployeeInfoId(employeeInfoId);
				employeeInfoService.deleteAuthEmployeeInfo(employeeInfoEntity);
			}
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			response.sendRedirect("view/user/employeeViewAll.jsp");
		}
		
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

}
