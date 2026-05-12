<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/style.css">
<title>Santosh Farming ERP</title>
<style>
	html, body { height: 100%; margin: 0; padding: 0; overflow: hidden; }

	#appShell {
		display: flex;
		height: 100vh;
		width: 100%;
	}

	#sidebar {
		width: 220px;
		min-width: 180px;
		flex-shrink: 0;
		background: var(--sidebar-bg);
		display: flex;
		flex-direction: column;
		height: 100vh;
		overflow-y: auto;
		overflow-x: hidden;
	}

	#contentFrame {
		flex: 1;
		min-width: 0;
		border: none;
		height: 100%;
		background: #eaf2ea;
		display: block;
	}
</style>
</head>
<body>

<div id="appShell">

	<!-- ── Sidebar ── -->
	<aside id="sidebar">

		<div id="sidebar-brand">
			<span class="brand-icon">&#127807;</span>
			<div class="brand-text">
				<span class="brand-name">Santosh Farming</span>
				<span class="brand-sub">Farm ERP</span>
			</div>
		</div>

		<nav id="sideNav">

			<div class="nav-group">
				<div class="nav-group-title">&#9881; Configuration</div>
				<a class="nav-link" href="view/user/configuration.jsp" target="contentFrame">Configuration</a>
				<a class="nav-link" href="view/user/registerUser.jsp" target="contentFrame">Register User</a>
				<a class="nav-link" href="view/user/assignCropToSite.jsp" target="contentFrame">Assign Crop To Site</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128100; Employee</div>
				<a class="nav-link" href="view/user/employeeInfo.jsp" target="contentFrame">Add Employee</a>
				<a class="nav-link" href="view/user/employeeViewAll.jsp" target="contentFrame">View All Employee</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128203; Task</div>
				<a class="nav-link" href="view/user/01createFarm.jsp" target="contentFrame">Create Farm</a>
				<a class="nav-link" href="view/user/01assignTaskToEmployeeViewAll.jsp" target="contentFrame">View Assign Tasks</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128176; Account</div>
				<a class="nav-link" href="view/user/02employeePaymentProcess.jsp" target="contentFrame">Process Payment</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#127978; Vendor</div>
				<a class="nav-link" href="view/user/addVendor.jsp" target="contentFrame">Add Vendor</a>
				<a class="nav-link" href="view/user/assignVendorToProduct.jsp" target="contentFrame">Assign Products</a>
				<a class="nav-link" href="view/user/assignVendorToProductView.jsp" target="contentFrame">View Products</a>
			</div>

			<div class="nav-group">
				<div class="nav-group-title">&#128202; Reports</div>
				<a class="nav-link" href="view/user/reportSite.jsp" target="contentFrame">Site Expenditure</a>
				<a class="nav-link" href="view/user/reportEmployee.jsp" target="contentFrame">Employee Payments</a>
			</div>

		</nav>

		<div id="sidebar-foot">
			<a class="nav-logout" href="logout.jsp" target="_top">&#128682; Logout</a>
		</div>

	</aside>

	<!-- ── Content iframe ── -->
	<iframe id="contentFrame" name="contentFrame"
		src="view/user/configuration.jsp"
		frameborder="0">
	</iframe>

</div>

</body>
</html>
