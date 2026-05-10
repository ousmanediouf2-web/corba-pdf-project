package com.pdfservice.dao;

import com.mongodb.client.*;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import com.pdfservice.model.User;
import com.pdfservice.model.OperationHistory;
import org.bson.Document;
import org.mindrot.jbcrypt.BCrypt;

import java.util.*;

public class MongoDBDAO {

    private static final String URI = getURI();
    private static final String DB   = "pdfservice";
    private static MongoClient client;
    private static MongoDatabase db;

    static {
        try {
            if (URI != null && !URI.contains("YOUR_")) {
                client = MongoClients.create(URI);
                db = client.getDatabase(DB);
                db.listCollectionNames().first();
                System.out.println("MongoDB connecte");
            } else {
                System.err.println("MONGODB_URI non configuree !");
            }
        } catch (Exception e) {
            System.err.println("Erreur MongoDB: " + e.getMessage());
        }
    }

    private static String getURI() {
        String env = System.getenv("MONGODB_URI");
        if (env != null && !env.isEmpty()) return env;
        String prop = System.getProperty("MONGODB_URI");
        if (prop != null && !prop.isEmpty()) return prop;
        return "mongodb+srv://YOUR_USER:YOUR_PASS@YOUR_CLUSTER.mongodb.net/pdfservice?retryWrites=true&w=majority";
    }

    private static MongoCollection<Document> users() {
        return db.getCollection("users");
    }

    private static MongoCollection<Document> history() {
        return db.getCollection("operations");
    }

    public static boolean createUser(String username, String email, String password) {
        try {
            if (findByUsername(username) != null) return false;
            if (findByEmail(email)    != null) return false;
            users().insertOne(new Document()
                .append("username",     username)
                .append("email",        email)
                .append("passwordHash", BCrypt.hashpw(password, BCrypt.gensalt(12)))
                .append("role",         "user")
                .append("active",       true)
                .append("createdAt",    new Date()));
            return true;
        } catch (Exception e) { return false; }
    }

    public static User authenticate(String username, String password) {
        try {
            Document doc = users().find(Filters.eq("username", username)).first();
            if (doc == null) return null;
            if (!BCrypt.checkpw(password, doc.getString("passwordHash"))) return null;
            if (!doc.getBoolean("active", true)) return null;
            users().updateOne(Filters.eq("username", username),
                Updates.set("lastLogin", new Date()));
            return toUser(doc);
        } catch (Exception e) { return null; }
    }

    public static User findByUsername(String u) {
        try { Document d = users().find(Filters.eq("username", u)).first();
              return d != null ? toUser(d) : null; }
        catch (Exception e) { return null; }
    }

    public static User findByEmail(String e) {
        try { Document d = users().find(Filters.eq("email", e)).first();
              return d != null ? toUser(d) : null; }
        catch (Exception ex) { return null; }
    }

    public static void saveOp(OperationHistory op) {
        try {
            history().insertOne(new Document()
                .append("userId",        op.getUserId())
                .append("username",      op.getUsername())
                .append("operationType", op.getType())
                .append("inputFile",     op.getInputFile())
                .append("outputFile",    op.getOutputFile())
                .append("status",        op.getStatus())
                .append("durationMs",    op.getDurationMs())
                .append("createdAt",     op.getCreatedAt()));
        } catch (Exception e) { System.err.println("Erreur save op: " + e.getMessage()); }
    }

    public static List<OperationHistory> getUserHistory(String userId, int limit) {
        List<OperationHistory> list = new ArrayList<>();
        try {
            for (Document d : history()
                    .find(Filters.eq("userId", userId))
                    .sort(new Document("createdAt", -1))
                    .limit(limit))
                list.add(toHistory(d));
        } catch (Exception e) { /* ignore */ }
        return list;
    }

    public static long countOps(String userId) {
        try { return history().countDocuments(Filters.eq("userId", userId)); }
        catch (Exception e) { return 0; }
    }

    private static User toUser(Document d) {
        User u = new User();
        u.setId(d.getObjectId("_id").toHexString());
        u.setUsername(d.getString("username"));
        u.setEmail(d.getString("email"));
        u.setRole(d.getString("role") != null ? d.getString("role") : "user");
        return u;
    }

    private static OperationHistory toHistory(Document d) {
        OperationHistory op = new OperationHistory();
        op.setUserId(d.getString("userId"));
        op.setUsername(d.getString("username"));
        op.setType(d.getString("operationType"));
        op.setInputFile(d.getString("inputFile"));
        op.setOutputFile(d.getString("outputFile"));
        op.setStatus(d.getString("status"));
        op.setDurationMs(d.getLong("durationMs") != null ? d.getLong("durationMs") : 0L);
        op.setCreatedAt(d.getDate("createdAt"));
        return op;
    }
}
