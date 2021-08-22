package privch.tunnel;

// IServiceEvent.aidl
// int anInt, long aLong, boolean aBoolean, float aFloat, double aDouble, String aString

interface IServiceEvent {
    void onMessage(in String message);
    void onServerChanged(in int serverId);
    void onStateChanged(in boolean running);
}
