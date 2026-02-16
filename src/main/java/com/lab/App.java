package com.lab;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;

import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class App {

    public static void main(String[] args) throws Exception {
        int port = 8080;

        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);

        server.createContext("/", exchange -> respond(exchange, 200, "Hello from sonar-demo\n"));
        server.createContext("/health", exchange -> respond(exchange, 200, "OK\n"));

        server.setExecutor(null); // default executor
        server.start();

        System.out.println("sonar-demo HTTP server started on port " + port);
    }

    private static void respond(HttpExchange exchange, int code, String body) throws Exception {
        byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Content-Type", "text/plain; charset=utf-8");
        exchange.sendResponseHeaders(code, bytes.length);
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(bytes);
        }
    }

    // Keep your methods for Sonar testing
    public int add(int a, int b) { return a + b; }

    public int divide(int a, int b) {
        if (b == 0) return 0;
        return a / b;
    }
}
