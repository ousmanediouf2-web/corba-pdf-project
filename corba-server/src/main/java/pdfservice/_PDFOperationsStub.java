package pdfservice;

public class _PDFOperationsStub extends org.omg.CORBA.portable.ObjectImpl implements PDFOperations {

    public byte[] mergePDFs(byte[][] pdfFiles) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("mergePDFs", true);
            $out.write_long(pdfFiles.length);
            for (byte[] f : pdfFiles) { $out.write_long(f.length); $out.write_octet_array(f, 0, f.length); }
            $in = _invoke($out);
            int l = $in.read_long(); byte[] $result = new byte[l]; $in.read_octet_array($result, 0, l);
            return $result;
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream();
            String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) {
            return mergePDFs(pdfFiles);
        } finally { _releaseReply($in); }
    }

    public byte[] splitPDF(byte[] pdfFile, int startPage, int endPage) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("splitPDF", true);
            $out.write_long(pdfFile.length); $out.write_octet_array(pdfFile, 0, pdfFile.length);
            $out.write_long(startPage); $out.write_long(endPage);
            $in = _invoke($out);
            int l = $in.read_long(); byte[] $result = new byte[l]; $in.read_octet_array($result, 0, l);
            return $result;
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream(); String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return splitPDF(pdfFile, startPage, endPage);
        } finally { _releaseReply($in); }
    }

    public byte[] extractPages(byte[] pdfFile, int[] pageNumbers) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("extractPages", true);
            $out.write_long(pdfFile.length); $out.write_octet_array(pdfFile, 0, pdfFile.length);
            $out.write_long(pageNumbers.length); for (int p : pageNumbers) $out.write_long(p);
            $in = _invoke($out);
            int l = $in.read_long(); byte[] $result = new byte[l]; $in.read_octet_array($result, 0, l);
            return $result;
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream(); String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return extractPages(pdfFile, pageNumbers);
        } finally { _releaseReply($in); }
    }

    public byte[] deletePages(byte[] pdfFile, int[] pageNumbers) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("deletePages", true);
            $out.write_long(pdfFile.length); $out.write_octet_array(pdfFile, 0, pdfFile.length);
            $out.write_long(pageNumbers.length); for (int p : pageNumbers) $out.write_long(p);
            $in = _invoke($out);
            int l = $in.read_long(); byte[] $result = new byte[l]; $in.read_octet_array($result, 0, l);
            return $result;
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream(); String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return deletePages(pdfFile, pageNumbers);
        } finally { _releaseReply($in); }
    }

    public byte[] addPassword(byte[] pdfFile, String userPassword, String ownerPassword) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("addPassword", true);
            $out.write_long(pdfFile.length); $out.write_octet_array(pdfFile, 0, pdfFile.length);
            $out.write_string(userPassword); $out.write_string(ownerPassword);
            $in = _invoke($out);
            int l = $in.read_long(); byte[] $result = new byte[l]; $in.read_octet_array($result, 0, l);
            return $result;
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream(); String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return addPassword(pdfFile, userPassword, ownerPassword);
        } finally { _releaseReply($in); }
    }

    public byte[] convertToImages(byte[] pdfFile, float dpi) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("convertToImages", true);
            $out.write_long(pdfFile.length); $out.write_octet_array(pdfFile, 0, pdfFile.length);
            $out.write_float(dpi);
            $in = _invoke($out);
            int l = $in.read_long(); byte[] $result = new byte[l]; $in.read_octet_array($result, 0, l);
            return $result;
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream(); String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return convertToImages(pdfFile, dpi);
        } finally { _releaseReply($in); }
    }

    public String extractText(byte[] pdfFile) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("extractText", true);
            $out.write_long(pdfFile.length); $out.write_octet_array(pdfFile, 0, pdfFile.length);
            $in = _invoke($out);
            return $in.read_string();
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream(); String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return extractText(pdfFile);
        } finally { _releaseReply($in); }
    }

    public byte[] createPDF(String title, String content, String author) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("createPDF", true);
            $out.write_string(title); $out.write_string(content); $out.write_string(author);
            $in = _invoke($out);
            int l = $in.read_long(); byte[] $result = new byte[l]; $in.read_octet_array($result, 0, l);
            return $result;
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream(); String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return createPDF(title, content, author);
        } finally { _releaseReply($in); }
    }

    public int getPageCount(byte[] pdfFile) throws PDFException {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("getPageCount", true);
            $out.write_long(pdfFile.length); $out.write_octet_array(pdfFile, 0, pdfFile.length);
            $in = _invoke($out);
            return $in.read_long();
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            $in = $ex.getInputStream(); String _id = $ex.getId();
            if (_id.equals(PDFExceptionHelper.id())) throw PDFExceptionHelper.read($in);
            throw new org.omg.CORBA.MARSHAL(_id);
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return getPageCount(pdfFile);
        } finally { _releaseReply($in); }
    }

    public String ping() {
        org.omg.CORBA.portable.InputStream $in = null;
        try {
            org.omg.CORBA.portable.OutputStream $out = _request("ping", true);
            $in = _invoke($out);
            return $in.read_string();
        } catch (org.omg.CORBA.portable.ApplicationException $ex) {
            throw new org.omg.CORBA.MARSHAL($ex.getId());
        } catch (org.omg.CORBA.portable.RemarshalException $rm) { return ping();
        } finally { _releaseReply($in); }
    }

    private static String[] __ids = { "IDL:pdfservice/PDFOperations:1.0" };

    public String[] _ids() { return __ids; }

    private void readObject(java.io.ObjectInputStream s) throws java.io.IOException {
        String str = s.readUTF();
        String[] args = null;
        java.util.Properties props = null;
        org.omg.CORBA.ORB orb = org.omg.CORBA.ORB.init(args, props);
        try { org.omg.CORBA.Object obj = orb.string_to_object(str);
              org.omg.CORBA.portable.Delegate delegate = ((org.omg.CORBA.portable.ObjectImpl) obj)._get_delegate();
              _set_delegate(delegate); }
        finally { orb.destroy(); }
    }

    private void writeObject(java.io.ObjectOutputStream s) throws java.io.IOException {
        String[] args = null; java.util.Properties props = null;
        org.omg.CORBA.ORB orb = org.omg.CORBA.ORB.init(args, props);
        try { String str = orb.object_to_string(this); s.writeUTF(str); }
        finally { orb.destroy(); }
    }
}
