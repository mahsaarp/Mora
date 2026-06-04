import java.time.LocalDateTime;
import java.util.*;

public class Album {
    private int id;
    private int ownerId;
    private String name;
    private LocalDateTime date;
    private List<Integer> photoIds;
    private static Map<Integer, Album> albums = new HashMap<>();

    public Album(int id, int ownerId, String name, LocalDateTime date) {
        this.id = id;
        this.ownerId = ownerId;
        this.name = name;
        this.date = date;
        this.photoIds = new ArrayList<>();
    }

    public void addPhoto(Photo photo) {
        this.photoIds.add(photo.getId());
    }

    public void deletePhoto(Photo photo) {
        this.photoIds.remove(Integer.valueOf(photo.getId()));
    }

    public void movePhoto(Photo photo, Album destAlbum) {
        this.photoIds.remove(Integer.valueOf(photo.getId()));
        destAlbum.photoIds.add(photo.getId());
    }

    public void sortPhotosByDate() {
        this.photoIds = this.photoIds.stream()
                .map(id -> Photo.getPhotos().get(id))
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(Photo::getDate).reversed())
                .map(Photo::getId)
                .toList();
    }

    public void sortPhotosByName() {
        this.photoIds = this.photoIds.stream()
                .map(id -> Photo.getPhotos().get(id))
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(photo -> photo.getName().toLowerCase()))
                .map(Photo::getId)
                .toList();
    }



    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public List<Integer> getPhotoIds() {
        return photoIds;
    }

    public void setPhotoIds(List<Integer> photoIds) {
        this.photoIds = photoIds;
    }

    public Map<Integer, Album> getAlbums() {
        return albums;
    }

    public void setAlbums(Map<Integer, Album> albums) {
        this.albums = albums;
    }
}
