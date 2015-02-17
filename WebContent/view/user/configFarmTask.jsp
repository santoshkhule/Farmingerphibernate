<%@page import="san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title>Farming Task</title>
</head>
<script type="text/javascript">
	var tempId=-1; 
	var showEdit=function(id){
		//alert("hii"+tempId);
		if(tempId!=-1){			
			document.getElementById("img"+tempId).hidden=true;
		}
		$("#taskId").val($(id).find("td").eq(0).text());
		$("#taskName").val($(id).find("td").eq(1).text());
		document.getElementById("edit").hidden=false;
		document.getElementById("add").hidden=true;
		document.getElementById("th").hidden=false;
		document.getElementById("td"+$(id).find("td").eq(0).text()).hidden=false;
		document.getElementById("img"+$(id).find("td").eq(0).text()).hidden=false;
		tempId=$(id).find("td").eq(0).text();
	};
	function deleteFarmTask(id) {		
		window.location.href="../../ConfigFarmTaskController?taskId="+id+"&delete=delete";
	}
</script>
<body>
	<form method="post">
		<!-- <h2>Add Farming Task</h2>
		<hr> -->
		<table>
			<tr>
				<td>Task Name:</td>
				<td>
					<input type="hidden" name="taskId" id="taskId">
					<input type="text" name="taskName" id="taskName" required> 
				</td>
			</tr>
			<tr>
				<td colspan="2" style="text-align: center;">					
					<input type="submit" name="add" id="add" value="Add" onclick="this.form.action='../../ConfigFarmTaskController'">
					<input type="submit" name="edit" id="edit" value="Update" hidden onclick="this.form.action='../../ConfigFarmTaskController'">					
				</td>
			</tr>
		</table>
	</form>
	<hr>
	<form method="post">			
		<table border=1 cellspacing=0 style="width: 100%">
			<tr>
				<!-- <th>Select</th> -->
				<th>Id</th>
				<th>Task Name</th>
				<th id="th" hidden="true">Action</th>
			</tr>
			<%			
				try{
					ConfigFarmTaskService farmTaskService=new ConfigFarmTaskService();
					List<ConfigFarmTaskEntity> list=farmTaskService.fetch();
					for(ConfigFarmTaskEntity taskEntity:list){
			%>
			<tr ondblclick="showEdit(this)" align="center">
				<!-- <td><input type="radio" name="radTaskId" id="radTaskId" value=""></td> -->
				<td><%=taskEntity.getTaskId() %></td>
				<td><%=taskEntity.getTaskName() %></td>
				<td  id="td<%=taskEntity.getTaskId()%>" hidden="true"><img src="../../img/delete.jpg" height="18" width="40" id="img<%=taskEntity.getTaskId() %>" hidden onclick="deleteFarmTask(<%=taskEntity.getTaskId() %>)"></td>
			</tr>
			<%}
			}catch(Exception ex){
				ex.printStackTrace();
			}%>
		</table>
	</form>		
</body>
</html>