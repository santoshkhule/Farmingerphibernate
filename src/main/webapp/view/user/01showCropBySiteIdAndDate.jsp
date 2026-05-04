<%@page import="san.farm.adminuser.entity.AssignCropToSiteRefEntity"%>
<%@page import="san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="san.farm.adminuser.dao.AssignCropToSiteService"%>
<%@page import="java.util.List"%>
<%
try{
	
	if(null!=request.getParameter("siteId") && !request.getParameter("siteId").equalsIgnoreCase("")
			&& null!=request.getParameter("assignDate") && !request.getParameter("assignDate").equalsIgnoreCase("")){	
		
		int siteId=Integer.parseInt(request.getParameter("siteId"));		
		String cropAssignDate=request.getParameter("assignDate");
		
		String qry="from AssignCropToSiteEntity where siteInfoId="+siteId+" and cropAssignDate='"+cropAssignDate+"'";
		//out.println(qry);
		AssignCropToSiteService cropToSiteService=new AssignCropToSiteService();
		AssignCropToSiteEntity cropToSiteEntity=cropToSiteService.getAssignCropToSiteInfoBySiteIdDate(qry);	
%>
	<select name="selCrop" id="selCrop" onchange="onchangeCallIfrm()">
		<option value="">---select---</option>
		<%		
			for(AssignCropToSiteRefEntity cropToSiteRefEntity:cropToSiteEntity.getCropToSiteRefEntity()){
		%>
			<option value="<%=cropToSiteRefEntity.getConfigCropEntity().getCropId()%>"><%= cropToSiteRefEntity.getConfigCropEntity().getCropName()%></option>
		<%}
		%>
	</select>
<%
	}else{
		%>
		<select name="selCrop" id="selCrop" onchange="onchangeCallIfrm()">
			<option value="">---select---</option>				
		</select>
		<%
	}
}catch(Exception ex){
	ex.printStackTrace();
}
%>
