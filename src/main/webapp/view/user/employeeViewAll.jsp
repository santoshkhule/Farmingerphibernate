<%@page import="san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.EmployeeInfoService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="css/style.css">
<title>View All Employee</title>
</head>
<body>	
<%@include file="../../header.jsp" %>
<fieldset><legend>View All Employee</legend>
	<form action="" method="post">
	<!-- <h2>View All Employee</h2>
	<hr> -->
			
	<table>
		<tr>			
			<td><input type="submit" name="sbtView" value="View" onclick="this.form.action=''"></td>
			<td><input type="submit" name="sbtEdit" value="Edit" onclick="this.form.action=''"></td>
			<td><input type="submit" name="sbtDelete" value="Delete" onclick="this.form.action=''"></td>
			<td><input type="submit" name="sbtAssignTask" value="Assign Task" onclick="this.form.action=''" style="width: 150px"></td>
			<td><input type="submit" name="sbtViewAllTransac" value="View All Transaction" onclick="this.form.action=''" style="width: 150px"></td>
		</tr>
	</table>
	<table border="1" width="100%">
		<thead>
			<tr>
				<th width="2%">Select</th>
				<th width="2%">Id</th>
				<th>Name</th>
				<th width="15%">Contact No.</th>
				<th>Address</th>
				<th>Bank Name</th>
				<th>Acc No</th>
				<!-- <th>Crop</th> -->
				
			</tr>
		</thead>
		<tbody>
			<%
				EmployeeInfoService employeeInfoService=new EmployeeInfoService();
				List<EmployeeInfoEntity> listOfEmployee=employeeInfoService.getListOfEmployee();
				for(EmployeeInfoEntity entity:listOfEmployee){
					if(entity!=null){
			%>
			<tr align="center">
				<td>
					<input type="radio" name="radEmpId" id="radEmpId" value="" required="required">
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
				
				
			</tr>
			<%}} %>
		</tbody>
	</table>
	</form>
	</fieldset>
	<%@include file="../../footer.jsp" %>
</body>
</html>