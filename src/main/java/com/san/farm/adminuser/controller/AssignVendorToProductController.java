package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignVendorToProductService;
import com.san.farm.adminuser.entity.AssignVendorToProductEntity;
import com.san.farm.adminuser.entity.BrandEntity;
import com.san.farm.adminuser.entity.CategoryEntity;
import com.san.farm.adminuser.entity.FertilizerEntity;
import com.san.farm.adminuser.entity.UnitEntity;
import com.san.farm.adminuser.entity.VendorEntity;

public class AssignVendorToProductController extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(AssignVendorToProductController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		logger.debug("Processing AssignVendorToProduct request");
		String vendorId      = request.getParameter("vendorId");
		String redirectTarget = request.getParameter("redirectTarget");
		try {
			AssignVendorToProductService service = new AssignVendorToProductService();

			if (request.getParameter("add") != null) {
				AssignVendorToProductEntity entity = buildEntity(request);
				logger.info("Adding assignment for vendorId={}", vendorId);
				service.save(entity);
			}

			if (request.getParameter("edit") != null) {
				int id = Integer.parseInt(request.getParameter("assignVendorProductId"));
				AssignVendorToProductEntity entity = buildEntity(request);
				entity.setAssignVendorProductId(id);
				logger.info("Updating assignment id={}", id);
				service.update(entity);
			}

			if (request.getParameter("deleteSelected") != null) {
				String[] ids = request.getParameterValues("deleteIds");
				if (ids != null) {
					logger.info("Bulk deleting {} assignment(s)", ids.length);
					for (String id : ids) service.delete(Integer.parseInt(id));
				}
			}
		} catch (Exception e) {
			logger.error("Error processing AssignVendorToProduct request", e);
		} finally {
			String redirect = resolveRedirect(redirectTarget, vendorId);
			response.sendRedirect(redirect);
		}
	}

	private AssignVendorToProductEntity buildEntity(HttpServletRequest request) {
		AssignVendorToProductEntity entity = new AssignVendorToProductEntity();

		String vid = request.getParameter("vendorId");
		if (vid != null && !vid.isEmpty()) {
			VendorEntity v = new VendorEntity(); v.setVendorId(Integer.parseInt(vid));
			entity.setVendorEntity(v);
		}
		String catId = request.getParameter("categoryId");
		if (catId != null && !catId.isEmpty()) {
			CategoryEntity c = new CategoryEntity(); c.setCategoryId(Integer.parseInt(catId));
			entity.setCategoryEntity(c);
		}
		String fid = request.getParameter("fertilizerId");
		if (fid != null && !fid.isEmpty()) {
			FertilizerEntity f = new FertilizerEntity(); f.setFertilizerId(Integer.parseInt(fid));
			entity.setFertilizerEntity(f);
		}
		String bid = request.getParameter("brandId");
		if (bid != null && !bid.isEmpty()) {
			BrandEntity b = new BrandEntity(); b.setBrandId(Integer.parseInt(bid));
			entity.setBrandEntity(b);
		}
		String uid = request.getParameter("unitId");
		if (uid != null && !uid.isEmpty()) {
			UnitEntity u = new UnitEntity(); u.setUnitId(Integer.parseInt(uid));
			entity.setUnitEntity(u);
		}
		String priceStr = request.getParameter("price");
		entity.setPrice(priceStr != null && !priceStr.isEmpty() ? Double.parseDouble(priceStr) : 0);
		entity.setProdDesc(request.getParameter("prodDesc"));
		entity.setComment(request.getParameter("comment"));
		return entity;
	}

	private String resolveRedirect(String redirectTarget, String vendorId) {
		String vid = (vendorId != null && !vendorId.isEmpty()) ? "?vendor_id=" + vendorId : "";
		if ("iframe".equals(redirectTarget))
			return "view/user/assignVendorToProductIframe.jsp" + vid;
		if ("viewIframe".equals(redirectTarget))
			return "view/user/assignVendorToProductViewIframe.jsp" + vid;
		return "view/user/assignVendorToProduct.jsp";
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException { doProcess(request, response); }

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException { doProcess(request, response); }
}
