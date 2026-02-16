package com.lab;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("text/plain");
        resp.getWriter().println("Hello from Tomcat Microservice!");
    }
}

