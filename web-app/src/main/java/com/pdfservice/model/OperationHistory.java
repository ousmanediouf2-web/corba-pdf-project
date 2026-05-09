package com.pdfservice.model;

import org.bson.types.ObjectId;
import java.util.Date;

public class OperationHistory {
    private ObjectId id;
    private String userId;
    private String username;
    private String operationType; // merge, split, extract, delete, password, convert, text, create
    private String inputFilename;
    private String outputFilename;
    private long inputSize;
    private long outputSize;
    private String status; // success, error
    private String errorMessage;
    private Date createdAt;
    private long durationMs;

    public OperationHistory() {
        this.createdAt = new Date();
        this.status = "success";
    }

    // Getters & Setters
    public ObjectId getId() { return id; }
    public void setId(ObjectId id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getOperationType() { return operationType; }
    public void setOperationType(String operationType) { this.operationType = operationType; }

    public String getInputFilename() { return inputFilename; }
    public void setInputFilename(String inputFilename) { this.inputFilename = inputFilename; }

    public String getOutputFilename() { return outputFilename; }
    public void setOutputFilename(String outputFilename) { this.outputFilename = outputFilename; }

    public long getInputSize() { return inputSize; }
    public void setInputSize(long inputSize) { this.inputSize = inputSize; }

    public long getOutputSize() { return outputSize; }
    public void setOutputSize(long outputSize) { this.outputSize = outputSize; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public long getDurationMs() { return durationMs; }
    public void setDurationMs(long durationMs) { this.durationMs = durationMs; }

    public String getOperationLabel() {
        switch (operationType) {
            case "merge": return "Fusion PDF";
            case "split": return "Découpage PDF";
            case "extract": return "Extraction de pages";
            case "delete": return "Suppression de pages";
            case "password": return "Ajout mot de passe";
            case "convert": return "Conversion en images";
            case "text": return "Extraction de texte";
            case "create": return "Création de PDF";
            default: return operationType;
        }
    }
}
