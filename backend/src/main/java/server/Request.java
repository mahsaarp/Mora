package server;

import com.google.gson.JsonObject;

public class Request<JsonObject> {
    private String route;
    private String method;
    private JsonObject payload;

    public Request() {
    }

    public Request(String route, String method, JsonObject payload) {
        this.route = route;
        this.method = method;
        this.payload = payload;
    }

    public String getRoute() {
        return route;
    }

    public void setRoute(String route) {
        this.route = route;
    }

    public String getAction() {
        return route;
    }

    public void setAction(String action) {
        this.route = action;
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
                "route='" + route + '\'' +
                ", method='" + method + '\'' +
                ", payload=" + payload +
                '}';
    }
}