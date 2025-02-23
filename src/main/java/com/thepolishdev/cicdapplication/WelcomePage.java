package com.thepolishdev.cicdapplication;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class WelcomePage {

    @Value("${welcome.message}")
    private String welcomeMessage;

    @GetMapping("/hello")
    public String welcome() {
        return welcomeMessage;
    }

    @GetMapping("/anotherController")
    public String welcome2() {
        return "test-me-up";
    }
}
