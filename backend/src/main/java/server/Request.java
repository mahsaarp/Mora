package server;

import com.google.gson.JsonObject;

public class Request {
    private String action;
    private String method;
    private JsonObject payload;

    public Request() {
    }

    public Request(String route, String method, JsonObject payload) {
        this.action = route;
        this.method = method;
        this.payload = payload;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public JsonObject getPayload() {
        return payload;
    }

    public void setPayload(JsonObject payload) {
        this.payload = payload;
    }

    @Override
    public String toString() {
        return "Request{" +
                "route='" + action + '\'' +
                ", method='" + method + '\'' +
                ", payload=" + payload +
                '}';
    }
}