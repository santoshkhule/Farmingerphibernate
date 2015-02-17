<%@page import="san.farm.adminuser.entity.AssignCropToSiteRefEntity"%>
<%@page import="san.farm.adminuser.dao.AssignCropToSiteRefService"%>
<%@page import="san.farm.util.FarmUtility"%>
<%@page import="san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="san.farm.adminuser.dao.AssignCropToSiteService"%>
<%@page import="san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="san.farm.adminuser.dao.ConfigCropService"%>
<%@page import="san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script> 
<title>Assign Crop to site</title>
</head>
<script>
	$(function() {		
		$("#cropAssignDate").datepicker({

			changeMonth : true,
			changeYear : true,
			dateFormat : "dd/mm/yy"
		}).val();

	});
</script>
<script type="text/javascript">
var tempId=-1;
  var showEdit=function (id) {
	  if(tempId!=-1){
		  $("#img"+tempId).hide();  
	  }		
		$("#cropToSiteId").val($(id).find("td").eq(1).text());
		$("#siteInfoId").val($(id).find("td").eq(3).text());
		
		//var cropIdArr=$(id).find("td").eq(4).text();
		var cropIdArr=$(id).find("td").eq(4).text().split(",");	
		
		
		for(var i=0;i<cropIdArr.length;i++){			
			$("#cropId").val(cropIdArr[i]);
		}
		
		//$("#cropId").val($(id).find("td").eq(4).text().trim());
		$("#cropAssignDate").val($(id).find("td").eq(2).text().trim());
		$("#edit").show();
		$("#add").hide();
		$("#th").show();
		$("#td"+$(id).find("td").eq(1).text().trim()).show();		
		$("#img"+$(id).find("td").eq(1).text().trim()).show();
		tempId=$(id).find("td").eq(1).text().trim();		
  }
  function deleteCropToSite(id) {		
		window.location.href="../../AssignCropToSiteController?cropToSiteId="+id+"&delete=delete";
	}
</script>
<body>
<%@include file="../../header.jsp" %>	
<fieldset>	
<legend>Assign Crop To Site</legend>
	<form action="../../AssignCropToSiteController" method="post">
		<!-- <h2>Assign Crop To Site</h2>
		<hr> -->
		
					
		<table border=0>
			<tr>
				<td>Site:</td>				
				<td>
					<select name="siteInfoId" id="siteInfoId" required>	
					<%
						ConfigSiteInformationService informationService=new ConfigSiteInformationService();
						List<ConfigSiteInformationEntity> listOfSite=informationService.fetch();
						for(ConfigSiteInformationEntity siteInfoEntity:listOfSite){
					%>					
						<option value="<%=siteInfoEntity.getSiteInfoId()%>"><%=siteInfoEntity.getSiteName() %></option>
						<%} %>									
					</select>
				</td>
			</tr>
			<tr>
				<td style="text-align: right;">Crop:</td>
				<td>
					<select name="cropId" id="cropId" multiple="multiple" required>
					<%
						ConfigCropService cropService=new ConfigCropService();
						List<ConfigCropEntity> listOfCrop=cropService.fetch();
						for(ConfigCropEntity cropEntity:listOfCrop){
					%>
						<option value="<%=cropEntity.getCropId()%>"><%=cropEntity.getCropName() %></option>
					<%} %>
				</select>
			<tr>
			<tr>
				<td style="text-align: right;">Date:</td>
				<td>					
			 		<input type="text" name="cropAssignDate" id="cropAssignDate"
					pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
					oninvalid="setCustomValidity('Enter Date: Select From Calender')"
					onchange="setCustomValidity('')" title="Enter Date"
					placeholder="dd/mm/yyyy" required="required">
				</td>
			</tr>
			<tr>
				<td colspan="8" style="text-align: center;"> 						
					<input type="hidden" name="cropToSiteId" id="cropToSiteId"> 
					<input type="submit" name="edit" id="edit" value="Update" hidden="true">					
					<input type="submit" name="add" id="add" value="Add">					
				</td>
			</tr>
		</table>
	</form>
	<hr>
	<form method="post">
	<table>
		<tr>			
			<td><input type="submit" name="sbtView" value="View" onclick="this.form.action='assignCropToSite.jsp',target='_blank'"></td>
			<td><input type="submit" name="sbtDelete" value="Delete" onclick="this.form.action='action/assignCropToSiteAction.jsp'"></td>
		</tr>
	</table>
		<table border=1 style="width: 100%" cellSpacing=0>
			<tr>
				<th>Select</th>
				<th>Sr. No.</th>
				<th>Date</th>
				<th>Site</th>
				<th>Crop</th>
				<th width="2%" id="th" hidden="true">Action</th>				
			</tr>
			<%
				AssignCropToSiteService cropToSiteService=new AssignCropToSiteService();
				List<AssignCropToSiteEntity> cropToSiteEntities=cropToSiteService.getListOFAssignCropToSite();
				for(AssignCropToSiteEntity cropToSiteEntity:cropToSiteEntities){
			%>
			<tr align="center" onclick="showEdit(this)">
				<td>
					<input type="radio" name="radAssignCropSiteId" id="radAssignCropSiteId" value="" required="required">
				</td>
				<td><%if(cropToSiteEntity!=null){out.println(cropToSiteEntity.getAssignCroptoSiteId());} %></td>
				<td><%if(cropToSiteEntity!=null){out.println(FarmUtility.convertfrom_yymmddToddmmyy(cropToSiteEntity.getCropAssignDate().toString()));} %></td>
				<td hidden="true"><%=cropToSiteEntity.getSiteInformationEntity().getSiteInfoId() %></td>
				<%
				List<AssignCropToSiteRefEntity> cropToSiteRefEntities=cropToSiteEntity.getCropToSiteRefEntity();
				String cropId=null,cropName=null;
				for(AssignCropToSiteRefEntity siteRefEntity:cropToSiteRefEntities){
					if(null!=cropId){
						cropId=cropId+","+siteRefEntity.getConfigCropEntity().getCropId();
					}else{
						cropId=String.valueOf(siteRefEntity.getConfigCropEntity().getCropId());
					}
					if(null!=cropName){
						cropName=cropName+","+siteRefEntity.getConfigCropEntity().getCropName();
					}else{
						cropName=siteRefEntity.getConfigCropEntity().getCropName();
					}
				}
				%>
				<td hidden="true"><%=cropId%></td>
				<td><%if(cropToSiteEntity.getSiteInformationEntity()!=null){out.println(cropToSiteEntity.getSiteInformationEntity().getSiteName());} %></td>
				<td><%if(null!=cropName){out.println(cropName);} %></td>
				<td id="td<%=cropToSiteEntity.getAssignCroptoSiteId() %>" hidden="true"><img src="../../img/delete.jpg" height="18" width="40" id="img<%=cropToSiteEntity.getAssignCroptoSiteId() %>" hidden onclick="deleteCropToSite(<%=cropToSiteEntity.getAssignCroptoSiteId()%>)"></td>
			</tr>
			<%} %>
		</table>
		
	</form>
	</fieldset>
	<%@include file="../../footer.jsp" %>
	
</body>
</html>