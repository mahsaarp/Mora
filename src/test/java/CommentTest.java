import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class CommentTest {

    @Test
    void createCommentTest() {
        LocalDateTime date = LocalDateTime.now();
        Comment comment = Comment.createComment(
                1,
                2,
                date,
                "Beautiful photo!"
        );

        assertEquals(1, comment.getOwnerId());
        assertEquals(2, comment.getPhotoId());
        assertEquals(date, comment.getDate());
        assertEquals("Beautiful photo!", comment.getText());
    }

}
