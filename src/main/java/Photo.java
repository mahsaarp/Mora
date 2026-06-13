import java.time.LocalDateTime;
import java.util.*;

public class Photo {
    private final int id;
    private int ownerId;
    private String name;
    private LocalDateTime date;
    private List<String> tags;
    private String caption;
    private List<Integer> userLikedIds;
    private boolean commentAllowed;
    private List<Integer> albumIds;
    private List<Integer> commentIds;
    private static final Map<Integer, Photo> photos = new LinkedHashMap<>();
    private String route;

    public Photo(int id, int ownerId, String name, LocalDateTime date, List<String> tags, String caption, boolean commentAllowed, String route) {
        this.id = id;
        this.ownerId = ownerId;
        this.name = name;
        this.date = date;
        this.tags = (tags != null) ? new ArrayList<>(tags) : new ArrayList<>();
        this.caption = caption;
        this.commentAllowed = commentAllowed;
        this.route = route;
        this.albumIds = new ArrayList<>();
        this.commentIds = new ArrayList<>();
        this.userLikedIds = new ArrayList<>();
    }

    public void like(User user) {
        if (user == null) {
            return;
        }

        if (!userLikedIds.contains(user.getId())) {
            userLikedIds.add(user.getId());

            if (!user.getLikedPhotoIds().contains(this.id)) {
                user.addFavoritePhoto(this.id);
            }
        }
    }

    public void addComment(Comment comment) {
        if (comment == null) {
            return;
        }

        if (!commentAllowed) {
            throw new IllegalStateException("Comments are not allowed for this photo.");
        }

        if (!this.commentIds.contains(comment.getId())) {
            this.commentIds.add(comment.getId());
        }
    }

    public void deleteComment(Comment comment) {
        if (comment == null) {
            return;
        }

        this.commentIds.remove(Integer.valueOf(comment.getId()));
    }

    public void addTag(String tag) {
        if (tag == null || tag.isBlank()) {
            throw new IllegalArgumentException("Your tag can't be blank!");
        }
        if (tags.stream().noneMatch(a -> a.equalsIgnoreCase(tag))) {
            this.tags.add(tag);
        }
    }

    public void removeTag(String tag) {
        if (tag == null) {
            return;
        }
        this.tags.removeIf(a -> a.equalsIgnoreCase(tag));
    }

    public void editName(String newName) {
        this.name = newName;
    }

    public void editCaption(String newCaption) {
        this.caption = newCaption;
    }

    public static List<Photo> sortPhotosByName() {
        return photos.values()
                .stream()
                .sorted(Comparator.comparing(Photo::getName, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER)))
                .toList();
    }

    public static List<Photo> sortPhotosByDate() {
        return photos.values()
                .stream()
                .sorted(Comparator.comparing(Photo::getDate, Comparator.nullsLast(Comparator.reverseOrder())))
                .toList();
    }

    public static List<Photo> searchByName(String name) {
        if (name == null || name.isBlank()) {
            return new ArrayList<>();
        }
        List<Photo> matchedPhotos = new ArrayList<>();
        String word = name.toLowerCase();

        for (Photo photo : photos.values()) {
            if (photo.getName() != null && photo.getName().toLowerCase().contains(word)) {
                matchedPhotos.add(photo);
            }
        }
        return matchedPhotos;
    }

    public static List<Photo> searchByTag(String tag) {
        if (tag == null || tag.isBlank()) {
            return new ArrayList<>();
        }
        List<Photo> matchedPhotos = new ArrayList<>();

        for (Photo photo : photos.values()) {
            if (photo.getTags() != null && photo.getTags().stream().anyMatch(a -> a.equalsIgnoreCase(tag))) {
                matchedPhotos.add(photo);
            }
        }
        return matchedPhotos;
    }

    public static Photo uploadPhoto(int ownerId, String name, LocalDateTime date, List<String> tags, String caption, boolean commentAllowed, String route) {
        int id = IdGenerator.nextPhotoId();
        Photo photo = new Photo(id, ownerId, name, date, tags, caption, commentAllowed, route);
        photos.put(id, photo);

        User owner = User.getUsers().get(ownerId);
        if (owner != null) {
            owner.addPhoto(id);
        }

        return photo;
    }

    public static void deletePhoto(Photo photo) {
        if (photo == null) {
            return;
        }

        User owner = User.getUsers().get(photo.getOwnerId());
        if (owner != null) {
            owner.removePhoto(photo.getId());
        }

        for (Integer albumId : new ArrayList<>(photo.getAlbumIds())) {
            Album album = Album.getAlbums().get(albumId);
            if (album != null) {
                album.getPhotoIds().remove(Integer.valueOf(photo.getId()));
            }
        }

        photos.remove(photo.getId());
    }

    static void clearPhotosForTest() {
        photos.clear();
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

    public int getLikes() {
        return userLikedIds.size();
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
        return new LinkedHashMap<>(photos);
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
