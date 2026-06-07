import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AdminTest
{
    //==================================== PASSWORD CHECK TEST

    @Test
    void adminPasswordTest() {
        assertTrue(Admin.checkPassword("Mora405Ap"));
        assertFalse(Admin.checkPassword("wrongPassword"));
    }

    //==================================== BAN USER TEST

    @Test
    void banUserTest() {
        User user = new User(1, "user1", "Aa123456", User.UserRank.NEWBIE, User.EnterType.EMAIL);

        Admin admin = new Admin(99, "admin", "adminPass", User.EnterType.EMAIL);
        admin.ban(user);
        assertTrue(user.isBanned());
    }

    //==================================== UNBAN USER TEST

    @Test
    void unbanUserTest() {
        User user = new User(2, "user2", "Aa123456", User.UserRank.NEWBIE, User.EnterType.EMAIL);
        Admin admin = new Admin(99, "admin", "adminPass", User.EnterType.EMAIL);
        user.ban();
        admin.unban(user);

        assertFalse(user.isBanned());
    }
}