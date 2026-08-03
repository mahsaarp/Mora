package controllers;

import server.Response;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import model.*;

public class AlbumController {

    public static Response createAlbum(JsonObject payload) {
        try {
            int userId = payload.get("userId").getAsInt();
            String name = payload.get("albumName").getAsString();

            if (User.getUsers().get(userId) == null) {
                return new Response(404, "User not found", null);
            }

            Album album = Album.createAlbum(userId, name);
            JsonObject data = new JsonObject();
            data.addProperty("albumId", album.getId());
            data.addProperty("albumName", album.getName());

            return new Response(200, "Album created", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response addPhotoToAlbum(JsonObject payload) {
        try {
            int albumId = payload.get("albumId").getAsInt();
            int photoId = payload.get("photoId").getAsInt();

            Album album = Album.getAlbumById(albumId);
            Photo photo = Photo.getPhotoById(photoId);

            if (album == null || photo == null) {
                return new Response(404, "Not found", null);
            }

            if (!album.addPhoto(photo)) {
                return new Response(400, "Already in album", null);
            }

            return new Response(200, "Added", null);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response removePhotoFromAlbum(JsonObject payload) {
        try {
            int albumId = payload.get("albumId").getAsInt();
            int photoId = payload.get("photoId").getAsInt();

            Album album = Album.getAlbumById(albumId);
            Photo photo = Photo.getPhotoById(photoId);

            if (album == null || photo == null || !album.removePhoto(photo)) {
                return new Response(400, "Error removing photo", null);
            }

            return new Response(200, "Removed", null);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }

    public static Response getAlbumDetails(JsonObject payload) {
        try {
            int albumId = payload.get("albumId").getAsInt();
            Album album = Album.getAlbumById(albumId);
            if (album == null) {
                return new Response(404, "Album not found", null);
            }

            JsonObject data = new JsonObject();
            data.addProperty("albumId", album.getId());
            data.addProperty("albumName", album.getName());

            JsonArray arr = new JsonArray();
            for (Photo p : album.getPhotos()) {
                JsonObject o = new JsonObject();
                o.addProperty("photoId", p.getId());
                o.addProperty("name", p.getName());
                o.addProperty("route", p.getRoute());
                arr.add(o);
            }
            data.add("photos", arr);

            return new Response(200, "OK", data);
        } catch (Exception e) {
            return new Response(500, e.getMessage(), null);
        }
    }
}