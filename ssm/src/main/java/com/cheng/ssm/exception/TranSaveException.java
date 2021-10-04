package com.cheng.ssm.exception;

public class TranSaveException extends RuntimeException{

    public TranSaveException() {
    }

    public TranSaveException(String message) {
        super(message);
    }
}
