import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public class Album {
    private int id;
    private int ownerId;
    private String name;
    private LocalDate date;
    List<Integer> photoIds;
    private Map<Integer, Album> albums;


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

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
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
