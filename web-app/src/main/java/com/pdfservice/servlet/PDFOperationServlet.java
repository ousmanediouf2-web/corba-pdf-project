package com.pdfservice.servlet;

import com.pdfservice.dao.MongoDBDAO;
import com.pdfservice.model.OperationHistory;
import com.pdfservice.model.User;
import com.pdfservice.util.CORBAClient;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import pdfservice.PDFException;
import pdfservice.PDFOperations;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.*;

@WebServlet(urlPatterns = {"/pdf/*", "/operation"})
public class PDFOperationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String pathInfo = req.getPathInfo();
        if (pathInfo == null) pathInfo = "/";

        switch (pathInfo) {
            case "/merge":   forward(req, resp, "/WEB-INF/pages/op_merge.jsp"); break;
            case "/split":   forward(req, resp, "/WEB-INF/pages/op_split.jsp"); break;
            case "/extract": forward(req, resp, "/WEB-INF/pages/op_extract.jsp"); break;
            case "/delete":  forward(req, resp, "/WEB-INF/pages/op_delete.jsp"); break;
            case "/password":forward(req, resp, "/WEB-INF/pages/op_password.jsp"); break;
            case "/convert": forward(req, resp, "/WEB-INF/pages/op_convert.jsp"); break;
            case "/text":    forward(req, resp, "/WEB-INF/pages/op_text.jsp"); break;
            case "/create":  forward(req, resp, "/WEB-INF/pages/op_create.jsp"); break;
            default: resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = req.getPathInfo();
        if (pathInfo == null) pathInfo = "/";

        PDFOperations pdfService = CORBAClient.getPDFService();
        if (pdfService == null) {
            req.setAttribute("error", "Le serveur CORBA n'est pas disponible. Vérifiez que le serveur est démarré.");
            forward(req, resp, "/WEB-INF/pages/error.jsp");
            return;
        }

        try {
            switch (pathInfo) {
                case "/merge":    handleMerge(req, resp, pdfService, user); break;
                case "/split":    handleSplit(req, resp, pdfService, user); break;
                case "/extract":  handleExtract(req, resp, pdfService, user); break;
                case "/delete":   handleDelete(req, resp, pdfService, user); break;
                case "/password": handlePassword(req, resp, pdfService, user); break;
                case "/convert":  handleConvert(req, resp, pdfService, user); break;
                case "/text":     handleText(req, resp, pdfService, user); break;
                case "/create":   handleCreate(req, resp, pdfService, user); break;
                default: resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Erreur: " + e.getMessage());
            forward(req, resp, "/WEB-INF/pages/error.jsp");
        }
    }

    private void handleMerge(HttpServletRequest req, HttpServletResponse resp,
                              PDFOperations service, User user) throws Exception {
        List<FileItem> items = parseMultipart(req);
        List<byte[]> pdfBytes = new ArrayList<>();
        List<String> filenames = new ArrayList<>();

        for (FileItem item : items) {
            if (!item.isFormField() && item.getName().endsWith(".pdf")) {
                pdfBytes.add(item.get());
                filenames.add(item.getName());
            }
        }

        if (pdfBytes.size() < 2) {
            throw new Exception("Veuillez sélectionner au moins 2 fichiers PDF.");
        }

        long startTime = System.currentTimeMillis();
        byte[][] pdfArray = pdfBytes.toArray(new byte[0][]);
        byte[] result = service.mergePDFs(pdfArray, "merged.pdf");
        long duration = System.currentTimeMillis() - startTime;

        saveHistory(user, "merge", String.join(", ", filenames), "merged.pdf",
                    pdfBytes.stream().mapToLong(b -> b.length).sum(), result.length, duration);

        sendPDFResponse(resp, result, "merged.pdf");
    }

    private void handleSplit(HttpServletRequest req, HttpServletResponse resp,
                              PDFOperations service, User user) throws Exception {
        List<FileItem> items = parseMultipart(req);
        byte[] pdfData = null;
        String filename = "document.pdf";
        int startPage = 1, endPage = 1;

        for (FileItem item : items) {
            if (!item.isFormField() && item.getName().endsWith(".pdf")) {
                pdfData = item.get();
                filename = item.getName();
            } else if (item.isFormField()) {
                if ("startPage".equals(item.getFieldName()))
                    startPage = Integer.parseInt(item.getString());
                else if ("endPage".equals(item.getFieldName()))
                    endPage = Integer.parseInt(item.getString());
            }
        }

        if (pdfData == null) throw new Exception("Aucun fichier PDF sélectionné.");

        long startTime = System.currentTimeMillis();
        byte[] result = service.splitPDF(pdfData, startPage, endPage);
        long duration = System.currentTimeMillis() - startTime;

        String outName = "split_" + startPage + "_" + endPage + ".pdf";
        saveHistory(user, "split", filename, outName, pdfData.length, result.length, duration);
        sendPDFResponse(resp, result, outName);
    }

    private void handleExtract(HttpServletRequest req, HttpServletResponse resp,
                                PDFOperations service, User user) throws Exception {
        List<FileItem> items = parseMultipart(req);
        byte[] pdfData = null;
        String filename = "document.pdf";
        String pagesStr = "";

        for (FileItem item : items) {
            if (!item.isFormField() && item.getName().endsWith(".pdf")) {
                pdfData = item.get();
                filename = item.getName();
            } else if (item.isFormField() && "pages".equals(item.getFieldName())) {
                pagesStr = item.getString();
            }
        }

        if (pdfData == null) throw new Exception("Aucun fichier PDF sélectionné.");

        int[] pageNumbers = parsePageNumbers(pagesStr);
        long startTime = System.currentTimeMillis();
        byte[] result = service.extractPages(pdfData, pageNumbers);
        long duration = System.currentTimeMillis() - startTime;

        String outName = "extracted_pages.pdf";
        saveHistory(user, "extract", filename, outName, pdfData.length, result.length, duration);
        sendPDFResponse(resp, result, outName);
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp,
                               PDFOperations service, User user) throws Exception {
        List<FileItem> items = parseMultipart(req);
        byte[] pdfData = null;
        String filename = "document.pdf";
        String pagesStr = "";

        for (FileItem item : items) {
            if (!item.isFormField() && item.getName().endsWith(".pdf")) {
                pdfData = item.get();
                filename = item.getName();
            } else if (item.isFormField() && "pages".equals(item.getFieldName())) {
                pagesStr = item.getString();
            }
        }

        if (pdfData == null) throw new Exception("Aucun fichier PDF sélectionné.");

        int[] pageNumbers = parsePageNumbers(pagesStr);
        long startTime = System.currentTimeMillis();
        byte[] result = service.deletePages(pdfData, pageNumbers);
        long duration = System.currentTimeMillis() - startTime;

        String outName = "cleaned_" + filename;
        saveHistory(user, "delete", filename, outName, pdfData.length, result.length, duration);
        sendPDFResponse(resp, result, outName);
    }

    private void handlePassword(HttpServletRequest req, HttpServletResponse resp,
                                 PDFOperations service, User user) throws Exception {
        List<FileItem> items = parseMultipart(req);
        byte[] pdfData = null;
        String filename = "document.pdf";
        String userPassword = "", ownerPassword = "";

        for (FileItem item : items) {
            if (!item.isFormField() && item.getName().endsWith(".pdf")) {
                pdfData = item.get();
                filename = item.getName();
            } else if (item.isFormField()) {
                if ("userPassword".equals(item.getFieldName())) userPassword = item.getString();
                else if ("ownerPassword".equals(item.getFieldName())) ownerPassword = item.getString();
            }
        }

        if (pdfData == null) throw new Exception("Aucun fichier PDF sélectionné.");
        if (userPassword.isEmpty()) throw new Exception("Le mot de passe utilisateur est requis.");

        if (ownerPassword.isEmpty()) ownerPassword = userPassword;

        long startTime = System.currentTimeMillis();
        byte[] result = service.addPassword(pdfData, userPassword, ownerPassword);
        long duration = System.currentTimeMillis() - startTime;

        String outName = "protected_" + filename;
        saveHistory(user, "password", filename, outName, pdfData.length, result.length, duration);
        sendPDFResponse(resp, result, outName);
    }

    private void handleConvert(HttpServletRequest req, HttpServletResponse resp,
                                PDFOperations service, User user) throws Exception {
        List<FileItem> items = parseMultipart(req);
        byte[] pdfData = null;
        String filename = "document.pdf";
        float dpi = 150f;

        for (FileItem item : items) {
            if (!item.isFormField() && item.getName().endsWith(".pdf")) {
                pdfData = item.get();
                filename = item.getName();
            } else if (item.isFormField() && "dpi".equals(item.getFieldName())) {
                dpi = Float.parseFloat(item.getString());
            }
        }

        if (pdfData == null) throw new Exception("Aucun fichier PDF sélectionné.");

        long startTime = System.currentTimeMillis();
        byte[] result = service.convertToImages(pdfData, dpi);
        long duration = System.currentTimeMillis() - startTime;

        String outName = "images_" + filename.replace(".pdf", "") + ".zip";
        saveHistory(user, "convert", filename, outName, pdfData.length, result.length, duration);

        resp.setContentType("application/zip");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + outName + "\"");
        resp.setContentLength(result.length);
        resp.getOutputStream().write(result);
    }

    private void handleText(HttpServletRequest req, HttpServletResponse resp,
                             PDFOperations service, User user) throws Exception {
        List<FileItem> items = parseMultipart(req);
        byte[] pdfData = null;
        String filename = "document.pdf";

        for (FileItem item : items) {
            if (!item.isFormField() && item.getName().endsWith(".pdf")) {
                pdfData = item.get();
                filename = item.getName();
            }
        }

        if (pdfData == null) throw new Exception("Aucun fichier PDF sélectionné.");

        long startTime = System.currentTimeMillis();
        String extractedText = service.extractText(pdfData);
        long duration = System.currentTimeMillis() - startTime;

        saveHistory(user, "text", filename, "extracted_text.txt",
                    pdfData.length, extractedText.length(), duration);

        req.setAttribute("extractedText", extractedText);
        req.setAttribute("filename", filename);
        req.getRequestDispatcher("/WEB-INF/pages/op_text_result.jsp").forward(req, resp);
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp,
                               PDFOperations service, User user) throws Exception {
        String title = req.getParameter("title");
        String content = req.getParameter("content");
        String author = req.getParameter("author");

        if (title == null || title.isEmpty()) throw new Exception("Le titre est requis.");
        if (content == null || content.isEmpty()) throw new Exception("Le contenu est requis.");
        if (author == null || author.isEmpty()) author = user.getUsername();

        long startTime = System.currentTimeMillis();
        byte[] result = service.createPDF(title, content, author);
        long duration = System.currentTimeMillis() - startTime;

        String outName = title.replaceAll("[^a-zA-Z0-9]", "_") + ".pdf";
        saveHistory(user, "create", "manual_input", outName, content.length(), result.length, duration);
        sendPDFResponse(resp, result, outName);
    }

    // ==================== HELPERS ====================

    private List<FileItem> parseMultipart(HttpServletRequest req) throws Exception {
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setSizeThreshold(10 * 1024 * 1024); // 10 MB
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setFileSizeMax(50 * 1024 * 1024); // 50 MB max par fichier
        return upload.parseRequest(req);
    }

    private void sendPDFResponse(HttpServletResponse resp, byte[] data, String filename) throws IOException {
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        resp.setContentLength(data.length);
        resp.getOutputStream().write(data);
    }

    private int[] parsePageNumbers(String pagesStr) throws Exception {
        if (pagesStr == null || pagesStr.trim().isEmpty()) {
            throw new Exception("Veuillez spécifier les numéros de pages (ex: 1,3,5).");
        }
        String[] parts = pagesStr.split("[,\\s]+");
        int[] result = new int[parts.length];
        for (int i = 0; i < parts.length; i++) {
            result[i] = Integer.parseInt(parts[i].trim());
        }
        return result;
    }

    private void saveHistory(User user, String opType, String inFile, String outFile,
                              long inSize, long outSize, long duration) {
        OperationHistory op = new OperationHistory();
        op.setUserId(user.getId().toHexString());
        op.setUsername(user.getUsername());
        op.setOperationType(opType);
        op.setInputFilename(inFile);
        op.setOutputFilename(outFile);
        op.setInputSize(inSize);
        op.setOutputSize(outSize);
        op.setDurationMs(duration);
        MongoDBDAO.saveOperation(op);
    }

    private void forward(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher(page).forward(req, resp);
    }
}
