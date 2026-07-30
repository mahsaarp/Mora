import model.Album;
import model.Photo;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class AlbumTest {

    @Test
    void addPhotoTest() {
        Album album = new Album(1, 2, "nature", LocalDateTime.now());
        Photo photo1 = Photo.uploadPhoto(2,
                "snow",
                LocalDateTime.now(),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");
        album.addPhoto(photo1);
        album.addPhoto(photo1);
        album.addPhoto(null);

        assertEquals(1, album.getPhotoIds().size());
        assertTrue(album.getPhotoIds().contains(photo1.getId()));
    }

    @Test
    void deletePhotoTest() {
        Album album = new Album(2, 2, "nature", LocalDateTime.now());
        Photo photo1 = Photo.uploadPhoto(2,
                "snow",
                LocalDateTime.now(),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");
        album.addPhoto(photo1);
        album.deletePhoto(photo1);

        assertEquals(0, album.getPhotoIds().size());
    }

    @Test
    void movePhotoTest() {
        Album album1 = new Album(3, 2, "nature", LocalDateTime.now());
        Album album2 = new Album(4, 2, "family", LocalDateTime.now());
        Photo photo1 = Photo.uploadPhoto(2,
                "snow",
                LocalDateTime.now(),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");
        album2.addPhoto(photo1);
        album2.movePhoto(photo1, album1);

        assertEquals(0, album2.getPhotoIds().size());
        assertEquals(1, album1.getPhotoIds().size());
        assertTrue(album1.getPhotoIds().contains(photo1.getId()));
    }

    @Test
    void sortPhotosByNameTest() {
        Album album = new Album(5, 2, "nature", LocalDateTime.now());
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
        album.addPhoto(photo1);
        album.addPhoto(photo2);

        album.sortPhotosByName();

        assertEquals(photo2.getId(), album.getPhotoIds().get(0));
        assertEquals(photo1.getId(), album.getPhotoIds().get(1));
    }

    @Test
    void sortPhotosByDateTest() {
        Album album = new Album(6, 2, "nature", LocalDateTime.now());
        Photo photo1 = Photo.uploadPhoto(2,
                "snow",
                LocalDateTime.of(2020, 1, 1, 1, 1, 1),
                new ArrayList<>(List.of("umbrella", "pouring")),
                "peace comes with rain...",
                true,
                "abcd");
        Photo photo2 = Photo.uploadPhoto(3,
                "rain",
                LocalDateTime.of(2019, 1, 1, 1, 1, 1),
                new ArrayList<>(List.of("UMBRELLA", "water")),
                "peace comes with snow...",
                false,
                "abcdefg");
        album.addPhoto(photo1);
        album.addPhoto(photo2);

        album.sortPhotosByDate();

        assertEquals(photo2.getId(), album.getPhotoIds().get(1));
        assertEquals(photo1.getId(), album.getPhotoIds().get(0));
    }

    @Test
    void createAlbumTest() {
        Album album = Album.createAlbum(
                2,
                "nature",
                LocalDateTime.now()
        );

        assertTrue(Album.getAlbums().containsKey(album.getId()));
        assertEquals("nature", album.getName());
        assertEquals(2, album.getOwnerId());
    }

    @Test
    void deleteAlbumTest() {
        Album album = Album.createAlbum(
                3,
                "nature",
                LocalDateTime.now()
        );

        Album.deleteAlbum(album);

        assertFalse(Album.getAlbums().containsKey(album.getId()));
    }
}
