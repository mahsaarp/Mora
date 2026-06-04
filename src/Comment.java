import java.time.LocalDate;

public class Comment {
    private int id;
    private int ownerId;
    private int photoId;
    private LocalDate date;
    private String text;

    public Comment(int id, int ownerId, int photoId, LocalDate date, String text) {
        this.id = id;
        this.ownerId = ownerId;
        this.photoId = photoId;
        this.date = date;
        this.text = text;
    }

    public int getId() {
        return id;
    }

    public int getOwnerId() {
        return ownerId;
    }

    public int getPhotoId() {
        return photoId;
    }

    public LocalDate getDate() {
        return date;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }
}
