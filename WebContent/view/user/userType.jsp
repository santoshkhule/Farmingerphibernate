<%@page import="san.farm.adminuser.entity.UserTypeEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.UserTypeService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title>Cofiguration:UserType</title>
</head>
<script type="text/javascript">
	var showEdit=function (id) {
		//alert("hii"+id+"  "+$(id).find("td").eq(1).text().trim());		
		$("#userTypeId").val($(id).find("td").eq(0).text().trim());
		$("#userType").val($(id).find("td").eq(1).text().trim());
		document.getElementById("add").hidden=true;
		document.getElementById("edit").hidden=false;
		document.getElementById("delete").hidden=false;
	}
</script>
<body>
	<%-- <%@include file="../../header.jsp" %> --%>
		<!-- <h2>User Type</h2>
		<hr> -->
		<form method="post">
		<table>
			<tr>
				<td>
					User Type:
				</td>
				<td>
					<input type="hidden" name="userTypeId" id="userTypeId">
					<input type="text" name="userType" id="userType" required>
				</td>
			</tr>
			<tr>				
				<td colspan="2" align="center">
					<input type="submit" name="add" id="add" value="Add" onclick="this.form.action='../../UserTypeController'">
					<input type="submit" name="edit" id="edit" hidden value="update" onclick="this.form.action='../../UserTypeController'">
					<input type="submit" name="delete" id="delete" hidden value="Delete" onclick="this.form.action='../../UserTypeController'">
				</td>
			</tr>
		</table>
		</form>
		<table border="1" width="100%">
			<tr align="center">
				<!-- <th>Select</th> -->
				<th>Id</th>
				<th>User Type</th>
			</tr>
			<%
				UserTypeService userTypeModel=new UserTypeService();
					List<UserTypeEntity> list=userTypeModel.fetch();
					for(UserTypeEntity entity:list){
			%>
			<tr align="center" ondblclick="showEdit(this)">
			<%-- 	<td><input type="radio" name="radUserTypeId" id="radUserTypeId" value="<%=entity.getUserTypeId()%>"></td> --%>
				<td><%=entity.getUserTypeId()%>
					<input type="hidden" id="hdnUserTypeId" value="<%=entity.getUserTypeId()%>">
				</td>
				<td><%=entity.getUserType()%>
					<input type="hidden" id="hdnUserType" value="<%=entity.getUserType()%>">
				</td>
				
			</tr>
			<%} %>
		</table>
		
	
	<%-- <%@include file="../../footer.jsp" %> --%>
</body>
</html>