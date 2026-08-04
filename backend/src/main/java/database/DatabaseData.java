package database;

import model.Album;
import model.Photo;
import model.User;

import java.util.ArrayList;
import java.util.List;

public class DatabaseData {

    private List<User> users = new ArrayList<>();
    private List<Album> albums = new ArrayList<>();
    private List<Photo> photos = new ArrayList<>();

    public List<User> getUsers() {
        return users;
    }

    public void setUsers(List<User> users) {
        this.users = users;
    }

    public List<Album> getAlbums() {
        return albums;
    }

    public void setAlbums(List<Album> albums) {
        this.albums = albums;
    }

    public List<Photo> getPhotos() {
        return photos;
    }

    public void setPhotos(List<Photo> photos) {
        this.photos = photos;
    }
}