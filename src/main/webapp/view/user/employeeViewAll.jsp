<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.EmployeeInfoService"%>
<%@page import="com.san.farm.adminuser.dao.SalaryProcessingDao"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css">
<title>View All Employee</title>
</head>
<script type="text/javascript">
	function doAction(action) {
		var radios = document.getElementsByName('radEmpId');
		var selectedId = '';
		for (var i = 0; i < radios.length; i++) {
			if (radios[i].checked) {
				selectedId = radios[i].value;
				break;
			}
		}
		if (selectedId === '') {
			alert('Please select an employee first.');
			return false;
		}
		if (action === 'view') {
			window.location = 'employeeInfo.jsp?employeeInfoId=' + selectedId + '&mode=view';
			return false;
		} else if (action === 'edit') {
			window.location = 'employeeInfo.jsp?employeeInfoId=' + selectedId + '&mode=edit';
			return false;
		} else if (action === 'delete') {
			if (!confirm('Are you sure you want to delete this employee?')) return false;
			document.getElementById('hdnEmployeeInfoId').value = selectedId;
			document.getElementById('frmEmpList').action = '../../EmployeeInfoController';
			return true;
		} else if (action === 'assignTask') {
			window.location = '01assignTaskToEmployeeViewAll.jsp?employeeInfoId=' + selectedId;
			return false;
		} else if (action === 'viewTransaction') {
			window.location = '02ViewEmployeeForSalaryProcess.jsp?employeeInfoId=' + selectedId;
			return false;
		}
		return false;
	}
</script>
<body>
<%@include file="../../header.jsp" %>
<fieldset><legend>View All Employee</legend>
	<form id="frmEmpList" action="" method="post" enctype="multipart/form-data">
		<input type="hidden" name="employeeInfoId" id="hdnEmployeeInfoId" value="">

	<div style="margin-bottom:10px; display:flex; gap:6px; flex-wrap:wrap;">
		<input type="submit" class="btn-action" name="sbtView"           value="View"                 onclick="return doAction('view')">
		<input type="submit" class="btn-action" name="sbtEdit"           value="Edit"                 onclick="return doAction('edit')">
		<input type="submit" class="btn-delete" name="delete"            value="Delete"               onclick="return doAction('delete')">
		<input type="submit" class="btn-action" name="sbtAssignTask"     value="Assign Task"          onclick="return doAction('assignTask')">
		<input type="submit" class="btn-action" name="sbtViewAllTransac" value="View All Transaction" onclick="return doAction('viewTransaction')">
	</div>
	<table border="1" width="100%" class="tbl-data">
		<thead>
			<tr>
				<th width="2%">Select</th>
				<th width="2%">Id</th>
				<th>Name</th>
				<th width="15%">Contact No.</th>
				<th>Address</th>
				<th>Bank Name</th>
				<th>Acc No</th>
				<th>Total Amount</th>
				<th>Amount Unpaid</th>
				<th>Pay Status</th>
			</tr>
		</thead>
		<tbody>
			<%
				EmployeeInfoService employeeInfoService=new EmployeeInfoService();
				SalaryProcessingDao salaryProcessingDao=new SalaryProcessingDao();
				AssignResourceEmployeeToFarmService assignService=new AssignResourceEmployeeToFarmService();
				List<EmployeeInfoEntity> listOfEmployee=employeeInfoService.getListOfEmployee();
				for(EmployeeInfoEntity entity:listOfEmployee){
					if(entity!=null){
						int empId=entity.getEmployeeInfoId();
						double[] amountAdv=assignService.getTotalAmountAndAdvByEmployeeInfoId(empId);
						double totalAssigned=amountAdv[0];
						double totalAdv=amountAdv[1];
						double totalSalaryPaid=salaryProcessingDao.getTotalSalaryPaidByEmployeeInfoId(empId);
						double totalPaid=totalAdv+totalSalaryPaid;
						String payStatus;
						String payStatusColor;
						if(totalAssigned==0){
							payStatus="No Work";
							payStatusColor="#888888";
						}else if(totalPaid>=totalAssigned){
							payStatus="Paid";
							payStatusColor="#007700";
						}else if(totalPaid>0){
							payStatus="Partial";
							payStatusColor="#cc7700";
						}else{
							payStatus="Unpaid";
							payStatusColor="#cc0000";
						}
			%>
			<tr align="center">
				<td>
					<input type="radio" name="radEmpId" value="<%=entity.getEmployeeInfoId()%>" required="required">
				</td>
				<td><%=entity.getEmployeeInfoId() %></td>
				<td>
					<%if(null!=entity.getFirstName() && !entity.getFirstName().equalsIgnoreCase("")){out.println(entity.getFirstName());} %>
					<%if(null!=entity.getMiddleName() && !entity.getMiddleName().equalsIgnoreCase("")){out.print(entity.getMiddleName());} %>
					<%if(null!=entity.getLastName() && !entity.getLastName().equalsIgnoreCase("")){out.print(entity.getLastName());} %>
				</td>
				<td><%if(null!=entity.getContactNo1() && !entity.getContactNo1().equalsIgnoreCase("")){out.print(entity.getContactNo1());} %></td>
				<td><%if(null!=entity.getLocalAddress() && !entity.getLocalAddress().equalsIgnoreCase("")){out.print(entity.getLocalAddress());} %></td>
				<td><%if(null!=entity.getBankName() && !entity.getBankName().equalsIgnoreCase("")){out.print(entity.getBankName());} %></td>
				<td><%if(null!=entity.getAccountNumber() && !entity.getAccountNumber().equalsIgnoreCase("")){out.print(entity.getAccountNumber());} %></td>
				<td><%=totalAssigned%></td>
				<td style="color:#cc0000;"><%=(totalAssigned - totalPaid) > 0 ? (totalAssigned - totalPaid) : 0%></td>
				<td style="font-weight:bold; color:<%=payStatusColor%>;"><%=payStatus%></td>
			</tr>
			<%}} %>
		</tbody>
	</table>
	</form>
	</fieldset>
	<%@include file="../../footer.jsp" %>
</body>
</html>
