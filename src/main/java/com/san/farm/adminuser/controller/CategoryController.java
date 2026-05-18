package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.CategoryService;
import com.san.farm.adminuser.entity.CategoryEntity;

public class CategoryController extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(CategoryController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		logger.debug("Processing Category request");
		try {
			CategoryService service = new CategoryService();
			CategoryEntity entity = new CategoryEntity();

			if (request.getParameter("add") != null) {
				entity.setCategoryName(request.getParameter("categoryName"));
				logger.info("Adding category: {}", entity.getCategoryName());
				service.save(entity);
			}

			if (request.getParameter("edit") != null) {
				entity.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
				entity.setCategoryName(request.getParameter("categoryName"));
				logger.info("Updating category id: {}", entity.getCategoryId());
				service.update(entity);
			}

			if (request.getParameter("deleteSelected") != null) {
				String[] ids = request.getParameterValues("deleteIds");
				if (ids != null) {
					logger.info("Bulk deleting {} category(s)", ids.length);
					for (String id : ids) {
						service.delete(Integer.parseInt(id));
					}
				}
			}
		} catch (Exception e) {
			logger.error("Error processing Category request", e);
		} finally {
			response.sendRedirect("view/user/masterData.jsp?tab=category");
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
