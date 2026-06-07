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
    private List<Integer> favoritePhotoIds;

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
    this.favoritePhotoIds = new ArrayList<>();
    }
}