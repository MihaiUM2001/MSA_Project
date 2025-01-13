package com.example.swappy.exception.swap;

public class SwapStatusAlreadyNotPendingException extends RuntimeException {
    private String message;

    public SwapStatusAlreadyNotPendingException() {}

    public SwapStatusAlreadyNotPendingException(String msg) {
        super(msg);
        this.message = msg;
    }
 }
