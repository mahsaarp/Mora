package server;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Base64;

public class FileServer {

    private static final String UPLOAD_DIR = "photos/";

    static {
        try {
            Files.createDirectories(Paths.get(UPLOAD_DIR));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static String saveFile(String base64Data, String originalName) throws IOException {
        if (base64Data == null || base64Data.isEmpty()) {
            throw new IllegalArgumentException("File data cannot be empty");
        }

        byte[] fileBytes = Base64.getDecoder().decode(base64Data);

        String uniqueFileName = System.currentTimeMillis() + "_" + originalName.replaceAll("\\s+", "_");
        Path targetPath = Paths.get(UPLOAD_DIR, uniqueFileName);

        Files.write(targetPath, fileBytes);

        return targetPath.toString().replace("\\", "/");
    }

    public static String loadFileAsBase64(String relativePath) throws IOException {
        if (relativePath == null) {
            return null;
        }
        Path path = Paths.get(relativePath);
        if (!Files.exists(path)) {
            return null;
        }
        byte[] fileBytes = Files.readAllBytes(path);
        return Base64.getEncoder().encodeToString(fileBytes);
    }

    public static boolean deleteFile(String relativePath) {
        if (relativePath == null) {
            return false;
        }
        try {
            Path path = Paths.get(relativePath);
            return Files.deleteIfExists(path);
        } catch (IOException e) {
            return false;
        }
    }
}