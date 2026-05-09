package com.pdfservice.util;

import org.omg.CORBA.ORB;
import org.omg.CosNaming.NamingContextExt;
import org.omg.CosNaming.NamingContextExtHelper;
import pdfservice.PDFOperations;
import pdfservice.PDFOperationsHelper;

import java.util.Properties;

public class CORBAClient {

    private static ORB orb;
    private static PDFOperations pdfService;
    private static final String CORBA_HOST = System.getProperty("corba.host", "localhost");
    private static final String CORBA_PORT = System.getProperty("corba.port", "1050");

    public static synchronized PDFOperations getPDFService() {
        if (pdfService == null) {
            initCORBA();
        }
        return pdfService;
    }

    private static void initCORBA() {
        try {
            Properties props = new Properties();
            props.put("org.omg.CORBA.ORBInitialHost", CORBA_HOST);
            props.put("org.omg.CORBA.ORBInitialPort", CORBA_PORT);

            orb = ORB.init(new String[]{}, props);

            org.omg.CORBA.Object namingRef = orb.resolve_initial_references("NameService");
            NamingContextExt ncRef = NamingContextExtHelper.narrow(namingRef);

            org.omg.CORBA.Object ref = ncRef.resolve_str("PDFService");
            pdfService = PDFOperationsHelper.narrow(ref);

            System.out.println("✅ Connexion CORBA établie vers " + CORBA_HOST + ":" + CORBA_PORT);
        } catch (Exception e) {
            System.err.println("❌ Erreur connexion CORBA: " + e.getMessage());
            pdfService = null;
        }
    }

    public static boolean isConnected() {
        try {
            PDFOperations service = getPDFService();
            if (service == null) return false;
            String response = service.ping();
            return response != null && !response.isEmpty();
        } catch (Exception e) {
            pdfService = null; // Réinitialiser pour forcer reconnexion
            return false;
        }
    }

    public static void reset() {
        pdfService = null;
    }

    // Convertir tableau de bytes Java en tableau pour CORBA (byte[])
    public static byte[][] toCorbaByteArrayArray(byte[][] arrays) {
        return arrays;
    }
}
