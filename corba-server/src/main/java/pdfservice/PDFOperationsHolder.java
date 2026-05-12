package pdfservice;

public final class PDFOperationsHolder implements org.omg.CORBA.portable.Streamable {
    public PDFOperations value = null;

    public PDFOperationsHolder() {}

    public PDFOperationsHolder(PDFOperations initialValue) {
        value = initialValue;
    }

    public void _read(org.omg.CORBA.portable.InputStream i) {
        value = PDFOperationsHelper.read(i);
    }

    public void _write(org.omg.CORBA.portable.OutputStream o) {
        PDFOperationsHelper.write(o, value);
    }

    public org.omg.CORBA.TypeCode _type() {
        return PDFOperationsHelper.type();
    }
}
