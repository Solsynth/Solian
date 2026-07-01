package io.wazo.callkeep.utils;

public interface Callback <Arg> {

    void invoke(Arg arg);
}
