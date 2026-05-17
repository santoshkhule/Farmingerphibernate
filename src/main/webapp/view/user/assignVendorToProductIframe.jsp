<%@page import="com.san.farm.adminuser.entity.*"%>
<%@page import="com.san.farm.adminuser.dao.*"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<title><%= msg.getString("vendor.assign_product.iframe_legend") %></title>
<style>
	#formPanel { background:#f0f6ff; border:1px solid #b0c8f0; padding:12px 16px; margin-bottom:10px; border-radius:4px; }
	#formPanel label { font-weight:bold; display:inline-block; width:130px; text-align:right; margin-right:6px; }
	#formPanel select, #formPanel input[type=text] { width:200px; padding:3px; }
	.form-row { margin-bottom:8px; }
	.form-btns { text-align:center; margin-top:10px; }
	.btn-add { background:#007bff; color:#fff; border:none; padding:5px 16px; cursor:pointer; border-radius:3px; }
	.btn-add:hover { background:#0056b3; }
	.note { color:red; font-style:italic; padding:10px; }
</style>
</head>
<body>
<%
	String vendorIdStr = request.getParameter("vendor_id");
	if (vendorIdStr == null || vendorIdStr.isEmpty()) {
%>
<p class="note"><%= msg.getString("vendor.assign_product.iframe_note") %></p>
<%
	} else {
		int vendor_id = Integer.parseInt(vendorIdStr);
		VendorService vendorService         = new VendorService();
		CategoryService categoryService     = new CategoryService();
		FertilizerService fertilizerService = new FertilizerService();
		BrandService brandService           = new BrandService();
		UnitService unitService             = new UnitService();

		List<CategoryEntity>   categoryList   = categoryService.fetch();
		List<FertilizerEntity> fertilizerList = fertilizerService.fetch();
		List<BrandEntity>      brandList      = brandService.fetch();
		List<UnitEntity>       unitList       = unitService.fetch();
%>
<fieldset><legend><%= msg.getString("vendor.assign_product.iframe_legend") %></legend>
<form method="post" action="../../AssignVendorToProductController">
	<input type="hidden" name="vendorId"      value="<%=vendor_id%>">
	<input type="hidden" name="redirectTarget" value="iframe">
	<div id="formPanel">
		<div class="form-row">
			<label><%= msg.getString("vendor.assign_product.label_category") %>:</label>
			<select name="categoryId">
				<option value=""><%= msg.getString("buyer.select_type") %></option>
				<% for (CategoryEntity c : categoryList) { %>
				<option value="<%=c.getCategoryId()%>"><%=c.getCategoryName()%></option>
				<% } %>
			</select>
		</div>
		<div class="form-row">
			<label><%= msg.getString("vendor.assign_product.label_product") %>:</label>
			<select name="fertilizerId" required>
				<option value=""><%= msg.getString("buyer.select_type") %></option>
				<% for (FertilizerEntity f : fertilizerList) { %>
				<option value="<%=f.getFertilizerId()%>"><%=f.getFertilizerName()%></option>
				<% } %>
			</select>
		</div>
		<div class="form-row">
			<label><%= msg.getString("vendor.assign_product.label_brand") %>:</label>
			<select name="brandId">
				<option value=""><%= msg.getString("buyer.select_type") %></option>
				<% for (BrandEntity b : brandList) { %>
				<option value="<%=b.getBrandId()%>"><%=b.getBrandName()%></option>
				<% } %>
			</select>
		</div>
		<div class="form-row">
			<label><%= msg.getString("vendor.assign_product.label_unit") %>:</label>
			<select name="unitId">
				<option value=""><%= msg.getString("buyer.select_type") %></option>
				<% for (UnitEntity u : unitList) { %>
				<option value="<%=u.getUnitId()%>"><%=u.getUnitName()%></option>
				<% } %>
			</select>
		</div>
		<div class="form-row">
			<label><%= msg.getString("vendor.assign_product.label_price") %>:</label>
			<input type="text" name="price" placeholder="0.00">
		</div>
		<div class="form-row">
			<label><%= msg.getString("vendor.assign_product.label_product_desc") %>:</label>
			<input type="text" name="prodDesc" placeholder="Description">
		</div>
		<div class="form-row">
			<label><%= msg.getString("tbl.col_comment") %>:</label>
			<input type="text" name="comment" placeholder="Comment">
		</div>
		<div class="form-btns">
			<input type="submit" class="btn-add" name="add" value="<%= msg.getString("btn.add") %>">
		</div>
	</div>
</form>
</fieldset>
<% } %>
</body>
</html>
