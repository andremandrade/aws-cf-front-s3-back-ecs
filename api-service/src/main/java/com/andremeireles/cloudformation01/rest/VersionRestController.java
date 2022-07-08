package com.andremeireles.cloudformation01.rest;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/version")
public class VersionRestController {

    @GetMapping
    String getVersion(){
        return "0.5";
    }
}
