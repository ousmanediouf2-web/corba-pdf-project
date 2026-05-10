package com.pdfservice.util;

import org.omg.CORBA.ORB;
import org.omg.CosNaming.NamingContextExt;
import org.omg.CosNaming.NamingContextExtHelper;
import pdfservice.PDFOperations;
import pdfservice.PDFOperationsHelper;

import java.util.Properties;

public class CORBAClient {

    private static ORB orb;
    private static PDFOperations service;

    private static final String HOST = System.getProperty("corba.host", "localhost");
    private static final String PORT = System.getProperty("corba.port", "1050");

    public static synchronized PDFOperations getService() {
        if (service == null) init();
        return service;
    }

    private static void init() {
        try {
            Properties p = new Properties();
            p.put("org.omg.CORBA.ORBInitialHost", HOST);
            p.put("org.omg.CORBA.ORBInitialPort", PORT);
            orb = ORB.init(new String[]{}, p);
            org.omg.CORBA.Object ref = orb
                .resolve_initial_references("NameService");
            NamingContextExt nc = NamingContextExtHelper.narrow(ref);
            service = PDFOperationsHelper.narrow(nc.resolve_str("PDFService"));
            System.out.println("CORBA connecte " + HOST + ":" + PORT);
        } catch (Exception e) {
            System.err.println("CORBA erreur: " + e.getMessage());
            service = null;
        }
    }

    public static boolean isAlive() {
        try {
            PDFOperations s = getService();
            return s != null && s.ping() != null;
        } catch (Exception e) {
            service = null;
            return false;
        }
    }

    public static void reset() { service = null; }
}
