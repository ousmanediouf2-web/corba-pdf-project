package pdfservice;

public abstract class PDFOperationsPOA extends org.omg.PortableServer.Servant
    implements PDFOperations, org.omg.CORBA.portable.InvokeHandler {

    private static java.util.Hashtable _methods = new java.util.Hashtable();

    static {
        _methods.put("mergePDFs",      new java.lang.Integer(0));
        _methods.put("splitPDF",       new java.lang.Integer(1));
        _methods.put("extractPages",   new java.lang.Integer(2));
        _methods.put("deletePages",    new java.lang.Integer(3));
        _methods.put("addPassword",    new java.lang.Integer(4));
        _methods.put("convertToImages",new java.lang.Integer(5));
        _methods.put("extractText",    new java.lang.Integer(6));
        _methods.put("createPDF",      new java.lang.Integer(7));
        _methods.put("getPageCount",   new java.lang.Integer(8));
        _methods.put("ping",           new java.lang.Integer(9));
    }

    public org.omg.CORBA.portable.OutputStream _invoke(String $method,
        org.omg.CORBA.portable.InputStream in,
        org.omg.CORBA.portable.ResponseHandler $rh) {

        org.omg.CORBA.portable.OutputStream out = null;
        java.lang.Integer __method = (java.lang.Integer)_methods.get($method);
        if (__method == null) throw new org.omg.CORBA.BAD_OPERATION(0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);

        switch (__method.intValue()) {
            case 0: { // mergePDFs
                int len0 = in.read_long();
                byte[][] pdfFiles = new byte[len0][];
                for (int i0 = 0; i0 < len0; i0++) { int l = in.read_long(); pdfFiles[i0] = new byte[l]; in.read_octet_array(pdfFiles[i0], 0, l); }
                try { byte[] $result = mergePDFs(pdfFiles); out = $rh.createReply(); out.write_long($result.length); out.write_octet_array($result, 0, $result.length); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 1: { // splitPDF
                int l1 = in.read_long(); byte[] pdfFile = new byte[l1]; in.read_octet_array(pdfFile, 0, l1);
                int startPage = in.read_long(); int endPage = in.read_long();
                try { byte[] $result = splitPDF(pdfFile, startPage, endPage); out = $rh.createReply(); out.write_long($result.length); out.write_octet_array($result, 0, $result.length); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 2: { // extractPages
                int l2 = in.read_long(); byte[] pdfFile = new byte[l2]; in.read_octet_array(pdfFile, 0, l2);
                int len2 = in.read_long(); int[] pageNumbers = new int[len2]; for (int i = 0; i < len2; i++) pageNumbers[i] = in.read_long();
                try { byte[] $result = extractPages(pdfFile, pageNumbers); out = $rh.createReply(); out.write_long($result.length); out.write_octet_array($result, 0, $result.length); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 3: { // deletePages
                int l3 = in.read_long(); byte[] pdfFile = new byte[l3]; in.read_octet_array(pdfFile, 0, l3);
                int len3 = in.read_long(); int[] pageNumbers = new int[len3]; for (int i = 0; i < len3; i++) pageNumbers[i] = in.read_long();
                try { byte[] $result = deletePages(pdfFile, pageNumbers); out = $rh.createReply(); out.write_long($result.length); out.write_octet_array($result, 0, $result.length); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 4: { // addPassword
                int l4 = in.read_long(); byte[] pdfFile = new byte[l4]; in.read_octet_array(pdfFile, 0, l4);
                String userPassword = in.read_string(); String ownerPassword = in.read_string();
                try { byte[] $result = addPassword(pdfFile, userPassword, ownerPassword); out = $rh.createReply(); out.write_long($result.length); out.write_octet_array($result, 0, $result.length); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 5: { // convertToImages
                int l5 = in.read_long(); byte[] pdfFile = new byte[l5]; in.read_octet_array(pdfFile, 0, l5);
                float dpi = in.read_float();
                try { byte[] $result = convertToImages(pdfFile, dpi); out = $rh.createReply(); out.write_long($result.length); out.write_octet_array($result, 0, $result.length); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 6: { // extractText
                int l6 = in.read_long(); byte[] pdfFile = new byte[l6]; in.read_octet_array(pdfFile, 0, l6);
                try { String $result = extractText(pdfFile); out = $rh.createReply(); out.write_string($result); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 7: { // createPDF
                String title = in.read_string(); String content = in.read_string(); String author = in.read_string();
                try { byte[] $result = createPDF(title, content, author); out = $rh.createReply(); out.write_long($result.length); out.write_octet_array($result, 0, $result.length); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 8: { // getPageCount
                int l8 = in.read_long(); byte[] pdfFile = new byte[l8]; in.read_octet_array(pdfFile, 0, l8);
                try { int $result = getPageCount(pdfFile); out = $rh.createReply(); out.write_long($result); }
                catch (PDFException $ex) { out = $rh.createExceptionReply(); PDFExceptionHelper.write(out, $ex); }
                break;
            }
            case 9: { // ping
                String $result = ping(); out = $rh.createReply(); out.write_string($result);
                break;
            }
            default: throw new org.omg.CORBA.BAD_OPERATION(0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);
        }
        return out;
    }

    private static String[] __ids = { "IDL:pdfservice/PDFOperations:1.0" };

    public String[] _all_interfaces(org.omg.PortableServer.POA poa, byte[] objectId) {
        return __ids;
    }

    public PDFOperations _this() {
        return PDFOperationsHelper.narrow(super._this_object());
    }

    public PDFOperations _this(org.omg.CORBA.ORB orb) {
        return PDFOperationsHelper.narrow(super._this_object(orb));
    }
}
