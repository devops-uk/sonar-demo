package com.lab;

import org.junit.Test;
import static org.junit.Assert.*;

public class AppTest {

    @Test
    public void testAdd() {
        App app = new App();
        assertEquals(5, app.add(2, 3));
    }

    @Test
    public void testDivide() {
        App app = new App();
        assertEquals(2, app.divide(4, 2));
    }

    @Test
    public void testDivideByZero() {
        App app = new App();
        assertEquals(0, app.divide(4, 0));
    }
}
