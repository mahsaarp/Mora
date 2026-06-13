import java.time.LocalDateTime;
import java.util.*;

public class Album {
    private final int id;
    private int ownerId;
    private String name;
    private LocalDateTime date;
    private List<Integer> photoIds;
    private static final Map<Integer, Album> albums = new LinkedHashMap<>();

    public Album(int id, int ownerId, String name, LocalDateTime date) {
        this.id = id;
        this.ownerId = ownerId;
        this.name = name;
        this.date = date;
        this.photoIds = new ArrayList<>();
    }

    public void addPhoto(Photo photo) {
        if (photo != null && !photoIds.contains(photo.getId())) {
            this.photoIds.add(photo.getId());

            if (!photo.getAlbumIds().contains(this.id)) {
                photo.getAlbumIds().add(this.id);
            }
        }
    }

    public void deletePhoto(Photo photo) {
        if (photo == null) {
            return;
        }

        this.photoIds.remove(Integer.valueOf(photo.getId()));
        photo.getAlbumIds().remove(Integer.valueOf(this.id));
    }

    public void movePhoto(Photo photo, Album destAlbum) {
        if (photo == null || destAlbum == null) return;
        this.deletePhoto(photo);
        destAlbum.addPhoto(photo);
    }

    public void sortPhotosByDate() {
        this.photoIds = new ArrayList<>(
                this.photoIds.stream()
                        .map(Photo::getPhotoById)
                        .filter(Objects::nonNull)
                        .sorted(Comparator.comparing(Photo::getDate, Comparator.nullsLast(Comparator.reverseOrder())))
                        .map(Photo::getId)
                        .toList()
        );
    }

    public void sortPhotosByName() {
        this.photoIds = new ArrayList<>(
                this.photoIds.stream()
                        .map(Photo::getPhotoById)
                        .filter(Objects::nonNull)
                        .sorted(Comparator.comparing(Photo::getName, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER)))
                        .map(Photo::getId)
                        .toList()
        );
    }

    public static Album createAlbum(int ownerId, String name, LocalDateTime date) {
        int id = IdGenerator.nextAlbumId();
        Album album = new Album(id, ownerId, name, date);
        albums.put(id, album);

        User owner = User.getUsers().get(ownerId);
        if (owner != null) {
            owner.addAlbum(id);
        }

        return album;
    }

    public static void deleteAlbum(Album album) {
        if (album == null) {
            return;
        }

        User owner = User.getUsers().get(album.getOwnerId());
        if (owner != null) {
            owner.removeAlbum(album.getId());
        }

        for (Integer photoId : new ArrayList<>(album.getPhotoIds())) {
            Photo photo = Photo.getPhotoById(photoId);
            if (photo != null) {
                photo.getAlbumIds().remove(Integer.valueOf(album.getId()));
            }
        }

        albums.remove(album.getId());
    }

    static void clearAlbumsForTest() {
        albums.clear();
    }

    public int getId() {
        return id;
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

    public static Map<Integer, Album> getAlbums() {
        return new LinkedHashMap<>(albums);
    }
}
