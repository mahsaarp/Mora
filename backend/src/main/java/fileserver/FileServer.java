package fileserver;

import com.sun.net.httpserver.HttpServer;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.net.InetSocketAddress;

public class FileServer {

    public static final String Uplode_folder = "uploads";

    public static void start(int port) {
        try {
            File dir = new File(Uplode_folder);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);

            server.createContext("/files", exchange -> {
                String path = exchange.getRequestURI().getPath();
                String fileName = path.substring("/files/".length());

                File file = new File(Uplode_folder, fileName);

                if (file.exists() && file.isFile()) {
                    exchange.sendResponseHeaders(200, file.length());

                    try (OutputStream os = exchange.getResponseBody();
                         FileInputStream fis = new FileInputStream(file)) {

                        byte[] buffer = new byte[1024];
                        int bytesRead;
                        while ((bytesRead = fis.read(buffer)) != -1) {
                            os.write(buffer, 0, bytesRead);
                        }
                    }
                } else {
                    System.out.println("File not found: " + fileName);
                    exchange.sendResponseHeaders(404, -1);
                }
            });

            server.start();
            System.out.println("File server started on port " + port);

        } catch (IOException e) {
            System.out.println("Error starting FileServer: " + e.getMessage());
        }
    }
}