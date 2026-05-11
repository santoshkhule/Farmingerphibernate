package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.UnitService;
import com.san.farm.adminuser.entity.UnitEntity;

public class UnitController extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(UnitController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		logger.debug("Processing Unit request");
		try {
			UnitService service = new UnitService();
			UnitEntity entity = new UnitEntity();

			if (request.getParameter("add") != null) {
				entity.setUnitName(request.getParameter("unitName"));
				logger.info("Adding unit: {}", entity.getUnitName());
				service.save(entity);
			}

			if (request.getParameter("edit") != null) {
				entity.setUnitId(Integer.parseInt(request.getParameter("unitId")));
				entity.setUnitName(request.getParameter("unitName"));
				logger.info("Updating unit id: {}", entity.getUnitId());
				service.update(entity);
			}

			if (request.getParameter("delete") != null) {
				int id = Integer.parseInt(request.getParameter("unitId"));
				logger.info("Deleting unit id: {}", id);
				service.delete(id);
			}

			if (request.getParameter("deleteSelected") != null) {
				String[] ids = request.getParameterValues("deleteIds");
				if (ids != null) {
					logger.info("Bulk deleting {} unit(s)", ids.length);
					for (String id : ids) {
						service.delete(Integer.parseInt(id));
					}
				}
			}
		} catch (Exception e) {
			logger.error("Error processing Unit request", e);
		} finally {
			response.sendRedirect("view/user/addUnits.jsp");
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
