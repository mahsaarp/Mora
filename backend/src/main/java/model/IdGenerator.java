package model;

import java.util.concurrent.atomic.AtomicInteger;

public class IdGenerator {
    private static AtomicInteger userId = new AtomicInteger(1);
    private static AtomicInteger photoId = new AtomicInteger(1);
    private static AtomicInteger albumId = new AtomicInteger(1);
    private static AtomicInteger commentId = new AtomicInteger(1);

    public static int nextUserId() {
        return userId.getAndIncrement();
    }

    public static int nextPhotoId() {
        return photoId.getAndIncrement();
    }

    public static int nextAlbumId() {
        return albumId.getAndIncrement();
    }

    public static int nextCommentId() {
        return commentId.getAndIncrement();
    }
}