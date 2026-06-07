import java.util.List;
import java.util.ArrayList;
import java.util.Map;

public class User {
//=============================================ENUM
    public enum userRank {
        NEWBIE,
        PHOTOGRAPHER,
        COMMENTER,
        INFLUENCER,
        ADMIN
    }

    public enum EnterType {
        phoneNumber,
        email
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

    private userRank rank;
    private EnterType enterType;

    private static Map<Integer, User> users;
//=============================================CONSTRUCTOR
public User(int id, String username, String password, userRank rank, EnterType enterType) {
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

    public userRank getRank() {
        return rank;
    }

    public EnterType getEnterType() {
        return enterType;
    }

    public List<Integer> getLikedPhotoIds() {
        return likedPhotoIds;
    }

//=============================================SETTERS
    public void ban() {
        isBanned = true;
    }
    
    public void unban() {
        isBanned = false;
    }
//=============================================VALIDATONS
    public static boolean isValidUsername(String username, EnterType enterType) {
        if(enterType == EnterType.email) {
            if (username.contains("@gmail.com")) {
                return true;
            }
        }
        if(enterType == EnterType.phoneNumber) {
            if (username.length() == 11 && username.startsWith("09")) {
                return true;
            }
        }
        return false;
    }


    public static boolean isValidPassword(String username, String password){
        if(password.length() < 8){
            return false;
        }
        if(password.contains(username)){
            return false;
        }
        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;

        for(int i = 0; i < password.length(); i++){
            char c = password.charAt(i);
            if(Character.isUpperCase(c)){
                hasUpper = true;
            }
            if(Character.isLowerCase(c)){
                hasLower = true;
            }
            if(Character.isDigit(c)){
                hasDigit = true;
            }
        }
        return hasUpper && hasLower && hasDigit;
    }
//=============================================SIGNUP AND LOGIN
    public static User signUp(EnterType enterType, String username, String password) {
        if(isValidUsername(username , enterType)) {
            return null;
        }

        if(isValidPassword(username, password)) {
            return null;
        }

        User user = new User(IdGenerator.nextUserId(), username, password, userRank.NEWBIE, enterType);
        users.put(user.getId(), user);

        return user;
    }

    public static User login(String username, String password) {
        for(User user : users.values()) {
            if(user.getUsername().equals(username) && user.getPassword().equals(password)) {
                if(user.isBanned()) {
                    return null;
                }
                user.isLoggedIn = true;
                return user;
            }
        }
        return null;
    }
//=============================================LOG OUT AND DELET ACCOUNT

}