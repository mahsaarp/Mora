import model.Comment;
import model.Photo;
import model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class PhotoTest {

    @BeforeEach
    void start() {
        Photo.clearPhotosForTest();
    }


    @Test
    void likeTest() {
        User user = new User(1, "username", "password", User.UserRank.COMMENTER, User.EnterType.PHONE);
        Photo photo = Photo.uploadPhoto(2,
                "snow",
                LocalDateTime.now(),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");

        photo.like(user);

        assertTrue(photo.getUserLikedIds().contains(user.getId()));
        assertTrue(user.getLikedPhotoIds().contains(photo.getId()));
    }

    @Test
    void alreadyLikedTest() {
        User user = new User(1, "username", "password", User.UserRank.COMMENTER, User.EnterType.PHONE);
        Photo photo = Photo.uploadPhoto(2,
                "snow",
                LocalDateTime.now(),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");

        photo.like(user);
        photo.like(user);

        assertEquals(1, photo.getUserLikedIds().size());
        assertEquals(1, user.getLikedPhotoIds().size());
    }

    @Test
    void addTagTest() {
        Photo photo = new Photo(1,
                2,
                "sea",
                LocalDateTime.now(),
                new ArrayList<>(List.of("nature", "water")),
                "peace near the sea...",
                true,
                "abcd");

        photo.addTag("sunset");
        photo.addTag("Sunset");
        photo.addTag("SUNSET");

        assertEquals(3, photo.getTags().size());
        assertTrue(photo.getTags().contains("sunset"));
    }

    @Test
    void removeTagTest() {
        Photo photo = new Photo(1,
                2,
                "sea",
                LocalDateTime.now(),
                new ArrayList<>(List.of("nature", "water")),
                "peace near the sea...",
                true,
                "abcd");

        photo.removeTag("NATURE");

        assertEquals(1, photo.getTags().size());
        assertFalse(photo.getTags().contains("nature"));
    }

    @Test
    void addCommentTest() {
        Photo photo1 = new Photo(1,
                2,
                "sea",
                LocalDateTime.now(),
                new ArrayList<>(List.of("nature", "water")),
                "peace near the sea...",
                false,
                "abcd");

        Comment comment1 = new Comment(3, 4, 1, LocalDateTime.now(), "So beautiful!");

        assertThrows(IllegalStateException.class, () -> {
            photo1.addComment(comment1);
        });
        assertFalse(photo1.getCommentIds().contains(comment1.getId()));


        Photo photo2 = new Photo(5,
                2,
                "sea",
                LocalDateTime.now(),
                new ArrayList<>(List.of("nature", "water")),
                "peace near the sea...",
                true,
                "abcd");

        Comment comment2 = new Comment(6, 4, 2, LocalDateTime.now(), "So beautiful!");

        assertDoesNotThrow(() -> {
            photo2.addComment(comment2);
        });
        assertTrue(photo2.getCommentIds().contains(comment2.getId()));
    }

    @Test
    void uploadPhotoTest() {
        Photo photo = Photo.uploadPhoto(2,
                "sea",
                LocalDateTime.now(),
                new ArrayList<>(List.of("nature", "water")),
                "peace near the sea...",
                true,
                "abcd");

        assertTrue(Photo.getPhotos().containsKey(photo.getId()));
    }

    @Test
    void deletePhotoTest() {
        Photo photo = Photo.uploadPhoto(2,
                "sea",
                LocalDateTime.now(),
                new ArrayList<>(List.of("nature", "water")),
                "peace near the sea...",
                true,
                "abcd");

        Photo.deletePhoto(photo);

        assertFalse(Photo.getPhotos().containsKey(photo.getId()));
    }

    @Test
    void searchByNameTest() {
        Photo photo1 = Photo.uploadPhoto(2,
                "sea",
                LocalDateTime.now(),
                new ArrayList<>(List.of("nature", "water")),
                "peace near the sea...",
                true,
                "abcd");
        Photo photo2 = Photo.uploadPhoto(3,
                "ocean",
                LocalDateTime.now(),
                new ArrayList<>(List.of("nature", "water")),
                "peace near the ocean...",
                false,
                "abcdefg");

        assertTrue(Photo.searchByName("lake").isEmpty());
        assertEquals(1, Photo.searchByName("ocean").size());
    }

    @Test
    void searchByTagTest() {
        Photo photo1 = Photo.uploadPhoto(2,
                "rain",
                LocalDateTime.now(),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");
        Photo photo2 = Photo.uploadPhoto(3,
                "snow",
                LocalDateTime.now(),
                new ArrayList<>(List.of("UMBRELLA", "water")),
                "peace comes with snow...",
                false,
                "abcdefg");

        assertEquals(2, Photo.searchByTag("Umbrella").size());
        assertEquals(1, Photo.searchByTag("pouring").size());
    }

    @Test
    void sortByNameTest() {

        Photo photo1 = Photo.uploadPhoto(2,
                "snow",
                LocalDateTime.now(),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");
        Photo photo2 = Photo.uploadPhoto(3,
                "rain",
                LocalDateTime.now(),
                new ArrayList<>(List.of("UMBRELLA", "water")),
                "peace comes with snow...",
                false,
                "abcdefg");

        List<Photo> sortedPhotos = Photo.sortPhotosByName();

        assertEquals(photo2, sortedPhotos.get(0));
        assertEquals(photo1, sortedPhotos.get(1));
    }

    @Test
    void sortByDateTest() {

        Photo photo1 = Photo.uploadPhoto(2,
                "rain",
                LocalDateTime.of(2020, 1, 1, 1, 1, 1),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");
        Photo photo2 = Photo.uploadPhoto(3,
                "snow",
                LocalDateTime.of(2019, 1, 1, 1, 1, 1),
                new ArrayList<>(List.of("UMBRELLA", "water")),
                "peace comes with snow...",
                false,
                "abcdefg");

        List<Photo> sortedPhotos = Photo.sortPhotosByDate();

        assertEquals(photo2, sortedPhotos.get(1));
        assertEquals(photo1, sortedPhotos.get(0));

    }


}

