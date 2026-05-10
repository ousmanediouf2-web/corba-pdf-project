package com.pdfservice.server;

import com.pdfservice.impl.PDFOperationsImpl;
import org.omg.CORBA.ORB;
import org.omg.CosNaming.NameComponent;
import org.omg.CosNaming.NamingContextExt;
import org.omg.CosNaming.NamingContextExtHelper;
import org.omg.PortableServer.POA;
import org.omg.PortableServer.POAHelper;
import pdfservice.PDFOperations;
import pdfservice.PDFOperationsHelper;

import java.util.Properties;

public class PDFServer {

    public static void main(String[] args) {
        try {
            System.out.println("=== Demarrage Serveur CORBA PDF ===");

            Properties props = new Properties();
            props.put("org.omg.CORBA.ORBInitialHost", "localhost");
            props.put("org.omg.CORBA.ORBInitialPort", "1050");

            ORB orb = ORB.init(args, props);

            POA rootPoa = POAHelper.narrow(orb.resolve_initial_references("RootPOA"));
            rootPoa.the_POAManager().activate();

            PDFOperationsImpl impl = new PDFOperationsImpl();
            byte[] id = rootPoa.activate_object(impl);
            org.omg.CORBA.Object ref = rootPoa.id_to_reference(id);
            PDFOperations pdfRef = PDFOperationsHelper.narrow(ref);

            org.omg.CORBA.Object namingRef = orb.resolve_initial_references("NameService");
            NamingContextExt nc = NamingContextExtHelper.narrow(namingRef);
            NameComponent[] path = nc.to_name("PDFService");
            nc.rebind(path, pdfRef);

            // Écrire l'IOR pour que le client puisse se connecter
            String ior = orb.object_to_string(pdfRef);
            java.nio.file.Files.write(
                java.nio.file.Paths.get("pdf_service.ior"),
                ior.getBytes()
            );

            System.out.println("=== Serveur CORBA pret sur port 1050 ===");
            orb.run();

        } catch (Exception e) {
            System.err.println("Erreur: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
