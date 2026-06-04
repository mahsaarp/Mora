import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public class Photo {
    private int id;
    private int ownerId;
    private String name;
    private LocalDate date;
    private List<String> tags;
    private String caption;
    private int likes;
    private boolean commentAllowed;
    private List<Integer> albumIds;
    private List<Integer> commentIds;
    private Map<Integer, Photo> photos;
    private String route;


    public void like(User user, int id) {

        // TO DO

    }

    public void addComment(Comment comment) {
        this.commentIds.add(comment.getId());
    }

    public void addTag(String tag) {
        this.tags.add(tag);
    }

    public void editCaption(String newCaption) {
        this.caption = newCaption;
    }

    public static void sortPhotos() {

        //TO DO

    }

    public static Photo searchByName(String name) {
        for (Map<Integer, Photo> photo : this.photos) {

        }
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

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
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

    public int getLikes() {
        return likes;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }

    public boolean isCommentAllowed() {
        return commentAllowed;
    }

    public void setCommentAllowed(boolean commentAllowed) {
        this.commentAllowed = commentAllowed;
    }

    public List<Album> getAlbumIds() {
        return albumIds;
    }

    public void setAlbumIds(List<Album> albumIds) {
        this.albumIds = albumIds;
    }

    public Map<Integer, Photo> getPhotos() {
        return photos;
    }

    public void setPhotos(Map<Integer, Photo> photos) {
        this.photos = photos;
    }

    public String getRoute() {
        return route;
    }

    public void setRoute(String route) {
        this.route = route;
    }

    public void setAlbumIds(List<Integer> albumIds) {
        this.albumIds = albumIds;
    }

    public List<Integer> getCommentIds() {
        return commentIds;
    }

    public void setCommentIds(List<Integer> commentIds) {
        this.commentIds = commentIds;
    }
}
