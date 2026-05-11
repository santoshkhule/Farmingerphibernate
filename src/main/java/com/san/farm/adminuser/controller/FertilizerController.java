package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.FertilizerService;
import com.san.farm.adminuser.entity.FertilizerEntity;

public class FertilizerController extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(FertilizerController.class);

	protected void doProcess(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		logger.debug("Processing Fertilizer request");
		try {
			FertilizerService service = new FertilizerService();
			FertilizerEntity entity = new FertilizerEntity();

			if (request.getParameter("add") != null) {
				entity.setFertilizerName(request.getParameter("fertilizerName"));
				logger.info("Adding fertilizer: {}", entity.getFertilizerName());
				service.save(entity);
			}

			if (request.getParameter("edit") != null) {
				entity.setFertilizerId(Integer.parseInt(request.getParameter("fertilizerId")));
				entity.setFertilizerName(request.getParameter("fertilizerName"));
				logger.info("Updating fertilizer id: {}", entity.getFertilizerId());
				service.update(entity);
			}

			if (request.getParameter("delete") != null) {
				int id = Integer.parseInt(request.getParameter("fertilizerId"));
				logger.info("Deleting fertilizer id: {}", id);
				service.delete(id);
			}

			if (request.getParameter("deleteSelected") != null) {
				String[] ids = request.getParameterValues("deleteIds");
				if (ids != null) {
					logger.info("Bulk deleting {} fertilizer(s)", ids.length);
					for (String id : ids) {
						service.delete(Integer.parseInt(id));
					}
				}
			}
		} catch (Exception e) {
			logger.error("Error processing Fertilizer request", e);
		} finally {
			response.sendRedirect("view/user/addFertilizer.jsp");
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
