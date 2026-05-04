<%@page import="san.farm.login.dao.LoginUserService"%>
<%@page import="san.farm.login.entity.LoginUser"%>
<%@page import="san.farm.adminuser.entity.UserTypeEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.UserTypeService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<script src="../../js/jquery-1.9.1.js"></script>
<title>Register User</title>
</head>
<script type="text/javascript">
 function validationEmail(){
	 var Email_id=document.getElementById("emailId").value;
	 var confirm_Email_id=document.getElementById("confirmEmailId").value;
	 var pass=document.getElementById("passwrd").value;
	 var confirm_pass=document.getElementById("confirmPasswrd").value;
	 if(Email_id!="" && confirm_Email_id!="" && Email_id!=confirm_Email_id){
		 alert("Email ID Is Not Matching");	
		 document.getElementById("confirmEmailId").value="";
	 }
	 if(pass!="" && confirm_pass!="" && pass!=confirm_pass){
		 alert("Password Is Not Matching");		
		 document.getElementById("confirmPasswrd").value="";
	 }
 }
 var showEdit=function(id){
	// alert("hii"+$(id).find("td").eq(3).text().trim());
	 $("#emailId").val($(id).find("td").eq(2).text().trim());
	 $("#confirmEmailId").val($(id).find("td").eq(2).text().trim());
	 $("#loginUserId").val($(id).find("td").eq(0).text().trim());
	 $("#selUserTypeId").val($(id).find("td").eq(3).text().trim());
	 
	 document.getElementById("curPasswrd").required=true;
	 document.getElementById("delete").hidden=false;
	 document.getElementById("tr4").hidden=false;
	 document.getElementById("edit").hidden=false;
	 document.getElementById("delete").hidden=false;
	 document.getElementById("add").hidden=true;
	
	 
 }
</script>
<body>
<%@include file="../../header.jsp" %>
<%
	boolean isValid=false,edit=false;
	if(request.getParameter("isValid")!=null){
		isValid=Boolean.parseBoolean(request.getParameter("isValid"));
		if(isValid){
%>
			<script>
				alert("Email Id Already Exist");
				window.location="registerUser.jsp";
			</script>
			<%
				}	
					}
					if(request.getParameter("isCurPwdValid")!=null){
						boolean isCurPwdValid=false;
						isCurPwdValid=Boolean.parseBoolean(request.getParameter("isCurPwdValid"));
						if(isCurPwdValid){
			%>
			<script>
				alert("Enter Correct Current Password");
				window.location="registerUser.jsp";
			</script>
			<%
				}else{
			%>
			<script>
				alert("Password Changed Successfully");				
				window.location="registerUser.jsp";
			</script>
			<%
				}	
					}
			%>
	<!-- <h2>Register User</h2>
	<hr> -->	
	<form name="frmRegUser" method="get" action="../../RegisterUserController">
		<table>
			<tr>
				<td style="text-align: right;font-weight: bold;">User:</td>
				<%
					try{
								
										UserTypeService userTypeModel=new UserTypeService();
										List<UserTypeEntity> list=userTypeModel.fetch();
				%>
				<td>
					<select name="selUserTypeId" id="selUserTypeId" required>
					<option value="">---Select---</option>
					<%
						for(UserTypeEntity userTypeEntity:list){
							if(null!=userTypeEntity){
					%>
								<option value="<%=userTypeEntity.getUserTypeId()%>"><%=userTypeEntity.getUserType()%></option>	
							<%
								}
						}
							
				}catch(Exception ex){
					ex.printStackTrace();
				}
					%>
					</select>					
				</td>
			</tr>
			<tr>		
				<td style="text-align: right;font-weight: bold;">Email Id:
					<input type="hidden" id="loginUserId" name="loginUserId"> 
				</td>
				<td><input type="text" name="emailId" id="emailId" required 
						placeholder="username@domain.com"
						pattern="[a-zA-Z0-9._-]+\@[a-zA-Z]+\.[a-z]+"
						oninvalid="setCustomValidity('Enter Valid Email Address')"
						onchange="setCustomValidity('')"  onblur="validationEmail()" 
						value="">
				</td>
			</tr>
			
			<tr>
				<td style="text-align: right;font-weight: bold;">Confirm Email Id:</td>
				<td><input type="text" name="confirmEmailId" id="confirmEmailId" required
						placeholder="username@domain.com"
						pattern="[a-zA-Z0-9._-]+\@[a-zA-Z]+\.[a-z]+"
						oninvalid="setCustomValidity('Enter Valid Email Address')"
						onchange="setCustomValidity('')" onblur="validationEmail()">						
				</td>
			</tr>
			
			<tr hidden id="tr4">
				<td style="text-align: right;font-weight: bold;">Current Password:</td>
				<td><input type="password" name="curPasswrd" id="curPasswrd"></td>
			</tr>
			
			<tr>
				<td style="text-align: right;font-weight: bold;">Password:</td>
				<td><input type="password" name="passwrd" id="passwrd" required onblur="validationEmail()"></td>
			</tr>
			<tr>
				<td style="text-align: right;font-weight: bold;">Confirm Password:</td>
				<td><input type="password" name="confirmPasswrd" id="confirmPasswrd" required onblur="validationEmail()"></td>
			</tr>
			<tr>
				
				<td colspan="2" style="text-align: center;">				
					<input type="submit" name="add" id="add" value="Register">					
					<input type="submit" name="edit" id="edit" value="Update" hidden onclick="this.form.action='../../RegisterUserController'">
					<input type="submit" name="delete" id="delete" value="Delete" hidden onclick="this.form.action='../../RegisterUserController'">					
					
				</td>
			</tr>
		</table>
		</form>
		
		<table style="width: 100%" border=1>
			<tr align="center">
				<!-- <th>Select</th>	 -->
				<th width="5%">Id</th>			
				<th>User Type</th>
				<th>Email Id</th>
			</tr>
			<%
				try{
				LoginUserService loginUserService=new LoginUserService();
				List<LoginUser> list=loginUserService.fetch();
				for(LoginUser loginUser:list){
					if(loginUser!=null){
			%>
			<tr align="center" ondblclick="showEdit(this)">
				<%-- <td><input type="radio" name="radLoginUserId" id="radLoginUserId" value="<%=loginUser.getLoginUserId()%>"></td> --%>
				<td><%=loginUser.getLoginUserId() %>					
				</td>
				
				<td><%if(loginUser.getUserTypeEntity()!=null){out.println(loginUser.getUserTypeEntity().getUserType());} %>					
				</td>
				<td><%if(loginUser.getUname()!=null){out.println(loginUser.getUname());} %>					
				</td>
				<td hidden><%if(loginUser.getUserTypeEntity()!=null){out.println(loginUser.getUserTypeEntity().getUserTypeId());} %></td>
			</tr>	
				<%		}
					}
				}catch(Exception exception){
					System.err.print("Error While Iterating Register User "+exception.getMessage());
					
				} %>
		</table>	
	
	<%@include file="../../footer.jsp" %>
</body>
</html>