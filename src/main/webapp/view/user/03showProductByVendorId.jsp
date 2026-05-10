<%@page import="farm.connection.DBfactory"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<%
try{
	
	 if(null!=request.getParameter("vendor_id") && !request.getParameter("vendor_id").equals("")){
		int vendor_id=Integer.parseInt(request.getParameter("vendor_id"));
		
		Connection con = null;
		DBfactory dBfactory = new DBfactory();
		con = dBfactory.DBconnection();
		
		//out.println("vendor_id:=>>"+request.getParameter("vendor_id") +"  cat_id:=>"+request.getParameter("cat_id") );
		%>				 
			<input type="hidden" name="hdnVendorId" id="hdnVendorId" value="<%=vendor_id %>">			
			<table border="1" cellspacing="0" style="width: 100%">
				<tr>
					<th>Select</th>
					<th>Category</th>
					<th>Product</th>
					<th>Brand</th>
					<th>Unit</th>
					<th>Quantity</th>
					<th>Price</th>
					<th>Product Description</th>
					<th>Comment</th>									
				</tr>
				<% 
				int cnt=0;		
				try{				
					String qry_showAsignProd="select * from assignvendortoprod where vendor_id_fk="+vendor_id;					
					Statement st_showAsignProd=con.createStatement();
					ResultSet rs_showAsignProd=st_showAsignProd.executeQuery(qry_showAsignProd);
					
					while(rs_showAsignProd.next()){						
						
					 cnt++;
				%>
				<tr>				
					<td><input type="checkbox" name="chkProd" id="chkProd<%=cnt%>" value="<%=cnt%>" onclick="disableEnableTextBox(this.value)">
					</td>					
						<td>
						<%
						
						String cateogry=null;
						try{
							String selectQry = "select cat_name from category where cat_id="+rs_showAsignProd.getInt(8);
							Statement st1 = con.createStatement();
							ResultSet rs1 = st1.executeQuery(selectQry);							
							while (rs1.next()) {									
								cateogry=rs1.getString("cat_name");
							}
								rs1.close();
								st1.close();
							}catch(Exception ex){
								ex.printStackTrace();
							}
								%>							
							<span id="spanCat<%=cnt%>"><% out.println(cateogry); %></span>							
						</td>	
					<td>					
							<%
							String product=null;
							String qry_prod="select fertilizer_name from fertilizer where fertilizer_id="+rs_showAsignProd.getInt(5);
							Statement st_prod=con.createStatement();
							ResultSet rs_prod=st_prod.executeQuery(qry_prod);								 
							while(rs_prod.next()){								
								product=rs_prod.getString("fertilizer_name");							
							}
							%>						
						<span id="spanProdName<%=cnt%>"><%out.println(product); %></span>												
					</td>
					<td>	
					<%
						try{
							
							String qry_brand="select brand_Name from brand where brand_id="+rs_showAsignProd.getInt(6);
							Statement st_brand=con.createStatement();
							String brand=null;
							ResultSet rs_brand=st_brand.executeQuery(qry_brand);										
							try{							
							while(rs_brand.next()){								
								brand=rs_brand.getString("brand_Name");								
							} 								
							%>						
						<span id="spanBrandName<%=cnt%>"><%out.println(brand); %></span>
						
						<%}catch(Exception ex){
							ex.printStackTrace();
						}}catch(Exception ex){
							ex.printStackTrace();
						} %>
					</td>
					<td>	
					<%
						try{
							String unit=null;
							String qry_unit="select unit_name from units where unit_id="+rs_showAsignProd.getInt(9);
							Statement st_unit=con.createStatement();
							ResultSet rs_unit=st_unit.executeQuery(qry_unit);										
							try{					
							while(rs_unit.next()){								
								unit=rs_unit.getString("unit_name");									
							} 								
							%>						
						<span id="spanUnitName<%=cnt%>"><%out.println(unit); %></span>
						
						<%}catch(Exception ex){
							ex.printStackTrace();
						}}catch(Exception ex){
							ex.printStackTrace();	
						} %>
					</td>
					<td>
						<input type="text" style="width: 100px" name="txtQty<%=cnt%>" id="txtQty<%=cnt%>" value="1" required>					
					</td>
					<td>
						<input type="text" style="width: 100px" name="txtPrice<%=cnt%>" id="txtPrice<%=cnt%>" value="<%=rs_showAsignProd.getDouble(2) %>" readonly="readonly">
						<%-- <span id="spanPrice<%=cnt%>"><%=rs_showAsignProd.getDouble(2) %></span>	 --%>					
					</td>
					<td>
						<span id="spanProdDesc<%=cnt%>"><%=rs_showAsignProd.getString(3) %></span>						
					</td>
					<td>
						<span id="spanComment<%=cnt%>"><%=rs_showAsignProd.getString(4) %></span>						
					</td>					
				</tr>				
				<%
					}
					}catch(Exception ex){
						ex.printStackTrace();
					}
				%>				
			</table>			
		<%
	}
}catch(Exception ex){
	ex.printStackTrace();
}
%>
</body>
</html>