package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.VendorService;
import com.san.farm.adminuser.entity.VendorEntity;

public class VendorController extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(VendorController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		logger.debug("Processing Vendor request");
		try {
			VendorService service = new VendorService();
			VendorEntity entity = new VendorEntity();

			if (request.getParameter("add") != null) {
				entity.setVendorName(request.getParameter("vendorName"));
				entity.setShopName(request.getParameter("shopName"));
				entity.setPerContactNo(request.getParameter("perContactNo"));
				entity.setOfcContactNo(request.getParameter("ofcContactNo"));
				entity.setAddress(request.getParameter("address"));
				entity.setEmailId(request.getParameter("emailId"));
				logger.info("Adding vendor: {}", entity.getVendorName());
				service.save(entity);
			}

			if (request.getParameter("edit") != null) {
				entity.setVendorId(Integer.parseInt(request.getParameter("vendorId")));
				entity.setVendorName(request.getParameter("vendorName"));
				entity.setShopName(request.getParameter("shopName"));
				entity.setPerContactNo(request.getParameter("perContactNo"));
				entity.setOfcContactNo(request.getParameter("ofcContactNo"));
				entity.setAddress(request.getParameter("address"));
				entity.setEmailId(request.getParameter("emailId"));
				logger.info("Updating vendor id: {}", entity.getVendorId());
				service.update(entity);
			}

			if (request.getParameter("delete") != null) {
				int id = Integer.parseInt(request.getParameter("vendorId"));
				logger.info("Deleting vendor id: {}", id);
				service.delete(id);
			}

			if (request.getParameter("deleteSelected") != null) {
				String[] ids = request.getParameterValues("deleteIds");
				if (ids != null) {
					logger.info("Bulk deleting {} vendor(s)", ids.length);
					for (String id : ids) {
						service.delete(Integer.parseInt(id));
					}
				}
			}
		} catch (Exception e) {
			logger.error("Error processing Vendor request", e);
		} finally {
			response.sendRedirect("view/user/addVendor.jsp");
		}
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doProcess(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doProcess(request, response);
	}
}
