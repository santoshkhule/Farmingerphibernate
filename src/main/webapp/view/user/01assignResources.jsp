<%@page import="san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@page import="san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.EmployeeInfoService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/jquery-ui.css" />
<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script> 
<title>Insert title here</title>
</head>
<script>
	$(function() {	
		//alert("hi");
		$("#txtDate").datepicker({
			changeMonth : true,
			changeYear : true,
			dateFormat : "dd/mm/yy"
		}).val();

	});
	
</script>

<script type="text/javascript">
function addRow(tableID) {	
   var table = document.getElementById(tableID);
   var rowCount = table.rows.length;
  // alert(tableID+" "+rowCount);
  
   if(tableID=='dataTable'){
	   /* Code Dynamic row for Employee table */
   var row = table.insertRow(rowCount);  
   var firstCell = row.insertCell(0);
   var option="";
   var empName=document.getElementById("hdnEmpName").value;  
   var empId=document.getElementById("hdnEmpId").value;  
   var arrEmpName=empName.split(",");
   var arrEmpValue=empId.split(",");
   for(var i=0;i<arrEmpName.length;i++){		 
	   if(option!=""){
		   option=option+"<option value='"+arrEmpValue[i]+"'>"+arrEmpName[i].trim()+"</option>";
	   }else{
		   option="<option value=''>---select---</option><option value='"+arrEmpValue[i]+"'>"+arrEmpName[i].trim()+"</option>";
	   } 
   }
   firstCell.innerHTML="<select style='width: 100px' name='selEmpName"+rowCount+"' id='selEmpName"+rowCount+"' required>"+option+"</select>";
   
   var secondCell = row.insertCell(1);	   
   //secondCell.innerHTML="<input type='text' name='txtDate"+rowCount+"' id='txtDate"+rowCount+"' oninvalid='setCustomValidity(Enter Date: Select From Calender)' onchange='setCustomValidity('')' title='Enter Date' style='width: 100px' pattern='(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}' placeholder='dd/mm/yyyy' required='required'>";
   secondCell.innerHTML="<input type='text' name='txtDate"+rowCount+"' id='txtDate"+rowCount+"' oninvalid='setCustomValidity(Enter Date: Select From Calender)' onchange='setCustomValidity('')' title='Enter Date' style='width: 100px' placeholder='dd/mm/yyyy' required='required' readonly>";
   
   var thirdCell = row.insertCell(2);
   var option="";
   var workName=document.getElementById("hdnWorkName").value;  
   var workId=document.getElementById("hdnWorkId").value;  
   var arrWorkName=workName.split(",");
   var arrworkId=workId.split(",");
   for(var i=0;i<arrWorkName.length;i++){
	   if(option!=""){
		   option=option+"<option value='"+arrworkId[i]+"'>"+arrWorkName[i]+"</option>";
	   }else{
		   //<option value=''>---select---</option>
		   option="<option value='"+arrworkId[i]+"'>"+arrWorkName[i]+"</option>";
	   } 
   }
   thirdCell.innerHTML="<select style='width: 100px' name='selWork"+rowCount+"' id='selWork"+rowCount+"' required multiple='multiple'>"+option+"</select>";
   
   var fourthCell = row.insertCell(3);
   var option="<option value=''>---select---</option><option value='Contract'>Contract</option>";
  option=option+"<option value='Per Day Payment'>Per Day Payment</option>";
   fourthCell.innerHTML="<select style='width: 100px' name='selWorkType"+rowCount+"' id='selWorkType"+rowCount+"'>"+option+"</select>";
   
   var fifthCell = row.insertCell(4);
   fifthCell.innerHTML="<input type='text' name='txtAmount"+rowCount+"' id='txtAmount"+rowCount+"' value=0 required='required' oninput='validateAmt("+rowCount+")'>";
      
   var sixthCell = row.insertCell(5);  
   sixthCell.innerHTML="<input type='text' name='txtAdvPayment"+rowCount+"' id='txtAdvPayment"+rowCount+"' value=0 required='required' oninput='validateAmt("+rowCount+")'>";
   
   var seventhCell = row.insertCell(6);  
   var option="";
   option="<option value=''>---select---</option><option value='Completed'>Completed</option><option value='Pending'>Pending</option>";
   option=option+"<option value='Reject'>Reject</option>";
   seventhCell.innerHTML="<select style='width: 100px' name='selWorkStatus"+rowCount+"' id='selWorkStatus"+rowCount+"' required>"+option+"</select>"; 
  
   var eighthCell = row.insertCell(7);  
   eighthCell.innerHTML="<textarea name='txtComment"+rowCount+"' id='txtComment"+rowCount+"' cols='25' rows='1'></textarea>";
   
   var ninethCell = row.insertCell(8);  
   ninethCell.innerHTML="<img name='imgRemove' id='imgRemove' src='../../img/remove.jpg' height='18' width='20' onclick='deleteRow("+tableID+")'>";
   
   document.getElementById("hdnEmpInfoCnt").value=rowCount;
   
   $(function() {	
		//alert("hi");
		$("#txtDate"+rowCount).datepicker({
			changeMonth : true,
			changeYear : true,
			dateFormat : "dd/mm/yy"
		}).val();

	});
   }else if(tableID=="dataTable1"){
	   
	   /* Code Dynamic Rows for Vendor */
	    var row = table.insertRow(rowCount);  
   		var firstCell = row.insertCell(0);
	   var option="";
	   var vendorName=document.getElementById("hdnVendorName").value;  
	   var vendorId=document.getElementById("hdnVendorId").value;  
	   var arrVendorName=vendorName.split(",");
	   var arrVendorId=vendorId.split(",");
	   for(var i=0;i<arrVendorName.length;i++){		 
		   if(option!=""){
			   option=option+"<option value='"+arrVendorId[i]+"'>"+arrVendorName[i]+"</option>";
		   }else{
			   option="<option value=''>---select---</option><option value='"+arrVendorId[i]+"'>"+arrVendorName[i]+"</option>";
		   } 
	   }
	   //alert(option);
	   firstCell.style="text-align: left";
	   
	   firstCell.innerHTML="Vendor Name:<select name='selVendor"+rowCount+"' id='selVendor"+rowCount+"' onChange='showProdByVendorId("+rowCount+")' required>"+option+"</select><img name='imgRemove' id='imgRemove' src='../../img/remove.jpg' height='18' width='20' onclick='deleteRow("+tableID+")'>";
	  
	   var row = table.insertRow(rowCount+1);			
	   var firstCell = row.insertCell(0);   
	   firstCell.innerHTML="<div id='showProd"+rowCount+"'></div>";
	   
	   document.getElementById("hdnVendorCnt").value=rowCount;
	   
   }else if(tableID=="dataTable2"){
	   
	   /* Code Dynamic Rows for Home Products */
	   var row = table.insertRow(rowCount);  
  	   /* var firstCell = row.insertCell(0);
	   firstCell.innerHTML="<input type='checkbox' name='chkProd' id='chkProd"+rowCount+"' value="+rowCount+" onclick=disableEnableTextBox(this.value)>"; */
	   
	   var secondCell = row.insertCell(0);
	   var option="";
	   var catName=document.getElementById("hdnCatName").value;  
	   var catValue=document.getElementById("hdnCatValue").value;  
	   var arrCatName=catName.split(",");
	   var arrCatValue=catValue.split(",");
	   for(var i=0;i<arrCatName.length;i++){
		 //  alert(arrCatValue[i]+"<=> "+arrCatName[i]);
		   if(option!=""){
			   option=option+"<option value='"+arrCatValue[i]+"'>"+arrCatName[i]+"</option>";
		   }else{
			   option="<option value=''>---select---</option><option value='"+arrCatValue[i]+"'>"+arrCatName[i]+"</option>";
		   } 
	   }
	   secondCell.innerHTML="<select style='width: 110px' name='selCat"+rowCount+"' id='selCat"+rowCount+"' onchange='showProdByCatId("+rowCount+")' >"+option+"</select>";
	   
	   var thirdCell = row.insertCell(1);  
	   thirdCell.innerHTML="<div id='divProdName"+rowCount+"'><select style='width: 110px' name='selProdName"+rowCount+"' id='selProdName"+rowCount+"' ><option>---select---</option></select></div>";
	   
	   var fourthCell = row.insertCell(2);
	   var option="";
	   var brandName=document.getElementById("hdnBrandName").value;  
	   var brandValue=document.getElementById("hdnBrandValue").value;  
	   var arrBrandName=brandName.split(",");
	   var arrBrandValue=brandValue.split(",");
	   for(var i=0;i<arrBrandName.length;i++){
		 //  alert(arrCatValue[i]+"<=> "+arrCatName[i]);
		   if(option!=""){
			   option=option+"<option value='"+arrBrandValue[i]+"'>"+arrBrandName[i]+"</option>";
		   }else{
			   option="<option value=''>---select---</option><option value='"+arrBrandValue[i]+"'>"+arrBrandName[i]+"</option>";
		   } 
	   }
	  // alert(option);
	   fourthCell.innerHTML="<select style='width: 110px' name='selBrandName"+rowCount+"' id='selBrandName"+rowCount+"' >"+option+"</select>";
	   
	   var fourthCell1 = row.insertCell(3);
	   var option="";
	   var unitName=document.getElementById("hdnUnitName").value;  
	   var unitValue=document.getElementById("hdnUnitValue").value;  
	   var arrUnitName=unitName.split(",");
	   var arrUnitValue=unitValue.split(",");
	   for(var i=0;i<arrUnitName.length;i++){
		 //  alert(arrCatValue[i]+"<=> "+arrCatName[i]);
		   if(option!=""){
			   option=option+"<option value='"+arrUnitValue[i]+"'>"+arrUnitName[i]+"</option>";
		   }else{
			   option="<option value=''>---select---</option><option value='"+arrUnitValue[i]+"'>"+arrUnitName[i]+"</option>";
		   } 
	   }
	  
	   fourthCell1.innerHTML="<select style='width: 110px' name='selUnitName"+rowCount+"' id='selUnitName"+rowCount+"' >"+option+"</select>"; 
	   
	   var fifthCell = row.insertCell(4);  
	   fifthCell.innerHTML="<input style='width: 110px' type='text' name='txtPrice"+rowCount+"' id='txtPrice"+rowCount+"' >";
	   
	   var sixthCell = row.insertCell(5);  
	   sixthCell.innerHTML="<input style='width: 110px' type='text' name='txtProdDesc"+rowCount+"' id='txtProdDesc"+rowCount+"' >";
	   
	   var seventhCell = row.insertCell(6);  
	   seventhCell.innerHTML="<input style='width: 110px' type='text' name='txtComment"+rowCount+"' id='txtComment"+rowCount+"' >";
	   
	   var eighthCell = row.insertCell(7);  
	   eighthCell.innerHTML="<img name='imgRemove' id='imgRemove' src='../../img/remove.jpg' height='18' width='20' onclick='deleteRow("+tableID+")'>";
	   
	   document.getElementById("hdnHomeProdCnt").value=rowCount;
   }	   
}
/* Function To delete Dynamic Generated rows */
function deleteRow(tableID) {	
	var table = document.getElementById(tableID.id);
	var rowCount = table.rows.length;
	rowCount--;	
	try {
		table.deleteRow(rowCount);
		rowCount--;	
		if(tableID.id=="dataTable"){
			document.getElementById("hdnEmpInfoCnt").value=rowCount;
		}else if(tableID.id=="dataTable1"){
			document.getElementById("hdnVendorCnt").value=rowCount;
		}else if(tableID.id=="dataTable2"){
			 document.getElementById("hdnHomeProdCnt").value=rowCount;
		}
	}catch(e) {
		alert(e);
	}
}
</script>
<script type="text/javascript">
	/*  function to show Products onchange Vendor */
	function showProdByVendorId(cnt) {		
		var vendor_id = document.getElementById("selVendor"+cnt).value;		
		if (window.XMLHttpRequest) {
			xmlhttp = new XMLHttpRequest();
		} else {
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {				
				document.getElementById("showProd"+cnt).innerHTML = xmlhttp.responseText;				
			}
		};
		var url ="03showProductByVendorId.jsp?vendor_id="+vendor_id+"&count="+cnt;
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}
	
	/*  function to show Products In Drio Down List onchange Category */
	function showProdByCatId(cnt) {		
		var catId = document.getElementById("selCat"+cnt).value;		
		if (window.XMLHttpRequest) {
			xmlhttp = new XMLHttpRequest();
		} else {
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {				
				document.getElementById("divProdName"+cnt).innerHTML = xmlhttp.responseText;				
			}
		};
		var url ="showProductByCatId.jsp?catId="+catId+"&count="+cnt;
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}
	
	/* funtion to calculate Tatal Price for Product */
	function cal(block,cnt){
		//alert(cnt);
		if(block=="vendor"){
			var qty=document.getElementById("txtQty"+cnt).value;
			if(qty==""){
				qty=document.getElementById("txtQty"+cnt).value=1;	
			}
			//alert(qty);
			var price=document.getElementById("hdnPrice"+cnt).value;
			var res=parseFloat(qty)*parseFloat(price);
			//alert(res);
			document.getElementById("txtPrice"+cnt).value=res;
		}
	}
	
	/* funtion to disableEnableTextBox Onchange of Checkbox */
	function disableEnableTextBox(block,cnt){		
		if(document.getElementById("chkProd"+cnt).checked){
			document.getElementById("txtQty"+cnt).disabled=false;
		}else{
			document.getElementById("txtQty"+cnt).disabled=true;
		}		
	}
	function hideShowEmployee() {		
		$("#employeePanel").show();
		$("#colorEmp").css("background","white");
		$("#colorProd").css("background","gray");
		$("#homePanel").hide();
	}
	function hideShowHome() {		
		$("#employeePanel").hide();
		$("#homePanel").show();
		$("#colorProd").css("background","white");
		$("#colorEmp").css("background","gray");
		}
	function validateAmt(cnt) {
		var amount=document.getElementById("txtAmount"+cnt).value;
		var advAmount=document.getElementById("txtAdvPayment"+cnt).value;
		if(amount==""){
			document.getElementById("txtAmount"+cnt).value=0;	
		}
		if(advAmount==""){
			document.getElementById("txtAdvPayment"+cnt).value=0;	
		}
		/* alert(amount+" "+advAmount)
		if(NaN(amount)){
			alert("Enter Numeric Value Only");
		}else{
			alert("Enter Numeric Value Only");
		} */
	}
	</script>
