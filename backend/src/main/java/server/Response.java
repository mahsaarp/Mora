package server;

public class Response {
    private int statusCode;
    private String status;
    private String message;
    private Object data;

    public Response() {
    }

    public Response(int statusCode, String message, Object data) {
        this.statusCode = statusCode;
        this.status = (statusCode >= 200 && statusCode < 300) ? "success" : "fail";
        this.message = message;
        this.data = data;
    }

    public Response(String status, String message, Object data) {
        this.status = status;
        this.statusCode = ("success".equalsIgnoreCase(status) || "ok".equalsIgnoreCase(status)) ? 200 : 400;
        this.message = message;
        this.data = data;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

    public Object getPayload() {
        return data;
    }

    public void setPayload(Object payload) {
        this.data = payload;
    }

    @Override
    public String toString() {
        return "Response{" +
                "statusCode=" + statusCode +
                ", status='" + status + '\'' +
                ", message='" + message + '\'' +
                ", data=" + data +
                '}';
    }
}