package com.cheng.ssm.exception;

public class LoginFailException extends Exception {
    public LoginFailException() {
    }

    public LoginFailException(String message) {
        super(message);
    }
}
