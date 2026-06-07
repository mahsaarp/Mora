import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

public class User {
    public static void clearUsersForTest() {
        users.clear();
    }

    //=============================================ENUM
    public enum UserRank {
        NEWBIE,
        PHOTOGRAPHER,
        COMMENTER,
        INFLUENCER,
        ADMIN;
    }

    public enum EnterType {
        PHONE,
        EMAIL;
    }

    //=============================================PROPERTIES
    private int id;
    private String username;
    private String password;
    private List<Integer> photoIds;
    private List<Integer> albumIds;
    private List<Integer> likedPhotoIds;
    private boolean isBanned;
    private boolean isLoggedIn;
    private int commentCount;
    private UserRank rank;
    private EnterType enterType;

    private static Map<Integer, User> users = new HashMap<>();

    //=============================================CONSTRUCTOR
    public User(int id, String username, String password, UserRank rank, EnterType enterType) {
        this.id = id;
        this.username = username;
        this.password = password;

        this.rank = rank;
        this.enterType = enterType;

        this.isBanned = false;
        this.isLoggedIn = false;
        this.commentCount = 0;

        this.photoIds = new ArrayList<>();
        this.albumIds = new ArrayList<>();
        this.likedPhotoIds = new ArrayList<>();
    }

    //=============================================GETTERS
    public int getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public List<Integer> getPhotoIds() {
        return photoIds;
    }

    public List<Integer> getAlbumIds() {
        return albumIds;
    }

    public boolean isBanned() {
        return isBanned;
    }

    public boolean isLoggedIn() {
        return isLoggedIn;
    }

    public int getCommentCount() {
        return commentCount;
    }

    public UserRank getRank() {
        return rank;
    }

    public EnterType getEnterType() {
        return enterType;
    }

    public List<Integer> getLikedPhotoIds() {
        return likedPhotoIds;
    }

    public static Map<Integer, User> getAllUsers() {
        return users;
    }

    public static Map<Integer, User> getUsers() {
        return users;
    }

    //=============================================SETTERS
    public void ban() {
        isBanned = true;
    }

    public void unban() {
        isBanned = false;
    }

    public void login() {
        isLoggedIn = true;
    }

    public void logout() {
        isLoggedIn = false;
    }

    public void changeUsername(String newUsername) {
        if (isValidUsername(newUsername, enterType)) {
            username = newUsername;
        }
    }

    public void changePassword(String newPassword) {
        if (isValidPassword(username, newPassword)) {
            password = newPassword;
        }
    }

    public void addPhoto(int photoId) {
        photoIds.add(photoId);
        updateRank();
    }

    public void removePhoto(int photoId) {
        photoIds.remove(Integer.valueOf(photoId));
        updateRank();
    }

    public void addAlbum(int albumId) {
        albumIds.add(albumId);
    }

    public void removeAlbum(int albumId) {
        albumIds.remove(Integer.valueOf(albumId));
    }

    public void addFavoritePhoto(int photoId) {
        likedPhotoIds.add(photoId);
    }

    public void removeFavoritePhoto(int photoId) {
        likedPhotoIds.remove(Integer.valueOf(photoId));
    }

    public void incrementCommentCount() {
        commentCount++;
        updateRank();
    }

    //=============================================VALIDATIONS
    public static boolean isValidUsername(String username, EnterType enterType) {
        if (enterType == EnterType.EMAIL) {
            return username.contains("@gmail.com");
        }

        if (enterType == EnterType.PHONE) {
            return username.length() == 11 && username.startsWith("09");
        }

        return false;
    }

    public static boolean isValidPassword(String username, String password) {
        if (password.length() < 8) {
            return false;
        }
        if (password.contains(username)) {
            return false;
        }

        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;

        for (int i = 0; i < password.length(); i++) {
            char c = password.charAt(i);
            if (Character.isUpperCase(c)) {
                hasUpper = true;
            }
            if (Character.isLowerCase(c)) {
                hasLower = true;
            }
            if (Character.isDigit(c)) {
                hasDigit = true;
            }
        }

        return hasUpper && hasLower && hasDigit;
    }

    //=============================================SIGNUP AND LOGIN
    public static User signUp(EnterType enterType, String username, String password) {
        if (!isValidUsername(username, enterType)) {
            return null;
        }

        if (!isValidPassword(username, password)) {
            return null;
        }

        User user = new User(IdGenerator.nextUserId(), username, password, UserRank.NEWBIE, enterType);
        users.put(user.getId(), user);

        return user;
    }

    public static User login(String username, String password) {
        for (User user : users.values()) {
            if (user.getUsername().equals(username) && user.getPassword().equals(password)) {
                if (user.isBanned()) {
                    return null;
                }
                user.isLoggedIn = true;
                return user;
            }
        }
        return null;
    }

    //=============================================LOG OUT AND DELETE ACCOUNT
    public static void logout(User user) {
        user.isLoggedIn = false;
    }

    public static void deleteAccount(User user) {
        users.remove(user.getId());
    }

    //============================================UPDATE RANK
    public void updateRank() {
        if (rank == UserRank.ADMIN) {
            return;
        }

        if (photoIds.size() >= 100 && commentCount >= 200) {
            rank = UserRank.INFLUENCER;
        } else if (photoIds.size() >= 100) {
            rank = UserRank.PHOTOGRAPHER;
        } else if (commentCount >= 200) {
            rank = UserRank.COMMENTER;
        } else {
            rank = UserRank.NEWBIE;
        }
    }

    //============================================SEARCH USERS
    public static List<User> searchByUsername(String name) {
        List<User> result = new ArrayList<>();

        for (User user : users.values()) {
            if (user.getUsername().contains(name)) {
                result.add(user);
            }
        }
        return result;
    }
}
