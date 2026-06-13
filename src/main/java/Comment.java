import java.time.LocalDateTime;

public class Comment {
    private final int id;
    private final int ownerId;
    private final int photoId;
    private final LocalDateTime date;
    private String text;

    public Comment(int id, int ownerId, int photoId, LocalDateTime date, String text) {
        this.id = id;
        this.ownerId = ownerId;
        this.photoId = photoId;
        this.date = date;
        this.text = text;
    }

    public static Comment createComment(int ownerId, int photoId, LocalDateTime date, String text) {
        Photo photo = Photo.getPhotos().get(photoId);
        if (photo == null) {
            return null;
        }

        int id = IdGenerator.nextCommentId();
        Comment comment = new Comment(id, ownerId, photoId, date, text);

        photo.addComment(comment);

        User owner = User.getUsers().get(ownerId);
        if (owner != null) {
            owner.incrementCommentCount();
        }

        return comment;
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

    public LocalDateTime getDate() {
        return date;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }
}
