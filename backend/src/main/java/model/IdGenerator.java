package model;

public class IdGenerator {

    private static int userId = 1;
    private static int photoId = 1;
    private static int albumId = 1;
    private static int commentId = 1;

    public static int nextUserId() {
        return userId++;
    }

    public static int nextPhotoId() {
        return photoId++;
    }

    public static int nextAlbumId() {
        return albumId++;
    }

    public static int nextCommentId() {
        return commentId++;
    }

}