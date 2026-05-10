<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css" type="text/css">
<title>Farming Menu</title>
</head>
<body>
	<div id="nicefooter">
		<ul>
			<li style="margin-left: 2em"><a href="<%=request.getContextPath()%>/view/user/configuration.jsp">Configuration</a>
				<ul>
					<li><a href="<%=request.getContextPath()%>/view/user/configuration.jsp">Basic Config</a></li>
					<li><a href="<%=request.getContextPath()%>/view/user/registerUser.jsp">Register User</a></li>
					<li><a href="<%=request.getContextPath()%>/view/user/assignCropToSite.jsp">Assign Crop To Site</a></li>

				</ul></li>
			<li><a href="<%=request.getContextPath()%>/view/user/employeeViewAll.jsp">Employee</a>
				<ul>
					<li><a href="<%=request.getContextPath()%>/view/user/employeeInfo.jsp">Add</a></li>
					<li><a href="<%=request.getContextPath()%>/view/user/employeeViewAll.jsp">View All Employee</a></li>


				</ul></li>
			<li><a href="#">Task</a>
				<ul>
					<li><a href="<%=request.getContextPath()%>/view/user/assignCropToSite.jsp">Assign Crop To Site</a></li>
					<li><a href="<%=request.getContextPath()%>/view/user/01createFarm.jsp">Create Farm</a></li>
					<li><a href="<%=request.getContextPath()%>/view/user/01assignTaskToEmployeeViewAll.jsp">View Assign Task To Employee</a></li>

				</ul></li>
			<li><a href="<%=request.getContextPath()%>/view/user/02employeeSalaryProcess.jsp">Account</a>
				<ul>
					<li><a href="<%=request.getContextPath()%>/view/user/02employeeSalaryProcess.jsp">Process Salary</a></li>
				</ul></li>
			<li><a href="<%=request.getContextPath()%>/view/user/addVendor.jsp">Vendor</a>
				<ul>
					<li><a href="<%=request.getContextPath()%>/view/user/addVendor.jsp">Add Vendor</a></li>
				</ul></li>
				<li><a style="margin-left:37em;color: green;" href="<%=request.getContextPath()%>/logout.jsp">Logout</a></li>
		</ul>
	</div>

</body>
</html>
