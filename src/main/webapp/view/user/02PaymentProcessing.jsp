
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="com.san.farm.adminuser.entity.PaymentProcessingEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.PaymentProcessingDao"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script>
<link rel="stylesheet" href="../../css/style.css">
<title><%= msg.getString("payment.page_title") %></title>
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

				PaymentProcessingDao salaryProcessingDao = new PaymentProcessingDao();
				List<PaymentProcessingEntity> processingEntities =
						salaryProcessingDao.getAllSalaryTransactionByAssignResourceId(assignResourceId);

				double ttlPaid = 0;
				for(PaymentProcessingEntity pe : processingEntities){
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
				<td colspan="4" style="font-weight:bold; background:#d0e8ff; padding:4px;"><%= msg.getString("payment.fieldset_title") %></td>
			</tr>
			<tr>
				<td style="text-align:right; width:20%;"><%= msg.getString("payment.info_label_employee") %>:</td>
				<td style="width:30%;"><b><%=empName.trim()%></b></td>
				<td style="text-align:right; width:20%;"><%= msg.getString("tbl.col_date") %>:</td>
				<td style="width:30%;"><%=workDate%></td>
			</tr>
			<tr>
				<td style="text-align:right;"><%= msg.getString("tbl.col_site") %>:</td>
				<td><%=siteName%></td>
				<td style="text-align:right;"><%= msg.getString("tbl.col_crop") %>:</td>
				<td><%=cropName%></td>
			</tr>
			<tr>
				<td style="text-align:right;"><%= msg.getString("payment.info_label_work_type") %>:</td>
				<td><%=workType%></td>
				<td style="text-align:right;"><%= msg.getString("tbl.col_status") %>:</td>
				<td><%=workStatus%></td>
			</tr>
		</table>
		<br>
		<table style="width: 70%" border="1" cellspacing="0" align="center">
			<tr>
				<td style="text-align: right;"><%= msg.getString("payment.amt_to_pay") %>:</td>
				<td style="text-align: left;"><input type="text" name="amountToPay" value="<%=amountToPay%>" readonly="readonly"></td>
				<td style="text-align: right;"><%= msg.getString("payment.amt_adv_paid") %>:</td>
				<td style="text-align: left;"><input type="text" value="<%=advPayment%>" readonly="readonly"></td>
				<td style="text-align: right;"><%= msg.getString("payment.amt_salary_paid") %>:</td>
				<td style="text-align: left;"><input type="text" name="amountTopaid" value="<%=ttlPaid%>" readonly="readonly"></td>
			</tr>
			<tr>
				<td style="text-align: right;">Total Paid:</td>
				<td style="text-align: left;"><input type="text" value="<%=totalPaid%>" readonly="readonly"></td>
				<td style="text-align: right;"><%= msg.getString("payment.amt_balance_due") %>:</td>
				<td style="text-align: left;"><input type="text" value="<%=balance%>" readonly="readonly"></td>
				<td style="text-align: right;">Excess:</td>
				<td style="text-align: left;"><input type="text" value="<%=excess%>" readonly="readonly"></td>
			</tr>
			<tr>
				<td style="text-align: right;"><%= msg.getString("payment.form_label_payment_type") %>:</td>
				<td style="text-align: left;">
					<select name="paymentType" id="paymentType" required=required>
						<option value="">Select</option>
						<option value="Cash"><%= msg.getString("payment.form_cash") %></option>
						<option value="Check"><%= msg.getString("payment.form_check") %></option>
						<option value="Other"><%= msg.getString("payment.form_other") %></option>
					</select>
				</td>
				<td style="text-align: right;"><%= msg.getString("payment.form_label_amount") %>:</td>
				<td style="text-align: left;">
					<input type="text" name="txtAmount" id="amount" value="" required="required" pattern="[0-9]+|[0-9]+\.[0-9]+">
				</td>
				<td style="text-align: right;"><%= msg.getString("payment.form_label_date") %>:</td>
				<td style="text-align: left;">
					<input type="text" name="txtDate" id="txtDate" pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
					oninvalid="setCustomValidity('Enter Date: Select From Calender')" onchange="setCustomValidity('')" title="Enter Date"
					placeholder="dd/mm/yyyy" required="required" value=""></td>
			</tr>
			<tr>
				<td style="text-align: right;"><%= msg.getString("payment.form_label_bank_name") %>:</td>
				<td style="text-align: left;">
					<input type="text" name="bankName" id="bankName" value="<%=defaultBankName%>">
				</td>
				<td style="text-align: right;"><%= msg.getString("payment.form_label_account_no") %>:</td>
				<td style="text-align: left;">
					<input type="text" name="accountNO" id="accountNO" value="<%=defaultAccountNo%>">
				</td>
				<td style="text-align: right;"><%= msg.getString("payment.form_label_comment") %>:</td>
				<td style="text-align: left;">
					<textarea rows="1" cols="20" name="comment" id="comment" placeholder="Comment If Any"></textarea>
				</td>
			</tr>
			<tr>
				<td colspan="6" style="text-align: center;">
					<input type="hidden" name="assignResourceId" id="assignResourceId" value="<%=assignResourceId%>">
					<input type="hidden" name="salaryProcessId" id="salaryProcessId">
					<input type="submit" name="sbtUpdateAmount" hidden="true" id="sbtUpdateAmount" value="<%= msg.getString("btn.update") %>" style="width: 12em" onclick="this.form.action='../../PaymentProcessingServlet'">
					<input type="submit" name="sbtPayAmount" id="sbtPayAmount" value="<%= msg.getString("btn.pay_amount") %>" style="width: 10em" onclick="this.form.action='../../PaymentProcessingServlet'">
					<input type="button" value="<%= msg.getString("btn.reset") %>" style="width: 6em" onclick="resetPayForm()">
				</td>
			</tr>
		</table>
	</form>

	<hr>
	<form>
		<table>
			<tr>
				<td><input type="button" value="<%= msg.getString("btn.edit") %>" onclick="populateEditForm()"></td>
				<td><input type="submit" name="sbtDelete" value="<%= msg.getString("btn.delete") %>" onclick="this.form.action='action/SalaryProcessingAction.jsp'"></td>
			</tr>
		</table>
		<table border="1" cellspacing="0" style="width: 100%">
			<tr>
				<th>Select</th>
				<th><%= msg.getString("tbl.col_number") %></th>
				<th><%= msg.getString("payment.history_col_type") %></th>
				<th><%= msg.getString("tbl.col_date") %></th>
				<th><%= msg.getString("tbl.col_amount") %></th>
				<th><%= msg.getString("payment.history_col_bank") %></th>
				<th><%= msg.getString("payment.history_col_account_no") %></th>
				<th><%= msg.getString("tbl.col_comment") %></th>
			</tr>
			<%
				int cnt = 0;
				for(PaymentProcessingEntity processingEntity : processingEntities){
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
		for(PaymentProcessingEntity pe : processingEntities){
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
