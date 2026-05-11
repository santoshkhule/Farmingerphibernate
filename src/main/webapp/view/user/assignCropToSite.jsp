<%@page import="com.san.farm.adminuser.entity.AssignCropToSiteRefEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignCropToSiteRefService"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="com.san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignCropToSiteService"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.adminuser.dao.ConfigCropService"%>
<%@page import="com.san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
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
	function showEdit(row) {
		var $row = $(row);
		$("#cropToSiteId").val($row.data("id"));
		$("#siteInfoId").val($row.data("siteInfoId"));
		var cropIds = String($row.data("cropId")).split(",");
		var $sel = $("#cropId");
		$sel.find("option").prop("selected", false);
		for (var i = 0; i < cropIds.length; i++) {
			$sel.find("option[value='" + cropIds[i].trim() + "']").prop("selected", true);
		}
		$("#cropAssignDate").val($row.data("date"));
		$("#edit").show();
		$("#add").hide();
		$("tr.selected-row").removeClass("selected-row");
		$row.addClass("selected-row");
	}
	function deleteCropToSite(id) {
		if (confirm("Delete this assignment?")) {
			window.location.href = "../../AssignCropToSiteController?cropToSiteId=" + id + "&delete=delete";
		}
	}
</script>
<script>
$(document).ready(function() {
	if ($.fn.DataTable && !$.fn.DataTable.isDataTable('#assignCropTable')) {
		$('#assignCropTable').DataTable({
			pageLength: 25,
			lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
			autoWidth: false,
			scrollX: true,
			columnDefs: [
				{ orderable: false, targets: [0, 4] }
			],
			language: {
				search: '', searchPlaceholder: 'Search...',
				lengthMenu: 'Show _MENU_ entries',
				info: '_START_ - _END_ of _TOTAL_',
				infoEmpty: '0 entries',
				emptyTable: 'No records found',
				paginate: { previous: '&#8249;', next: '&#8250;' }
			},
			dom: '<"dt-toolbar"lf>rt<"dt-footer"ip>'
		});
	}
});
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
		<table id="assignCropTable" border="1" width="100%" class="tbl-data" cellspacing="0">
			<thead>
			<tr>
				<th>Sr. No.</th>
				<th>Date</th>
				<th>Site</th>
				<th>Crop</th>
				<th>Action</th>
			</tr>
			</thead>
			<tbody>
			<%
				int cnt = 0;
				AssignCropToSiteService cropToSiteService=new AssignCropToSiteService();
				List<AssignCropToSiteEntity> cropToSiteEntities=cropToSiteService.getListOFAssignCropToSite();
				for(AssignCropToSiteEntity cropToSiteEntity:cropToSiteEntities){
					if(cropToSiteEntity==null) continue;
					cnt++;
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
					String assignDate = FarmUtility.convertfrom_yymmddToddmmyy(cropToSiteEntity.getCropAssignDate().toString());
			%>
			<tr align="center" onclick="showEdit(this)"
				data-id="<%=cropToSiteEntity.getAssignCroptoSiteId()%>"
				data-site-info-id="<%=cropToSiteEntity.getSiteInformationEntity().getSiteInfoId()%>"
				data-crop-id="<%=cropId%>"
				data-date="<%=assignDate%>">
				<td><%=cnt%></td>
				<td><%=assignDate%></td>
				<td><%=cropToSiteEntity.getSiteInformationEntity()!=null ? cropToSiteEntity.getSiteInformationEntity().getSiteName() : ""%></td>
				<td><%=cropName!=null ? cropName : ""%></td>
				<td style="text-align:center; white-space:nowrap;">
					<button type="button" class="btn-delete" onclick="event.stopPropagation(); deleteCropToSite(<%=cropToSiteEntity.getAssignCroptoSiteId()%>)">Delete</button>
				</td>
			</tr>
			<%} %>
			</tbody>
		</table>
	</fieldset>
	<%@include file="../../footer.jsp" %>
	
</body>
</html>