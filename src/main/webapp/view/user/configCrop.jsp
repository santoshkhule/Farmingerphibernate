<%@page import="san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.ConfigCropService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title>New Crop</title>
</head>
<script type="text/javascript">
	var tempId=-1; 
	var showEdit=function(id){
		alert("hii"+tempId);
		if(tempId!=-1){			
			document.getElementById("img"+tempId).hidden=true;
		}
		$("#cropId").val($(id).find("td").eq(0).text());
		$("#cropName").val($(id).find("td").eq(1).text());
		document.getElementById("edit").hidden=false;
		document.getElementById("add").hidden=true;
		document.getElementById("th").hidden=false;
		document.getElementById("td"+$(id).find("td").eq(0).text()).hidden=false;
		document.getElementById("img"+$(id).find("td").eq(0).text()).hidden=false;
		tempId=$(id).find("td").eq(0).text();
	}
	function deleteCrop(id) {
		//alert("../../ConfigSiteInformationController?siteInfoId="+id);
		window.location.href="../../ConfigCropController?cropId="+id+"&delete=delete";
	}
</script>
<body>			
	<!-- <h2>Crop Name</h2>
	<hr> -->
	<form method="post">
		<table>
			<tr>
				<td>Crop Name:</td>
				<td>
					
					<input type="hidden" name="cropId" id="cropId">					
					<input type="text" required="required" name="cropName" id="cropName">
				</td>
			</tr>
			<tr>
				<td colspan="2" style="text-align: center;">
					<input type="submit" name="add" id="add" value="Add" onclick="this.form.action='../../ConfigCropController'">
					<input type="submit" id="edit" name="edit" value="Update" onclick="this.form.action='../../ConfigCropController'" hidden>
				</td>			
			</tr>
		</table>
	</form>
	<hr>
	<form method="post">		
		<table width="100%" border=1>
			<tr>				
				<th width="2%">Id</th>
				<th>Crop Name</th>
				<th hidden id="th" width="2%">Action</th>
			</tr>
			<%
			try{				
				ConfigCropService configCropService=new ConfigCropService();
				List<ConfigCropEntity> list=configCropService.fetch();
				for(ConfigCropEntity cropEntity:list){
			%>
			<tr align="center" ondblclick="showEdit(this)">					
				<td><%=cropEntity.getCropId() %></td>
				<td><%=cropEntity.getCropName() %></td>
				<td  id="td<%=cropEntity.getCropId() %>" hidden="true"><img src="../../img/delete.jpg" height="18" width="40" id="img<%=cropEntity.getCropId() %>" hidden onclick="deleteCrop(<%=cropEntity.getCropId() %>)"></td>
			</tr>
					<%
				}
			}catch(Exception ex){
				ex.printStackTrace();
			}
			%>
			
		</table>
	</form>			
</body>
</html>
