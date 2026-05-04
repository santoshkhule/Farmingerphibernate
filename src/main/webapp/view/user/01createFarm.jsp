<%@page import="san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Create Farm</title>
<script type="text/javascript">
	function showCropBySiteIdAndDate() {	
		var siteId=document.getElementById("selSite").value;
		var assignDate=document.getElementById("selDate").value;
		if (window.XMLHttpRequest) {
			xmlhttp = new XMLHttpRequest();
		} else {
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {				
				document.getElementById("divCrop").innerHTML = xmlhttp.responseText;				
			}
		};
		var url ="01showCropBySiteIdAndDate.jsp?siteId="+siteId+"&assignDate="+assignDate;
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}
	
	function showDateBySiteId() {	
		//alert("hi");
		var siteId=document.getElementById("selSite").value;
		document.getElementById("selCrop").innerHTML="<option value=''>---select---</option>";
		
		if (window.XMLHttpRequest) {
			xmlhttp = new XMLHttpRequest();
		} else {
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				//alert("divProdName"+cnt+"  ==> divProdName2");
				document.getElementById("divDate").innerHTML = xmlhttp.responseText;				
			}
		};
		var url ="01showDateBySiteId.jsp?siteId="+siteId;
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}
	function onchangeCallIfrm(){
		var siteId=document.getElementById("selSite").value;
		var cropId=document.getElementById("selCrop").value;
		var assignDate=document.getElementById("selDate").value;
		
		window.open("01assignResources.jsp?siteId="+siteId+"&cropId="+cropId+"&assignDate="+assignDate,"ifrmAssignResrc");
	}
</script>
</head>
<body>
<%@include file="../../header.jsp" %>
<%try{ %>
<fieldset>
		<legend class="legend">Assign Work To Employee</legend>
<table>
		<tr>
			<td>Select Site:</td>		
			<td>
				<select name="selSite" id="selSite" onchange="showDateBySiteId()">
					<option value="">---select---</option>
					<%
						ConfigSiteInformationService informationService=new ConfigSiteInformationService();
						List<ConfigSiteInformationEntity> list=informationService.fetch();
						for(ConfigSiteInformationEntity informationEntity:list){
							
					%>
					<option value="<%=informationEntity.getSiteInfoId()%>"><%=informationEntity.getSiteName() %></option>
					<%
						}
					%>
				</select>
			</td>
			<td>Date:</td>		
			<td>
				<div id="divDate">
					<select name="selDate" id="selDate" onchange="showCropBySiteIdAndDate()">
						<option value="">---select---</option>				
					</select>
				</div>
			</td>		
			<td>Select Crop:</td>		
			<td>
				<div id="divCrop">
					<select name="selCrop" id="selCrop" onchange="onchangeCallIfrm()">
						<option value="">---select---</option>				
					</select>
				</div>
			</td>
						
		</tr>		
	</table>
	<iframe name="ifrmAssignResrc" width="100%" height="440px" src="01assignResources.jsp"></iframe>
	</fieldset>
<%
}catch(Exception ex){
	ex.printStackTrace();
}
%>

<%@include file="../../footer.jsp" %>
</body>
</html>