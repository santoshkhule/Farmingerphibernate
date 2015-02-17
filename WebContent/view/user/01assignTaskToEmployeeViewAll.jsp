<%@page import="san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@page import="san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="san.farm.util.FarmUtility"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>View All Assign Task</title>
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script>
</head>
<script>
	$(function() {
		$("#txtDate").datepicker({
			changeMonth : true,
			changeYear : true,
			dateFormat : "dd/mm/yy"
		}).val();

	});
</script>
<script type="text/javascript">
	function showAllEmployeeByFilterId() {
		var fromDate = document.getElementById("txtDate").value;		
		var empName = document.getElementById("txtName").value;
		var work_status = document.getElementById("work_status").value;
		var work_Id = document.getElementById("selWorkId").value;
		alert(fromDate+" "+empName+" "+work_status+" "+work_Id);
		if (window.XMLHttpRequest) {
			xmlhttp = new XMLHttpRequest();
		} else {
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				document.getElementById("showTable").innerHTML = xmlhttp.responseText;
			}
		};

		var url = "01assignTaskToEmployeeViewAllAjax.jsp?fromDate=" + fromDate
				+ "&empName=" + empName + "&workStatus=" + work_status
				+ "&taskId=" + work_Id;
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}
	var tempId=-1;
	function showEditDelete(id) {
		if(tempId!=-1){
			$("#td"+tempId).hide();			
		}
		//alert(id);
		//alert($(id).find("td").eq(0).text());
		$("#td"+id).show();
		$("#th").show();
		$("#imgDelete"+id).show();
		$("#imgEdit"+id).show();
		tempId=id;
	}
	function actionEditDelete(id,action){
		alert(action+" "+"../../AssignResourcesController?assignResourceId="+id);
		if(action=="delete"){
			window.location="../../AssignResourcesController?assignResourceId="+id+"&action=delete";
		}else{
			//window.location="";
		}
		
	}
