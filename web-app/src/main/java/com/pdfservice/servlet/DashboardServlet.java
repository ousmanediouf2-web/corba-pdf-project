package com.pdfservice.servlet;

import com.pdfservice.dao.MongoDBDAO;
import com.pdfservice.model.User;
import com.pdfservice.util.CORBAClient;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/dashboard", "/history"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) s.getAttribute("user");
        String userId = user.getId();

        req.setAttribute("corbaOk",  CORBAClient.isAlive());
        req.setAttribute("totalOps", MongoDBDAO.countOps(userId));

        if ("/history".equals(req.getServletPath())) {
            req.setAttribute("history", MongoDBDAO.getUserHistory(userId, 50));
            req.getRequestDispatcher("/WEB-INF/pages/history.jsp").forward(req, res);
        } else {
            req.setAttribute("recentOps", MongoDBDAO.getUserHistory(userId, 5));
            req.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(req, res);
        }
    }
}
