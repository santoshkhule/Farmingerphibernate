<%@page import="com.san.farm.adminuser.entity.*"%>
<%@page import="com.san.farm.adminuser.dao.*"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<title>Vendor Product Assignments</title>
<style>
	#bulkBar { display:none; background:#fdecea; border:1px solid #e06060; padding:6px 12px; border-radius:3px; margin-bottom:8px; }
	#editBanner { display:none; background:#fff3cd; border:1px solid #ffc107; color:#856404; padding:4px 10px; border-radius:3px; margin-bottom:6px; font-weight:bold; }
	.tbl-data th { background:#dce8ff; padding:5px 8px; font-size:12px; }
	.tbl-data td { padding:4px 6px; font-size:12px; }
	.tbl-data tr.selected-row { background:#c2d7f9 !important; font-weight:bold; }
	.tbl-data tbody tr:nth-child(even) { background:#f5f8ff; }
	.tbl-data tbody tr:hover { background:#e4edff; }
	.btn-update  { background:#28a745; color:#fff; border:none; padding:3px 10px; cursor:pointer; border-radius:3px; font-size:12px; }
	.btn-delete  { background:#dc3545; color:#fff; border:none; padding:3px 10px; cursor:pointer; border-radius:3px; font-size:12px; }
	.btn-cancel  { background:#6c757d; color:#fff; border:none; padding:3px 10px; cursor:pointer; border-radius:3px; font-size:12px; }
	.btn-row-edit { background:#e8f0fe; border:1px solid #4a80d4; color:#1a56c4; padding:2px 7px; cursor:pointer; border-radius:2px; font-size:11px; }
	.btn-row-edit:hover { background:#c2d5f9; }
	.edit-input  { width:90px; padding:2px; font-size:11px; }
	.edit-select { width:95px; font-size:11px; }
	.note { color:red; font-style:italic; padding:10px; }
</style>
</head>
<%
	String vendorIdStr = request.getParameter("vendor_id");

	CategoryService   categoryService   = new CategoryService();
	FertilizerService fertilizerService = new FertilizerService();
	BrandService      brandService      = new BrandService();
	UnitService       unitService       = new UnitService();

	List<CategoryEntity>   categoryList   = categoryService.fetch();
	List<FertilizerEntity> fertilizerList = fertilizerService.fetch();
	List<BrandEntity>      brandList      = brandService.fetch();
	List<UnitEntity>       unitList       = unitService.fetch();
%>
<script type="text/javascript">
	var editingRowEl = null;

	function editRow(id) {
		if (editingRowEl) editingRowEl.classList.remove('selected-row');
		editingRowEl = document.getElementById('row-' + id);
		if (editingRowEl) editingRowEl.classList.add('selected-row');

		showEdit(id, true);
		document.getElementById('editBanner').style.display = 'block';
		document.getElementById('editBanner').innerText = 'Editing row id: ' + id;
	}

	function showEdit(id, editing) {
		['Cat','Prod','Brand','Unit','Price','Desc','Comment'].forEach(function(f) {
			var span = document.getElementById('span' + f + id);
			var inp  = document.getElementById('inp' + f + id);
			if (span) span.style.display = editing ? 'none' : '';
			if (inp)  inp.style.display  = editing ? '' : 'none';
		});
		var btnEdit   = document.getElementById('btnEdit' + id);
		var btnSave   = document.getElementById('btnSave' + id);
		var btnCancel = document.getElementById('btnCancel' + id);
		if (btnEdit)   btnEdit.style.display   = editing ? 'none' : '';
		if (btnSave)   btnSave.style.display   = editing ? '' : 'none';
		if (btnCancel) btnCancel.style.display = editing ? '' : 'none';
	}

	function cancelEdit(id) {
		if (editingRowEl) { editingRowEl.classList.remove('selected-row'); editingRowEl = null; }
		showEdit(id, false);
		document.getElementById('editBanner').style.display = 'none';
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
		<%
			String vid = (vendorIdStr != null && !vendorIdStr.isEmpty()) ? vendorIdStr : "";
		%>
		var vidInp = document.createElement('input');
		vidInp.type = 'hidden'; vidInp.name = 'vendorId'; vidInp.value = '<%=vid%>';
		form.appendChild(vidInp);
		var rtInp = document.createElement('input');
		rtInp.type = 'hidden'; rtInp.name = 'redirectTarget'; rtInp.value = 'viewIframe';
		form.appendChild(rtInp);
		form.submit();
	}

	function clearSelection() {
		document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = false; });
		document.getElementById('chkAll').checked = false;
		document.getElementById('bulkBar').style.display = 'none';
	}
</script>
<body>
<%
	if (vendorIdStr == null || vendorIdStr.isEmpty()) {
%>
<p class="note">Note: Select a Vendor to view assignments.</p>
<%
	} else {
		int vendor_id = Integer.parseInt(vendorIdStr);
		AssignVendorToProductService avpService = new AssignVendorToProductService();
		List<AssignVendorToProductEntity> assignList = avpService.fetchByVendor(vendor_id);
%>
	<div id="editBanner"></div>

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
				<th width="3%"><input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)"></th>
				<th>Category</th>
				<th>Product</th>
				<th>Brand</th>
				<th>Unit</th>
				<th>Price</th>
				<th>Description</th>
				<th>Comment</th>
				<th>Actions</th>
			</tr>
		</thead>
		<tbody>
		<% for (AssignVendorToProductEntity avp : assignList) {
			int id = avp.getAssignVendorProductId();
			String catId   = avp.getCategoryEntity()   != null ? String.valueOf(avp.getCategoryEntity().getCategoryId())     : "";
			String ferId   = avp.getFertilizerEntity() != null ? String.valueOf(avp.getFertilizerEntity().getFertilizerId())  : "";
			String briId   = avp.getBrandEntity()      != null ? String.valueOf(avp.getBrandEntity().getBrandId())           : "";
			String uniId   = avp.getUnitEntity()       != null ? String.valueOf(avp.getUnitEntity().getUnitId())             : "";
			String catName = avp.getCategoryEntity()   != null ? avp.getCategoryEntity().getCategoryName()     : "";
			String ferName = avp.getFertilizerEntity() != null ? avp.getFertilizerEntity().getFertilizerName() : "";
			String briName = avp.getBrandEntity()      != null ? avp.getBrandEntity().getBrandName()           : "";
			String uniName = avp.getUnitEntity()       != null ? avp.getUnitEntity().getUnitName()             : "";
			String desc    = avp.getProdDesc()  != null ? avp.getProdDesc()  : "";
			String comment = avp.getComment()   != null ? avp.getComment()   : "";
		%>
		<tr id="row-<%=id%>">
			<td style="text-align:center;"><input type="checkbox" class="rowChk" value="<%=id%>" onchange="updateBulkBar()"></td>
			<td>
				<span id="spanCat<%=id%>"><%=catName%></span>
				<select class="edit-select" id="inpCat<%=id%>" name="categoryId" style="display:none">
					<option value="">---</option>
					<% for (CategoryEntity c : categoryList) { %>
					<option value="<%=c.getCategoryId()%>" <%=String.valueOf(c.getCategoryId()).equals(catId)?"selected":""%>><%=c.getCategoryName()%></option>
					<% } %>
				</select>
			</td>
			<td>
				<span id="spanProd<%=id%>"><%=ferName%></span>
				<select class="edit-select" id="inpProd<%=id%>" name="fertilizerId" style="display:none">
					<option value="">---</option>
					<% for (FertilizerEntity f : fertilizerList) { %>
					<option value="<%=f.getFertilizerId()%>" <%=String.valueOf(f.getFertilizerId()).equals(ferId)?"selected":""%>><%=f.getFertilizerName()%></option>
					<% } %>
				</select>
			</td>
			<td>
				<span id="spanBrand<%=id%>"><%=briName%></span>
				<select class="edit-select" id="inpBrand<%=id%>" name="brandId" style="display:none">
					<option value="">---</option>
					<% for (BrandEntity b : brandList) { %>
					<option value="<%=b.getBrandId()%>" <%=String.valueOf(b.getBrandId()).equals(briId)?"selected":""%>><%=b.getBrandName()%></option>
					<% } %>
				</select>
			</td>
			<td>
				<span id="spanUnit<%=id%>"><%=uniName%></span>
				<select class="edit-select" id="inpUnit<%=id%>" name="unitId" style="display:none">
					<option value="">---</option>
					<% for (UnitEntity u : unitList) { %>
					<option value="<%=u.getUnitId()%>" <%=String.valueOf(u.getUnitId()).equals(uniId)?"selected":""%>><%=u.getUnitName()%></option>
					<% } %>
				</select>
			</td>
			<td>
				<span id="spanPrice<%=id%>"><%=avp.getPrice()%></span>
				<input class="edit-input" type="text" id="inpPrice<%=id%>" name="price" value="<%=avp.getPrice()%>" style="display:none">
			</td>
			<td>
				<span id="spanDesc<%=id%>"><%=desc%></span>
				<input class="edit-input" type="text" id="inpDesc<%=id%>" name="prodDesc" value="<%=desc%>" style="display:none">
			</td>
			<td>
				<span id="spanComment<%=id%>"><%=comment%></span>
				<input class="edit-input" type="text" id="inpComment<%=id%>" name="comment" value="<%=comment%>" style="display:none">
			</td>
			<td style="text-align:center; white-space:nowrap;">
				<button type="button" class="btn-row-edit" id="btnEdit<%=id%>" onclick="editRow(<%=id%>)">Edit</button>
				<form method="post" action="../../AssignVendorToProductController" style="display:inline" id="frmEdit<%=id%>">
					<input type="hidden" name="edit" value="edit">
					<input type="hidden" name="assignVendorProductId" value="<%=id%>">
					<input type="hidden" name="vendorId"       value="<%=vendor_id%>">
					<input type="hidden" name="redirectTarget"  value="viewIframe">
					<input type="hidden" name="categoryId"  id="hidCat<%=id%>">
					<input type="hidden" name="fertilizerId" id="hidProd<%=id%>">
					<input type="hidden" name="brandId"     id="hidBrand<%=id%>">
					<input type="hidden" name="unitId"      id="hidUnit<%=id%>">
					<input type="hidden" name="price"       id="hidPrice<%=id%>">
					<input type="hidden" name="prodDesc"    id="hidDesc<%=id%>">
					<input type="hidden" name="comment"     id="hidComment<%=id%>">
					<button type="button" class="btn-update" id="btnSave<%=id%>" style="display:none"
						onclick="
							document.getElementById('hidCat<%=id%>').value    = document.getElementById('inpCat<%=id%>').value;
							document.getElementById('hidProd<%=id%>').value   = document.getElementById('inpProd<%=id%>').value;
							document.getElementById('hidBrand<%=id%>').value  = document.getElementById('inpBrand<%=id%>').value;
							document.getElementById('hidUnit<%=id%>').value   = document.getElementById('inpUnit<%=id%>').value;
							document.getElementById('hidPrice<%=id%>').value  = document.getElementById('inpPrice<%=id%>').value;
							document.getElementById('hidDesc<%=id%>').value   = document.getElementById('inpDesc<%=id%>').value;
							document.getElementById('hidComment<%=id%>').value= document.getElementById('inpComment<%=id%>').value;
							document.getElementById('frmEdit<%=id%>').submit();">Save</button>
				</form>
				<button type="button" class="btn-cancel" id="btnCancel<%=id%>" style="display:none" onclick="cancelEdit(<%=id%>)">Cancel</button>
			</td>
		</tr>
		<% } %>
		</tbody>
	</table>
<% } %>
</body>
</html>
