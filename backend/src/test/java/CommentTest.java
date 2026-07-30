import model.Comment;
import model.Photo;
import model.User;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class CommentTest {

    @Test
    void createCommentTest() {
        User user = User.signUp(User.EnterType.EMAIL, "moraTest@gmail.com", "Mora405Ap");

        Photo photo = Photo.uploadPhoto(
                user.getId(),
                "testPhoto",
                LocalDateTime.now(),
                new ArrayList<>(),
                "testCaption",
                true,
                "src/test"
        );

        LocalDateTime date = LocalDateTime.now();
        Comment comment = Comment.createComment(
                user.getId(),
                photo.getId(),
                date,
                "Beautiful photo!"
        );

        assertNotNull(comment, "Comment shouldn't be null");
        assertEquals(user.getId(), comment.getOwnerId());
        assertEquals(photo.getId(), comment.getPhotoId());
        assertEquals(date, comment.getDate());
        assertEquals("Beautiful photo!", comment.getText());
        assertEquals(1, user.getCommentCount());
    }

}
