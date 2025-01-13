package com.example.swappy.exception.product;

public class SellerDoesntOwnProductException extends RuntimeException {
    private String message;

    public SellerDoesntOwnProductException() {}

    public SellerDoesntOwnProductException(String msg) {
        super(msg);
        this.message = msg;
    }
}
