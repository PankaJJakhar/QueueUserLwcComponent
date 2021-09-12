/**
 * Created by pankajjakhar on 12/09/21.
 */
trigger QueueUserChangeTrigger on QueueUserChange__e (after insert) {

    System.debug('QueueUserChangeTrigger');

    if (Trigger.isAfter && Trigger.isInsert) {
        System.debug('QueueUserChangeTrigger -> Platform Event Created');
        QueueUserChangeTriggerHandler handler = new QueueUserChangeTriggerHandler();
        handler.processAfterInsert(Trigger.newMap.values());
    }
}