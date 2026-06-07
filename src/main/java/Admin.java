public class Admin extends User
{
    private static final String AdminPassword = "Mora405Ap";

    public Admin(int id, String username, String password, EnterType enterType) {
        super(id, username, password, userRank.ADMIN, enterType);
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
