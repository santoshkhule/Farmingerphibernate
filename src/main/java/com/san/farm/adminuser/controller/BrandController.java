package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.BrandService;
import com.san.farm.adminuser.entity.BrandEntity;

public class BrandController extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(BrandController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		logger.debug("Processing Brand request");
		try {
			BrandService brandService = new BrandService();
			BrandEntity brand = new BrandEntity();

			if (request.getParameter("add") != null) {
				brand.setBrandName(request.getParameter("brandName"));
				logger.info("Adding brand: {}", brand.getBrandName());
				brandService.saveBrand(brand);
				logger.info("Brand added successfully");
			}

			if (request.getParameter("edit") != null) {
				int brandId = Integer.parseInt(request.getParameter("brandId"));
				brand.setBrandId(brandId);
				brand.setBrandName(request.getParameter("brandName"));
				logger.info("Updating brand id: {}", brandId);
				brandService.updateBrand(brand);
				logger.info("Brand updated successfully");
			}

			if (request.getParameter("delete") != null) {
				int brandId = Integer.parseInt(request.getParameter("brandId"));
				logger.info("Deleting brand id: {}", brandId);
				brandService.deleteBrand(brandId);
				logger.info("Brand deleted successfully");
			}

			if (request.getParameter("deleteSelected") != null) {
				String[] ids = request.getParameterValues("deleteIds");
				if (ids != null) {
					logger.info("Bulk deleting {} brand(s)", ids.length);
					for (String id : ids) {
						brandService.deleteBrand(Integer.parseInt(id));
						logger.info("Deleted brand id: {}", id);
					}
				}
			}
		} catch (Exception e) {
			logger.error("Error processing Brand request", e);
		} finally {
			response.sendRedirect("view/user/configuration.jsp?tab=brand");
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
