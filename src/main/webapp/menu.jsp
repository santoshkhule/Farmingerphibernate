<div id="sidebar-brand">
	<span class="brand-icon">&#127807;</span>
	<div class="brand-text">
		<span class="brand-name">Sevak</span>
		<span class="brand-sub">Farm ERP</span>
	</div>
</div>

<nav id="sideNav">

	<div class="nav-group">
		<div class="nav-group-title">&#9881; Configuration</div>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/masterData.jsp">Master Data</a>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/registerUser.jsp">Register User</a>
	</div>

	<div class="nav-group">
		<div class="nav-group-title">&#128100; Employee</div>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/employeeInfo.jsp">Add Employee</a>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/employeeViewAll.jsp">View All Employee</a>
	</div>

	<div class="nav-group">
		<div class="nav-group-title">&#128203; Farm Setup</div>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/assignCropToSite.jsp">Site Resource Allocation</a>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/01assignTaskToEmployeeViewAll.jsp">View Assign Tasks</a>
	</div>

	<div class="nav-group">
		<div class="nav-group-title">&#128176; Account</div>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/02employeePaymentProcess.jsp">Process Payment</a>
	</div>

	<div class="nav-group">
		<div class="nav-group-title">&#127978; Vendor</div>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/addVendor.jsp">Add Vendor</a>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/assignVendorToProduct.jsp">Assign Products</a>
		<a class="nav-link" href="<%=request.getContextPath()%>/view/user/assignVendorToProductView.jsp">View Products</a>
	</div>

</nav>

<div id="sidebar-foot">
	<a class="nav-logout" href="<%=request.getContextPath()%>/logout.jsp">&#128682; Logout</a>
</div>