</script>
<body>
	<%@include file="../../header.jsp"%>
	<!-- <h2>View All Employee Assign Task</h2> <hr>-->

	<fieldset style="height: 575px">
		<legend>View All Employee Assign Task</legend>
		<table>
			<tr>
				<td>Date:</td>
				<td><input type="text" name="txtDate" id="txtDate"
					pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
					oninvalid="setCustomValidity('Enter Date: Select From Calender')"
					title="Select Date" placeholder="dd/mm/yyyy"
					onchange="showAllEmployeeByFilterId()"></td>
				<td>Name:</td>
				<td><input type="text" name="txtName" id="txtName"
					oninput="showAllEmployeeByFilterId()"></td>
				<td>Work:</td>
				<td><select name="selWorkId" id="selWorkId"
					onchange="showAllEmployeeByFilterId()">
						<option value="-1">Select</option>
						<%
							ConfigFarmTaskService farmTaskService=new ConfigFarmTaskService();
							List<ConfigFarmTaskEntity> taskEntities=farmTaskService.fetch();
							for(ConfigFarmTaskEntity taskEntity:taskEntities){
						%>
						<option value="<%=taskEntity.getTaskId()%>"><%=taskEntity.getTaskName() %></option>
						<%} %>

				</select></td>
				<td style="text-align: right;">Work Status:</td>
				<td><select name="work_status" id="work_status"
					onchange="showAllEmployeeByFilterId()">
						<option value="-1">select</option>
						<option value="Completed">Completed</option>
						<option value="Pending">Pending</option>
						<option value="Reject">Reject</option>
				</select></td>
			</tr>
		</table>
		<hr>
		<form method="post">
			<table>
				<tr>
					<td><input type="submit" name="sbtEdit" value="Edit"
						onclick="this.form.action='assignTaskToEmployee.jsp'"></td>
					<td><input type="submit" name="sbtView" value="View"
						onclick="this.form.action='assignTaskToEmployeeSingleView.jsp',target='_blank'"></td>
					<td><input type="submit" name="sbtDelete" value="Delete"
						onclick="this.form.action='action/assignTaskToEmployeeAction.jsp'"></td>
				</tr>
			</table>
			<div id="showTable">
				<table border="1" width=100%>
					<tr>
						<th>Select</th>
						<th>Sr. No.</th>
						<!-- <th>Work_Id</th> -->
						<th>Name</th>
						<th>Date</th>
						<th>Site Name</th>
						<th>Crop Name</th>
						<th>Work Type</th>
						<th>Work Status</th>
						<th>Assign Work</th>
						<th>Amount To Pay</th>
						<th>Paid</th>
						<th>Balance</th>
						<th hidden id="th" width="2%">Action</th>
						<!-- <th>Excess Amount</th> -->
					</tr>

					<%
						AssignResourceEmployeeToFarmService employeeToFarmService=new AssignResourceEmployeeToFarmService();
						
						List<AssignEmployeeToFarmEntity> employeeToFarmEntities=null;
						int cnt = 0;
						try {
							employeeToFarmEntities=employeeToFarmService.getListOFEmployeeToFarm();
							for(AssignEmployeeToFarmEntity employeeToFarm:employeeToFarmEntities){
								if(employeeToFarm!=null){
							cnt++;
					%>
					<tr id="rowId<%=cnt%>" ondblclick="showEditDelete(<%=cnt%>)">
						<td><input type="radio" name="radAssignWorkId"
							id="radAssignWorkId" value="" required="required"></td>
						<td><%=cnt%></td>
						<td>
							<%
								if(employeeToFarm.getEmployeeInfoEntity()!=null){
									if(employeeToFarm.getEmployeeInfoEntity().getFirstName()!=null){
										out.print(employeeToFarm.getEmployeeInfoEntity().getFirstName()+" ");
									}
									if(employeeToFarm.getEmployeeInfoEntity().getMiddleName()!=null){
										out.print(employeeToFarm.getEmployeeInfoEntity().getMiddleName()+" ");
									}
									if(employeeToFarm.getEmployeeInfoEntity().getLastName()!=null){
										out.print(employeeToFarm.getEmployeeInfoEntity().getLastName());
									}
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getAssignWorkDate()!=null){
									out.println(FarmUtility.convertfrom_yymmddToddmmyy(employeeToFarm.getAssignWorkDate().toString()));
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getCropToSiteEntity()!=null && employeeToFarm.getCropToSiteEntity().getSiteInformationEntity()!=null 
									&& employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName()!=null){
									out.println(employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName());
								}
							%>
						</td>
						<td>
							<%-- <%
								if(employeeToFarm.getListFarmTaskEntities()!=null){
									for(ConfigCropEntity crop:employeeToFarm.getListFarmTaskEntities())
									out.println(employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName());
								}
							%> --%>
						</td>
						<td>
							<%
								if(employeeToFarm.getTypeOfWork()!=null){
									out.println(employeeToFarm.getTypeOfWork());
								}
							%>
						</td>
						<td>
							<%
								if(employeeToFarm.getWorkStatus()!=null){
									out.println(employeeToFarm.getWorkStatus());
								}
							%>
						</td>
						<td>
							<%								
								int i=0;								
								for(ConfigFarmTaskEntity taskToEmployee:employeeToFarm.getListFarmTaskEntities()){
									if(i==0){
										i++;
										out.println(taskToEmployee.getTaskName());
									}else{
										out.println(","+taskToEmployee.getTaskName());
									}
								}
							%>
						</td>						
						<%
							double ttl_transaction_paid_amount = 0;
								double excessAmount = 0;
								double balanceAmount = 0;
								try {
									balanceAmount=employeeToFarm.getAmount()-employeeToFarm.getAdvPayment();
								} catch (Exception ex) {
									ex.printStackTrace();
								}
								balanceAmount = ttl_transaction_paid_amount;
								if (balanceAmount < 0) {
									excessAmount = -balanceAmount;
									balanceAmount = 0;
								}
						%>
						<td>
							<%								
								out.println(employeeToFarm.getAmount());								
							%>
						</td>
						<td>
							<%
								out.println(employeeToFarm.getAdvPayment());
							%>
						</td>
						<td>
							<%
								out.print(balanceAmount);
							%>
						</td>
						<td  id="td<%=cnt%>" hidden="true" width="6%">
							<img src="../../img/edit.jpg" height="17" width="30" id="imgEdit<%=cnt %>" hidden onclick="actionEditDelete(<%=employeeToFarm.getAssignResourceId() %>,'edit')">
							<img src="../../img/delete.jpg" height="17" width="30" id="imgDelete<%=cnt %>" hidden onclick="actionEditDelete(<%=employeeToFarm.getAssignResourceId() %>,'delete')">
						</td>
						<%-- <td><%out.print(excessAmount); %></td> --%>
					</tr>
					<%
								}//if end
							}//for end
						} catch (Exception ex) {
							ex.printStackTrace();
						}
					%>
				</table>
			</div>
		</form>
	</fieldset>
	<%@include file="../../footer.jsp"%>
</body>
</html>