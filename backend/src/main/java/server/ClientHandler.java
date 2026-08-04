package server;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import controllers.AlbumController;
import controllers.PhotoController;
import controllers.UserController;

import java.io.*;
import java.net.Socket;
import java.nio.charset.StandardCharsets;

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

                System.out.println(">>> Received request length: " + line.length());

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

            case "uploadPhoto":
                return PhotoController.uploadPhoto(payload);
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
            case "addPhotoToAlbum":
                return AlbumController.addPhotoToAlbum(payload);
            case "removePhotoFromAlbum":
                return AlbumController.removePhotoFromAlbum(payload);
            case "getAlbumDetails":
                return AlbumController.getAlbumDetails(payload);

            case "getUserProfile":
                return UserController.getUserProfile(payload);

            default:
                return new Response(404, "Action not found: " + action, null);
        }
    }
}