import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

public class Comment {
    private final int id;
    private final int ownerId;
    private final int photoId;
    private final LocalDateTime date;
    private String text;
    private static Map<Integer, Comment> comments = new HashMap<>();

    public Comment(int id, int ownerId, int photoId, LocalDateTime date, String text) {
        this.id = id;
        this.ownerId = ownerId;
        this.photoId = photoId;
        this.date = date;
        this.text = text;
    }

    public static Comment createComment(int ownerId, int photoId, LocalDateTime date, String text) {
        Photo photo = Photo.getPhotoById(photoId);
        if (photo == null) {
            return null;
        }

        int id = IdGenerator.nextCommentId();
        Comment comment = new Comment(id, ownerId, photoId, date, text);

        comments.put(id, comment);

        photo.addComment(comment);

        User owner = User.getUsers().get(ownerId);
        if (owner != null) {
            owner.incrementCommentCount();
        }

        return comment;
    }

    public static void deleteComment(Comment comment) {
        if (comment == null)
            return;

        Photo photo = Photo.getPhotoById(comment.getPhotoId());
        if (photo != null) {
            photo.deleteComment(comment);
        }

        comments.remove(comment.getId());
    }

    public static Map<Integer, Comment> getComments() {
        return comments;
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
