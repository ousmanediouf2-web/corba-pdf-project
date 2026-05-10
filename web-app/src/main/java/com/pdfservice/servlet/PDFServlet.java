package com.pdfservice.servlet;

import com.pdfservice.dao.MongoDBDAO;
import com.pdfservice.model.OperationHistory;
import com.pdfservice.model.User;
import com.pdfservice.util.CORBAClient;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import pdfservice.PDFOperations;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/pdf/*")
public class PDFServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!checkSession(req, res)) return;
        String op = getOp(req);
        req.setAttribute("corbaOk", CORBAClient.isAlive());
        req.getRequestDispatcher("/WEB-INF/pages/op_" + op + ".jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!checkSession(req, res)) return;

        PDFOperations svc = CORBAClient.getService();
        if (svc == null) {
            error(req, res, "Serveur CORBA non disponible.");
            return;
        }

        User user = (User) req.getSession().getAttribute("user");
        String op = getOp(req);

        try {
            switch (op) {
                case "merge":    doMerge(req, res, svc, user);    break;
                case "split":    doSplit(req, res, svc, user);    break;
                case "extract":  doExtract(req, res, svc, user);  break;
                case "delete":   doDelete(req, res, svc, user);   break;
                case "password": doPassword(req, res, svc, user); break;
                case "convert":  doConvert(req, res, svc, user);  break;
                case "text":     doText(req, res, svc, user);     break;
                case "create":   doCreate(req, res, svc, user);   break;
                default: res.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } catch (Exception e) {
            error(req, res, "Erreur : " + e.getMessage());
        }
    }

    // ── Opérations ──────────────────────────────────

    private void doMerge(HttpServletRequest req, HttpServletResponse res,
                         PDFOperations svc, User user) throws Exception {
        List<FileItem> items = parse(req);
        List<byte[]> pdfs = new ArrayList<>();
        List<String> names = new ArrayList<>();
        for (FileItem i : items)
            if (!i.isFormField() && i.getName().endsWith(".pdf")) {
                pdfs.add(i.get()); names.add(i.getName());
            }
        if (pdfs.size() < 2) throw new Exception("Minimum 2 fichiers PDF requis.");
        long t = System.currentTimeMillis();
        byte[] result = svc.mergePDFs(pdfs.toArray(new byte[0][]));
        saveHistory(user, "merge", String.join(", ", names), "merged.pdf",
                    System.currentTimeMillis() - t);
        sendPDF(res, result, "merged.pdf");
    }

    private void doSplit(HttpServletRequest req, HttpServletResponse res,
                         PDFOperations svc, User user) throws Exception {
        List<FileItem> items = parse(req);
        byte[] pdf = null; String name = "doc.pdf";
        int start = 1, end = 1;
        for (FileItem i : items) {
            if (!i.isFormField() && i.getName().endsWith(".pdf")) { pdf = i.get(); name = i.getName(); }
            else if ("startPage".equals(i.getFieldName())) start = Integer.parseInt(i.getString());
            else if ("endPage".equals(i.getFieldName()))   end   = Integer.parseInt(i.getString());
        }
        if (pdf == null) throw new Exception("Aucun fichier selectionne.");
        long t = System.currentTimeMillis();
        byte[] result = svc.splitPDF(pdf, start, end);
        saveHistory(user, "split", name, "split_p" + start + "_p" + end + ".pdf",
                    System.currentTimeMillis() - t);
        sendPDF(res, result, "split.pdf");
    }

    private void doExtract(HttpServletRequest req, HttpServletResponse res,
                            PDFOperations svc, User user) throws Exception {
        List<FileItem> items = parse(req);
        byte[] pdf = null; String name = "doc.pdf", pages = "";
        for (FileItem i : items) {
            if (!i.isFormField() && i.getName().endsWith(".pdf")) { pdf = i.get(); name = i.getName(); }
            else if ("pages".equals(i.getFieldName())) pages = i.getString();
        }
        if (pdf == null) throw new Exception("Aucun fichier selectionne.");
        long t = System.currentTimeMillis();
        byte[] result = svc.extractPages(pdf, parsePages(pages));
        saveHistory(user, "extract", name, "extracted.pdf", System.currentTimeMillis() - t);
        sendPDF(res, result, "extracted.pdf");
    }

    private void doDelete(HttpServletRequest req, HttpServletResponse res,
                           PDFOperations svc, User user) throws Exception {
        List<FileItem> items = parse(req);
        byte[] pdf = null; String name = "doc.pdf", pages = "";
        for (FileItem i : items) {
            if (!i.isFormField() && i.getName().endsWith(".pdf")) { pdf = i.get(); name = i.getName(); }
            else if ("pages".equals(i.getFieldName())) pages = i.getString();
        }
        if (pdf == null) throw new Exception("Aucun fichier selectionne.");
        long t = System.currentTimeMillis();
        byte[] result = svc.deletePages(pdf, parsePages(pages));
        saveHistory(user, "delete", name, "cleaned.pdf", System.currentTimeMillis() - t);
        sendPDF(res, result, "cleaned.pdf");
    }

    private void doPassword(HttpServletRequest req, HttpServletResponse res,
                             PDFOperations svc, User user) throws Exception {
        List<FileItem> items = parse(req);
        byte[] pdf = null; String name = "doc.pdf", up = "", op = "";
        for (FileItem i : items) {
            if (!i.isFormField() && i.getName().endsWith(".pdf")) { pdf = i.get(); name = i.getName(); }
            else if ("userPassword".equals(i.getFieldName()))  up = i.getString();
            else if ("ownerPassword".equals(i.getFieldName())) op = i.getString();
        }
        if (pdf == null) throw new Exception("Aucun fichier selectionne.");
        if (up.isEmpty()) throw new Exception("Mot de passe requis.");
        if (op.isEmpty()) op = up;
        long t = System.currentTimeMillis();
        byte[] result = svc.addPassword(pdf, up, op);
        saveHistory(user, "password", name, "protected.pdf", System.currentTimeMillis() - t);
        sendPDF(res, result, "protected.pdf");
    }

    private void doConvert(HttpServletRequest req, HttpServletResponse res,
                            PDFOperations svc, User user) throws Exception {
        List<FileItem> items = parse(req);
        byte[] pdf = null; String name = "doc.pdf"; float dpi = 150f;
        for (FileItem i : items) {
            if (!i.isFormField() && i.getName().endsWith(".pdf")) { pdf = i.get(); name = i.getName(); }
            else if ("dpi".equals(i.getFieldName())) dpi = Float.parseFloat(i.getString());
        }
        if (pdf == null) throw new Exception("Aucun fichier selectionne.");
        long t = System.currentTimeMillis();
        byte[] result = svc.convertToImages(pdf, dpi);
        saveHistory(user, "convert", name, "images.zip", System.currentTimeMillis() - t);
        res.setContentType("application/zip");
        res.setHeader("Content-Disposition", "attachment; filename=\"images.zip\"");
        res.setContentLength(result.length);
        res.getOutputStream().write(result);
    }

    private void doText(HttpServletRequest req, HttpServletResponse res,
                         PDFOperations svc, User user) throws Exception {
        List<FileItem> items = parse(req);
        byte[] pdf = null; String name = "doc.pdf";
        for (FileItem i : items)
            if (!i.isFormField() && i.getName().endsWith(".pdf")) { pdf = i.get(); name = i.getName(); }
        if (pdf == null) throw new Exception("Aucun fichier selectionne.");
        long t = System.currentTimeMillis();
        String text = svc.extractText(pdf);
        saveHistory(user, "text", name, "text.txt", System.currentTimeMillis() - t);
        req.setAttribute("text", text);
        req.setAttribute("filename", name);
        req.setAttribute("corbaOk", true);
        req.getRequestDispatcher("/WEB-INF/pages/op_text_result.jsp").forward(req, res);
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse res,
                           PDFOperations svc, User user) throws Exception {
        String title   = req.getParameter("title");
        String content = req.getParameter("content");
        String author  = req.getParameter("author");
        if (title == null || title.isEmpty())   throw new Exception("Titre requis.");
        if (content == null || content.isEmpty()) throw new Exception("Contenu requis.");
        if (author == null || author.isEmpty()) author = user.getUsername();
        long t = System.currentTimeMillis();
        byte[] result = svc.createPDF(title, content, author);
        saveHistory(user, "create", "saisie manuelle",
                    title.replaceAll("[^a-zA-Z0-9]", "_") + ".pdf",
                    System.currentTimeMillis() - t);
        sendPDF(res, result, title.replaceAll("[^a-zA-Z0-9]", "_") + ".pdf");
    }

    // ── Helpers ─────────────────────────────────────

    private String getOp(HttpServletRequest req) {
        String p = req.getPathInfo();
        return p != null ? p.replace("/", "") : "merge";
    }

    private boolean checkSession(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    private List<FileItem> parse(HttpServletRequest req) throws Exception {
        DiskFileItemFactory f = new DiskFileItemFactory();
        f.setSizeThreshold(10 * 1024 * 1024);
        ServletFileUpload up = new ServletFileUpload(f);
        up.setFileSizeMax(50 * 1024 * 1024L);
        return up.parseRequest(req);
    }

    private void sendPDF(HttpServletResponse res, byte[] data, String name) throws IOException {
        res.setContentType("application/pdf");
        res.setHeader("Content-Disposition", "attachment; filename=\"" + name + "\"");
        res.setContentLength(data.length);
        res.getOutputStream().write(data);
    }

    private int[] parsePages(String s) throws Exception {
        if (s == null || s.trim().isEmpty()) throw new Exception("Pages requises (ex: 1,3,5).");
        String[] parts = s.split("[,\\s]+");
        int[] r = new int[parts.length];
        for (int i = 0; i < parts.length; i++) r[i] = Integer.parseInt(parts[i].trim());
        return r;
    }

    private void saveHistory(User u, String type, String in, String out, long ms) {
        OperationHistory op = new OperationHistory();
        op.setUserId(u.getId()); op.setUsername(u.getUsername());
        op.setType(type); op.setInputFile(in); op.setOutputFile(out);
        op.setDurationMs(ms);
        MongoDBDAO.saveOp(op);
    }

    private void error(HttpServletRequest req, HttpServletResponse res, String msg)
            throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.setAttribute("corbaOk", false);
        req.getRequestDispatcher("/WEB-INF/pages/error.jsp").forward(req, res);
    }
}
