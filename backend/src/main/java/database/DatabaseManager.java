package database;

import com.google.gson.*;
import model.Album;
import model.Photo;
import model.User;

import java.io.*;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
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
        if (!file.exists()) {
            databaseData = new DatabaseData();
            // TODO ********** save database
            return;
        }
        try {
            FileReader reader = new FileReader(file);
            databaseData = gson.fromJson(reader, DatabaseData.class);
            reader.close();

            if (databaseData== null) {
                databaseData = new DatabaseData();
            }

            if (databaseData.getUsers() != null) {
                User.getUsers().clear();
                User.getUsers().putAll(databaseData.getUsers());
            }

            if (databaseData.getPhotos() != null) {
                Photo.getPhotos().clear();
                Photo.getPhotos().putAll(databaseData.getPhotos());
            }

            if (databaseData.getAlbums() != null) {
                Album.getAlbums().clear();
                Album.getAlbums().putAll(databaseData.getAlbums());
            }

        } catch (IOException e) {
            e.printStackTrace();
            databaseData = new DatabaseData();
        }
    }


    public synchronized void saveDatabase() {
        try {
            databaseData.setUsers(User.getUsers());
            databaseData.setAlbums(Album.getAlbums());
            databaseData.setPhotos(Photo.getPhotos());

            FileWriter writer = new FileWriter("database/database.json");
            gson.toJson(databaseData, writer);
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public synchronized void addUser(User user) {
        databaseData.getUsers().put(user.getId(), user);
        User.getUsers().put(user.getId(), user);
        saveDatabase();
    }

    public synchronized User getUser(int userId) {
        return databaseData.getUsers().get(userId);
    }

    public synchronized Map<Integer, User> getAllUsers() {
        return databaseData.getUsers();
    }

    




}
