package server;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import controllers.AlbumController;
import controllers.PhotoController;
import controllers.UserController;

import java.io.*;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

public class ClientHandler extends Thread {
    private final Socket socket;
    private final Gson gson = new Gson();

    public ClientHandler(Socket socket) {
        this.socket = socket;
    }

    @Override
    public void run() {
        try (
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
                BufferedWriter writer = new BufferedWriter(
                        new OutputStreamWriter(socket.getOutputStream(), StandardCharsets.UTF_8))
        ) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;

                System.out.println(">>> Received request: " + (line.length() > 200 ? line.substring(0, 200) + "..." : line));

                if (line.startsWith("GET ")) {
                    String[] parts = line.split(" ");
                    if (parts.length >= 2) {
                        String path = parts[1];
                        if (path.startsWith("/")) {
                            path = path.substring(1);
                        }
                        File file = new File(path);
                        if (file.exists() && !file.isDirectory()) {
                            OutputStream out = socket.getOutputStream();
                            out.write("HTTP/1.1 200 OK\r\nContent-Type: image/jpeg\r\n\r\n".getBytes());
                            Files.copy(file.toPath(), out);
                            out.flush();
                        }
                    }
                    return;
                }

                Request request = gson.fromJson(line, Request.class);
                Response response = routeRequest(request);

                String responseString = gson.toJson(response);
                writer.write(responseString);
                writer.newLine();
                writer.flush();
            }
        } catch (IOException e) {
            System.out.println("Client disconnected or error: " + e.getMessage());
        } finally {
            try {
                socket.close();
            } catch (IOException ignored) {}
        }
    }

    private Response routeRequest(Request request) {
        String action = request.getAction();
        JsonObject payload = request.getPayload();

        if (action == null) {
            return new Response(400, "Action is null", null);
        }

        switch (action) {
            case "login":
                return UserController.login(payload);
            case "signup":
                return UserController.signup(payload);
            case "logout":
                return UserController.logout(payload);
            case "deleteAccount":
                return UserController.deleteAccount(payload);
            case "updateSettings":
                return UserController.updateSettings(payload);
            case "updateProfile":
                return UserController.updateProfile(payload);
            case "getAllUsers":
                return UserController.getAllUsers();
            case "banUser":
                return UserController.banUser(payload);
            case "unbanUser":
                return UserController.unbanUser(payload);

            case "uploadPhoto":
                return PhotoController.uploadPhoto(payload);
            case "updatePhoto":
                return PhotoController.updatePhoto(payload);
            case "deletePhoto":
                return PhotoController.deletePhoto(payload);
            case "downloadPhoto":
                return PhotoController.downloadPhoto(payload);
            case "likePhoto":
                return PhotoController.likePhoto(payload);
            case "addComment":
                return PhotoController.addComment(payload);
            case "getHomePhotos":
                return PhotoController.getHomePhotos();
            case "search":
                return PhotoController.search(payload);

            case "createAlbum":
                return AlbumController.createAlbum(payload);
            case "getAlbums":
                return AlbumController.getAlbums();
            case "addPhotoToAlbum":
                return AlbumController.addPhotoToAlbum(payload);
            case "removePhotoFromAlbum":
                return AlbumController.removePhotoFromAlbum(payload);
            case "getAlbumDetails":
                return AlbumController.getAlbumDetails(payload);
            case "deleteAlbum":
                return AlbumController.deleteAlbum(payload);

            case "getUserProfile":
                return UserController.getUserProfile(payload);

            default:
                return new Response(404, "Action not found: " + action, null);
        }
    }
}
