
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="com.san.farm.adminuser.entity.SalaryProcessingEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.SalaryProcessingDao"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script>
<link rel="stylesheet" href="../../css/style.css">
<title>Salary Processing</title>
</head>
<script type="text/javascript">
	var salaryTransactions = {};

	function validation(){
		var paymentType = document.getElementById("paymentType").value;
		if(paymentType == ""){
			alert("Select Payment Type");
			return false;
		}
		return true;
	}

	function populateEditForm() {
		var selected = document.querySelector('input[name="radEmpSalTrancastionId"]:checked');
		if (!selected) {
			alert("Please select a transaction to edit.");
			return;
		}
		var id = selected.value;
		var data = salaryTransactions[id];
		if (data) {
			document.getElementById('bankName').value    = data.bankName;
			document.getElementById('accountNO').value   = data.accountNo;
			document.getElementById('comment').value     = data.comment;
			document.getElementById('amount').value      = data.amount;
			document.getElementById('txtDate').value     = data.date;
			document.getElementById('paymentType').value = data.paymentType;
			document.getElementById('salaryProcessId').value = id;
			document.getElementById('sbtUpdateAmount').removeAttribute('hidden');
			document.getElementById('sbtPayAmount').setAttribute('hidden', 'true');
		}
	}

	function resetPayForm() {
		document.getElementById('bankName').value    = '';
		document.getElementById('accountNO').value   = '';
		document.getElementById('comment').value     = '';
		document.getElementById('amount').value      = '';
		document.getElementById('txtDate').value     = '';
		document.getElementById('paymentType').value = '';
		document.getElementById('salaryProcessId').value = '';
		document.getElementById('sbtUpdateAmount').setAttribute('hidden', 'true');
		document.getElementById('sbtPayAmount').removeAttribute('hidden');
	}
</script>
<script>
	$(function() {
		$("#txtDate").datepicker({
			changeMonth : true,
			changeYear : true,
			dateFormat : "dd/mm/yy"
		}).val();
	});
</script>

