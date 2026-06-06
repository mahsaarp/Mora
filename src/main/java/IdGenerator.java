public class IdGenerator {
    private static int currentId = 1;

    public static int generateId() {
        return currentId++;
    }
}

