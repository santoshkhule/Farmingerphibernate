<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Configuration</title>
</head>
<body>
	<%@include file="../../header.jsp"%>
	<fieldset><legend>Configuration for Farming</legend>
	<table width="100%" border="1">
		<tr>
			<th>User Type</th>
			<th>Site Information</th>
			<th>Crops</th>
			<th>Farming Task</th>
		</tr>
				
		<tr>
			<td><iframe width="100%" height="550px" src="userType.jsp"></iframe></td>
			<td><iframe width="100%" height="550px" src="configSiteInformation.jsp"></iframe></td>
			<td><iframe width="100%" height="550px" src="configCrop.jsp"></iframe></td>
			<td><iframe width="100%" height="550px" src="configFarmTask.jsp"></iframe></td>
			
		</tr>
	</table>
	</fieldset>
	
	<%@include file="../../footer.jsp"%>
</body>
</html>