<body>
	<form onsubmit="return validation();">

		<%
			if(request.getParameter("assignResourceId")!=null){
				int assignResourceId = Integer.parseInt(request.getParameter("assignResourceId"));

				AssignResourceEmployeeToFarmService employeeToFarmService = new AssignResourceEmployeeToFarmService();
				AssignEmployeeToFarmEntity employeeToFarm = employeeToFarmService.getEmployeeToFarmById(assignResourceId);

				double amountToPay  = (employeeToFarm != null) ? employeeToFarm.getAmount()     : 0;
				double advPayment   = (employeeToFarm != null) ? employeeToFarm.getAdvPayment()  : 0;

				SalaryProcessingDao salaryProcessingDao = new SalaryProcessingDao();
				List<SalaryProcessingEntity> processingEntities =
						salaryProcessingDao.getAllSalaryTransactionByAssignResourceId(assignResourceId);

				double ttlPaid = 0;
				for(SalaryProcessingEntity pe : processingEntities){
					ttlPaid += pe.getAmount();
				}

				double totalPaid = advPayment + ttlPaid;
				double balance = amountToPay - totalPaid;
				double excess = 0;
				if(balance < 0){
					excess = -balance;
					balance = 0;
				}
		%><%
				/* ---- Employee details section ---- */
				String empName = "";
				if (employeeToFarm != null) {
					EmployeeInfoEntity emp = employeeToFarm.getEmployeeInfoEntity();
					if (emp != null) {
						if (emp.getFirstName()  != null) empName += emp.getFirstName()  + " ";
						if (emp.getMiddleName() != null) empName += emp.getMiddleName() + " ";
						if (emp.getLastName()   != null) empName += emp.getLastName();
					}
				}
				String workDate  = (employeeToFarm != null && employeeToFarm.getAssignWorkDate() != null)
						? FarmUtility.convertfrom_yymmddToddmmyy(employeeToFarm.getAssignWorkDate().toString()) : "";
				String siteName  = (employeeToFarm != null
						&& employeeToFarm.getCropToSiteEntity() != null
						&& employeeToFarm.getCropToSiteEntity().getSiteInformationEntity() != null)
						? employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName() : "";
				String cropName  = (employeeToFarm != null && employeeToFarm.getCropEntity() != null)
						? employeeToFarm.getCropEntity().getCropName() : "";
				String workType  = (employeeToFarm != null && employeeToFarm.getTypeOfWork()  != null)
						? employeeToFarm.getTypeOfWork()  : "";
				String workStatus= (employeeToFarm != null && employeeToFarm.getWorkStatus()  != null)
						? employeeToFarm.getWorkStatus()  : "";
				String defaultBankName = "";
				String defaultAccountNo = "";
				if (employeeToFarm != null && employeeToFarm.getEmployeeInfoEntity() != null) {
					EmployeeInfoEntity empInfo = employeeToFarm.getEmployeeInfoEntity();
					if (empInfo.getBankName()      != null) defaultBankName  = empInfo.getBankName();
					if (empInfo.getAccountNumber() != null) defaultAccountNo = empInfo.getAccountNumber();
				}
		%>
		<table style="width: 70%; background:#f5f5f5;" border="1" cellspacing="0" align="center">
			<tr>
				<td colspan="4" style="font-weight:bold; background:#d0e8ff; padding:4px;">Employee Work Details</td>
			</tr>
			<tr>
				<td style="text-align:right; width:20%;">Employee Name:</td>
				<td style="width:30%;"><b><%=empName.trim()%></b></td>
				<td style="text-align:right; width:20%;">Work Date:</td>
				<td style="width:30%;"><%=workDate%></td>
			</tr>
			<tr>
				<td style="text-align:right;">Site:</td>
				<td><%=siteName%></td>
				<td style="text-align:right;">Crop:</td>
				<td><%=cropName%></td>
			</tr>
			<tr>
				<td style="text-align:right;">Work Type:</td>
				<td><%=workType%></td>
				<td style="text-align:right;">Work Status:</td>
				<td><%=workStatus%></td>
			</tr>
		</table>
		<br>
		<table style="width: 70%" border="1" cellspacing="0" align="center">
			<tr>
				<td style="text-align: right;">Amount To Pay:</td>
				<td style="text-align: left;"><input type="text" name="amountToPay" value="<%=amountToPay%>" readonly="readonly"></td>
				<td style="text-align: right;">Advance Paid:</td>
				<td style="text-align: left;"><input type="text" value="<%=advPayment%>" readonly="readonly"></td>
				<td style="text-align: right;">Amount Paid:</td>
				<td style="text-align: left;"><input type="text" name="amountTopaid" value="<%=ttlPaid%>" readonly="readonly"></td>
			</tr>
			<tr>
				<td style="text-align: right;">Total Paid:</td>
				<td style="text-align: left;"><input type="text" value="<%=totalPaid%>" readonly="readonly"></td>
				<td style="text-align: right;">Balance:</td>
				<td style="text-align: left;"><input type="text" value="<%=balance%>" readonly="readonly"></td>
				<td style="text-align: right;">Excess:</td>
				<td style="text-align: left;"><input type="text" value="<%=excess%>" readonly="readonly"></td>
			</tr>
			<tr>
				<td style="text-align: right;">Payment type:</td>
				<td style="text-align: left;">
					<select name="paymentType" id="paymentType" required=required>
						<option value="">Select</option>
						<option value="Cash">Cash</option>
						<option value="Check">Check</option>
						<option value="Other">Other</option>
					</select>
				</td>
				<td style="text-align: right;">Amount:</td>
				<td style="text-align: left;">
					<input type="text" name="txtAmount" id="amount" value="" required="required" pattern="[0-9]+|[0-9]+\.[0-9]+">
				</td>
				<td style="text-align: right;">Date:</td>
				<td style="text-align: left;">
					<input type="text" name="txtDate" id="txtDate" pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
					oninvalid="setCustomValidity('Enter Date: Select From Calender')" onchange="setCustomValidity('')" title="Enter Date"
					placeholder="dd/mm/yyyy" required="required" value=""></td>
			</tr>
			<tr>
				<td style="text-align: right;">Bank Name:</td>
				<td style="text-align: left;">
					<input type="text" name="bankName" id="bankName" value="<%=defaultBankName%>">
				</td>
				<td style="text-align: right;">Account Number:</td>
				<td style="text-align: left;">
					<input type="text" name="accountNO" id="accountNO" value="<%=defaultAccountNo%>">
				</td>
				<td style="text-align: right;">Comment:</td>
				<td style="text-align: left;">
					<textarea rows="1" cols="20" name="comment" id="comment" placeholder="Comment If Any"></textarea>
				</td>
			</tr>
			<tr>
				<td colspan="6" style="text-align: center;">
					<input type="hidden" name="assignResourceId" id="assignResourceId" value="<%=assignResourceId%>">
					<input type="hidden" name="salaryProcessId" id="salaryProcessId">
					<input type="submit" name="sbtUpdateAmount" hidden="true" id="sbtUpdateAmount" value="Update Paid Amount" style="width: 12em" onclick="this.form.action='../../SalaryProcessingServlet'">
					<input type="submit" name="sbtPayAmount" id="sbtPayAmount" value="Pay Amount" style="width: 10em" onclick="this.form.action='../../SalaryProcessingServlet'">
					<input type="button" value="Reset" style="width: 6em" onclick="resetPayForm()">
				</td>
			</tr>
		</table>
	</form>

	<hr>
	<form>
		<table>
			<tr>
				<td><input type="button" value="Edit" onclick="populateEditForm()"></td>
				<td><input type="submit" name="sbtDelete" value="Delete" onclick="this.form.action='action/SalaryProcessingAction.jsp'"></td>
			</tr>
		</table>
		<table border="1" cellspacing="0" style="width: 100%">
			<tr>
				<th>Select</th>
				<th>Sr. No.</th>
				<th>Payment Type</th>
				<th>Date</th>
				<th>Amount</th>
				<th>Bank Name</th>
				<th>Account Number</th>
				<th>Comment</th>
			</tr>
			<%
				int cnt = 0;
				for(SalaryProcessingEntity processingEntity : processingEntities){
					cnt++;
			%>
			<tr>
				<td>
					<input type="radio" name="radEmpSalTrancastionId" id="radEmpSalTrancastionId" value="<%=processingEntity.getSalaryProcessId()%>" required="required">
				</td>
				<td><%=cnt%></td>
				<td><%=processingEntity.getPaymentType()%></td>
				<td><%=(processingEntity.getDate()!=null) ? FarmUtility.convertfrom_yymmddToddmmyy(processingEntity.getDate().toString()) : ""%></td>
				<td><%=processingEntity.getAmount()%></td>
				<td><%=processingEntity.getBankName()    != null ? processingEntity.getBankName()    : ""%></td>
				<td><%=processingEntity.getAccountNumber() != null ? processingEntity.getAccountNumber() : ""%></td>
				<td><%=processingEntity.getComment()       != null ? processingEntity.getComment()       : ""%></td>
			</tr>
			<%}%>
		</table>
	</form>

	<script>
	<%
		for(SalaryProcessingEntity pe : processingEntities){
	%>
	salaryTransactions[<%=pe.getSalaryProcessId()%>] = {
		amount:      <%=pe.getAmount()%>,
		date:        '<%=(pe.getDate()!=null) ? FarmUtility.convertfrom_yymmddToddmmyy(pe.getDate().toString()) : ""%>',
		paymentType: '<%=pe.getPaymentType()     != null ? pe.getPaymentType().replace("'","\\'")     : ""%>',
		bankName:    '<%=pe.getBankName()         != null ? pe.getBankName().replace("'","\\'")         : ""%>',
		accountNo:   '<%=pe.getAccountNumber()    != null ? pe.getAccountNumber().replace("'","\\'")    : ""%>',
		comment:     '<%=pe.getComment()          != null ? pe.getComment().replace("'","\\'")          : ""%>'
	};
	<% } %>
	</script>
	<%}%>

</body>
</html>
