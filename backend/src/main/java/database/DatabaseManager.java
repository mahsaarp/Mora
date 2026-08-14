package database;

import com.google.gson.*;
import model.*;

import java.io.*;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Map;

public class DatabaseManager {

    private DatabaseData databaseData;
    private static DatabaseManager instance;

    private final Gson gson = new GsonBuilder()
            .setPrettyPrinting()
            .registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
                @Override
                public JsonElement serialize(LocalDateTime localDateTime, Type type, JsonSerializationContext jsonSerializationContext) {
                    return new JsonPrimitive(localDateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                }
            })
            .registerTypeAdapter(LocalDateTime.class, new JsonDeserializer<LocalDateTime>() {
                @Override
                public LocalDateTime deserialize(JsonElement jsonElement, Type type, JsonDeserializationContext jsonDeserializationContext) throws JsonParseException {
                    return LocalDateTime.parse(jsonElement.getAsString(), DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                }
            })
            .create();

    private DatabaseManager() {
        createDatabaseDirectoryIfNeeded();
        loadDatabase();
    }

    public static synchronized DatabaseManager getInstance() {
        if (instance == null) {
            instance = new DatabaseManager();
        }
        return instance;
    }

    private void createDatabaseDirectoryIfNeeded() {
        File file = new File("database");
        if (!file.exists()) {
            file.mkdir();
        }
    }

    public synchronized void loadDatabase() {
        File file = new File("database/database.json");
        System.out.println("Reading database from: " + file.getAbsolutePath());
        if (!file.exists()) {
            databaseData = new DatabaseData();
            saveDatabase();
            return;
        }
        try (FileReader reader = new FileReader(file)) {
            databaseData = gson.fromJson(reader, DatabaseData.class);

            if (databaseData == null) {
                databaseData = new DatabaseData();
            }

            int maxUserId = 0;
            if (databaseData.getUsers() != null) {
                User.getUsers().clear();
                for (User user : databaseData.getUsers()) {
                    User.getUsers().put(user.getId(), user);
                    if (user.getId() > maxUserId) {
                        maxUserId = user.getId();
                    }
                }
            }
            IdGenerator.setUserId(maxUserId + 1);

            int maxPhotoId = 0;
            if (databaseData.getPhotos() != null) {
                Photo.loadPhotos(databaseData.getPhotos());
                for (Photo photo : databaseData.getPhotos()) {
                    if (photo.getId() > maxPhotoId) {
                        maxPhotoId = photo.getId();
                    }
                }
            }
            IdGenerator.setPhotoId(maxPhotoId + 1);

            int maxAlbumId = 0;
            if (databaseData.getAlbums() != null) {
                Album.loadAlbums(databaseData.getAlbums());
                for (Album album : databaseData.getAlbums()) {
                    if (album.getId() > maxAlbumId) {
                        maxAlbumId = album.getId();
                    }
                }
            }
            IdGenerator.setAlbumId(maxAlbumId + 1);

            int maxCommentId = 0;
            if (databaseData.getComments() != null) {
                Comment.loadComments(databaseData.getComments());
                for (Comment comment : databaseData.getComments()) {
                    if (comment.getId() > maxCommentId) {
                        maxCommentId = comment.getId();
                    }
                }
            }
            IdGenerator.setCommentId(maxCommentId + 1);

        } catch (Exception e) {
            e.printStackTrace();
            databaseData = new DatabaseData();
        }
    }

    public synchronized void saveDatabase() {
        try {
            if (databaseData == null) {
                databaseData = new DatabaseData();
            }

            databaseData.setUsers(new ArrayList<>(User.getUsers().values()));
            databaseData.setAlbums(new ArrayList<>(Album.getAlbums().values()));
            databaseData.setPhotos(new ArrayList<>(Photo.getPhotos().values()));
            databaseData.setComments(new ArrayList<>(Comment.getComments().values()));

            File file = new File("database/database.json");
            System.out.println("Saving database to: " + file.getAbsolutePath());

            try (FileWriter writer = new FileWriter(file)) {
                gson.toJson(databaseData, writer);
                writer.flush();
                System.out.println("Database saved successfully! Photos: " + Photo.getPhotos().size() + ", Comments: " + Comment.getComments().size());
            }
        } catch (Exception e) {
            System.err.println("ERROR saving database:");
            e.printStackTrace();
        }
    }

    public synchronized void addUser(User user) {
        User.getUsers().put(user.getId(), user);
        saveDatabase();
    }

    public synchronized User getUser(int userId) {
        return User.getUsers().get(userId);
    }

    public synchronized Map<Integer, User> getAllUsers() {
        return User.getUsers();
    }

    public synchronized void addAlbum(Album album) {
        Album.getAlbums().put(album.getId(), album);
        saveDatabase();
    }

    public synchronized Album getAlbum(int albumId) {
        return Album.getAlbums().get(albumId);
    }

    public synchronized void removeAlbum(int albumId) {
        Album.getAlbums().remove(albumId);
        saveDatabase();
    }

    public synchronized Map<Integer, Album> getAllAlbums() {
        return Album.getAlbums();
    }

    public synchronized void addPhoto(Photo photo) {
        Photo.getPhotos().put(photo.getId(), photo);
        saveDatabase();
    }

    public synchronized Photo getPhoto(int photoId) {
        return Photo.getPhotos().get(photoId);
    }

    public synchronized void removePhoto(int photoId) {
        Photo.getPhotos().remove(photoId);
        saveDatabase();
    }

    public synchronized Map<Integer, Photo> getAllPhotos() {
        return Photo.getPhotos();
    }
}