<body>
<%
if(null!=request.getParameter("siteId")&& null!=request.getParameter("cropId")&& null!=request.getParameter("assignDate")
&& !request.getParameter("siteId").equalsIgnoreCase("") && !request.getParameter("cropId").equalsIgnoreCase("") && !request.getParameter("assignDate").equalsIgnoreCase("")){
%>
	
<form action="../../AssignResourcesController">
<input type="hidden" name="hdnSiteId" id="hdnSiteId" value="<%=request.getParameter("siteId")%>">
<input type="hidden" name="hdnCropId" id="hdnCropId" value="<%=request.getParameter("cropId")%>">
<input type="hidden" name="hdnDate" id="hdnDate" value="<%=request.getParameter("assignDate")%>">


<div style="background: gray">
	<table border="0">
		<tr style="background: gray;">
			<td onclick="hideShowEmployee()" id="colorEmp" style="background: white;" class="panel-head">Employee </td>
			<!-- <td onclick="hideShowHome()" id="colorProd" class="panel-head"> Home Products</td> -->
			<td><input type="submit" name="sbtAdd" id="sbtAdd" value="Add"></td>
		</tr>
	</table>
</div>

	<div id="employeePanel" class="panel">
	<!-- <fieldset>
		<legend class="legend">Assign Work To Employee</legend> -->
		<table border="1" cellspacing="0" id="dataTable" width="100%">
			<tr>
				<th>Name</th>
				<th>Date</th>
				<th>Work</th>
				<th>Type of Work</th>
				<th>Amount</th>
				<th>Advance Payment</th>
				<th>Work Status</th>
				<th>Comment<img name="imgAdd" id="imgAdd" src="../../img/add.jpg" height="18" width="20" onclick="addRow('dataTable')"></th>
			</tr>
			<tr>
				<td>
				<%
					int cnt=1;
					String empName=null,empId=null;
				%>
					<select name="selEmpName<%=cnt %>" id="selEmpName<%=cnt %>" required=required style="width: 100px">
						<option value="">---select---</option>
						<%
							EmployeeInfoService employeeInfoService=new EmployeeInfoService();
							List<EmployeeInfoEntity> list=employeeInfoService.getListOfEmployee();
							for(EmployeeInfoEntity infoEntity:list){
								if(empName!=null){
									empName=empName.trim()+","+infoEntity.getFirstName()+" "+infoEntity.getMiddleName()+" "+infoEntity.getLastName();
								}else{
									empName=infoEntity.getFirstName()+" "+infoEntity.getMiddleName()+" "+infoEntity.getLastName();
								}
								
								if(empId!=null){
									empId=empId+","+infoEntity.getEmployeeInfoId();
								}else{
									empId=String.valueOf(infoEntity.getEmployeeInfoId());
								}
								%>
								<option value="<%=infoEntity.getEmployeeInfoId()%>"> <%if(infoEntity.getFirstName()!=null){out.print(infoEntity.getFirstName()+" ");} if(infoEntity.getMiddleName()!=null){out.print(infoEntity.getMiddleName()+" ");}%><%=infoEntity.getLastName() %></option>
								<%
							}
						%>						
					</select>
					<input type="hidden" id="hdnEmpName" name="hdnEmpName" value="<%=empName%>">
				<input type="hidden" id="hdnEmpId" name="hdnEmpId" value="<%=empId%>">
				</td>
				<td>				
					<input type="text" name="txtDate<%=cnt %>" id="txtDate" style="width: 100px" pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
						oninvalid="setCustomValidity('Enter Date: Select From Calender')" onchange="setCustomValidity('')" title="Enter Date"
						value="" 
						placeholder="dd/mm/yyyy" required="required">				
						
				</td>
				<td>
					<select name="selWork<%=cnt %>" id="selWork<%=cnt %>" style="width: 100px" multiple="multiple">
						<!-- <option value="">---select---</option> -->
						<%
							String workId=null,workName=null;
							ConfigFarmTaskService farmTaskService=new ConfigFarmTaskService();
							List<ConfigFarmTaskEntity> farmTaskEntities=farmTaskService.fetch();
							for(ConfigFarmTaskEntity taskEntity:farmTaskEntities){
								if(workName!=null){
									workName=workName+","+taskEntity.getTaskName();
								}else{
									workName=taskEntity.getTaskName();
								}
								if(workId!=null){
									workId=workId+","+taskEntity.getTaskId();
								}else{
									workId=String.valueOf(taskEntity.getTaskId());
								}
								%>
								<option value="<%=taskEntity.getTaskId()%>"><%=taskEntity.getTaskName()%></option>
								<%
							}
						%>
						
					</select>
					<input type="hidden" name="hdnWorkName" id="hdnWorkName" value="<%=workName%>">
					<input type="hidden" name="hdnWorkId" id="hdnWorkId" value="<%=workId%>">
				</td>	
				<td>				
					<select name="selWorkType<%=cnt %>" id="selWorkType<%=cnt %>" required style="width: 100px">
						<option value=" ">---select---</option>
						<option value="Contract">Contract</option>	
						<option value="Per Day Payment">Per Day Payment</option>
							
					</select>
				</td>
				<td>
					<input type="text" name="txtAmount<%=cnt %>" id="txtAmount<%=cnt %>" value="0" oninput="validateAmt(<%=cnt %>)">
				</td>
				<td>
					<input type="text" name="txtAdvPayment<%=cnt %>" id="txtAdvPayment<%=cnt %>" value="0" oninput="validateAmt(<%=cnt %>)">
				</td>
				<td>
					<select name="selWorkStatus<%=cnt %>" id="selWorkStatus<%=cnt %>" style="width: 100px">
						<option value="">---select---</option>
						<option value="Completed">Completed</option>
						<option value="Pending">Pending</option>
						<option value="Reject">Reject</option>						
					</select>
				</td>
				<td>
					<textarea name="txtComment<%=cnt %>" id="txtComment<%=cnt %>" cols="25" rows="1"></textarea>
					<input type="hidden" name="hdnEmpInfoCnt" id="hdnEmpInfoCnt" value="<%=cnt%>">
				</td>
				
			</tr>
		</table>
	</fieldset>	
	</div>
	<%-- <div id="vendorPanel" hidden="true">
	<fieldset>
		<legend class="legend">Vendor Information</legend>
		<table width="100%" id="dataTable1" border="0">
			<tr>
				<td>Vendor Name:
					
					<select name="selVendor<%=cnt %>" id="selVendor<%=cnt %>" onchange="showProdByVendorId(<%=cnt %>)">
					<option value="">---Select---</option>
					
					</select>
					<img name="imgAdd" id="imgAdd" src="../../img/add.jpg" height="18" width="20" onclick="addRow('dataTable1')" title="addVendor">
					<input type="hidden" id="hdnVendorName" name="hdnVendorName" value="">
					<input type="hidden" id="hdnVendorId" name="hdnVendorId" value="">
	 				<input type="text" id="hdnVendorCnt" name="hdnVendorCnt" value="">
				</td>
			</tr>
			<tr>
				<td>
					<div id="showProd<%=cnt%>"></div>
				</td>
			</tr>					
		</table>
	</fieldset>
	</div>--%>
	
	<%-- <div id="homePanel" hidden="true" class="panel">	
	
		
		<%
			request.getParameter("txtUname");
		%>
		<table border="1" id="dataTable2" cellspacing="0" style="width: 100%">
			<tr>
				<!-- <th>Select</th> -->
				<th>Category</th>
				<th>Product</th>
				<th>Brand</th>
				<th>Unit</th>
				<th>Price</th>
				<th>Product Description</th>
				<th>Comment <img name="imgAdd" id="imgAdd" src="../../img/add.jpg" height="18" width="20" onclick="addRow('dataTable2')"></th>
				<!-- <th id="thAction">Action</th> -->				
			</tr>
			<tr>							
				<td>
				
					<select name="selCat<%=cnt %>" style="width: 110px" id="selCat<%=cnt%>" onchange="showProdByCatId(<%=cnt %>)" required="required">
						<option value="">---Select---</option>
						
					</select>
					<span id="spanCat<%=cnt%>"><% out.println(cateogry); %></span>
					<input type="hidden" name="hdnCatName" id="hdnCatName" value="">
					<input type="hidden" name="hdnCatValue" id="hdnCatValue" value="">
				</td>	
				<td>						
					<div id="divProdName<%=cnt%>">
						
					<select name="selProdName<%=cnt%>" style="width: 110px" id="selProdName<%=cnt%>" required="required" >
						<option value="">---select---</option>
						
					</select>
					
					</div>						
				</td>
				<td>	
								
					<select name="selBrandName<%=cnt%>" style="width: 110px" id="selBrandName<%=cnt%>"  required="required">
						<option value="">---select---</option>					
					</select>						
					<input type="hidden" name="hdnBrandName" id="hdnBrandName" value="">
					<input type="hidden" name="hdnBrandValue" id="hdnBrandValue" value="">
					
				</td>
				<td>							
					<select name="selUnitName<%=cnt%>" id="selUnitName<%=cnt%>" required="required"  style="width: 110px">
						<option value="">---select---</option>
						
					</select>						
					<input type="hidden" name="hdnUnitName" id="hdnUnitName" value="">
					<input type="hidden" name="hdnUnitValue" id="hdnUnitValue" value="">						
				</td>
				<td>
				
					<input type="text" style="width: 110px" name="txtPrice<%=cnt %>" id="txtPrice<%=cnt%>"  value="" required="required">
				</td>
				<td>						
					<input type="text" style="width: 110px" name="txtProdDesc<%=cnt %>" id="txtProdDesc<%=cnt%>"  value="">
				</td>
				<td>						
					<input type="text" style="width: 110px" name="txtComment<%=cnt %>" id="txtComment<%=cnt%>"  value="">
					<input type="hidden" style="width: 110px" name="hdnHomeProdCnt" id="hdnHomeProdCnt"  value="<%=cnt%>">
				</td>			
			</tr>						
		</table>
	<!-- </fieldset> -->	
	</div> --%>

</form>	
<%} %>	
<%-- <%@include file="../../footer.jsp" %> --%>
</body>
</html>