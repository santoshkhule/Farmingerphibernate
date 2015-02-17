
<%@page import="san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="san.farm.util.FarmUtility"%>
<%@page import="san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script>
<link rel="stylesheet" href="../../css/style.css">
<title>View Employee To Salary Process</title>
</head>
<script>
	$(function() {		
		$("#txtDate").datepicker({

			changeMonth : true,
			changeYear : true,
			dateFormat : "dd/mm/yy"
		}).val();

	});
</script>
<script type="text/javascript">
	function processSalary(assignResourceId){		
		window.open("02SalaryProcessing.jsp?assignResourceId="+assignResourceId, "iframSalProcess");		
	}	
</script>
<script type="text/javascript">
function showAllEmployeeByFilterId() {
	var fromDate=document.getElementById("txtDate").value;
	//alert(fromDate);
	var empName=document.getElementById("txtName").value;
	var work_status=document.getElementById("work_status").value;
	var work_Id=document.getElementById("selWorkId").value;
	
	if (window.XMLHttpRequest) {
		xmlhttp = new XMLHttpRequest();
	} else {
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			document.getElementById("showTable").innerHTML = xmlhttp.responseText;			
		}
	};
	
	var url = "001ViewEmployeeForSalaryProcessAjax.jsp?fromDate="+fromDate+"&empName="+empName+"&work_status="+work_status+"&work_Id="+work_Id;
	xmlhttp.open("GET", url, true);
	xmlhttp.send();
}
</script>
<body>
	<%
		Connection con = null;
		Statement st = null;
		double ttlAmountToPay = 0;
		double ttlAmountPaid = 0;
		double ttlAdvancedPaid = 0;
		double ttlBalance = 0, ttlExcessAmount = 0;
		int assignWorkId = 0;
		if (null != request.getParameter("assignWorkId")) {
			assignWorkId = Integer.parseInt(request
					.getParameter("assignWorkId"));
		}
	%>
	<table>
		<tr>
			<td>Date:</td>
			<td><input type="text" name="txtDate" id="txtDate"
				readonly="readonly"
				pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
				oninvalid="setCustomValidity('Enter Date: Select From Calender')"
				title="Select Date" placeholder="dd/mm/yyyy"
				onchange="showAllEmployeeByFilterId()"></td>
			<td>Name:</td>
			<td><input type="text" name="txtName" id="txtName"
				oninput="showAllEmployeeByFilterId()"></td>
			<td>Work:</td>
			<td><select name="selWorkId" id="selWorkId"
				onchange="showAllEmployeeByFilterId()">
					<option>Select</option>
					<%
						try {
					%>
					<option value=""></option>
					<%
						} catch (Exception ex) {
							ex.printStackTrace();
						}
					%>
			</select></td>
			<td style="text-align: right;">Work Status:</td>
			<td><select name="work_status" id="work_status"
				onchange="showAllEmployeeByFilterId()">
					<option value="-1">select</option>
					<option value="Completed">Completed</option>
					<option value="Pending">Pending</option>
					<option value="Reject">Reject</option>
			</select></td>
		</tr>
	</table>
	<hr>
	<div id="showTable">
		<table border="1" cellspacing="0" style="width: 100%">

			<tr>
			<tr>
				<th>Select</th>
				<th>Sr. No.</th>
			
				<th>Name</th>
				<th>Date</th>
				<th>Site Name</th>
				<th>Crop Name</th>
				<th>Work Type</th>
				<th>Work Status</th>
				<th>Assign Work</th>
				<th>Amount To Pay</th>
				<th>Advanced Paid</th>
				<th>Amount Paid</th>
				<th>Balance</th>						
				<th>Excess Amount</th>
			</tr>
				
			<tbody>
				<%
					try {

						int cnt = 0;
						AssignResourceEmployeeToFarmService employeeToFarmService=new AssignResourceEmployeeToFarmService();
						List<AssignEmployeeToFarmEntity> employeeToFarmEntities=employeeToFarmService.getListOFEmployeeToFarm();
						for(AssignEmployeeToFarmEntity employeeToFarm:employeeToFarmEntities){
						cnt++;
						int assignResourceId = employeeToFarm.getAssignResourceId();
						int emp_id = 0;
				%>
				<tr>
					<td><input type="radio" name="radAssignWorkId"
						id="radAssignWorkId" value="" required="required"
						onclick="processSalary(<%=assignResourceId%>);"></td>
					<td><%=cnt %></td>
					<td>
						<%
							if(employeeToFarm.getEmployeeInfoEntity()!=null){
								if(employeeToFarm.getEmployeeInfoEntity().getFirstName()!=null){
									out.print(employeeToFarm.getEmployeeInfoEntity().getFirstName()+" ");
								}
								if(employeeToFarm.getEmployeeInfoEntity().getMiddleName()!=null){
									out.print(employeeToFarm.getEmployeeInfoEntity().getMiddleName()+" ");
								}
								if(employeeToFarm.getEmployeeInfoEntity().getLastName()!=null){
									out.print(employeeToFarm.getEmployeeInfoEntity().getLastName());
								}
							}
						%>
					</td>
					<td>
							<%
								if(employeeToFarm.getAssignWorkDate()!=null){
									out.println(FarmUtility.convertfrom_yymmddToddmmyy(employeeToFarm.getAssignWorkDate().toString()));
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getCropToSiteEntity()!=null && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity()!=null 
									&& employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName()!=null){
									out.println(employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName());
								}
							%>
						</td>
						<td>
							<%
								/*if(employeeToFarm.getTaskToEmployeeEntities()!=null){
									for(ConfigCropEntity crop:employeeToFarm.getTaskToEmployeeEntities().)
									out.println(employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName());
								}*/
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getTypeOfWork()!=null){
									out.println(employeeToFarm.getTypeOfWork());
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getWorkStatus()!=null){
									out.println(employeeToFarm.getWorkStatus());
								}
							%>
						</td>
						<td>
							<%								
								int i=0;
							
								for(ConfigFarmTaskEntity taskToEmployee:employeeToFarm.getListFarmTaskEntities()){
									if(i==0){
										i++;
										out.println(taskToEmployee.getTaskName());
									}else{
										out.println(","+taskToEmployee.getTaskName());
									}
								}
							%>
						</td>						
						<%
							double ttl_transaction_paid_amount = 0;
								double excessAmount = 0;
								double balanceAmount = 0;
								try {
									balanceAmount=employeeToFarm.getAmount()-employeeToFarm.getAdvPayment();
								} catch (Exception ex) {
									ex.printStackTrace();
								}
								balanceAmount = ttl_transaction_paid_amount;
								if (balanceAmount < 0) {
									excessAmount = -balanceAmount;
									balanceAmount = 0;
								}
						%>
						<td>
							<%								
								out.println(employeeToFarm.getAmount());								
							%>
						</td>
						<td>
							<%
								out.println(employeeToFarm.getAdvPayment());
							%>
						</td>
						<td>
							<%
								out.print(balanceAmount);
							%>
						</td>
						<td>
							<%
								out.print(balanceAmount);
							%>
						</td>
						<td>
							<%
								out.print(balanceAmount);
							%>
						</td>
				</tr>
					<%} %>

				<tr>
					<td style="font-weight: bold; text-align: right;" colspan="9">Total</td>
					<td><b><%=ttlAmountToPay%></b></td>
					<td><b><%=ttlAdvancedPaid%></b></td>
					<td><b><%=ttlAmountPaid%></b></td>
					<td><b><%=ttlBalance%></b></td>
					<td><b><%=ttlExcessAmount%></b></td>
				</tr>
				<%
				
					} catch (Exception ex) {
						ex.printStackTrace();
					}
				%>
			</tbody>
		</table>
	</div>

</body>
</html>