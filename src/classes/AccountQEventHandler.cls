/**
 * Created by pankajjakhar on 12/09/21.
 */

public with sharing class AccountQEventHandler extends QEventHandler {

    public AccountQEventHandler(List<QueueUserChange__e> eventsList) {
        super(eventsList);
    }

    public void process() {
        processCommon();
    }
}