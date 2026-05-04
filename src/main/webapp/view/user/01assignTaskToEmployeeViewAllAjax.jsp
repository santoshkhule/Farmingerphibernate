<%@page import="san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="java.sql.Date"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page
	import="san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="san.farm.util.FarmUtility"%>

<%

int taskId=0;
String workStatus=null,empName=null,assignWorkDate=null;
if(request.getParameter("fromDate")!=null || request.getParameter("empName")!=null || request.getParameter("work_status")!=null || request.getParameter("work_Id")!=null){
	if(request.getParameter("fromDate")!=null && !request.getParameter("fromDate").equalsIgnoreCase("")){
		assignWorkDate=FarmUtility.convertfrom_ddmmyyToyymmdd(request.getParameter("fromDate"));
	}
	if(request.getParameter("empName")!=null && !request.getParameter("empName").equalsIgnoreCase("")){
		empName=request.getParameter("empName");
	}
	if(request.getParameter("workStatus")!=null && !request.getParameter("workStatus").equalsIgnoreCase("-1")){
		workStatus=request.getParameter("workStatus");
	}
	if(request.getParameter("taskId")!=null && !request.getParameter("taskId").equalsIgnoreCase("-1")){
		taskId=Integer.parseInt(request.getParameter("taskId"));
	}
}
%>

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
		<!-- <th>Excess Amount</th> -->
	</tr>

	<%
		AssignResourceEmployeeToFarmService employeeToFarmService=new AssignResourceEmployeeToFarmService();				
		List<AssignEmployeeToFarmEntity> employeeToFarmEntities=null;
		int cnt = 0,flag=0;
		
		try {
			String query="from AssignEmployeeToFarmEntity";
			if(assignWorkDate!=null){				
				if(!query.contains("where")){
					query=query+" where assignWorkDate='"+Date.valueOf(assignWorkDate)+"'";
				}else{
					query=query+" and assignWorkDate='"+Date.valueOf(assignWorkDate)+"'";
				}				
			}
			if(workStatus!=null){				
				if(!query.contains("where")){
					query=query+" where workStatus='"+workStatus+"'";
				}else{
					query=query+" and workStatus='"+workStatus+"'";
				}				
			}
			/* if(assignWorkDate!=null){				
				if(!query.contains("where")){
					query=query+" where workStatus='"+workStatus+"'";
				}else{
					query=query+" and workStatus='"+workStatus+"'";
				}				
			} */
			if(empName!=null){				
				if(!query.contains("where")){
					query=query+" where employeeInfoId in(from EmployeeInfoEntity where firstName like '%"+empName+"%' or middleName like '%"+empName+"%' or lastName like '%"+empName+"%')";
				}else{
					query=query+" and employeeInfoId in(from EmployeeInfoEntity where firstName like '%"+empName+"%' or middleName like '%"+empName+"%' or lastName like '%"+empName+"%')";
				}				
			}
			
			if(query.contains("where")){
				flag=1;
			}
			out.println(query);
			if(flag==0){
				employeeToFarmEntities=employeeToFarmService.getListOFEmployeeToFarm();
			}else{
				employeeToFarmEntities=employeeToFarmService.getListOFEmployeeToFarmByQry(query);
			}
			
			for(AssignEmployeeToFarmEntity employeeToFarm:employeeToFarmEntities){
				if(employeeToFarm!=null){
			cnt++;
	%>
	<tr id="rowId<%=cnt%>">
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
			<%
				/*if(employeeToFarm.getTaskToEmployeeEntities()!=null){
										for(ConfigCropEntity crop:employeeToFarm.getTaskToEmployeeEntities().)
										out.println(employeeToFarm.getCropToSiteEntity().getSiteInformationEntity().getSiteName());
									}*/
			%>
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