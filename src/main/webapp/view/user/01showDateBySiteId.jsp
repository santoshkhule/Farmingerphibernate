<%@page import="san.farm.util.FarmUtility"%>
<%@page import="san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.AssignCropToSiteService"%>
<%	
try{
	if(null!=request.getParameter("siteId") && !request.getParameter("siteId").equalsIgnoreCase("")){	
		
		int siteId=Integer.parseInt(request.getParameter("siteId"));
		AssignCropToSiteService cropToSiteService=new AssignCropToSiteService();
		String qry="from AssignCropToSiteEntity where siteInfoId="+siteId;
		List<AssignCropToSiteEntity> list=cropToSiteService.getAssignCropToSiteInfoByFilter(qry);
		
		
%>
	<select name="selDate" id="selDate" onchange="showCropBySiteIdAndDate()">
		<option value="">---select---</option>
		<%
			for(AssignCropToSiteEntity cropToSiteEntity:list){
				%>
				<option value="<%=cropToSiteEntity.getCropAssignDate()%>"><%=FarmUtility.convertfrom_yymmddToddmmyy(cropToSiteEntity.getCropAssignDate().toString())%></option>
				<%
			}
		%>
	</select>	
<%
	}else{
		%>
		<select name="selDate" id="selDate" onchange="showCropBySiteIdAndDate()">
		<option value="">---select---</option>			
		</select>
		<%
	}
}catch(Exception exception){
	exception.printStackTrace();
}
%>
