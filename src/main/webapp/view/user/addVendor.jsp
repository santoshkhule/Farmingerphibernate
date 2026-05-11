<%@page import="com.san.farm.adminuser.entity.VendorEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.VendorService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title>Vendor</title>
<style>
	#formPanel {
		background:#f0f6ff; border:1px solid #b0c8f0;
		padding:12px 16px; margin-bottom:10px;
		border-radius:4px; display:inline-block; min-width:460px;
	}
	#editBanner {
		display:none; background:#fff3cd; border:1px solid #ffc107;
		color:#856404; padding:4px 10px; border-radius:3px;
		margin-bottom:8px; font-weight:bold;
	}
	#bulkBar {
		display:none; background:#fdecea; border:1px solid #e06060;
		padding:6px 12px; border-radius:3px; margin-bottom:8px;
	}
	#formPanel label { font-weight:bold; display:inline-block; width:140px; text-align:right; margin-right:6px; }
	#formPanel input[type=text], #formPanel textarea { width:220px; padding:3px; }
	#formPanel textarea { height:50px; resize:vertical; }
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
	.form-row { margin-bottom:6px; }
	.form-btns { text-align:center; margin-top:8px; }
</style>
</head>
<script type="text/javascript">
	var editingRowEl = null;

	function editRow(id, vendorName, shopName, perContactNo, ofcContactNo, address, emailId) {
		if (editingRowEl) editingRowEl.classList.remove('selected-row');
		editingRowEl = document.getElementById('row-' + id);
		if (editingRowEl) editingRowEl.classList.add('selected-row');

		document.getElementById('vendorId').value      = id;
		document.getElementById('vendorName').value    = vendorName;
		document.getElementById('shopName').value      = shopName;
		document.getElementById('perContactNo').value  = perContactNo;
		document.getElementById('ofcContactNo').value  = ofcContactNo;
		document.getElementById('address').value       = address;
		document.getElementById('emailId').value       = emailId;

		document.getElementById('btnAdd').style.display    = 'none';
		document.getElementById('btnUpdate').style.display = 'inline-block';
		document.getElementById('btnCancel').style.display = 'inline-block';

		var banner = document.getElementById('editBanner');
		banner.style.display = 'block';
		banner.innerText = 'Editing: ' + vendorName;

		document.getElementById('formPanel').scrollIntoView({behavior:'smooth'});
		document.getElementById('vendorName').focus();
	}

	function resetForm() {
		if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
		document.getElementById('vendorId').value          = '';
		document.getElementById('vendorName').value        = '';
		document.getElementById('shopName').value          = '';
		document.getElementById('perContactNo').value      = '';
		document.getElementById('ofcContactNo').value      = '';
		document.getElementById('address').value           = '';
		document.getElementById('emailId').value           = '';
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
<%@include file="../../header.jsp"%>
<fieldset><legend>Vendor</legend>

	<form method="post" id="frmVendor" action="../../VendorController">
		<input type="hidden" name="vendorId" id="vendorId">
		<div id="formPanel">
			<div id="editBanner"></div>
			<div class="form-row"><label for="vendorName">Vendor Name:</label><input type="text" name="vendorName" id="vendorName" required placeholder="Enter vendor name"></div>
			<div class="form-row"><label for="shopName">Shop Name:</label><input type="text" name="shopName" id="shopName" placeholder="Enter shop name"></div>
			<div class="form-row"><label for="perContactNo">Personal Contact:</label><input type="text" name="perContactNo" id="perContactNo" placeholder="Personal number"></div>
			<div class="form-row"><label for="ofcContactNo">Shop Contact:</label><input type="text" name="ofcContactNo" id="ofcContactNo" placeholder="Shop number"></div>
			<div class="form-row"><label for="address">Address:</label><textarea name="address" id="address" placeholder="Enter address"></textarea></div>
			<div class="form-row"><label for="emailId">Email Id:</label><input type="text" name="emailId" id="emailId" placeholder="Enter email"></div>
			<div class="form-btns">
				<input type="submit" class="btn-add"    id="btnAdd"    name="add"  value="Add">
				<input type="submit" class="btn-update" id="btnUpdate" name="edit" value="Update" style="display:none">
				<input type="button" class="btn-cancel" id="btnCancel"              value="Cancel" style="display:none" onclick="resetForm()">
			</div>
		</div>
	</form>

	<div id="bulkBar">
		<span id="selCount">0</span> record(s) selected &nbsp;
		<button type="button" class="btn-delete" onclick="deleteSelected()">Delete Selected</button>
		&nbsp;
		<button type="button" class="btn-cancel" onclick="clearSelection()">Clear Selection</button>
	</div>

	<form method="post" id="frmBulkDelete" action="../../VendorController"></form>

	<table border="1" width="100%" class="tbl-data" cellspacing="0">
		<thead>
			<tr>
				<th width="3%"><input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)" title="Select All"></th>
				<th width="5%">Id</th>
				<th>Vendor Name</th>
				<th>Shop Name</th>
				<th>Personal No.</th>
				<th>Shop No.</th>
				<th>Address</th>
				<th>Email Id</th>
				<th width="8%">Actions</th>
			</tr>
		</thead>
		<tbody>
			<%
				VendorService vendorService = new VendorService();
				List<VendorEntity> vendorList = vendorService.fetch();
				for (VendorEntity vendor : vendorList) {
					String eVendorName   = vendor.getVendorName()   != null ? vendor.getVendorName().replace("'", "\\'")   : "";
					String eShopName     = vendor.getShopName()     != null ? vendor.getShopName().replace("'", "\\'")     : "";
					String ePerContact   = vendor.getPerContactNo() != null ? vendor.getPerContactNo().replace("'", "\\'") : "";
					String eOfcContact   = vendor.getOfcContactNo() != null ? vendor.getOfcContactNo().replace("'", "\\'") : "";
					String eAddress      = vendor.getAddress()      != null ? vendor.getAddress().replace("'", "\\'").replace("\n", " ").replace("\r", "") : "";
					String eEmailId      = vendor.getEmailId()      != null ? vendor.getEmailId().replace("'", "\\'")      : "";
			%>
			<tr id="row-<%=vendor.getVendorId()%>">
				<td style="text-align:center;"><input type="checkbox" class="rowChk" value="<%=vendor.getVendorId()%>" onchange="updateBulkBar()"></td>
				<td><%=vendor.getVendorId()%></td>
				<td><%=vendor.getVendorName() != null ? vendor.getVendorName() : ""%></td>
				<td><%=vendor.getShopName() != null ? vendor.getShopName() : ""%></td>
				<td><%=vendor.getPerContactNo() != null ? vendor.getPerContactNo() : ""%></td>
				<td><%=vendor.getOfcContactNo() != null ? vendor.getOfcContactNo() : ""%></td>
				<td><%=vendor.getAddress() != null ? vendor.getAddress() : ""%></td>
				<td><%=vendor.getEmailId() != null ? vendor.getEmailId() : ""%></td>
				<td style="text-align:center;">
					<button type="button" class="btn-row-edit"
						onclick="editRow(<%=vendor.getVendorId()%>,'<%=eVendorName%>','<%=eShopName%>','<%=ePerContact%>','<%=eOfcContact%>','<%=eAddress%>','<%=eEmailId%>')">Edit</button>
				</td>
			</tr>
			<%} %>
		</tbody>
	</table>
</fieldset>
<%@include file="../../footer.jsp"%>
</body>
</html>
