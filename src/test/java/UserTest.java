import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class UserTest {

    @BeforeEach
    void setup() {
        User.clearUsersForTest();
    }

    //==================================== VALIDATION TEST
    @Test
    void validationTest() {
        assertTrue(User.isValidUsername("09123456789", User.EnterType.PHONE));
        assertTrue(User.isValidUsername("test@gmail.com", User.EnterType.EMAIL));

        assertFalse(User.isValidUsername("sdnvjnsvKMK", User.EnterType.EMAIL));
        assertFalse(User.isValidUsername("123", User.EnterType.PHONE));

        assertTrue(User.isValidPassword("user", "A123456a"));
        assertFalse(User.isValidPassword("user", "123"));
        assertFalse(User.isValidPassword("user", "moraproject"));
    }

    //==================================== SIGN UP TEST
    @Test
    void signUpTest() {
        User user = User.signUp(User.EnterType.EMAIL, "test@gmail.com", "A123456a");

        assertNotNull(user);
        assertEquals("test@gmail.com", user.getUsername());
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
        User.signUp(User.EnterType.EMAIL, "test@gmail.com", "A123456a");
        User user = User.login("test@gmail.com", "wrongpass");

        assertNull(user);
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

        for (User u : User.getAllUsers().values()) {
            if (u.getUsername().equals("test@gmail.com")) {
                exists = true;
            }
        }

        assertFalse(exists);
    }
}
