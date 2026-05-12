package pdfservice;

public interface PDFOperationsOperations {
    byte[] mergePDFs(byte[][] pdfFiles) throws PDFException;
    byte[] splitPDF(byte[] pdfFile, int startPage, int endPage) throws PDFException;
    byte[] extractPages(byte[] pdfFile, int[] pageNumbers) throws PDFException;
    byte[] deletePages(byte[] pdfFile, int[] pageNumbers) throws PDFException;
    byte[] addPassword(byte[] pdfFile, String userPassword, String ownerPassword) throws PDFException;
    byte[] convertToImages(byte[] pdfFile, float dpi) throws PDFException;
    String extractText(byte[] pdfFile) throws PDFException;
    byte[] createPDF(String title, String content, String author) throws PDFException;
    int getPageCount(byte[] pdfFile) throws PDFException;
    String ping();
}
