<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="css/style.css">
<title>Santosh Farming ERP - Login</title>
</head>
<body class="login-page">

<div class="login-card">
	<div class="login-icon">&#127807;</div>
	<h1>Santosh Farming</h1>
	<p class="subtitle">Farm Management System</p>

	<div class="err-msg" id="errMsg"></div>

	<form action="shell.jsp" method="post">
		<div class="field">
			<label for="txtUname">Username</label>
			<input type="text" name="txtUname" id="txtUname" placeholder="Enter username" autocomplete="username" required>
		</div>
		<div class="field">
			<label for="txtPwd">Password</label>
			<input type="password" name="txtPwd" id="txtPwd" placeholder="Enter password" autocomplete="current-password" required>
		</div>
		<input type="submit" class="btn-login" name="sbtSignIn" value="Sign In">
	</form>
</div>

</body>
</html>
