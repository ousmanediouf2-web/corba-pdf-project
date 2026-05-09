package com.pdfservice.server;

import com.pdfservice.impl.PDFOperationsImpl;
import org.omg.CORBA.ORB;
import org.omg.CORBA.Object;
import org.omg.CosNaming.NameComponent;
import org.omg.CosNaming.NamingContextExt;
import org.omg.CosNaming.NamingContextExtHelper;
import org.omg.PortableServer.POA;
import org.omg.PortableServer.POAHelper;
import pdfservice.PDFOperations;
import pdfservice.PDFOperationsHelper;

import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class PDFServer {

    private static final Map<String, PDFOperations> sessions = new HashMap<>();

    public static void main(String[] args) {
        try {
            System.out.println("=== Démarrage du Serveur CORBA PDF ===");

            Properties props = new Properties();
            props.put("org.omg.CORBA.ORBInitialHost", "localhost");
            props.put("org.omg.CORBA.ORBInitialPort", "1050");

            // Initialisation de l'ORB
            ORB orb = ORB.init(args, props);

            // Obtenir le POA racine et l'activer
            POA rootPoa = POAHelper.narrow(orb.resolve_initial_references("RootPOA"));
            rootPoa.the_POAManager().activate();

            // Créer l'implémentation du service PDF
            PDFOperationsImpl pdfImpl = new PDFOperationsImpl("default");

            // Activer l'objet avec le POA
            byte[] id = rootPoa.activate_object(pdfImpl);
            Object ref = rootPoa.id_to_reference(id);
            PDFOperations pdfRef = PDFOperationsHelper.narrow(ref);

            // Enregistrer dans le Naming Service
            Object namingRef = orb.resolve_initial_references("NameService");
            NamingContextExt ncRef = NamingContextExtHelper.narrow(namingRef);

            NameComponent path[] = ncRef.to_name("PDFService");
            ncRef.rebind(path, pdfRef);

            System.out.println("=== Serveur CORBA PDF démarré sur le port 1050 ===");
            System.out.println("Service enregistré sous le nom: PDFService");
            System.out.println("En attente de requêtes...");

            // Écrire l'IOR dans un fichier pour que le client web puisse le trouver
            String ior = orb.object_to_string(pdfRef);
            java.nio.file.Files.write(
                java.nio.file.Paths.get("pdf_service.ior"),
                ior.getBytes()
            );
            System.out.println("IOR écrit dans pdf_service.ior");

            orb.run();

        } catch (Exception e) {
            System.err.println("Erreur serveur CORBA: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
