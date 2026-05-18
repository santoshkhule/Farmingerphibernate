<%@page import="com.san.farm.adminuser.dao.PaymentProcessingDao"%>
<%@page import="com.san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%@ include file="../../userPerms.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= msg.getString("task.view_all.fieldset_title") %></title>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<script src="../../js/jquery-ui.js"></script>
<style>
    /* ── responsive filter bar ── */
    .filter-bar {
        display: flex;
        flex-wrap: wrap;
        gap: 8px 14px;
        align-items: flex-end;
        padding: 6px 0 10px;
    }
    .filter-item { display: flex; flex-direction: column; gap: 3px; }
    .filter-item label {
        font-size: 10px; font-weight: 700; text-transform: uppercase;
        letter-spacing: .5px; color: var(--text-muted, #666); white-space: nowrap;
    }
    .filter-item input[type="text"],
    .filter-item select {
        border: 1px solid #ccc; border-radius: var(--r-sm, 3px);
        padding: 5px 8px; font-size: 12px; width: 140px; box-sizing: border-box;
    }
    .filter-item input[type="text"]:focus,
    .filter-item select:focus {
        outline: none; border-color: var(--green-dk);
        box-shadow: 0 0 0 2px rgba(56,142,60,.12);
    }

    /* ── table scroll: single CSS overflow, no DataTables scrollX ── */
    #showTable { width: 100%; overflow-x: auto; -webkit-overflow-scrolling: touch; }
    #showTable table.tbl-data { min-width: 860px; width: 100%; font-size: 11px; }
    #showTable table.tbl-data th {
        white-space: nowrap; padding: 7px 7px; font-size: 10px;
        background: var(--green-lt, #e8f5e9); color: var(--green-dk, #1b5e20);
    }
    #showTable table.tbl-data td { padding: 5px 7px; vertical-align: middle; }

    /* fixed-width compact columns */
    #showTable table.tbl-data th:nth-child(1),
    #showTable table.tbl-data td:nth-child(1) { width: 28px; text-align: center; }
    #showTable table.tbl-data th:nth-child(2),
    #showTable table.tbl-data td:nth-child(2) { width: 32px; text-align: center; }
    #showTable table.tbl-data th:nth-child(4),
    #showTable table.tbl-data td:nth-child(4) { width: 78px; white-space: nowrap; }
    #showTable table.tbl-data th:nth-child(8),
    #showTable table.tbl-data td:nth-child(8) { text-align: center; }
    #showTable table.tbl-data th:nth-child(10),
    #showTable table.tbl-data td:nth-child(10),
    #showTable table.tbl-data th:nth-child(11),
    #showTable table.tbl-data td:nth-child(11),
    #showTable table.tbl-data th:nth-child(12),
    #showTable table.tbl-data td:nth-child(12) { width: 68px; text-align: right; white-space: nowrap; }
    #showTable table.tbl-data th:nth-child(13),
    #showTable table.tbl-data td:nth-child(13) { width: 90px; text-align: center; white-space: nowrap; }

    /* ── status pill badges ── */
    .ws-pill { padding: 1px 8px; border-radius: 10px; font-size: 10px; font-weight: 700; display: inline-block; }
    .ws-Completed { background: #e8f5e9; color: #2e7d32; }
    .ws-Pending   { background: #fff3e0; color: #e65100; }
    .ws-Reject    { background: #fdecea; color: #c62828; }

    /* compact action buttons inside table rows */
    #showTable .btn-row-edit { padding: 3px 8px; font-size: 11px; }
    #showTable .btn-update   { padding: 3px 8px; font-size: 11px; }

    /* dt-toolbar stretches full width */
    .dataTables_wrapper { width: 100%; }
</style>
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
		var fromDate    = document.getElementById("txtDate").value;
		var empName     = document.getElementById("txtName").value;
		var work_status = document.getElementById("work_status").value;
		var work_Id     = document.getElementById("selWorkId").value;
		if (window.XMLHttpRequest) { xmlhttp = new XMLHttpRequest(); }
		else { xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); }
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				var tbl = $('#showTable table.tbl-data');
				if (tbl.length && $.fn.DataTable.isDataTable(tbl)) { tbl.DataTable().destroy(); }
				document.getElementById("showTable").innerHTML = xmlhttp.responseText;
				clearSelection();
				initAssignTable();
			}
		};
		var url = "01assignTaskToEmployeeViewAllAjax.jsp?fromDate=" + fromDate
				+ "&empName=" + empName + "&workStatus=" + work_status + "&taskId=" + work_Id;
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}

	function actionRowNav(id, action) {
		if (action == "edit") {
			window.location = "../../AssignResourcesController?sbtEdit=Edit&radAssignWorkId=" + id;
		} else if (action == "view") {
			window.location = "../../AssignResourcesController?sbtView=View&radAssignWorkId=" + id;
		}
	}

	function toggleSelectAll(chk) {
		document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = chk.checked; });
		updateBulkBar();
	}
	function updateBulkBar() {
		var checked = document.querySelectorAll('input.rowChk:checked');
		var all     = document.querySelectorAll('input.rowChk');
		document.getElementById('bulkBar').style.display = checked.length > 0 ? 'block' : 'none';
		document.getElementById('selCount').innerText    = checked.length;
		var chkAll = document.getElementById('chkAll');
		if (chkAll) chkAll.checked = (checked.length === all.length && all.length > 0);
	}
	function clearSelection() {
		document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = false; });
		var chkAll = document.getElementById('chkAll');
		if (chkAll) chkAll.checked = false;
		document.getElementById('bulkBar').style.display = 'none';
	}
	function deleteSelected() {
		var checked = document.querySelectorAll('input.rowChk:checked');
		if (checked.length === 0) return;
		if (!confirm('Delete ' + checked.length + ' selected record(s)?')) return;
		var form = document.getElementById('frmBulkDelete');
		form.innerHTML = '';
		checked.forEach(function(b) {
			var inp = document.createElement('input');
			inp.type = 'hidden'; inp.name = 'deleteIds'; inp.value = b.value;
			form.appendChild(inp);
		});
		var flag = document.createElement('input');
		flag.type = 'hidden'; flag.name = 'deleteSelected'; flag.value = '1';
		form.appendChild(flag);
		form.submit();
	}

	function initAssignTable() {
		var tbl = $('#showTable table.tbl-data');
		if (tbl.length && !$.fn.DataTable.isDataTable(tbl)) {
			tbl.DataTable({
				pageLength: 25,
				lengthMenu: [[10, 25, 50, -1], [10, 25, 50, 'All']],
				autoWidth: false,
				columnDefs: [{ orderable: false, targets: [0, 12] }],
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
	<fieldset>
		<legend><%= msg.getString("task.view_all.fieldset_title") %></legend>

		<!-- ── filter bar ── -->
		<div class="filter-bar">
			<div class="filter-item">
				<label for="txtDate"><%= msg.getString("task.view_all.filter_label_date") %></label>
				<input type="text" name="txtDate" id="txtDate"
					pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
					oninvalid="setCustomValidity('Enter Date: Select From Calender')"
					title="Select Date" placeholder="dd/mm/yyyy"
					onchange="showAllEmployeeByFilterId()">
			</div>
			<div class="filter-item">
				<label for="txtName"><%= msg.getString("task.view_all.filter_label_name") %></label>
				<input type="text" name="txtName" id="txtName"
					placeholder="Search name…" oninput="showAllEmployeeByFilterId()">
			</div>
			<div class="filter-item">
				<label for="selWorkId"><%= msg.getString("task.view_all.filter_label_work") %></label>
				<select name="selWorkId" id="selWorkId" onchange="showAllEmployeeByFilterId()">
					<option value="-1">All</option>
					<%
						ConfigFarmTaskService farmTaskService = new ConfigFarmTaskService();
						List<ConfigFarmTaskEntity> taskEntities = farmTaskService.fetch();
						for (ConfigFarmTaskEntity taskEntity : taskEntities) {
					%>
					<option value="<%=taskEntity.getTaskId()%>"><%=taskEntity.getTaskName()%></option>
					<%} %>
				</select>
			</div>
			<div class="filter-item">
				<label for="work_status"><%= msg.getString("task.view_all.filter_label_status") %></label>
				<select name="work_status" id="work_status" onchange="showAllEmployeeByFilterId()">
					<option value="-1">All</option>
					<option value="Completed"><%= msg.getString("task.view_all.filter_status_completed") %></option>
					<option value="Pending"><%= msg.getString("task.view_all.filter_status_pending") %></option>
					<option value="Reject"><%= msg.getString("task.view_all.filter_status_rejected") %></option>
				</select>
			</div>
			<div class="filter-item" style="align-self:flex-end;">
				<button type="button" class="btn-cancel" onclick="clearAllFilters()"><%= msg.getString("btn.clear_filters") %></button>
			</div>
		</div>
		<hr>

		<!-- ── bulk-delete bar ── -->
		<div id="bulkBar" style="display:none; background:#fdecea; border:1px solid #e06060; padding:6px 12px; border-radius:3px; margin-bottom:8px;">
			<span id="selCount">0</span> record(s) selected &nbsp;
			<% if (_isAdmin || !_hasRolePerms || _perms.contains("farm_view_tasks.delete")) { %>
			<button type="button" class="btn-delete" onclick="deleteSelected()"><%= msg.getString("btn.delete") %> Selected</button>
			<% } %>
			&nbsp;
			<button type="button" class="btn-cancel" onclick="clearSelection()"><%= msg.getString("btn.clear") %> Selection</button>
		</div>
		<form method="post" id="frmBulkDelete" action="../../AssignResourcesController"></form>

		<!-- ── data table ── -->
		<div id="showTable">
			<table border="1" width="100%" class="tbl-data" cellspacing="0">
				<thead>
				<tr>
					<th><input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)"></th>
					<th><%= msg.getString("tbl.col_number") %></th>
					<th><%= msg.getString("tbl.col_name") %></th>
					<th><%= msg.getString("tbl.col_date") %></th>
					<th><%= msg.getString("tbl.col_site") %></th>
					<th><%= msg.getString("tbl.col_crop") %></th>
					<th><%= msg.getString("task.view_all.tbl_col_work_type") %></th>
					<th><%= msg.getString("tbl.col_status") %></th>
					<th><%= msg.getString("task.view_all.tbl_col_tasks") %></th>
					<th><%= msg.getString("tbl.col_amount") %></th>
					<th><%= msg.getString("task.view_all.tbl_col_paid") %></th>
					<th><%= msg.getString("task.view_all.tbl_col_balance") %></th>
					<th><%= msg.getString("tbl.col_actions") %></th>
				</tr>
				</thead>
				<tbody>
				<%
					AssignResourceEmployeeToFarmService employeeToFarmService = new AssignResourceEmployeeToFarmService();
					PaymentProcessingDao salaryProcessingDao = new PaymentProcessingDao();
					List<AssignEmployeeToFarmEntity> employeeToFarmEntities = null;
					int cnt = 0;
					try {
						employeeToFarmEntities = employeeToFarmService.getListOFEmployeeToFarm();
						for (AssignEmployeeToFarmEntity employeeToFarm : employeeToFarmEntities) {
							if (employeeToFarm != null) {
								cnt++;
				%>
				<tr id="rowId<%=cnt%>">
					<td><input type="checkbox" class="rowChk" value="<%=employeeToFarm.getAssignResourceId()%>" onchange="updateBulkBar()"></td>
					<td><%=cnt%></td>
					<td><%
						if (employeeToFarm.getEmployeeInfoEntity() != null) {
							if (employeeToFarm.getEmployeeInfoEntity().getFirstName() != null)
								out.print(employeeToFarm.getEmployeeInfoEntity().getFirstName() + " ");
							if (employeeToFarm.getEmployeeInfoEntity().getMiddleName() != null)
								out.print(employeeToFarm.getEmployeeInfoEntity().getMiddleName() + " ");
							if (employeeToFarm.getEmployeeInfoEntity().getLastName() != null)
								out.print(employeeToFarm.getEmployeeInfoEntity().getLastName());
						}
					%></td>
					<td><%
						if (employeeToFarm.getAssignWorkDate() != null)
							out.print(FarmUtility.convertfrom_yymmddToddmmyy(employeeToFarm.getAssignWorkDate().toString()));
					%></td>
					<td><%
						if (employeeToFarm.getCropToSiteEntity() != null
								&& employeeToFarm.getCropToSiteEntity().getSiteInformationEntity() != null
								&& employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName() != null)
							out.print(employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName());
					%></td>
					<td><%
						if (employeeToFarm.getCropEntity() != null && employeeToFarm.getCropEntity().getCropName() != null)
							out.print(employeeToFarm.getCropEntity().getCropName());
					%></td>
					<td><%
						if (employeeToFarm.getTypeOfWork() != null)
							out.print(employeeToFarm.getTypeOfWork());
					%></td>
					<td><%
						String ws = employeeToFarm.getWorkStatus();
						if (ws != null && !ws.isEmpty()) {
					%><span class="ws-pill ws-<%=ws%>"><%=ws%></span><%
						}
					%></td>
					<td><%
						int i = 0;
						for (ConfigFarmTaskEntity taskToEmployee : employeeToFarm.getListFarmTaskEntities()) {
							if (i++ > 0) out.print(", ");
							out.print(taskToEmployee.getTaskName());
						}
					%></td>
					<%
						double totalSalaryPaid = salaryProcessingDao.getTotalSalaryPaidByAssignResourceId(employeeToFarm.getAssignResourceId());
						double totalPaid = employeeToFarm.getAdvPayment() + totalSalaryPaid;
						double balanceAmount = employeeToFarm.getAmount() - totalPaid;
						if (balanceAmount < 0) balanceAmount = 0;
					%>
					<td><%=employeeToFarm.getAmount()%></td>
					<td><%=totalSalaryPaid%></td>
					<td><%=balanceAmount%></td>
					<td>
						<% if (_isAdmin || !_hasRolePerms || _perms.contains("farm_view_tasks.edit")) { %>
						<button type="button" class="btn-row-edit" onclick="actionRowNav(<%=employeeToFarm.getAssignResourceId()%>,'edit')"><%= msg.getString("btn.edit") %></button>
						<% } %>
						<button type="button" class="btn-update"   onclick="actionRowNav(<%=employeeToFarm.getAssignResourceId()%>,'view')">View</button>
					</td>
				</tr>
				<%
							}
						}
					} catch (Exception ex) {
						ex.printStackTrace();
					}
				%>
				</tbody>
			</table>
		</div>
	</fieldset>
	<%@include file="../../footer.jsp"%>
</body>
</html>
