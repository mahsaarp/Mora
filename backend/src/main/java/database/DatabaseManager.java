package database;

import java.util.concurrent.locks.ReentrantReadWriteLock;

public class DatabaseManager {
    private static final String FILE_PATH = "database/database.json";

    private final ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
    private DatabaseData databaseData;

    private static volatile DatabaseManager instance;


}
