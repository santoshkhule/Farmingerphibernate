
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.dao.SalaryProcessingDao"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<link rel="stylesheet" href="../../css/style.css">
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<script src="../../js/jquery-ui.js"></script>
<title>View Employee To Salary Process</title>
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
	function processSalary(assignResourceId){
		var iframe = parent.document.querySelector('iframe[name="iframSalProcess"]');
		if (iframe) {
			iframe.src = '02SalaryProcessing.jsp?assignResourceId=' + assignResourceId;
		}
	}
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
	var fromDate=document.getElementById("txtDate").value;
	var empName=document.getElementById("txtName").value;
	var work_status=document.getElementById("work_status").value;
	var work_Id=document.getElementById("selWorkId").value;
	if (window.XMLHttpRequest) { xmlhttp = new XMLHttpRequest(); }
	else { xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); }
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			var tbl = $('#showTable table.tbl-data');
			if (tbl.length && $.fn.DataTable.isDataTable(tbl)) { tbl.DataTable().destroy(); }
			document.getElementById("showTable").innerHTML = xmlhttp.responseText;
			initSalaryTable();
		}
	};
	var url = "001ViewEmployeeForSalaryProcessAjax.jsp?fromDate="+fromDate+"&empName="+empName+"&work_status="+work_status+"&work_Id="+work_Id;
	xmlhttp.open("GET", url, true);
	xmlhttp.send();
}
function initSalaryTable() {
	var tbl = $('#showTable table.tbl-data');
	if (tbl.length && !$.fn.DataTable.isDataTable(tbl)) {
		tbl.DataTable({
			pageLength: 25,
			lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
			autoWidth: false,
			columnDefs: [{ orderable: false, targets: [0] }],
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
$(document).ready(function() { initSalaryTable(); });
</script>
<body>
	<%
		double ttlAmountToPay = 0;
		double ttlAmountPaid = 0;
		double ttlAdvancedPaid = 0;
		double ttlBalance = 0, ttlExcessAmount = 0;
		int assignWorkId = 0;
		if (null != request.getParameter("assignWorkId")) {
			assignWorkId = Integer.parseInt(request
					.getParameter("assignWorkId"));
		}
	%>
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
						try {
							ConfigFarmTaskService farmTaskService = new ConfigFarmTaskService();
							List<ConfigFarmTaskEntity> taskList = farmTaskService.fetch();
							for (ConfigFarmTaskEntity taskEntity : taskList) {
					%>
					<option value="<%=taskEntity.getTaskId()%>"><%=taskEntity.getTaskName()%></option>
					<%
							}
						} catch (Exception ex) {
							ex.printStackTrace();
						}
					%>
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
	<div id="showTable">
		<table border="1" cellspacing="0" width="100%" class="tbl-data">
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
				<th>Advanced Paid</th>
				<th>Amount Paid</th>
				<th>Balance</th>
				<th>Excess Amount</th>
			</tr>
			</thead>
			<tbody>
				<%
					try {

						int cnt = 0;
						AssignResourceEmployeeToFarmService employeeToFarmService=new AssignResourceEmployeeToFarmService();
						SalaryProcessingDao salaryProcessingDao = new SalaryProcessingDao();
						List<AssignEmployeeToFarmEntity> employeeToFarmEntities=employeeToFarmService.getListOFEmployeeToFarm();
						for(AssignEmployeeToFarmEntity employeeToFarm:employeeToFarmEntities){
						cnt++;
						int assignResourceId = employeeToFarm.getAssignResourceId();
				%>
				<tr>
					<td><input type="radio" name="radAssignWorkId"
						id="radAssignWorkId" value="" required="required"
						onclick="processSalary(<%=assignResourceId%>);"></td>
					<td><%=cnt %></td>
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
							double totalSalaryPaid = salaryProcessingDao.getTotalSalaryPaidByAssignResourceId(assignResourceId);
							double totalPaid       = employeeToFarm.getAdvPayment() + totalSalaryPaid;
							double excessAmount    = 0;
							double balanceAmount   = employeeToFarm.getAmount() - totalPaid;
							if (balanceAmount < 0) {
								excessAmount = -balanceAmount;
								balanceAmount = 0;
							}
							ttlAmountToPay  += employeeToFarm.getAmount();
							ttlAdvancedPaid += employeeToFarm.getAdvPayment();
							ttlAmountPaid   += totalSalaryPaid;
							ttlBalance      += balanceAmount;
							ttlExcessAmount += excessAmount;
						%>
						<td><%=employeeToFarm.getAmount()%></td>
						<td><%=employeeToFarm.getAdvPayment()%></td>
						<td><%=totalSalaryPaid%></td>
						<td><%=balanceAmount%></td>
						<td><%=excessAmount%></td>
				</tr>
					<%} %>
			<%
				} catch (Exception ex) {
					ex.printStackTrace();
				}
			%>
			</tbody>
			<tfoot>
				<tr>
					<td style="font-weight:bold; text-align:right;" colspan="9">Total</td>
					<td><b><%=ttlAmountToPay%></b></td>
					<td><b><%=ttlAdvancedPaid%></b></td>
					<td><b><%=ttlAmountPaid%></b></td>
					<td><b><%=ttlBalance%></b></td>
					<td><b><%=ttlExcessAmount%></b></td>
				</tr>
			</tfoot>
		</table>
	</div>

</body>
</html>