<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<title>Process Payment</title>
</head>
<body>
	<%@include file="../../header.jsp"%>
	<table border="1" cellspacing="0" width="100%">
		<thead>
			<tr>
				<th style="text-align: center;">View All Employee Assign for
					Work</th>
			</tr>
		</thead>
		<tr>
			<td><iframe src="02ViewEmployeeForPaymentProcess.jsp"
					name="ifrmViewEmployee" width="100%" height="400px"></iframe></td>
		</tr>
		<thead>
			<tr>
				<th>Process Payment</th>
			</tr>
		</thead>
		<tr>
			<td><iframe src="02PaymentProcessing.jsp" name="iframSalProcess"
					width="100%" height="400px"></iframe></td>
		</tr>
	</table>
	<%@include file="../../footer.jsp"%>
</body>
</html>