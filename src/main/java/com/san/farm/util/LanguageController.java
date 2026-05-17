package com.san.farm.util;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Stores the user's chosen language in the HTTP session, then redirects
 * back to the caller (or shell.jsp as fallback).
 *
 * Usage:  <a href="LanguageController?lang=mr">मराठी</a>
 */
public class LanguageController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final Set<String> SUPPORTED = new HashSet<>(Arrays.asList("en", "hi", "mr"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String lang = request.getParameter("lang");
        if (lang != null && SUPPORTED.contains(lang)) {
            request.getSession().setAttribute("locale", lang);
        }

        String referer = request.getHeader("Referer");
        String fallback = request.getContextPath() + "/shell.jsp";
        response.sendRedirect(referer != null && !referer.isEmpty() ? referer : fallback);
    }
}
