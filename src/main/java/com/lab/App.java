package com.lab;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello SonarQube!");
    }

    public int add(int a, int b) {
        return a + b;
    }

    public int divide(int a, int b) {
        if (b == 0) {
            return 0; // simple check to avoid crash
        }
        return a / b;
    }
}

