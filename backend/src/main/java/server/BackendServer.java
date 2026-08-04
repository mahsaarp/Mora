package server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class BackendServer {

    private static final int socket_port = 8080;

    public static void main(String[] args) {
        try (ServerSocket serverSocket = new ServerSocket(socket_port)) {
            System.out.println("==========================================");
            System.out.println("The Running port is: " + socket_port);
            System.out.println("==========================================");

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("New client connected from: " + clientSocket.getInetAddress());

                new Thread(new ClientHandler(clientSocket)).start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}