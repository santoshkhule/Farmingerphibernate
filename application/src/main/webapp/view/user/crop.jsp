<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.ConfigCropService"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title><%= msg.getString("crop.page_title") %></title>
<style>
	#formPanel {
		background:#f0f6ff; border:1px solid #b0c8f0;
		padding:10px 16px; margin-bottom:10px;
		border-radius:4px; display:inline-block; min-width:380px;
	}
	#editBanner {
		display:none; background:#fff3cd; border:1px solid #ffc107;
		color:#856404; padding:4px 10px; border-radius:3px;
		margin-bottom:6px; font-weight:bold;
	}
	#bulkBar {
		display:none; background:#fdecea; border:1px solid #e06060;
		padding:6px 12px; border-radius:3px; margin-bottom:8px;
	}
	#formPanel label { font-weight:bold; margin-right:6px; }
	#cropName { width:180px; padding:3px; }
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
	.tbl-data th { background:#dce8ff; padding:5px 8px; }
	.tbl-data td { padding:4px 8px; }
	.tbl-data tr.selected-row { background:#c2d7f9 !important; font-weight:bold; }
	.tbl-data tbody tr:nth-child(even) { background:#f5f8ff; }
	.tbl-data tbody tr:hover { background:#e4edff; }
</style>
</head>
<script type="text/javascript">
	var editingRowEl = null;

	function editRow(id, name) {
		if (editingRowEl) editingRowEl.classList.remove('selected-row');
		editingRowEl = document.getElementById('row-' + id);
		if (editingRowEl) editingRowEl.classList.add('selected-row');

		document.getElementById('cropId').value   = id;
		document.getElementById('cropName').value = name;

		document.getElementById('btnAdd').style.display    = 'none';
		document.getElementById('btnUpdate').style.display = 'inline-block';
		document.getElementById('btnCancel').style.display = 'inline-block';

		var banner = document.getElementById('editBanner');
		banner.style.display = 'block';
		banner.innerText = 'Editing: ' + name;

		document.getElementById('formPanel').scrollIntoView({behavior:'smooth'});
		document.getElementById('cropName').focus();
	}

	function resetForm() {
		if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
		document.getElementById('cropId').value            = '';
		document.getElementById('cropName').value          = '';
		document.getElementById('editBanner').style.display = 'none';
		document.getElementById('btnAdd').style.display    = 'inline-block';
		document.getElementById('btnUpdate').style.display = 'none';
		document.getElementById('btnCancel').style.display = 'none';
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
		document.getElementById('chkAll').checked        = (checked.length === all.length && all.length > 0);
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

	function clearSelection() {
		document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = false; });
		document.getElementById('chkAll').checked = false;
		document.getElementById('bulkBar').style.display = 'none';
	}
</script>
<body>
<fieldset><legend><%= msg.getString("crop.fieldset_title") %></legend>

	<form method="post" id="frmCrop" action="../../ConfigCropController">
		<input type="hidden" name="cropId" id="cropId">
		<div id="formPanel">
			<div id="editBanner"></div>
			<label for="cropName"><%= msg.getString("crop.label_crop_name") %>:</label>
			<input type="text" name="cropName" id="cropName" required placeholder="Enter crop name">
			&nbsp;
			<input type="submit" class="btn-add"    id="btnAdd"    name="add"  value="<%= msg.getString("btn.add") %>">
			<input type="submit" class="btn-update" id="btnUpdate" name="edit" value="<%= msg.getString("btn.update") %>" style="display:none">
			<input type="button" class="btn-cancel" id="btnCancel"              value="<%= msg.getString("btn.cancel") %>" style="display:none" onclick="resetForm()">
		</div>
	</form>

	<div id="bulkBar">
		<span id="selCount">0</span> record(s) selected &nbsp;
		<button type="button" class="btn-delete" onclick="deleteSelected()"><%= msg.getString("btn.delete") %> Selected</button>
		&nbsp;
		<button type="button" class="btn-cancel" onclick="clearSelection()"><%= msg.getString("btn.clear") %> Selection</button>
	</div>

	<form method="post" id="frmBulkDelete" action="../../ConfigCropController"></form>

	<table border="1" width="100%" class="tbl-data" cellspacing="0">
		<thead>
			<tr>
				<th width="4%"><input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)" title="<%= msg.getString("tbl.col_select_all") %>"></th>
				<th width="8%">Id</th>
				<th><%= msg.getString("crop.tbl_col_crop_name") %></th>
				<th width="10%"><%= msg.getString("tbl.col_actions") %></th>
			</tr>
		</thead>
		<tbody>
			<%
				ConfigCropService cropService = new ConfigCropService();
				List<ConfigCropEntity> cropList = cropService.fetch();
				for (ConfigCropEntity c : cropList) {
					String eName = c.getCropName() != null ? c.getCropName().replace("'","\\'") : "";
			%>
			<tr id="row-<%=c.getCropId()%>">
				<td style="text-align:center;"><input type="checkbox" class="rowChk" value="<%=c.getCropId()%>" onchange="updateBulkBar()"></td>
				<td><%=c.getCropId()%></td>
				<td><%=c.getCropName()%></td>
				<td style="text-align:center;">
					<button type="button" class="btn-row-edit"
						onclick="editRow(<%=c.getCropId()%>,'<%=eName%>')"><%= msg.getString("btn.edit") %></button>
				</td>
			</tr>
			<%} %>
		</tbody>
	</table>
</fieldset>
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/datatables.min.js"></script>
<script src="../../js/tableInit.js"></script>
</body>
</html>
