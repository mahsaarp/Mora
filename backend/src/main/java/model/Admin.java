package model;

public class Admin extends User {
    private static final String AdminPassword = "Mora405Ap";

    public Admin(int id, String username, String password, User.EnterType enterType) {
        super(id, username, password, User.UserRank.ADMIN, enterType);
    }
    public static boolean checkPassword(String password) {
        return AdminPassword.equals(password);
    }

    public void ban(User user) {
        user.ban();
    }

    public void unban(User user) {
        user.unban();
    }
}
