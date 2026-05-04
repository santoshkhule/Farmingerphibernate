<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="css/style.css">
<title>Farm login</title>
</head>
<body>

<marquee height="10%" bgcolor="blue" style="margin: 0px">
 	<h1 style="color: #000;font-style: italic;">Welcome To Santosh Farming</h1>
</marquee>
<hr>
<div align="center">
	<form action="view/user/configuration.jsp" method="post">
	<h1 style="text-align: center;font-family: serif;">Login Page</h1>
	<span id="hdnErrMessage" style="color: red;font-weight: bold;font-style: italic;" hidden="true">Enter Correct UserName or Password</span>
	<table>			
		<tr>
			<td style="text-align: right;font-weight: bold;">Username::</td>
			<td><input type="text" name="txtUname" id="txtUname"></td>
		</tr>
		<tr>
			<td style="text-align: right;font-weight: bold;">Password::</td>
			<td><input type="password" name="txtPwd" id="txtPwd"></td>
		</tr>
		<tr>
			<td style="text-align: center;" colspan="2"><input type="submit" name="sbtSignIn" value="Sign In"></td>
		</tr>
	</table>
	</form>
</div>
</body>
</html>