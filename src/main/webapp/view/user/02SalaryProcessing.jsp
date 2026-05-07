
<%@page import="com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
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
	function validation(){
		var paymentType=document.getElementById("paymentType").value;
		var flag=0;
		if(paymentType==""){
			alert("Select Payment Type");
		}else{
			flag=1;
		}
		if(flag==0){
			return false;
		}else{
		 	return true;
		}
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

				// Fetch the assignment record to get amount and advance
				AssignResourceEmployeeToFarmService employeeToFarmService = new AssignResourceEmployeeToFarmService();
				AssignEmployeeToFarmEntity employeeToFarm = employeeToFarmService
						.getEmployeeToFarmInfoByEmployeeInfoIdDate(
								"from AssignEmployeeToFarmEntity where assignResourceId=" + assignResourceId);

				double amountToPay = (employeeToFarm != null) ? employeeToFarm.getAmount() : 0;

				// Sum all salary transaction payments for this assignment
				SalaryProcessingDao salaryProcessingDao = new SalaryProcessingDao();
				List<SalaryProcessingEntity> processingEntities =
						salaryProcessingDao.getAllSalaryTransactionByAssignResourceId(assignResourceId);

				double ttlPaid = 0;
				for(SalaryProcessingEntity pe : processingEntities){
					ttlPaid += pe.getAmount();
				}

				double balance = amountToPay - ttlPaid;
				double excess = 0;
				if(balance < 0){
					excess = -balance;
					balance = 0;
				}
		%>
		<table style="width: 70%" border="1" cellspacing="0" align="center">
			<tr>
				<td style="text-align: right;">Amount To Pay:</td>
				<td style="text-align: left;"><input type="text" name="amountToPay" value="<%=amountToPay%>" readonly="readonly"></td>
				<td style="text-align: right;">Amount Paid:</td>
				<td style="text-align: left;"><input type="text" name="amountTopaid" value="<%=ttlPaid%>" readonly="readonly"></td>
				<td style="text-align: right;">Balance:</td>
				<td style="text-align: left;"><input type="text" value="<%=balance%>" readonly="readonly" style="text-align: left;"></td>
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
					<input type="text" name="bankName" id="bankName" value="">
				</td>
				<td style="text-align: right;">Account Number:</td>
				<td style="text-align: left;">
					<input type="text" name="accountNO" id="accountNO" value="">
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
				</td>
			</tr>
		</table>
	</form>

	<hr>
	<form>
		<table>
			<tr>
				<td><input type="submit" name="sbtEdit" value="Edit" onclick="this.form.action='001SalaryProcessing.jsp'"></td>
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
				<td><%=processingEntity.getBankName()%></td>
				<td><%=processingEntity.getAccountNumber()%></td>
				<td><%=processingEntity.getComment()%></td>
			</tr>
			<%}%>
		</table>
	</form>
	<%}%>

</body>
</html>
