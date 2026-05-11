<%@page import="com.san.farm.adminuser.entity.UserTypeEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.UserTypeService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title>Configuration: User Type</title>
<style>
	#formPanel {
		background: #f0f6ff;
		border: 1px solid #b0c8f0;
		padding: 10px 16px;
		margin-bottom: 10px;
		border-radius: 4px;
		display: inline-block;
		min-width: 420px;
	}
	#editBanner {
		display: none;
		background: #fff3cd;
		border: 1px solid #ffc107;
		color: #856404;
		padding: 4px 10px;
		border-radius: 3px;
		margin-bottom: 6px;
		font-weight: bold;
	}
	#bulkBar {
		display: none;
		background: #fdecea;
		border: 1px solid #e06060;
		padding: 6px 12px;
		border-radius: 3px;
		margin-bottom: 8px;
	}
	#formPanel label { font-weight: bold; margin-right: 6px; }
	#userType { width: 180px; padding: 3px; }

	.btn-add      { background:#007bff; color:#fff; border:none; padding:4px 12px; cursor:pointer; border-radius:3px; }
	.btn-update   { background:#28a745; color:#fff; border:none; padding:4px 12px; cursor:pointer; border-radius:3px; }
	.btn-delete   { background:#dc3545; color:#fff; border:none; padding:4px 12px; cursor:pointer; border-radius:3px; }
	.btn-cancel   { background:#6c757d; color:#fff; border:none; padding:4px 12px; cursor:pointer; border-radius:3px; }
	.btn-add:hover    { background:#0056b3; }
	.btn-update:hover { background:#1e7e34; }
	.btn-delete:hover { background:#a71d2a; }
	.btn-cancel:hover { background:#545b62; }

	.btn-row-edit       { background:#e8f0fe; border:1px solid #4a80d4; color:#1a56c4; padding:2px 8px; cursor:pointer; border-radius:2px; font-size:12px; }
	.btn-row-edit:hover { background:#c2d5f9; }

	.tbl-data th { background: #dce8ff; padding: 5px 8px; }
	.tbl-data td { padding: 4px 8px; }
	.tbl-data tr.selected-row { background: #c2d7f9 !important; font-weight: bold; }
	.tbl-data tbody tr:nth-child(even) { background: #f5f8ff; }
	.tbl-data tbody tr:hover { background: #e4edff; }
</style>
</head>
<script type="text/javascript">
	var editingRowEl = null;

	/* ---- single edit ---- */
	function editRow(id, name) {
		if (editingRowEl) editingRowEl.classList.remove('selected-row');
		editingRowEl = document.getElementById('row-' + id);
		if (editingRowEl) editingRowEl.classList.add('selected-row');

		document.getElementById('userTypeId').value = id;
		document.getElementById('userType').value   = name;

		document.getElementById('btnAdd').style.display    = 'none';
		document.getElementById('btnUpdate').style.display = 'inline-block';
		document.getElementById('btnCancel').style.display = 'inline-block';

		var banner = document.getElementById('editBanner');
		banner.style.display = 'block';
		banner.innerText     = 'Editing: ' + name;

		document.getElementById('formPanel').scrollIntoView({behavior:'smooth'});
		document.getElementById('userType').focus();
	}

	function resetForm() {
		if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
		document.getElementById('userTypeId').value        = '';
		document.getElementById('userType').value          = '';
		document.getElementById('editBanner').style.display = 'none';
		document.getElementById('btnAdd').style.display    = 'inline-block';
		document.getElementById('btnUpdate').style.display = 'none';
		document.getElementById('btnCancel').style.display = 'none';
	}

	/* ---- checkbox / select-all ---- */
	function toggleSelectAll(chk) {
		var boxes = document.querySelectorAll('input.rowChk');
		boxes.forEach(function(b) { b.checked = chk.checked; });
		updateBulkBar();
	}

	function updateBulkBar() {
		var checked = document.querySelectorAll('input.rowChk:checked');
		var bar = document.getElementById('bulkBar');
		if (checked.length > 0) {
			bar.style.display = 'block';
			document.getElementById('selCount').innerText = checked.length;
		} else {
			bar.style.display = 'none';
			document.getElementById('chkAll').checked = false;
		}
		// sync select-all state
		var all = document.querySelectorAll('input.rowChk');
		document.getElementById('chkAll').checked = (checked.length === all.length && all.length > 0);
	}

	/* ---- bulk delete ---- */
	function deleteSelected() {
		var checked = document.querySelectorAll('input.rowChk:checked');
		if (checked.length === 0) return;
		if (!confirm('Delete ' + checked.length + ' selected record(s)?')) return;

		var form = document.getElementById('frmBulkDelete');
		// clear any previous inputs
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
</script>
<body>
	<%-- <%@include file="../../header.jsp" %> --%>
	<fieldset><legend>User Type</legend>

		<%-- Add / Edit form --%>
		<form method="post" id="frmUserType">
			<input type="hidden" name="userTypeId" id="userTypeId">
			<div id="formPanel">
				<div id="editBanner"></div>
				<label for="userType">User Type:</label>
				<input type="text" name="userType" id="userType" required placeholder="Enter user type name">
				&nbsp;
				<input type="submit" class="btn-add"    id="btnAdd"    name="add"  value="Add"    onclick="this.form.action='../../UserTypeController'">
				<input type="submit" class="btn-update" id="btnUpdate" name="edit" value="Update" style="display:none" onclick="this.form.action='../../UserTypeController'">
				<input type="button" class="btn-cancel" id="btnCancel"              value="Cancel" style="display:none" onclick="resetForm()">
			</div>
		</form>

		<%-- Bulk delete bar --%>
		<div id="bulkBar">
			<span id="selCount">0</span> record(s) selected &nbsp;
			<button type="button" class="btn-delete" onclick="deleteSelected()">Delete Selected</button>
			&nbsp;
			<button type="button" class="btn-cancel" onclick="
				document.querySelectorAll('input.rowChk').forEach(function(b){b.checked=false;});
				document.getElementById('chkAll').checked=false;
				document.getElementById('bulkBar').style.display='none';">
				Clear Selection
			</button>
		</div>

		<%-- Hidden form used only for bulk delete POST --%>
		<form method="post" id="frmBulkDelete" action="../../UserTypeController"></form>

		<table border="1" width="100%" class="tbl-data" cellspacing="0">
			<thead>
				<tr>
					<th width="4%" title="Select All">
						<input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)">
					</th>
					<th width="8%">Id</th>
					<th>User Type</th>
					<th width="18%">Actions</th>
				</tr>
			</thead>
			<tbody>
				<%
					UserTypeService userTypeModel = new UserTypeService();
					List<UserTypeEntity> list = userTypeModel.fetch();
					for (UserTypeEntity entity : list) {
						String escapedName = entity.getUserType() != null
							? entity.getUserType().replace("'", "\\'") : "";
				%>
				<tr id="row-<%=entity.getUserTypeId()%>">
					<td style="text-align:center;">
						<input type="checkbox" class="rowChk" value="<%=entity.getUserTypeId()%>" onchange="updateBulkBar()">
					</td>
					<td><%=entity.getUserTypeId()%></td>
					<td><%=entity.getUserType()%></td>
					<td style="text-align:center;">
						<button type="button" class="btn-row-edit"
							onclick="editRow(<%=entity.getUserTypeId()%>, '<%=escapedName%>')">Edit</button>
					</td>
				</tr>
				<%} %>
			</tbody>
		</table>
	</fieldset>
	<%-- <%@include file="../../footer.jsp" %> --%>
</body>
</html>
