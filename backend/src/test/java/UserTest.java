import model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class UserTest {

    @BeforeEach
    void setup() {
        User.clearUsersForTest();
    }

    //==================================== SIGN UP TEST
    @Test
    void signUpTest() {
        User user = User.signUp(User.EnterType.EMAIL, "test@gmail.com", "A123456a");

        assertNotNull(user);
        assertEquals("test@gmail.com", user.getUsername());
    }

    @Test
    void signUpWithDisplayNameTest() {
        User user = User.signUp(User.EnterType.EMAIL, "test@gmail.com", "A123456a", "Ali Reza");

        assertNotNull(user);
        assertEquals("Ali Reza", user.getDisplayName());
    }

    //==================================== LOGIN TEST
    @Test
    void loginTest() {
        User.signUp(User.EnterType.EMAIL, "test@gmail.com", "A123456a");
        User user = User.login("test@gmail.com", "A123456a");

        assertNotNull(user);
        assertTrue(user.isLoggedIn());
    }

    @Test
    void wrongPasswordLoginTest() {
        User.clearUsersForTest();

        User.signUp(User.EnterType.EMAIL, "test@gmail.com", "A123456a");

        assertThrows(IllegalArgumentException.class, () -> {
            User.login("test@gmail.com", "wrongpass");
        }, "should throw IllegalArgumentException");
    }

    //==================================== LOGOUT TEST
    @Test
    void logoutTest() {
        User user = User.signUp(
                User.EnterType.EMAIL,
                "test@gmail.com",
                "Aa123456"
        );

        User.login("test@gmail.com", "Aa123456");
        User.logout(user);

        assertFalse(user.isLoggedIn());
    }

    //==================================== DELETE TEST
    @Test
    void deleteAccountTest() {
        User user = User.signUp(
                User.EnterType.EMAIL,
                "test@gmail.com",
                "Aa123456"
        );

        User.deleteAccount(user);

        boolean exists = false;

        for (User u : User.getUsers().values()) {
            if (u.getUsername().equals("test@gmail.com")) {
                exists = true;
            }
        }

        assertFalse(exists);
    }
}