package com.example.swappy.exception.swap;

public class CannotSwapOwnProductException extends RuntimeException {
    private String message;

    public CannotSwapOwnProductException () {}

    public CannotSwapOwnProductException(String msg) {
        super(msg);
        this.message = msg;
    }
 }
