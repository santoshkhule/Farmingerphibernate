<%@page import="java.sql.Date"%>
<%@page
	import="san.farm.adminuser.dao.AssignResourceEmployeeToFarmService"%>
<%@page import="san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="san.farm.util.FarmUtility"%>
<%@page import="san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="san.farm.adminuser.dao.AssignCropToSiteService"%>
<%@page import="san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="san.farm.adminuser.dao.ConfigCropService"%>
<%@page import="san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@page import="java.util.List"%>
<%@page import="san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<script src="../../js/jquery-1.9.1.js"></script>
<script src="../../js/jquery-ui.js"></script>
<title>Assign Crop to site</title>
</head>

<script type="text/javascript">
	/*  var showEdit=function () {
		
		/* $("h1").hide();
		//$(".myclass").slideUp("slow");
		 $(".myclass").animate({top:30},200); 
		
	}  */
	$(document).ready(function() {
		$("#move_up").click(function() {
			$("#myclass").animate({
				top : 30
			}, 200);
		});
		$("#move_Down").click(function() {
			$("#myclass").animate({
				top : 540
			}, 2000);
		});
		$("#disappear").click(function() {
			$("#myclass").toggle("slow");
		});
		$("#color").click(function() {
			$("#myclass").css("color", "purple");
		});
	});
</script>
<script>
	function loadXMLDoc() {
		alert("1");
		var xmlhttp;
		if (window.XMLHttpRequest) {
			alert("2");
			xmlhttp = new XMLHttpRequest();
		} else {
			alert("2 else");
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange = function() {
			alert("3");
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				alert("4");
				document.getElementById("myDiv").innerHTML = xmlhttp.responseText;
			}
		}
		alert("5");
		xmlhttp.open("GET", "ajax_info.txt", true);
		alert("6");
		xmlhttp.send();
	}
</script>
<body>
	<div id="myclass">
		<!-- <h1 id="h122">hello H1</h1>
<h2>hello H2</h2> -->
		hellloooooooooo.........!!!!!!!!!
	</div>
	<!-- <fieldset><legend>Configuration for Farming</legend>bhudhfsdfhsdufhsfh</fieldset>
	<fieldset><legend>Configuration for Employee</legend>bhudhfsdfhsdufhsfh</fieldset> -->
	<button id="move_up">move_up</button>
	<button id="move_Down">move_Down</button>
	<button id="color">change color</button>
	<button id="disappear">disappear</button>
	<%
		AssignResourceEmployeeToFarmService employeeToFarmService = new AssignResourceEmployeeToFarmService();
		AssignCropToSiteService service = new AssignCropToSiteService();
		Object obj = service.getTestAssignCropToSiteInfoBySiteIdDateCropId(
				5, Date.valueOf("2014-12-02"), 5);
	%>
<a onclick="loadXMLDoc"></a>


</body>
</html>