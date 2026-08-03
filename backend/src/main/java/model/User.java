package model;

import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

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

    private static Map<Integer, User> users = new ConcurrentHashMap<>();
    private static final int PHOTO_NUMBER = 100;
    private static final int COMMENT_NUMBER = 200;
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
        if (!isValidUsername(newUsername, enterType)) {
            throw new IllegalArgumentException("Invalid username");
        }
        if (usernameExists(newUsername) && !username.equals(newUsername)) {
            throw new IllegalArgumentException("Username already exists");
        }
        username = newUsername;
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
            throw new IllegalArgumentException("Invalid username");
        }

        if (usernameExists(username)) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (!isValidPassword(username, password)) {
           throw new IllegalArgumentException("Invalid password");
        }

        User user = new User(IdGenerator.nextUserId(), username, password, UserRank.NEWBIE, enterType);
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
        return user;
        }

    //=============================================LOG OUT AND DELETE ACCOUNT
    public static void logout(User user) {
        user.isLoggedIn = false;
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

    public void addPhoto(Photo photo) {
        if (photo != null && !photoIds.contains(photo.getId())) {
            photoIds.add(photo.getId());
            updateRank();
        }
    }
}
