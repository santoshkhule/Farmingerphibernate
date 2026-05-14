package com.san.farm.adminuser.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.BuyerService;
import com.san.farm.adminuser.entity.BuyerEntity;

/**
 * Handles Buyer CRUD operations.
 *
 * @author santosh khule
 * @version 1.0
 */
public class BuyerController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LoggerFactory.getLogger(BuyerController.class);

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logger.debug("Processing BuyerController request");
        String redirectUrl = "view/user/addBuyer.jsp";
        try {
            BuyerService buyerService = new BuyerService();

            int buyerId = 0;
            String buyerIdParam = request.getParameter("buyerId");
            if (buyerIdParam != null && !buyerIdParam.trim().isEmpty()) {
                try { buyerId = Integer.parseInt(buyerIdParam.trim()); } catch (Exception e) { buyerId = 0; }
            }

            String buyerName    = request.getParameter("buyerName")    != null ? request.getParameter("buyerName").trim()    : "";
            String buyerType    = request.getParameter("buyerType")    != null ? request.getParameter("buyerType").trim()    : "";
            String companyName  = request.getParameter("companyName")  != null ? request.getParameter("companyName").trim()  : "";
            String contactNo    = request.getParameter("contactNo")    != null ? request.getParameter("contactNo").trim()    : "";
            String address      = request.getParameter("address")      != null ? request.getParameter("address").trim()      : "";
            String email        = request.getParameter("email")        != null ? request.getParameter("email").trim()        : "";
            String comment      = request.getParameter("comment")      != null ? request.getParameter("comment").trim()      : "";

            // Add
            if (request.getParameter("add") != null) {
                logger.info("Adding new Buyer: {}", buyerName);
                BuyerEntity buyer = new BuyerEntity();
                buyer.setBuyerName(buyerName);
                buyer.setBuyerType(buyerType);
                buyer.setCompanyName(companyName);
                buyer.setContactNo(contactNo);
                buyer.setAddress(address);
                buyer.setEmail(email);
                buyer.setComment(comment);
                boolean saved = buyerService.save(buyer);
                redirectUrl = "view/user/addBuyer.jsp?" + (saved ? "msg=saved" : "err=failed");
            }

            // Edit
            else if (request.getParameter("edit") != null) {
                logger.info("Updating Buyer with id: {}", buyerId);
                BuyerEntity buyer = new BuyerEntity();
                buyer.setBuyerId(buyerId);
                buyer.setBuyerName(buyerName);
                buyer.setBuyerType(buyerType);
                buyer.setCompanyName(companyName);
                buyer.setContactNo(contactNo);
                buyer.setAddress(address);
                buyer.setEmail(email);
                buyer.setComment(comment);
                boolean updated = buyerService.update(buyer);
                redirectUrl = "view/user/addBuyer.jsp?" + (updated ? "msg=updated" : "err=failed");
            }

            // Delete
            else if (request.getParameter("delete") != null) {
                logger.info("Deleting Buyer with id: {}", buyerId);
                boolean deleted = buyerService.delete(buyerId);
                redirectUrl = "view/user/addBuyer.jsp?" + (deleted ? "msg=deleted" : "err=failed");
            }

        } catch (Exception exception) {
            logger.error("Error processing BuyerController request", exception);
            redirectUrl = "view/user/addBuyer.jsp?err=failed";
        } finally {
            logger.debug("Redirecting to: {}", redirectUrl);
            response.sendRedirect(redirectUrl);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doProcess(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doProcess(request, response);
    }
}
