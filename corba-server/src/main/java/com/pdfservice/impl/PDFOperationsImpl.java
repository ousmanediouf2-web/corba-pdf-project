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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class PDFOperationsImpl extends PDFOperationsPOA {

    private final String userId;

    public PDFOperationsImpl(String userId) {
        this.userId = userId;
    }

    @Override
    public byte[] mergePDFs(byte[][] pdfFiles, String outputFilename) throws PDFException {
        try {
            PDFMergerUtility merger = new PDFMergerUtility();
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            merger.setDestinationStream(outputStream);

            for (byte[] pdfData : pdfFiles) {
                merger.addSource(new ByteArrayInputStream(pdfData));
            }
            merger.mergeDocuments(null);
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur fusion PDF: " + e.getMessage());
        }
    }

    @Override
    public byte[] splitPDF(byte[] pdfFile, int startPage, int endPage) throws PDFException {
        try (PDDocument document = PDDocument.load(pdfFile)) {
            Splitter splitter = new Splitter();
            splitter.setStartPage(startPage);
            splitter.setEndPage(endPage);
            splitter.setSplitAtPage(endPage - startPage + 1);

            List<PDDocument> pages = splitter.split(document);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

            if (!pages.isEmpty()) {
                pages.get(0).save(outputStream);
                for (PDDocument page : pages) page.close();
            }
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur découpage PDF: " + e.getMessage());
        }
    }

    @Override
    public byte[] extractPages(byte[] pdfFile, int[] pageNumbers) throws PDFException {
        try (PDDocument source = PDDocument.load(pdfFile)) {
            PDDocument result = new PDDocument();
            List<Integer> pages = new ArrayList<>();
            for (int p : pageNumbers) pages.add(p);

            for (int i = 0; i < source.getNumberOfPages(); i++) {
                if (pages.contains(i + 1)) {
                    result.addPage(source.getPage(i));
                }
            }
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            result.save(outputStream);
            result.close();
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur extraction pages: " + e.getMessage());
        }
    }

    @Override
    public byte[] deletePages(byte[] pdfFile, int[] pageNumbers) throws PDFException {
        try (PDDocument document = PDDocument.load(pdfFile)) {
            List<Integer> toDelete = new ArrayList<>();
            for (int p : pageNumbers) toDelete.add(p);

            // Supprimer en ordre décroissant pour ne pas décaler les indices
            List<Integer> sorted = new ArrayList<>(toDelete);
            sorted.sort((a, b) -> b - a);

            for (int pageNum : sorted) {
                if (pageNum >= 1 && pageNum <= document.getNumberOfPages()) {
                    document.removePage(pageNum - 1);
                }
            }
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            document.save(outputStream);
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur suppression pages: " + e.getMessage());
        }
    }

    @Override
    public byte[] addPassword(byte[] pdfFile, String userPassword, String ownerPassword) throws PDFException {
        try (PDDocument document = PDDocument.load(pdfFile)) {
            AccessPermission ap = new AccessPermission();
            StandardProtectionPolicy spp = new StandardProtectionPolicy(ownerPassword, userPassword, ap);
            spp.setEncryptionKeyLength(128);
            document.protect(spp);

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            document.save(outputStream);
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur ajout mot de passe: " + e.getMessage());
        }
    }

    @Override
    public byte[] convertToImages(byte[] pdfFile, float dpi) throws PDFException {
        try (PDDocument document = PDDocument.load(pdfFile)) {
            PDFRenderer renderer = new PDFRenderer(document);
            ByteArrayOutputStream zipStream = new ByteArrayOutputStream();
            ZipOutputStream zip = new ZipOutputStream(zipStream);

            for (int i = 0; i < document.getNumberOfPages(); i++) {
                BufferedImage image = renderer.renderImageWithDPI(i, dpi, ImageType.RGB);
                ByteArrayOutputStream imgStream = new ByteArrayOutputStream();
                ImageIO.write(image, "PNG", imgStream);

                ZipEntry entry = new ZipEntry("page_" + (i + 1) + ".png");
                zip.putNextEntry(entry);
                zip.write(imgStream.toByteArray());
                zip.closeEntry();
            }
            zip.close();
            return zipStream.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur conversion images: " + e.getMessage());
        }
    }

    @Override
    public String extractText(byte[] pdfFile) throws PDFException {
        try (PDDocument document = PDDocument.load(pdfFile)) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        } catch (Exception e) {
            throw new PDFException("Erreur extraction texte: " + e.getMessage());
        }
    }

    @Override
    public byte[] createPDF(String title, String content, String author) throws PDFException {
        try {
            PDDocument document = new PDDocument();
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);

            PDPageContentStream contentStream = new PDPageContentStream(document, page);

            // Titre
            contentStream.setFont(PDType1Font.HELVETICA_BOLD, 18);
            contentStream.beginText();
            contentStream.newLineAtOffset(50, 750);
            contentStream.showText(title);
            contentStream.endText();

            // Auteur
            contentStream.setFont(PDType1Font.HELVETICA_OBLIQUE, 11);
            contentStream.beginText();
            contentStream.newLineAtOffset(50, 720);
            contentStream.showText("Auteur: " + author);
            contentStream.endText();

            // Ligne séparatrice
            contentStream.moveTo(50, 710);
            contentStream.lineTo(550, 710);
            contentStream.stroke();

            // Contenu (gestion du retour à la ligne)
            contentStream.setFont(PDType1Font.HELVETICA, 12);
            String[] lines = content.split("\n");
            float yPosition = 690;
            for (String line : lines) {
                if (yPosition < 50) {
                    contentStream.close();
                    page = new PDPage(PDRectangle.A4);
                    document.addPage(page);
                    contentStream = new PDPageContentStream(document, page);
                    contentStream.setFont(PDType1Font.HELVETICA, 12);
                    yPosition = 750;
                }
                // Tronquer les lignes trop longues
                String safeLine = line.length() > 90 ? line.substring(0, 90) + "..." : line;
                contentStream.beginText();
                contentStream.newLineAtOffset(50, yPosition);
                contentStream.showText(safeLine);
                contentStream.endText();
                yPosition -= 18;
            }

            contentStream.close();

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            document.save(outputStream);
            document.close();
            return outputStream.toByteArray();
        } catch (Exception e) {
            throw new PDFException("Erreur création PDF: " + e.getMessage());
        }
    }

    @Override
    public int getPageCount(byte[] pdfFile) throws PDFException {
        try (PDDocument document = PDDocument.load(pdfFile)) {
            return document.getNumberOfPages();
        } catch (Exception e) {
            throw new PDFException("Erreur lecture PDF: " + e.getMessage());
        }
    }

    @Override
    public String ping() {
        return "CORBA PDF Server is alive! User: " + userId;
    }
}
