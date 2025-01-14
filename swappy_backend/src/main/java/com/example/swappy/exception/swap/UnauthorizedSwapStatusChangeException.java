package com.example.swappy.exception.swap;

public class UnauthorizedSwapStatusChangeException extends RuntimeException {
    private String message;

    public UnauthorizedSwapStatusChangeException() {}

    public UnauthorizedSwapStatusChangeException(String msg) {
        super(msg);
        this.message = msg;
    }
 }
