package com.pdfservice.servlet;

import com.pdfservice.dao.MongoDBDAO;
import com.pdfservice.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login", "/logout", "/register"})
public class AuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/logout".equals(path)) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login?msg=logout");
            return;
        }

        // Redirige vers dashboard si déjà connecté
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        if ("/register".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        req.setCharacterEncoding("UTF-8");

        if ("/login".equals(path)) {
            handleLogin(req, resp);
        } else if ("/register".equals(path)) {
            handleRegister(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Veuillez remplir tous les champs.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
            return;
        }

        User user = MongoDBDAO.authenticateUser(username.trim(), password);

        if (user == null) {
            req.setAttribute("error", "Nom d'utilisateur ou mot de passe incorrect.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getId().toHexString());
        session.setAttribute("username", user.getUsername());
        session.setMaxInactiveInterval(3600); // 1 heure

        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Validations
        if (username == null || username.trim().length() < 3) {
            req.setAttribute("error", "Le nom d'utilisateur doit avoir au moins 3 caractères.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
            return;
        }

        if (email == null || !email.contains("@")) {
            req.setAttribute("error", "Adresse email invalide.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
            return;
        }

        if (password == null || password.length() < 6) {
            req.setAttribute("error", "Le mot de passe doit avoir au moins 6 caractères.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Les mots de passe ne correspondent pas.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
            return;
        }

        boolean created = MongoDBDAO.createUser(username.trim(), email.trim(), password);

        if (!created) {
            req.setAttribute("error", "Ce nom d'utilisateur ou cet email est déjà utilisé.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/login?msg=registered");
    }
}
