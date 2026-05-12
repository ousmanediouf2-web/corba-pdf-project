package pdfservice;

public final class PDFException extends org.omg.CORBA.UserException {
    public String message = "";

    public PDFException() {
        super(PDFExceptionHelper.id());
    }

    public PDFException(String message) {
        super(PDFExceptionHelper.id());
        this.message = message;
    }

    public PDFException(String $reason, String message) {
        super(PDFExceptionHelper.id() + "  " + $reason);
        this.message = message;
    }
}
