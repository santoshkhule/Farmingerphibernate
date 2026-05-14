package com.san.farm.adminuser.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.UserTypeService;
import com.san.farm.adminuser.entity.UserTypeEntity;
import com.san.farm.login.dao.LoginUserService;
import com.san.farm.login.entity.LoginUser;

/**
 * Accepts requests from registerUser.jsp, performs CRUD operations on LoginUser,
 * and redirects back with status parameters.
 *
 * @author santosh khule
 * @version 2.0
 * @since 14/11/2014
 */
public class RegisterUserController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LoggerFactory.getLogger(RegisterUserController.class);

    /** Admin is identified purely by username to avoid circular type checks. */
    private boolean isAdmin(LoginUser user) {
        return user != null && "admin".equalsIgnoreCase(user.getUname());
    }

    /**
     * Resolves an array of userTypeId strings into a list of UserTypeEntity objects.
     * Null or empty input returns an empty list.
     */
    private List<UserTypeEntity> resolveTypes(String[] typeIds) {
        List<UserTypeEntity> result = new ArrayList<UserTypeEntity>();
        if (typeIds == null) return result;
        UserTypeService utSvc = new UserTypeService();
        for (String idStr : typeIds) {
            if (idStr == null || idStr.trim().isEmpty()) continue;
            try {
                int id = Integer.parseInt(idStr.trim());
                UserTypeEntity ute = utSvc.getUsertypeIdByUserTypeId(id);
                if (ute != null) {
                    result.add(ute);
                }
            } catch (NumberFormatException e) {
                logger.warn("Non-numeric userTypeId ignored: {}", idStr);
            }
        }
        return result;
    }

    protected void doProcess(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logger.debug("Processing RegisterUser request");
        String redirectUrl = "view/user/registerUser.jsp";
        try {
            LoginUserService loginUserService = new LoginUserService();

            // ── DELETE ────────────────────────────────────────────────────────
            if (request.getParameter("delete") != null) {
                long loginUserId = Long.parseLong(request.getParameter("loginUserId"));
                LoginUser toDelete = loginUserService.getLoginUserInfoByLoginId(loginUserId);
                if (isAdmin(toDelete)) {
                    logger.warn("Attempt to delete admin user with id: {} blocked", loginUserId);
                    redirectUrl = "view/user/registerUser.jsp?err=admin_protected";
                    return;
                }
                logger.info("Deleting user with id: {}", loginUserId);
                loginUserService.deleteLoginUser(loginUserId);
                logger.info("User deleted successfully");
                redirectUrl = "view/user/registerUser.jsp?msg=deleted";
                return;
            }

            String uname      = request.getParameter("username");
            String password   = request.getParameter("passwrd");
            String curPasswrd = request.getParameter("curPasswrd");

            // ── ADD ───────────────────────────────────────────────────────────
            if (request.getParameter("add") != null) {
                String[] typeIds = request.getParameterValues("userTypeIds");
                List<UserTypeEntity> types = resolveTypes(typeIds);
                LoginUser loginUser = new LoginUser();
                loginUser.setUname(uname);
                loginUser.setPassword(password);
                loginUser.setUserTypes(types);
                if (loginUserService.existsByUname(uname)) {
                    logger.warn("Duplicate username rejected: {}", uname);
                    redirectUrl = "view/user/registerUser.jsp?err=username_exists";
                } else {
                    logger.info("Registering new user: {}", uname);
                    loginUserService.saveLoginUser(loginUser);
                    logger.info("User registered successfully");
                    redirectUrl = "view/user/registerUser.jsp?msg=registered";
                }
            }

            // ── EDIT ──────────────────────────────────────────────────────────
            if (request.getParameter("edit") != null) {
                long loginUserId = Long.parseLong(request.getParameter("loginUserId"));
                LoginUser existing = loginUserService.getLoginUserInfoByLoginId(loginUserId);
                logger.debug("Validating current password for loginUserId: {}", loginUserId);
                if (existing == null || !existing.getPassword().equals(curPasswrd)) {
                    logger.warn("Password validation failed for loginUserId: {}", loginUserId);
                    redirectUrl = "view/user/registerUser.jsp?err=wrong_pwd";
                } else if (isAdmin(existing)) {
                    // Admin: only password may change; username and roles are locked.
                    existing.setPassword(password);
                    loginUserService.mergeLoginUser(existing);
                    logger.info("Admin user {} password updated successfully", loginUserId);
                    redirectUrl = "view/user/registerUser.jsp?msg=updated";
                } else {
                    // Non-admin: resolve new types, check duplicate username, update.
                    String[] typeIds = request.getParameterValues("userTypeIds");
                    List<UserTypeEntity> types = resolveTypes(typeIds);
                    LoginUser loginUser = new LoginUser();
                    loginUser.setLoginUserId(loginUserId);
                    loginUser.setUname(uname);
                    loginUser.setPassword(password);
                    loginUser.setUserTypes(types);
                    if (loginUserService.existsByUnameExcludingId(uname, loginUserId)) {
                        logger.warn("Duplicate username on edit rejected: {}", uname);
                        redirectUrl = "view/user/registerUser.jsp?err=username_exists";
                    } else {
                        loginUserService.mergeLoginUser(loginUser);
                        logger.info("User {} updated successfully", loginUserId);
                        redirectUrl = "view/user/registerUser.jsp?msg=updated";
                    }
                }
            }

        } catch (Exception ex) {
            logger.error("Error processing RegisterUser request", ex);
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
