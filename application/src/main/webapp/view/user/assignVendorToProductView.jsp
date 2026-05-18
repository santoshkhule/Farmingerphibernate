<%@page import="com.san.farm.adminuser.entity.VendorEntity"%>
<%@page import="com.san.farm.adminuser.dao.VendorService"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<title><%= msg.getString("vendor.view_products.page_title") %></title>
<style>
	.filter-bar { padding:10px; background:#f0f6ff; border:1px solid #b0c8f0; border-radius:4px; margin-bottom:10px; display:inline-block; }
	.filter-bar label { font-weight:bold; margin-right:6px; }
	.filter-bar select { padding:3px; width:220px; }
</style>
<script type="text/javascript">
	function loadVendorProducts() {
		var vendorId = document.getElementById('selVendor').value;
		var iframe   = document.getElementById('ifrmProducts');
		if (vendorId) {
			iframe.src = 'assignVendorToProductViewIframe.jsp?vendor_id=' + vendorId;
		} else {
			iframe.src = 'assignVendorToProductViewIframe.jsp';
		}
	}
</script>
</head>
<body>
<%@include file="../../header.jsp"%>
<fieldset><legend><%= msg.getString("vendor.view_products.fieldset_title") %></legend>

	<%
		VendorService vendorService = new VendorService();
		List<VendorEntity> vendorList = vendorService.fetch();

		String selectedVendorId = request.getParameter("vendor_id") != null ? request.getParameter("vendor_id") : "";
	%>

	<div class="filter-bar">
		<label for="selVendor"><%= msg.getString("vendor.view_products.label_vendor") %>:</label>
		<select id="selVendor" onchange="loadVendorProducts()">
			<option value=""><%= msg.getString("vendor.view_products.select_vendor") %></option>
			<% for (VendorEntity v : vendorList) {
				boolean selected = String.valueOf(v.getVendorId()).equals(selectedVendorId);
			%>
			<option value="<%=v.getVendorId()%>" <%=selected ? "selected" : ""%>><%=v.getVendorName()%></option>
			<% } %>
		</select>
	</div>

	<br>
	<iframe id="ifrmProducts" name="ifrmProducts" width="100%" height="500" frameborder="0"
		src="assignVendorToProductViewIframe.jsp<%=selectedVendorId.isEmpty() ? "" : "?vendor_id=" + selectedVendorId%>">
	</iframe>

</fieldset>
<%@include file="../../footer.jsp"%>
</body>
</html>
