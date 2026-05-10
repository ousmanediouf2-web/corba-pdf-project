package com.pdfservice.model;

import java.util.Date;

public class OperationHistory {
    private String userId;
    private String username;
    private String type;
    private String inputFile;
    private String outputFile;
    private String status = "success";
    private long   durationMs;
    private Date   createdAt = new Date();

    public String getUserId()    { return userId; }
    public void   setUserId(String v)    { this.userId = v; }
    public String getUsername()  { return username; }
    public void   setUsername(String v)  { this.username = v; }
    public String getType()      { return type; }
    public void   setType(String v)      { this.type = v; }
    public String getInputFile() { return inputFile; }
    public void   setInputFile(String v) { this.inputFile = v; }
    public String getOutputFile(){ return outputFile; }
    public void   setOutputFile(String v){ this.outputFile = v; }
    public String getStatus()    { return status; }
    public void   setStatus(String v)    { this.status = v; }
    public long   getDurationMs(){ return durationMs; }
    public void   setDurationMs(long v)  { this.durationMs = v; }
    public Date   getCreatedAt() { return createdAt; }
    public void   setCreatedAt(Date v)   { this.createdAt = v; }

    public String getTypeLabel() {
        switch (type != null ? type : "") {
            case "merge":    return "Fusion PDF";
            case "split":    return "Decoupage";
            case "extract":  return "Extraction pages";
            case "delete":   return "Suppression pages";
            case "password": return "Mot de passe";
            case "convert":  return "PDF vers Images";
            case "text":     return "Extraction texte";
            case "create":   return "Creation PDF";
            default:         return type;
        }
    }
}
