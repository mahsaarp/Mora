import java.util.List;
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

    public enum enterType {
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
    private enterType enterType;

    private static Map<Integer, User> users;
    
}