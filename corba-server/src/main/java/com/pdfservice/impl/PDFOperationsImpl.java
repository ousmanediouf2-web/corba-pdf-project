package com.pdfservice.impl;

import org.apache.pdfbox.multipdf.PDFMergerUtility;
import org.apache.pdfbox.multipdf.Splitter;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.encryption.AccessPermission;
import org.apache.pdfbox.pdmodel.encryption.StandardProtectionPolicy;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.apache.pdfbox.text.PDFTextStripper;
import pdfservice.PDFOperationsPOA;
import pdfservice.PDFException;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;
import java.util.zip.*;

public class PDFOperationsImpl extends PDFOperationsPOA {

    @Override
    public byte[] mergePDFs(byte[][] pdfFiles) throws PDFException {
        try {
            PDFMergerUtility merger = new PDFMergerUtility();
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            merger.setDestinationStream(out);
            for (byte[] pdf : pdfFiles)
                merger.addSource(new ByteArrayInputStream(pdf));
            merger.mergeDocuments(null);
            return out.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur fusion: " + e.getMessage());
        }
    }

    @Override
    public byte[] splitPDF(byte[] pdfFile, int startPage, int endPage) throws PDFException {
        try (PDDocument doc = PDDocument.load(pdfFile)) {
            Splitter splitter = new Splitter();
            splitter.setStartPage(startPage);
            splitter.setEndPage(endPage);
            splitter.setSplitAtPage(endPage - startPage + 1);
            List<PDDocument> pages = splitter.split(doc);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            if (!pages.isEmpty()) {
                pages.get(0).save(out);
                for (PDDocument p : pages) p.close();
            }
            return out.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur decoupage: " + e.getMessage());
        }
    }

    @Override
    public byte[] extractPages(byte[] pdfFile, int[] pageNumbers) throws PDFException {
        try (PDDocument src = PDDocument.load(pdfFile)) {
            PDDocument result = new PDDocument();
            List<Integer> pages = new ArrayList<>();
            for (int p : pageNumbers) pages.add(p);
            for (int i = 0; i < src.getNumberOfPages(); i++)
                if (pages.contains(i + 1))
                    result.addPage(src.getPage(i));
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            result.save(out);
            result.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur extraction: " + e.getMessage());
        }
    }

    @Override
    public byte[] deletePages(byte[] pdfFile, int[] pageNumbers) throws PDFException {
        try (PDDocument doc = PDDocument.load(pdfFile)) {
            List<Integer> toDelete = new ArrayList<>();
            for (int p : pageNumbers) toDelete.add(p);
            toDelete.sort(Collections.reverseOrder());
            for (int p : toDelete)
                if (p >= 1 && p <= doc.getNumberOfPages())
                    doc.removePage(p - 1);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            doc.save(out);
            return out.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur suppression: " + e.getMessage());
        }
    }

    @Override
    public byte[] addPassword(byte[] pdfFile, String userPassword, String ownerPassword) throws PDFException {
        try (PDDocument doc = PDDocument.load(pdfFile)) {
            AccessPermission ap = new AccessPermission();
            StandardProtectionPolicy spp = new StandardProtectionPolicy(ownerPassword, userPassword, ap);
            spp.setEncryptionKeyLength(128);
            doc.protect(spp);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            doc.save(out);
            return out.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur protection: " + e.getMessage());
        }
    }

    @Override
    public byte[] convertToImages(byte[] pdfFile, float dpi) throws PDFException {
        try (PDDocument doc = PDDocument.load(pdfFile)) {
            PDFRenderer renderer = new PDFRenderer(doc);
            ByteArrayOutputStream zipStream = new ByteArrayOutputStream();
            ZipOutputStream zip = new ZipOutputStream(zipStream);
            for (int i = 0; i < doc.getNumberOfPages(); i++) {
                BufferedImage img = renderer.renderImageWithDPI(i, dpi, ImageType.RGB);
                ByteArrayOutputStream imgStream = new ByteArrayOutputStream();
                ImageIO.write(img, "PNG", imgStream);
                zip.putNextEntry(new ZipEntry("page_" + (i + 1) + ".png"));
                zip.write(imgStream.toByteArray());
                zip.closeEntry();
            }
            zip.close();
            return zipStream.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur conversion: " + e.getMessage());
        }
    }

    @Override
    public String extractText(byte[] pdfFile) throws PDFException {
        try (PDDocument doc = PDDocument.load(pdfFile)) {
            return new PDFTextStripper().getText(doc);
        } catch (Exception e) {
            throw new PDFException("Erreur extraction texte: " + e.getMessage());
        }
    }

    @Override
    public byte[] createPDF(String title, String content, String author) throws PDFException {
        try {
            PDDocument doc = new PDDocument();
            PDPage page = new PDPage(PDRectangle.A4);
            doc.addPage(page);
            PDPageContentStream cs = new PDPageContentStream(doc, page);
            cs.setFont(PDType1Font.HELVETICA_BOLD, 18);
            cs.beginText();
            cs.newLineAtOffset(50, 750);
            cs.showText(title);
            cs.endText();
            cs.setFont(PDType1Font.HELVETICA, 12);
            float y = 720;
            for (String line : content.split("\n")) {
                if (y < 50) break;
                String safe = line.length() > 90 ? line.substring(0, 90) : line;
                cs.beginText();
                cs.newLineAtOffset(50, y);
                cs.showText(safe);
                cs.endText();
                y -= 18;
            }
            cs.close();
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            doc.save(out);
            doc.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur creation: " + e.getMessage());
        }
    }

    @Override
    public int getPageCount(byte[] pdfFile) throws PDFException {
        try (PDDocument doc = PDDocument.load(pdfFile)) {
            return doc.getNumberOfPages();
        } catch (Exception e) {
            throw new PDFException("Erreur lecture: " + e.getMessage());
        }
    }

    @Override
    public String ping() {
        return "CORBA PDF Server OK";
    }
}
