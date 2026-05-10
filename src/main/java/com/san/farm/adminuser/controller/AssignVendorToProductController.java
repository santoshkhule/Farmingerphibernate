package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignVendorToProductService;
import com.san.farm.adminuser.dao.FertilizerService;
import com.san.farm.adminuser.dao.VendorService;
import com.san.farm.adminuser.entity.AssignVendorToProductEntity;
import com.san.farm.adminuser.entity.FertilizerEntity;
import com.san.farm.adminuser.entity.VendorEntity;

public class AssignVendorToProductController extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(AssignVendorToProductController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		logger.debug("Processing AssignVendorToProduct request");
		try {
			AssignVendorToProductService service = new AssignVendorToProductService();

			if (request.getParameter("add") != null) {
				int vendorId     = Integer.parseInt(request.getParameter("vendorId"));
				int fertilizerId = Integer.parseInt(request.getParameter("fertilizerId"));
				String priceStr  = request.getParameter("price");
				double price     = (priceStr != null && !priceStr.isEmpty()) ? Double.parseDouble(priceStr) : 0;

				VendorEntity vendor = new VendorEntity();
				vendor.setVendorId(vendorId);

				FertilizerEntity fertilizer = new FertilizerEntity();
				fertilizer.setFertilizerId(fertilizerId);

				AssignVendorToProductEntity entity = new AssignVendorToProductEntity();
				entity.setVendorEntity(vendor);
				entity.setFertilizerEntity(fertilizer);
				entity.setPrice(price);

				logger.info("Assigning vendor {} to product {}", vendorId, fertilizerId);
				service.save(entity);
			}

			if (request.getParameter("delete") != null) {
				int id = Integer.parseInt(request.getParameter("assignVendorProductId"));
				logger.info("Deleting assignment id: {}", id);
				service.delete(id);
			}

			if (request.getParameter("deleteSelected") != null) {
				String[] ids = request.getParameterValues("deleteIds");
				if (ids != null) {
					logger.info("Bulk deleting {} assignment(s)", ids.length);
					for (String id : ids) {
						service.delete(Integer.parseInt(id));
					}
				}
			}
		} catch (Exception e) {
			logger.error("Error processing AssignVendorToProduct request", e);
		} finally {
			response.sendRedirect("view/user/assignVendorToProduct.jsp");
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
