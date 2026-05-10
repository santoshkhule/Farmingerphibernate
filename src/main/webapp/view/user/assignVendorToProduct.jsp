<%@page import="com.san.farm.adminuser.entity.AssignVendorToProductEntity"%>
<%@page import="com.san.farm.adminuser.entity.VendorEntity"%>
<%@page import="com.san.farm.adminuser.entity.FertilizerEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignVendorToProductService"%>
<%@page import="com.san.farm.adminuser.dao.VendorService"%>
<%@page import="com.san.farm.adminuser.dao.FertilizerService"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title>Assign Vendor To Product</title>
<style>
	#formPanel {
		background:#f0f6ff; border:1px solid #b0c8f0;
		padding:12px 16px; margin-bottom:10px;
		border-radius:4px; display:inline-block; min-width:460px;
	}
	#bulkBar {
		display:none; background:#fdecea; border:1px solid #e06060;
		padding:6px 12px; border-radius:3px; margin-bottom:8px;
	}
	#formPanel label { font-weight:bold; display:inline-block; width:130px; text-align:right; margin-right:6px; }
	#formPanel select, #formPanel input[type=text] { width:200px; padding:3px; }
	.btn-add      { background:#007bff; color:#fff; border:none; padding:4px 12px; cursor:pointer; border-radius:3px; }
	.btn-delete   { background:#dc3545; color:#fff; border:none; padding:4px 12px; cursor:pointer; border-radius:3px; }
	.btn-cancel   { background:#6c757d; color:#fff; border:none; padding:4px 12px; cursor:pointer; border-radius:3px; }
	.btn-add:hover    { background:#0056b3; }
	.btn-delete:hover { background:#a71d2a; }
	.btn-cancel:hover { background:#545b62; }
	.tbl-data th { background:#dce8ff; padding:5px 8px; }
	.tbl-data td { padding:4px 8px; }
	.tbl-data tbody tr:nth-child(even) { background:#f5f8ff; }
	.tbl-data tbody tr:hover { background:#e4edff; }
	.form-row { margin-bottom:8px; }
	.form-btns { text-align:center; margin-top:10px; }
</style>
</head>
<script type="text/javascript">
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
		if (!confirm('Delete ' + checked.length + ' selected assignment(s)?')) return;
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
<fieldset><legend>Assign Vendor To Product</legend>

	<%
		VendorService vendorService         = new VendorService();
		FertilizerService fertilizerService = new FertilizerService();
		AssignVendorToProductService avpService = new AssignVendorToProductService();

		List<VendorEntity>     vendorList     = vendorService.fetch();
		List<FertilizerEntity> fertilizerList = fertilizerService.fetch();
		List<AssignVendorToProductEntity> assignList = avpService.fetch();
	%>

	<form method="post" id="frmAssign" action="../../AssignVendorToProductController">
		<div id="formPanel">
			<div class="form-row">
				<label for="vendorId">Vendor:</label>
				<select name="vendorId" id="vendorId" required>
					<option value="">--- Select Vendor ---</option>
					<% for (VendorEntity v : vendorList) { %>
					<option value="<%=v.getVendorId()%>"><%=v.getVendorName()%></option>
					<% } %>
				</select>
			</div>
			<div class="form-row">
				<label for="fertilizerId">Product:</label>
				<select name="fertilizerId" id="fertilizerId" required>
					<option value="">--- Select Product ---</option>
					<% for (FertilizerEntity f : fertilizerList) { %>
					<option value="<%=f.getFertilizerId()%>"><%=f.getFertilizerName()%></option>
					<% } %>
				</select>
			</div>
			<div class="form-row">
				<label for="price">Price:</label>
				<input type="text" name="price" id="price" placeholder="0.00">
			</div>
			<div class="form-btns">
				<input type="submit" class="btn-add" name="add" value="Assign">
			</div>
		</div>
	</form>

	<div id="bulkBar">
		<span id="selCount">0</span> record(s) selected &nbsp;
		<button type="button" class="btn-delete" onclick="deleteSelected()">Delete Selected</button>
		&nbsp;
		<button type="button" class="btn-cancel" onclick="clearSelection()">Clear Selection</button>
	</div>

	<form method="post" id="frmBulkDelete" action="../../AssignVendorToProductController"></form>

	<table border="1" width="100%" class="tbl-data" cellspacing="0">
		<thead>
			<tr>
				<th width="4%"><input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)" title="Select All"></th>
				<th width="6%">Id</th>
				<th>Vendor Name</th>
				<th>Product Name</th>
				<th width="10%">Price</th>
			</tr>
		</thead>
		<tbody>
			<% for (AssignVendorToProductEntity avp : assignList) { %>
			<tr id="row-<%=avp.getAssignVendorProductId()%>">
				<td style="text-align:center;">
					<input type="checkbox" class="rowChk" value="<%=avp.getAssignVendorProductId()%>" onchange="updateBulkBar()">
				</td>
				<td><%=avp.getAssignVendorProductId()%></td>
				<td><%=avp.getVendorEntity() != null ? avp.getVendorEntity().getVendorName() : ""%></td>
				<td><%=avp.getFertilizerEntity() != null ? avp.getFertilizerEntity().getFertilizerName() : ""%></td>
				<td><%=avp.getPrice()%></td>
			</tr>
			<% } %>
		</tbody>
	</table>
</fieldset>
<%@include file="../../footer.jsp"%>
</body>
</html>
