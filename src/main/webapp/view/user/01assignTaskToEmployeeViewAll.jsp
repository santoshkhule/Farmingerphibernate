<%@page import="com.san.farm.adminuser.dao.SalaryProcessingDao"%>
<%@page import="com.san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>View All Assign Task</title>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<script src="../../js/jquery-ui.js"></script>
</head>
<script>
	$(function() {
		$("#txtDate").datepicker({
			changeMonth : true,
			changeYear : true,
			dateFormat : "dd/mm/yy"
		}).val();

	});
</script>
<script type="text/javascript">
	function clearAllFilters() {
		document.getElementById("txtDate").value = "";
		document.getElementById("txtName").value = "";
		document.getElementById("work_status").value = "-1";
		document.getElementById("selWorkId").value = "-1";
		showAllEmployeeByFilterId();
	}
	function showAllEmployeeByFilterId() {
		var fromDate = document.getElementById("txtDate").value;		
		var empName = document.getElementById("txtName").value;
		var work_status = document.getElementById("work_status").value;
		var work_Id = document.getElementById("selWorkId").value;
		//alert(fromDate+" "+empName+" "+work_status+" "+work_Id);
		if (window.XMLHttpRequest) {
			xmlhttp = new XMLHttpRequest();
		} else {
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				var tbl = $('#showTable table.tbl-data');
				if (tbl.length && $.fn.DataTable.isDataTable(tbl)) {
					tbl.DataTable().destroy();
				}
				document.getElementById("showTable").innerHTML = xmlhttp.responseText;
				initAssignTable();
			}
		};

		var url = "01assignTaskToEmployeeViewAllAjax.jsp?fromDate=" + fromDate
				+ "&empName=" + empName + "&workStatus=" + work_status
				+ "&taskId=" + work_Id;
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}
	var tempId=-1;
	function showEditDelete(id) {
		if(tempId!=-1){
			$("#td"+tempId).hide();			
		}
		//alert(id);
		//alert($(id).find("td").eq(0).text());
		$("#td"+id).show();
		$("#th").show();
		$("#imgDelete"+id).show();
		$("#imgEdit"+id).show();
		tempId=id;
	}
	function doDelete() {
		var selected = document.querySelector('input[name="radAssignWorkId"]:checked');
		if (selected == null) {
			alert("Please select a record to delete.");
			return;
		}
		if (confirm("Are you sure you want to delete this assignment?")) {
			window.location = "../../AssignResourcesController?assignResourceId=" + selected.value + "&action=delete";
		}
	}
	function actionEditDelete(id, action) {
		if (action == "delete") {
			if (confirm("Are you sure you want to delete this assignment?")) {
				window.location = "../../AssignResourcesController?assignResourceId=" + id + "&action=delete";
			}
		}
	}
	function initAssignTable() {
		var tbl = $('#showTable table.tbl-data');
		if (tbl.length && !$.fn.DataTable.isDataTable(tbl)) {
			tbl.DataTable({
				pageLength: 25,
				lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
				autoWidth: false,
				columnDefs: [
					{ orderable: false, targets: [0, 12] }
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
	}
	$(document).ready(function() { initAssignTable(); });
</script>
<body>
	<!-- <h2>View All Employee Assign Task</h2> <hr>-->

	<fieldset style="height: 575px">
		<legend>View All Employee Assign Task</legend>
		<table>
			<tr>
				<td>Date:</td>
				<td><input type="text" name="txtDate" id="txtDate"
					pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
					oninvalid="setCustomValidity('Enter Date: Select From Calender')"
					title="Select Date" placeholder="dd/mm/yyyy"
					onchange="showAllEmployeeByFilterId()"></td>
				<td>Name:</td>
				<td><input type="text" name="txtName" id="txtName"
					oninput="showAllEmployeeByFilterId()"></td>
				<td>Work:</td>
				<td><select name="selWorkId" id="selWorkId"
					onchange="showAllEmployeeByFilterId()">
						<option value="-1">Select</option>
						<%
							ConfigFarmTaskService farmTaskService=new ConfigFarmTaskService();
							List<ConfigFarmTaskEntity> taskEntities=farmTaskService.fetch();
							for(ConfigFarmTaskEntity taskEntity:taskEntities){
						%>
						<option value="<%=taskEntity.getTaskId()%>"><%=taskEntity.getTaskName() %></option>
						<%} %>

				</select></td>
				<td style="text-align: right;">Work Status:</td>
				<td><select name="work_status" id="work_status"
					onchange="showAllEmployeeByFilterId()">
						<option value="-1">select</option>
						<option value="Completed">Completed</option>
						<option value="Pending">Pending</option>
						<option value="Reject">Reject</option>
				</select></td>
				<td><input type="button" value="Clear All" onclick="clearAllFilters()"></td>
			</tr>
		</table>
		<hr>
		<form method="post">
			<table>
				<tr>
					<td><input type="submit" name="sbtEdit" value="Edit"
						onclick="this.form.action='../../AssignResourcesController'"></td>
					<td><input type="submit" name="sbtView" value="View"
						onclick="this.form.action='../../AssignResourcesController'"></td>
					<td><input type="button" name="sbtDelete" value="Delete" onclick="doDelete()"></td>
				</tr>
			</table>
			<div id="showTable">
				<table border="1" width="100%" class="tbl-data" cellspacing="0">
					<thead>
					<tr>
						<th>Select</th>
						<th>Sr. No.</th>
						<th>Name</th>
						<th>Date</th>
						<th>Site Name</th>
						<th>Crop Name</th>
						<th>Work Type</th>
						<th>Work Status</th>
						<th>Assign Work</th>
						<th>Amount To Pay</th>
						<th>Paid</th>
						<th>Balance</th>
						<th>Action</th>
					</tr>
					</thead>
					<tbody>
					<%
						AssignResourceEmployeeToFarmService employeeToFarmService=new AssignResourceEmployeeToFarmService();
						SalaryProcessingDao salaryProcessingDao=new SalaryProcessingDao();
						List<AssignEmployeeToFarmEntity> employeeToFarmEntities=null;
						int cnt = 0;
						try {
							employeeToFarmEntities=employeeToFarmService.getListOFEmployeeToFarm();
							for(AssignEmployeeToFarmEntity employeeToFarm:employeeToFarmEntities){
								if(employeeToFarm!=null){
							cnt++;
					%>
					<tr id="rowId<%=cnt%>" ondblclick="showEditDelete(<%=cnt%>)">
						<td><input type="radio" name="radAssignWorkId"
							id="radAssignWorkId" value="<%=employeeToFarm.getAssignResourceId()%>"></td>
						<td><%=cnt%></td>
						<td>
							<%
								if(employeeToFarm.getEmployeeInfoEntity()!=null){
									if(employeeToFarm.getEmployeeInfoEntity().getFirstName()!=null){
										out.print(employeeToFarm.getEmployeeInfoEntity().getFirstName()+" ");
									}
									if(employeeToFarm.getEmployeeInfoEntity().getMiddleName()!=null){
										out.print(employeeToFarm.getEmployeeInfoEntity().getMiddleName()+" ");
									}
									if(employeeToFarm.getEmployeeInfoEntity().getLastName()!=null){
										out.print(employeeToFarm.getEmployeeInfoEntity().getLastName());
									}
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getAssignWorkDate()!=null){
									out.println(FarmUtility.convertfrom_yymmddToddmmyy(employeeToFarm.getAssignWorkDate().toString()));
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getCropToSiteEntity()!=null && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity()!=null 
									&& employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName()!=null){
									out.println(employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName());
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getCropEntity()!=null && employeeToFarm.getCropEntity().getCropName()!=null){
									out.println(employeeToFarm.getCropEntity().getCropName());
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getTypeOfWork()!=null){
									out.println(employeeToFarm.getTypeOfWork());
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getWorkStatus()!=null){
									out.println(employeeToFarm.getWorkStatus());
								}
							%>
						</td>
						<td>
							<%								
								int i=0;								
								for(ConfigFarmTaskEntity taskToEmployee:employeeToFarm.getListFarmTaskEntities()){
									if(i==0){
										i++;
										out.println(taskToEmployee.getTaskName());
									}else{
										out.println(","+taskToEmployee.getTaskName());
									}
								}
							%>
						</td>						
						<%
							double totalSalaryPaid = salaryProcessingDao.getTotalSalaryPaidByAssignResourceId(employeeToFarm.getAssignResourceId());
							double totalPaid = employeeToFarm.getAdvPayment() + totalSalaryPaid;
							double balanceAmount = employeeToFarm.getAmount() - totalPaid;
							if (balanceAmount < 0) { balanceAmount = 0; }
						%>
						<td><%=employeeToFarm.getAmount()%></td>
						<td><%=totalSalaryPaid%></td>
						<td><%=balanceAmount%></td>
						<td style="text-align:center; white-space:nowrap;">
							<button type="button" class="btn-row-edit" onclick="actionEditDelete(<%=employeeToFarm.getAssignResourceId()%>,'edit')">Edit</button>
							<button type="button" class="btn-delete" onclick="actionEditDelete(<%=employeeToFarm.getAssignResourceId()%>,'delete')">Delete</button>
						</td>
					</tr>
					<%
								}//if end
							}//for end
						} catch (Exception ex) {
							ex.printStackTrace();
						}
					%>
					</tbody>
				</table>
			</div>
		</form>
	</fieldset>
	<%@include file="../../footer.jsp"%>
</body>
</html>