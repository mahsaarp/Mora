package controllers;

import server.Response;
import com.google.gson.JsonObject;
import model.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Base64;

public class PhotoController {

    public static Response uploadPhoto(JsonObject payload) {
        try {
            int userId = payload.get("userId").getAsInt();
            String name = payload.get("name").getAsString();
            String caption = payload.has("caption") ? payload.get("caption").getAsString() : "";
            boolean commentAllowed = payload.has("commentAllowed") ? payload.get("commentAllowed").getAsBoolean() : true;

            byte[] bytes = Base64.getDecoder().decode(payload.get("fileData").getAsString());
            Files.createDirectories(Paths.get("photos"));

            String path = "photos/" + System.currentTimeMillis() + "_" + name + ".jpg";
            Files.write(Paths.get(path), bytes);

            Photo photo = Photo.uploadPhoto(userId, name, LocalDateTime.now(), null, caption, commentAllowed, path);
            if (photo == null) {
                return new Response(400, "error", null);
            }

            JsonObject data = new JsonObject();
            data.addProperty("photoId", photo.getId());
            data.addProperty("name", photo.getName());
            data.addProperty("route", photo.getRoute());

            return new Response(200, "OK", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response downloadPhoto(JsonObject payload) {
        try {
            int photoId = payload.get("photoId").getAsInt();
            Photo photo = Photo.getPhotoById(photoId);
            if (photo == null) {
                return new Response(404, "not found", null);
            }

            byte[] bytes = Files.readAllBytes(Paths.get(photo.getRoute()));
            JsonObject data = new JsonObject();
            data.addProperty("photoId", photo.getId());
            data.addProperty("name", photo.getName());
            data.addProperty("fileData", Base64.getEncoder().encodeToString(bytes));

            return new Response(200, "OK", data);
        } catch (IOException e) {
            return new Response(500, "io error", null);
        }
    }

    public static Response likePhoto(JsonObject payload) {
        try {
            int userId = payload.get("userId").getAsInt();
            int photoId = payload.get("photoId").getAsInt();

            User user = User.getUsers().get(userId);
            Photo photo = Photo.getPhotoById(photoId);

            if (user == null || photo == null) {
                return new Response(404, "not found", null);
            }

            photo.like(user);
            JsonObject data = new JsonObject();
            data.addProperty("likesCount", photo.getLikes());

            return new Response(200, "liked", data);
        } catch (Exception e) {
            return new Response(500, "error", null);
        }
    }

    public static Response addComment(JsonObject payload) {
        try {
            int userId = payload.get("userId").getAsInt();
            int photoId = payload.get("photoId").getAsInt();
            String text = payload.get("text").getAsString();

            Comment c = Comment.createComment(userId, photoId, LocalDateTime.now(), text);
            if (c == null) {
                return new Response(400, "failed", null);
            }

            JsonObject data = new JsonObject();
            data.addProperty("commentId", c.getId());
            data.addProperty("text", c.getText());

            return new Response(200, "comment added", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }
}