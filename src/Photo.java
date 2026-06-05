import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Photo {
    private int id;
    private int ownerId;
    private String name;
    private LocalDateTime date;
    private List<String> tags;
    private String caption;
    private List<Integer> userLikedIds;
    private boolean commentAllowed;
    private List<Integer> albumIds;
    private List<Integer> commentIds;
    private static Map<Integer, Photo> photos = new HashMap<>();
    private String route;

    public Photo(int id, int ownerId, String name, LocalDateTime date, List<String> tags, String caption, boolean commentAllowed, String route) {
        this.id = id;
        this.ownerId = ownerId;
        this.name = name;
        this.date = date;
        this.tags = (tags != null) ? tags : new ArrayList<>();
        this.caption = caption;
        this.commentAllowed = commentAllowed;
        this.route = route;
        this.albumIds = new ArrayList<>();
        this.commentIds = new ArrayList<>();
        this.userLikedIds = new ArrayList<>();
    }

    public void like(User user) {
        userLikedIds.add(Integer.valueOf(user.getId()));
        user.getFavoritePhotoIds().add(this.id);
    }

    public void addComment(Comment comment) {
        if (!commentAllowed) {
            throw new IllegalStateException("Comments are not allowed for this photo.");
        }
        this.commentIds.add(comment.getId());
    }

    public void deleteComment(Comment comment) {
        this.commentIds.remove(Integer.valueOf(comment.getId()));
    }

    public void addTag(String tag) {
        this.tags.add(tag);
    }

    public void removeTag(String tag) {
        this.tags.remove(tag);
    }

    public void editPhoto(String newName) {
        this.name = newName;
    }

    public void editCaption(String newCaption) {
        this.caption = newCaption;
    }


    public static void sortPhotos() {

        //TO DO

    }

    public static Photo searchByName(String name) {
        for (Photo photo : photos.values()) {
            if (photo.getName()!= null && photo.getName().equals(name)) {
                return photo;
            }
        }
        return null;
    }

    public static Photo searchByTag(String tag) {
        for (Photo photo : photos.values()) {
            if (photo.getTags() != null && photo.getTags().contains(tag)) {
                return photo;
            }
        }
        return null;
    }

    public static void uploadPhoto(int id, int ownerId, String name, LocalDateTime date, List<String> tags, String caption, boolean commentAllowed, String route) {
        photos.put(id, new Photo(id, ownerId, name, date, tags, caption, commentAllowed, route));
    }

    public static void deletePhoto(Photo photo) {
        photos.remove(Integer.valueOf(photo.getId()));
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

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public String getCaption() {
        return caption;
    }

    public void setCaption(String caption) {
        this.caption = caption;
    }

    public List<Integer> getUserLikedIds() {
        return userLikedIds;
    }

    public void setUserLikedIds(List<Integer> userLikedIds) {
        this.userLikedIds = userLikedIds;
    }

    public boolean isCommentAllowed() {
        return commentAllowed;
    }

    public void setCommentAllowed(boolean commentAllowed) {
        this.commentAllowed = commentAllowed;
    }

    public List<Integer> getAlbumIds() {
        return albumIds;
    }

    public void setAlbumIds(List<Integer> albumIds) {
        this.albumIds = albumIds;
    }

    public static Map<Integer, Photo> getPhotos() {
        return photos;
    }

    public String getRoute() {
        return route;
    }

    public void setRoute(String route) {
        this.route = route;
    }

    public List<Integer> getCommentIds() {
        return commentIds;
    }

    public void setCommentIds(List<Integer> commentIds) {
        this.commentIds = commentIds;
    }
}
