import java.util.ArrayList;
import java.util.Collection;

public class User {
    private final int id;

    public User(int id) {
        this.id = id;
    }



    public int getId() {
        return id;
    }

    public ArrayList<Integer> getFavoritePhotoIds() {
        return new ArrayList<>();
    }
}
