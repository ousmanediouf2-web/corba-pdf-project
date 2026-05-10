package com.pdfservice.model;

public class User {
    private String id;
    private String username;
    private String email;
    private String role;

    public String getId()       { return id; }
    public void   setId(String id)           { this.id = id; }
    public String getUsername() { return username; }
    public void   setUsername(String u)      { this.username = u; }
    public String getEmail()    { return email; }
    public void   setEmail(String e)         { this.email = e; }
    public String getRole()     { return role; }
    public void   setRole(String r)          { this.role = r; }
}
