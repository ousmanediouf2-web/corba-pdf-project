package com.pdfservice.servlet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/health")
public class HealthServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("text/plain");
        res.setStatus(200);
        res.getWriter().write("OK - CORBA PDF Service is alive");
    }
}
