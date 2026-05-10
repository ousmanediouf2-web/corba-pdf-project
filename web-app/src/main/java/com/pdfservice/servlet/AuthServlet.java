package com.pdfservice.servlet;

import com.pdfservice.dao.MongoDBDAO;
import com.pdfservice.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login", "/logout", "/register"})
public class AuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/logout".equals(path)) {
            HttpSession s = req.getSession(false);
            if (s != null) s.invalidate();
            res.sendRedirect(req.getContextPath() + "/login?msg=logout");
            return;
        }
        HttpSession s = req.getSession(false);
        if (s != null && s.getAttribute("user") != null) {
            res.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        String page = "/register".equals(path) ? "/WEB-INF/pages/register.jsp"
                                                : "/WEB-INF/pages/login.jsp";
        req.getRequestDispatcher(page).forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if ("/login".equals(req.getServletPath()))    login(req, res);
        else                                          register(req, res);
    }

    private void login(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String u = req.getParameter("username");
        String p = req.getParameter("password");
        if (u == null || u.isEmpty() || p == null || p.isEmpty()) {
            req.setAttribute("error", "Remplissez tous les champs.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, res);
            return;
        }
        User user = MongoDBDAO.authenticate(u.trim(), p);
        if (user == null) {
            req.setAttribute("error", "Identifiants incorrects.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, res);
            return;
        }
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setMaxInactiveInterval(3600);
        res.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private void register(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String u  = req.getParameter("username");
        String e  = req.getParameter("email");
        String p  = req.getParameter("password");
        String p2 = req.getParameter("confirmPassword");
        if (u == null || u.trim().length() < 3) {
            req.setAttribute("error", "Username min. 3 caracteres.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, res); return;
        }
        if (e == null || !e.contains("@")) {
            req.setAttribute("error", "Email invalide.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, res); return;
        }
        if (p == null || p.length() < 6) {
            req.setAttribute("error", "Mot de passe min. 6 caracteres.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, res); return;
        }
        if (!p.equals(p2)) {
            req.setAttribute("error", "Mots de passe differents.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, res); return;
        }
        if (!MongoDBDAO.createUser(u.trim(), e.trim(), p)) {
            req.setAttribute("error", "Username ou email deja utilise.");
            req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, res); return;
        }
        res.sendRedirect(req.getContextPath() + "/login?msg=registered");
    }
}
