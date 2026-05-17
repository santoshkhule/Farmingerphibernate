package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.sql.Date;
import java.util.Base64;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.san.farm.adminuser.dao.EmployeeInfoService;
import com.san.farm.adminuser.entity.EmployeeInfoEntity;
import com.san.farm.util.FarmUtility;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Handles employee CRUD. Photos are stored as base64 CLOB values in the DB
 * (max 255 KB source file; enforced both client-side and server-side).
 */
@MultipartConfig(maxFileSize = 261120, maxRequestSize = 786432)
public class EmployeeInfoController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(EmployeeInfoController.class);
	private static final int MAX_PHOTO_BYTES = 261120; // 255 KB

	protected void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		logger.debug("Processing EmployeeInfo request");
		try {
			String firstName        = nvl(request.getParameter("firstName"));
			String middleName       = nvl(request.getParameter("middleName"));
			String lastName         = nvl(request.getParameter("lastName"));
			String contactNo1       = nvl(request.getParameter("contactNo1"));
			String contactNo2       = nvl(request.getParameter("contactNo2"));
			String emailId          = nvl(request.getParameter("emailId"));
			String localAddress     = nvl(request.getParameter("localAddress"));
			String permanantAddress = nvl(request.getParameter("permanantAddress"));
			String bankName         = nvl(request.getParameter("bankName"));
			String accountNumber    = nvl(request.getParameter("accountNumber"));
			String comment          = nvl(request.getParameter("comment"));
			String panCardNo        = nvl(request.getParameter("panCardNo"));
			int    employeeInfoId   = 0;
			Date   birthDate        = null;

			String rawDate = request.getParameter("birthDate");
			if (rawDate != null && !rawDate.isEmpty())
				birthDate = Date.valueOf(FarmUtility.convertfrom_ddmmyyToyymmdd(rawDate));

			String rawId = request.getParameter("employeeInfoId");
			if (rawId != null && !rawId.isEmpty())
				employeeInfoId = Integer.parseInt(rawId);

			// Photo: read uploaded file, validate size, encode as full data URI
			String empPic = null;
			Part photoPart = request.getPart("fileEmpPhoto");
			if (photoPart != null && photoPart.getSize() > 0) {
				if (photoPart.getSize() > MAX_PHOTO_BYTES) {
					logger.warn("Photo rejected: {} bytes exceeds 255 KB limit", photoPart.getSize());
				} else {
					String mime = photoPart.getContentType();
					if (mime == null || mime.isEmpty()) mime = "image/jpeg";
					byte[] bytes = photoPart.getInputStream().readAllBytes();
					empPic = "data:" + mime + ";base64," + Base64.getEncoder().encodeToString(bytes);
					logger.info("Photo encoded: {} bytes -> {} chars CLOB", bytes.length, empPic.length());
				}
			}

			EmployeeInfoService employeeInfoService = new EmployeeInfoService();
			EmployeeInfoEntity  entity              = new EmployeeInfoEntity();

			entity.setFirstName(firstName);
			entity.setMiddleName(middleName);
			entity.setLastName(lastName);
			entity.setContactNo1(contactNo1);
			entity.setContactNo2(contactNo2);
			entity.setEmailId(emailId);
			entity.setBirthDate(birthDate);
			entity.setLocalAddress(localAddress);
			entity.setPerAddress(permanantAddress);
			entity.setBankName(bankName);
			entity.setAccountNumber(accountNumber);
			entity.setComment(comment);
			entity.setPanCardNo(panCardNo);
			entity.setEmpPic(empPic);

			if (request.getParameter("add") != null) {
				logger.info("Adding new employee: {} {}", firstName, lastName);
				employeeInfoService.saveAuthEmployeeInfo(entity);
				logger.info("Employee added successfully");
			}

			if (request.getParameter("edit") != null) {
				entity.setEmployeeInfoId(employeeInfoId);
				if (empPic == null) {
					// No new photo uploaded — preserve the existing CLOB value
					EmployeeInfoEntity existing = employeeInfoService.getEmployeeById(employeeInfoId);
					if (existing != null) entity.setEmpPic(existing.getEmpPic());
				}
				logger.info("Updating employee with id: {}", employeeInfoId);
				employeeInfoService.updateAuthEmployeeInfo(entity);
				logger.info("Employee updated successfully");
			}

			if (request.getParameter("delete") != null) {
				entity.setEmployeeInfoId(employeeInfoId);
				logger.info("Deleting employee with id: {}", employeeInfoId);
				employeeInfoService.deleteAuthEmployeeInfo(entity);
				logger.info("Employee deleted successfully");
			}

			if (request.getParameter("deleteBulk") != null) {
				String idsParam = request.getParameter("deleteIds");
				if (idsParam != null && !idsParam.trim().isEmpty()) {
					for (String idStr : idsParam.split(",")) {
						try {
							employeeInfoService.deleteEmployeeById(Integer.parseInt(idStr.trim()));
							logger.info("Bulk delete: employee {} deleted", idStr.trim());
						} catch (NumberFormatException nfe) {
							logger.warn("Invalid id in bulk delete: {}", idStr);
						}
					}
				}
				logger.info("Bulk delete completed");
			}
		} catch (Exception ex) {
			logger.error("Error processing EmployeeInfo request", ex);
		} finally {
			logger.debug("Redirecting to employeeViewAll.jsp");
			response.sendRedirect("view/user/employeeViewAll.jsp");
		}
	}

	private static String nvl(String s) { return s != null ? s : ""; }

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException { doProcess(request, response); }

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException { doProcess(request, response); }
}
