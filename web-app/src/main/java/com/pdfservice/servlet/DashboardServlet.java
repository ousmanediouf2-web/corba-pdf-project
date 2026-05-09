package com.pdfservice.servlet;

import com.pdfservice.dao.MongoDBDAO;
import com.pdfservice.model.OperationHistory;
import com.pdfservice.model.User;
import com.pdfservice.util.CORBAClient;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/dashboard", "/history"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Vérification de la session
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String userId = user.getId().toHexString();
        String path = req.getServletPath();

        if ("/history".equals(path)) {
            List<OperationHistory> history = MongoDBDAO.getUserHistory(userId, 50);
            req.setAttribute("history", history);
            req.getRequestDispatcher("/WEB-INF/pages/history.jsp").forward(req, resp);
        } else {
            // Dashboard
            List<OperationHistory> recentOps = MongoDBDAO.getUserHistory(userId, 5);
            long totalOps = MongoDBDAO.getUserOperationCount(userId);
            boolean corbaConnected = CORBAClient.isConnected();

            req.setAttribute("recentOps", recentOps);
            req.setAttribute("totalOps", totalOps);
            req.setAttribute("corbaConnected", corbaConnected);
            req.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(req, resp);
        }
    }
}
