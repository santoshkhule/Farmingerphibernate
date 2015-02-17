<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@page import="san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html >
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src="../../js/jquery-1.9.1.js"></script>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<title>Site information</title>
</head>
<script type="text/javascript">
	var tempId=-1;
	var showEdit=function(id){
		//alert(tempId);
		if(tempId!=-1){
			document.getElementById("img"+tempId).hidden=true;
		}
		
		$("#siteInfoId").val($(id).find("td").eq(0).text().trim());
		$("#siteName").val($(id).find("td").eq(1).text().trim());
		$("#siteArea").val($(id).find("td").eq(2).text().trim());
		$("#siteLocation").val($(id).find("td").eq(3).text().trim());		
		document.getElementById("edit").hidden=false;
		document.getElementById("add").hidden=true;	
		document.getElementById("th").hidden=false;
		document.getElementById("td"+$(id).find("td").eq(0).text().trim()).hidden=false;	
		document.getElementById("img"+$(id).find("td").eq(0).text().trim()).hidden=false;
		tempId=$(id).find("td").eq(0).text().trim();
		//alert(tempId);
	}
	function deleteSiteInfo(id) {
		//alert("../../ConfigSiteInformationController?siteInfoId="+id);
		window.location.href="../../ConfigSiteInformationController?siteInfoId="+id+"&delete=delete";
	}
</script>
<body>
<%try{ %>
<form action="../../ConfigSiteInformationController">
	<!-- <h2>Site information</h2>
	<hr> -->
	<table>
		<tr>
			<td style="text-align: right;">Site Name:</td>
			<td>
				<input type="text" required="required" name="siteName" id="siteName" >
				<input type="hidden" name="siteInfoId" id="siteInfoId" >
			</td>
		</tr>
		<tr>
			<td style="text-align: right;">Site Area:</td>
			<td><input type="text" required="required" name="siteArea" id="siteArea" placeholder=" in acres" pattern="[0-9]+|[0-9]+\.[0-9]+"></td>
		</tr>
		<tr>
			<td style="text-align: right;">Site Location:</td>
			<td><input type="text" required="required" name="siteLocation" id="siteLocation"></td>
		</tr>
		<tr>
		
			<td colspan="2" style="text-align: center;">			 
				<input type="hidden" name="hdnSiteId" id="hdnSiteId">
				<input type="submit" name="edit" id="edit" hidden="true" value="Update">				
				<input type="submit" name="add" id="add" value="Add">			
			</td>
		</tr>
	</table>
</form>

<hr>
<form>
	<!-- <table>
		<tr>			
			<td><input type="submit" name="sbtDelete" value="Delete" onclick="this.form.action='action/siteInformationAction.jsp'"></td>
		</tr>
	</table> -->
	<table border="1" style="width: 100%">
		<tr>
			<!-- <th width="5%">Select</th> -->
			<th width="2%">Id</th>
			<th>Site Name</th>
			<th>Site Area</th>
			<th>Site Location</th>
			<th width="3%" hidden id="th">action</th>			
		</tr>
		<%
			ConfigSiteInformationService siteInformationService=new ConfigSiteInformationService();
			List<ConfigSiteInformationEntity> informationEntity=siteInformationService.fetch();
			for(ConfigSiteInformationEntity siteInformationEntity:informationEntity){
		%>
		<tr ondblclick="showEdit(this)">
			<%-- <td><input type="radio" name="radSiteId" id="radSiteId" value="<%=siteInformationEntity.getSiteInfoId()%>"></td> --%>
			<td><%=siteInformationEntity.getSiteInfoId() %></td>
			<td><%=siteInformationEntity.getSiteName() %></td>
			<td><%=siteInformationEntity.getSiteArea() %></td>
			<td><%=siteInformationEntity.getSiteLocation() %></td>
			<td hidden id="td<%=siteInformationEntity.getSiteInfoId() %>"><img src="../../img/delete.jpg" height="18" width="40" id="img<%=siteInformationEntity.getSiteInfoId() %>" hidden onclick="deleteSiteInfo(<%=siteInformationEntity.getSiteInfoId() %>)"></td>
		</tr>
		<%} %>
	</table>
</form>
<%}catch(Exception ex){
	ex.printStackTrace();
} %>

</body>
</html>