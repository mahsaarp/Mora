package model;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;

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
    private String displayName;
    private String avatarRoute;
    private List<Integer> photoIds;
    private List<Integer> albumIds;
    private List<Integer> likedPhotoIds;
    private boolean isBanned;
    private boolean isLoggedIn;
    private int commentCount;
    private UserRank rank;
    private EnterType enterType;

    private String themeMode;
    private String themeColor;

    private static final Pattern PHONE_REGEX = Pattern.compile("^09\\d{9}$");
    private static final Pattern EMAIL_REGEX = Pattern.compile("^[a-zA-Z0-9_.+-]+@gmail\\.com$");
    private static final Pattern PASSWORD_REGEX = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$");

    private static Map<Integer, User> users = new ConcurrentHashMap<>();
    private static final int PHOTO_NUMBER = 5;
    private static final int COMMENT_NUMBER = 5;
    //=============================================CONSTRUCTOR
    public User(int id, String username, String password, UserRank rank, EnterType enterType) {
        this(id, username, password, username, rank, enterType);
    }

    public User(int id, String username, String password, String displayName, UserRank rank, EnterType enterType) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.displayName = (displayName == null || displayName.trim().isEmpty()) ? username : displayName.trim();

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

    public String getAvatarRoute() {
        return avatarRoute;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getDisplayName() {
        return displayName != null && !displayName.trim().isEmpty() ? displayName : username;
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
        updateRank();
        return rank;
    }

    public EnterType getEnterType() {
        return enterType;
    }

    public List<Integer> getLikedPhotoIds() {
        return likedPhotoIds;
    }

    public static Map<Integer, User> getUsers() {
        return users;
    }

    public String getThemeMode() {
        return themeMode;
    }

    public String getThemeColor() {
        return themeColor;
    }

    //=============================================SETTERS
    public void ban() {
        isBanned = true;
    }

    public void setAvatarRoute(String avatarRoute) {
        this.avatarRoute = avatarRoute;
    }

    public void setDisplayName(String displayName) {
        this.displayName = (displayName == null || displayName.trim().isEmpty()) ? username : displayName.trim();
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

    public void setThemeMode(String themeMode) {
        this.themeMode = themeMode;
    }

    public void setThemeColor(String themeColor) {
        this.themeColor = themeColor;
    }

    public void changeUsername(String newUsername) {
        if (!isValidUsername(newUsername)) {
            throw new IllegalArgumentException("Username must be a valid mobile number (09xxxxxxxx) or Gmail (@gmail.com)");
        }
        if (usernameExists(newUsername) && !username.equals(newUsername)) {
            throw new IllegalArgumentException("Username already exists");
        }
        this.username = newUsername;
        this.enterType = detectEnterType(newUsername);
    }

    public void changePassword(String newPassword) {
        if (!isValidPassword(username, newPassword)) {
            throw new IllegalArgumentException("Password must be at least 8 characters, include uppercase, lowercase, digits, and MUST NOT contain your username.");
        }
        this.password = newPassword;
    }

    public void changeDisplayName(String newDisplayName) {
        if (newDisplayName == null || newDisplayName.trim().isEmpty()) {
            throw new IllegalArgumentException("Display name is required");
        }
        this.displayName = newDisplayName.trim();
    }

    public void addPhoto(int photoId) {
        if (!photoIds.contains(photoId)) {
            photoIds.add(photoId);
            updateRank();
        }
    }

    public void addPhoto(Photo photo) {
        if (photo != null && !photoIds.contains(photo.getId())) {
            photoIds.add(photo.getId());
            updateRank();
        }
    }

    public void removePhoto(int photoId) {
        photoIds.remove(Integer.valueOf(photoId));
        updateRank();
    }

    public void addAlbum(int albumId) {
        if (!albumIds.contains(albumId)) {
            albumIds.add(albumId);
        }
    }

    public void removeAlbum(int albumId) {
        albumIds.remove(Integer.valueOf(albumId));
    }

    public void addFavoritePhoto(int photoId) {
        if (!likedPhotoIds.contains(photoId)) {
            likedPhotoIds.add(photoId);
            updateRank();
        }
    }

    public void removeFavoritePhoto(int photoId) {
        if (likedPhotoIds.remove(Integer.valueOf(photoId))) {
            updateRank();
        }
    }

    public void incrementCommentCount() {
        commentCount++;
        updateRank();
    }

    //=============================================VALIDATIONS
    public static boolean isValidUsername(String username) {
        if (username == null || username.trim().isEmpty()) return false;
        return PHONE_REGEX.matcher(username).matches() || EMAIL_REGEX.matcher(username).matches();
    }

    public static EnterType detectEnterType(String username) {
        if (username == null) return null;
        if (EMAIL_REGEX.matcher(username).matches()) {
            return EnterType.EMAIL;
        } else if (PHONE_REGEX.matcher(username).matches()) {
            return EnterType.PHONE;
        }
        return null;
    }

    public static boolean isValidPassword(String username, String password) {
        if (password == null || username == null) {
            return false;
        }
        if (password.toLowerCase().contains(username.toLowerCase())) {
            return false;
        }
        return PASSWORD_REGEX.matcher(password).matches();
    }

    //=============================================SIGNUP AND LOGIN
    public static User signUp(EnterType enterType, String username, String password) {
        return signUp(enterType, username, password, null);
    }

    public static User signUp(EnterType enterType, String username, String password, String displayName) {
        if (!isValidUsername(username)) {
            throw new IllegalArgumentException("Username must be a valid mobile number (09xxxxxxxx) or Gmail (@gmail.com)");
        }

        if (usernameExists(username)) {
            throw new IllegalArgumentException("Username already exists");
        }

        if (!isValidPassword(username, password)) {
            throw new IllegalArgumentException("Password must be at least 8 characters, include uppercase, lowercase, digits, and MUST NOT contain your username.");
        }

        EnterType resolvedType = (enterType != null) ? enterType : detectEnterType(username);

        User user = new User(IdGenerator.nextUserId(), username, password, displayName, UserRank.NEWBIE, resolvedType);
        users.put(user.getId(), user);

        return user;
    }

    public static User login(String username, String password) {
        User user = users.values()
                .stream()
                .filter(u -> u.getUsername().equals(username))
                .filter(u -> u.getPassword().equals(password))
                .findFirst()
                .orElseThrow(() ->
                        new IllegalArgumentException("Login failed"));

        if (user.isBanned()) {
            throw new IllegalStateException("User is banned");
        }

        user.login();
        user.updateRank();
        return user;
    }

    //=============================================LOG OUT AND DELETE ACCOUNT
    public static void logout(User user) {
        if (user != null) {
            user.isLoggedIn = false;
        }
    }

    public static void deleteAccount(User user) {
        if (user == null) return;

        for (Photo photo : new ArrayList<>(Photo.getPhotos().values())) {
            if (photo.getOwnerId() == user.getId()) {
                Photo.deletePhoto(photo);
            }
        }

        for (Album album : new ArrayList<>(Album.getAlbums().values())) {
            if (album.getOwnerId() == user.getId()) {
                Album.deleteAlbum(album);
            }
        }

        for (Comment comment : new ArrayList<>(Comment.getComments().values())) {
            if (comment.getOwnerId() == user.getId()) {
                Comment.deleteComment(comment);
            }
        }

        for (Photo photo : Photo.getPhotos().values()) {
            photo.getUserLikedIds().remove(Integer.valueOf(user.getId()));
        }

        users.remove(user.getId());
    }
    //============================================UPDATE RANK
    public void updateRank() {
        if (rank == UserRank.ADMIN) {
            return;
        }

        if (photoIds.size() >= PHOTO_NUMBER && commentCount >= COMMENT_NUMBER) {
            rank = UserRank.INFLUENCER;

        } else if (photoIds.size() >= PHOTO_NUMBER) {
            rank = UserRank.PHOTOGRAPHER;

        } else if (commentCount >= COMMENT_NUMBER) {
            rank = UserRank.COMMENTER;

        } else {
            rank = UserRank.NEWBIE;
        }
    }
    //============================================SEARCH USERS
    public static List<User> searchByUsername(String name) {
        return users.values()
                .stream()
                .filter(user ->
                        user.getUsername()
                                .toLowerCase()
                                .contains(name.toLowerCase()))
                .toList();
    }
    //=============================================CHECK USERS
    public static boolean usernameExists(String username) {
        return users.values()
                .stream()
                .anyMatch(user -> user.getUsername().equals(username));
    }

    public static User findUserById(int id) {
        return users.get(id);
    }

    public static User findUserById(String idStr) {
        try {
            int id = Integer.parseInt(idStr);
            return findUserById(id);
        } catch (NumberFormatException e) {
            return null;
        }
    }

}
