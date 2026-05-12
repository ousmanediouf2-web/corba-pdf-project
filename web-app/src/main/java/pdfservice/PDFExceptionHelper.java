package pdfservice;

public abstract class PDFExceptionHelper {
    private static String _id = "IDL:pdfservice/PDFException:1.0";

    public static void insert(org.omg.CORBA.Any a, PDFException that) {
        org.omg.CORBA.portable.OutputStream out = a.create_output_stream();
        a.type(type());
        write(out, that);
        a.read_value(out.create_input_stream(), type());
    }

    public static PDFException extract(org.omg.CORBA.Any a) {
        return read(a.create_input_stream());
    }

    private static org.omg.CORBA.TypeCode __typeCode = null;

    synchronized public static org.omg.CORBA.TypeCode type() {
        if (__typeCode == null) {
            org.omg.CORBA.StructMember[] _members0 = new org.omg.CORBA.StructMember[1];
            org.omg.CORBA.TypeCode _tcOf_members0 = null;
            _tcOf_members0 = org.omg.CORBA.ORB.init().get_primitive_tc(org.omg.CORBA.TCKind.tk_string);
            _members0[0] = new org.omg.CORBA.StructMember("message", _tcOf_members0, null);
            __typeCode = org.omg.CORBA.ORB.init().create_exception_tc(id(), "PDFException", _members0);
        }
        return __typeCode;
    }

    public static String id() { return _id; }

    public static PDFException read(org.omg.CORBA.portable.InputStream istream) {
        PDFException value = new PDFException();
        istream.read_string(); // repository ID
        value.message = istream.read_string();
        return value;
    }

    public static void write(org.omg.CORBA.portable.OutputStream ostream, PDFException value) {
        ostream.write_string(id());
        ostream.write_string(value.message);
    }
}
