package database;

import model.Album;
import model.Photo;
import model.User;

import java.util.HashMap;
import java.util.Map;

public class DatabaseData {

    private Map<Integer, User> users = new HashMap<>();
    private Map<Integer, Album> albums = new HashMap<>();
    private Map<Integer, Photo> photos = new HashMap<>();

    public Map<Integer, User> getUsers() {
        return users;
    }

    public void setUsers(Map<Integer, User> users) {
        this.users = users;
    }

    public Map<Integer, Album> getAlbums() {
        return albums;
    }

    public void setAlbums(Map<Integer, Album> albums) {
        this.albums = albums;
    }

    public Map<Integer, Photo> getPhotos() {
        return photos;
    }

    public void setPhotos(Map<Integer, Photo> photos) {
        this.photos = photos;
    }
}
