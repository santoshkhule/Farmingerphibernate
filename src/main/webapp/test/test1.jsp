<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
<script type="text/javascript">
function test11(fun) {
	alert("hi");
	document.forms[0].submit();
}
</script>
</head>
<body>
	<form >
		<select onchange="test11(this)" >
		<option>-------</option>
		<option>-------</option>
		</select>
	</form>
</body>
</html>