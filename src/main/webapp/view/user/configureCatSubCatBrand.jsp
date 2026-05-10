<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<title>Category / Product / Brand / Units</title>
</head>
<body>
<%@include file="../../header.jsp"%>
<fieldset><legend>Category / Product / Brand / Units</legend>
	<table border="1" cellspacing="0" style="width:100%">
		<tr>
			<th>Category</th>
			<th>Product</th>
			<th>Brand</th>
			<th>Units</th>
		</tr>
		<tr>
			<td><iframe name="ifrmCat"   src="addCategory.jsp"   width="100%" height="500" frameborder="0"></iframe></td>
			<td><iframe name="ifrmProd"  src="addFertilizer.jsp" width="100%" height="500" frameborder="0"></iframe></td>
			<td><iframe name="ifrmBrand" src="addBrand.jsp"      width="100%" height="500" frameborder="0"></iframe></td>
			<td><iframe name="ifrmUnit"  src="addUnits.jsp"      width="100%" height="500" frameborder="0"></iframe></td>
		</tr>
	</table>
</fieldset>
<%@include file="../../footer.jsp"%>
</body>
</html>
