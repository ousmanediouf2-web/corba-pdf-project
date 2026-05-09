package com.pdfservice.dao;

import com.mongodb.client.*;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import com.pdfservice.model.User;
import com.pdfservice.model.OperationHistory;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.mindrot.jbcrypt.BCrypt;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MongoDBDAO {

    /**
     * URI MongoDB Atlas - chargee depuis variable d'environnement MONGODB_URI
     * Pour configurer dans Tomcat: ajoutez dans setenv.bat/sh:
     *   set JAVA_OPTS=-DMONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/pdfservice
     */
    private static final String MONGODB_URI = getMongoURI();
    private static final String DB_NAME = "pdfservice";
    private static final String USERS_COLLECTION = "users";
    private static final String HISTORY_COLLECTION = "operations";

    private static MongoClient mongoClient;
    private static MongoDatabase database;

    static {
        try {
            if (MONGODB_URI == null || MONGODB_URI.contains("YOUR_USERNAME")) {
                System.err.println("MONGODB_URI non configuree - editez MongoDBDAO.java ou definissez la variable d'env");
            } else {
                mongoClient = MongoClients.create(MONGODB_URI);
                database = mongoClient.getDatabase(DB_NAME);
                database.listCollectionNames().first();
                System.out.println("Connexion MongoDB Atlas etablie");
            }
        } catch (Exception e) {
            System.err.println("Erreur connexion MongoDB: " + e.getMessage());
        }
    }

    private static String getMongoURI() {
        String env = System.getenv("MONGODB_URI");
        if (env != null && !env.isEmpty()) return env;
        String prop = System.getProperty("MONGODB_URI");
        if (prop != null && !prop.isEmpty()) return prop;
        // Remplacez ici pour le developpement local:
        return "mongodb+srv://YOUR_USERNAME:YOUR_PASSWORD@YOUR_CLUSTER.mongodb.net/pdfservice?retryWrites=true&w=majority";
    }

    private static MongoCollection<Document> getUsersCollection() {
        if (database == null) throw new RuntimeException("MongoDB non connecte");
        return database.getCollection(USERS_COLLECTION);
    }

    private static MongoCollection<Document> getHistoryCollection() {
        if (database == null) throw new RuntimeException("MongoDB non connecte");
        return database.getCollection(HISTORY_COLLECTION);
    }

    public static boolean createUser(String username, String email, String password) {
        try {
            if (findUserByUsername(username) != null) return false;
            if (findUserByEmail(email) != null) return false;
            String passwordHash = BCrypt.hashpw(password, BCrypt.gensalt(12));
            Document userDoc = new Document()
                .append("username", username).append("email", email)
                .append("passwordHash", passwordHash).append("role", "user")
                .append("active", true).append("createdAt", new Date()).append("lastLogin", null);
            getUsersCollection().insertOne(userDoc);
            return true;
        } catch (Exception e) { System.err.println("Erreur creation user: " + e.getMessage()); return false; }
    }

    public static User authenticateUser(String username, String password) {
        try {
            Document userDoc = getUsersCollection().find(Filters.eq("username", username)).first();
            if (userDoc == null) return null;
            if (!BCrypt.checkpw(password, userDoc.getString("passwordHash"))) return null;
            if (!userDoc.getBoolean("active", true)) return null;
            getUsersCollection().updateOne(Filters.eq("username", username), Updates.set("lastLogin", new Date()));
            return documentToUser(userDoc);
        } catch (Exception e) { System.err.println("Erreur auth: " + e.getMessage()); return null; }
    }

    public static User findUserByUsername(String username) {
        try { Document doc = getUsersCollection().find(Filters.eq("username", username)).first(); return doc != null ? documentToUser(doc) : null; }
        catch (Exception e) { return null; }
    }

    public static User findUserByEmail(String email) {
        try { Document doc = getUsersCollection().find(Filters.eq("email", email)).first(); return doc != null ? documentToUser(doc) : null; }
        catch (Exception e) { return null; }
    }

    public static List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        try { for (Document doc : getUsersCollection().find()) users.add(documentToUser(doc)); }
        catch (Exception e) { System.err.println("Erreur liste users: " + e.getMessage()); }
        return users;
    }

    public static void saveOperation(OperationHistory op) {
        try {
            Document doc = new Document()
                .append("userId", op.getUserId()).append("username", op.getUsername())
                .append("operationType", op.getOperationType()).append("inputFilename", op.getInputFilename())
                .append("outputFilename", op.getOutputFilename()).append("inputSize", op.getInputSize())
                .append("outputSize", op.getOutputSize()).append("status", op.getStatus())
                .append("errorMessage", op.getErrorMessage()).append("durationMs", op.getDurationMs())
                .append("createdAt", op.getCreatedAt());
            getHistoryCollection().insertOne(doc);
        } catch (Exception e) { System.err.println("Erreur sauvegarde historique: " + e.getMessage()); }
    }

    public static List<OperationHistory> getUserHistory(String userId, int limit) {
        List<OperationHistory> history = new ArrayList<>();
        try {
            for (Document doc : getHistoryCollection().find(Filters.eq("userId", userId))
                    .sort(new Document("createdAt", -1)).limit(limit))
                history.add(documentToHistory(doc));
        } catch (Exception e) { System.err.println("Erreur historique: " + e.getMessage()); }
        return history;
    }

    public static long getUserOperationCount(String userId) {
        try { return getHistoryCollection().countDocuments(Filters.eq("userId", userId)); }
        catch (Exception e) { return 0; }
    }

    private static User documentToUser(Document doc) {
        User user = new User();
        user.setId(doc.getObjectId("_id")); user.setUsername(doc.getString("username"));
        user.setEmail(doc.getString("email")); user.setPasswordHash(doc.getString("passwordHash"));
        user.setRole(doc.getString("role") != null ? doc.getString("role") : "user");
        user.setActive(doc.getBoolean("active", true));
        user.setCreatedAt(doc.getDate("createdAt")); user.setLastLogin(doc.getDate("lastLogin"));
        return user;
    }

    private static OperationHistory documentToHistory(Document doc) {
        OperationHistory op = new OperationHistory();
        op.setId(doc.getObjectId("_id")); op.setUserId(doc.getString("userId"));
        op.setUsername(doc.getString("username")); op.setOperationType(doc.getString("operationType"));
        op.setInputFilename(doc.getString("inputFilename")); op.setOutputFilename(doc.getString("outputFilename"));
        op.setInputSize(doc.getLong("inputSize") != null ? doc.getLong("inputSize") : 0L);
        op.setOutputSize(doc.getLong("outputSize") != null ? doc.getLong("outputSize") : 0L);
        op.setStatus(doc.getString("status")); op.setErrorMessage(doc.getString("errorMessage"));
        op.setDurationMs(doc.getLong("durationMs") != null ? doc.getLong("durationMs") : 0L);
        op.setCreatedAt(doc.getDate("createdAt"));
        return op;
    }
}
