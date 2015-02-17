<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script>
<title>Employee Information</title>
</head>
<script>
	$(function() {		
		$("#birthDate").datepicker({
			changeMonth : true,
			changeYear : true,
			dateFormat : "dd/mm/yy"
		}).val();

	});
</script>
<body>
<%@include file="../../header.jsp" %>
	<h2>Employee Information</h2>
	<hr>
	
	<form  name="frmAddEmp" action="../../EmployeeInfoController" enctype="multipart/form-data"  method="post">
		<table border=0 style="width: 100%" cellSpacing=0>
			<tr>
				<td rowspan="4">
				Upload Employee Photo:
				<input type="file" name="fileEmpPhoto" id="fileEmpPhoto"></td>
									
				<td style="text-align: center;" rowspan="4">
					<input type="hidden" name="hdnUploadedPhoto" value="">							
					<a href="DownloadFileServlet?fileName=">
						<img src="" width="135" height="100">
					</a>						
					<img src="" width="135" height="50px">						
				</td>				
			</tr>
			<tr>
				<td style="text-align: right;width: 20%;height: 2.0em" >First Name:</td>
				<td style="text-align: left;"><input type="text" name="firstName" id="firstName" required="required" value=""></td>
			</tr>
			<tr>
				<td style="text-align: right;height: 2.0em">Middle Name:</td>
				<td style="text-align: left;"><input type="text" name="middleName" id="middleName" value=""></td>
			</tr>
			<tr>
				<td style="text-align: right;height: 2.0em">Last Name:</td>
				<td style="text-align: left;"><input type="text" name="lastName" id="lastName" required value=""></td>			
			</tr>
			<tr>
				<td colspan="4">
				<hr>
				</td>
			</tr>				
			<tr>
				<td style="text-align: right;">Contact Number1:</td>
				<td style="text-align: left;"><input type="text" name="contactNo1" id="contactNo1" required value="">
				</td>
				<td style="text-align: right;">Contact Number2:</td>
				<td style="text-align: left;"><input type="text" name="contactNo2" id="contactNo2"  value="">
				</td>				
			</tr>
			<tr>				
				<td style="text-align: right;">Email_id:</td>
				<td style="text-align: left;"><input type="text" name="emailId" id="emailId" readonly="readonly" value="">
				</td>
				<td style="text-align: right;">Birth_Date:</td>
				<td style="text-align: left;">
							<input type="text" name="birthDate" id="birthDate" placeholder="dd/mm/yyyy" 
							pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}" oninvalid="setCustomValidity('Select Date From Calender')"								 
							value="">
				</td>				
			</tr>			
			<tr>
				<td style="text-align: right;width: 25%">Local Address:</td>
				<td style="text-align: left;width: 10%"><textarea name="localAddress" required="required"  id="localAddress" rows="" cols="20"></textarea></td>
				<td style="text-align: right;">Permanent Address:</td>
				<td style="text-align: left;width: 30%"><textarea name="permanantAddress" required="required"  id="permanantAddress" rows="" cols="20"></textarea></td>
														
			</tr>				
			<tr>
				<td style="text-align: right;">Bank Name:</td>
				<td style="text-align: left;"><input type="text" name="bankName" required="required" id="bankName" value=""></td>
				<td style="text-align: right;">Account Number:</td>
				<td style="text-align: left;"><input type="text" name="accountNumber" id="accountNumber" required="required" value=""></td>
							
			</tr>
			<tr>
				<td style="text-align: right;">Pan Card No:</td>
				<td style="text-align: left;"><input type="text" name="panCardNo" id="panCardNo"></td>
				<td style="text-align: right;">Comment:</td>
				<td style="text-align: left;"><textarea name="comment" rows="" cols="20"> </textarea></td>
				
							
			</tr>
			<tr>
				<td colspan="5" style="text-align: center;"><br>
				
					<input type="hidden" name="employeeInfoId" id="employeeInfoId" value="">
					<input type="Submit" name="edit" value="Save" hidden="true">
				
				<input type="Submit" name="add" value="Add">
				</td>
			</tr>
		</table>
	</form>
<%@include file="../../footer.jsp" %>
			
</body>
</html> 