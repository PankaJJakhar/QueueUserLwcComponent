/**
 * Created by pankajjakhar on 12/09/21.
 */
public with sharing class QueueUserChangeTriggerHandler {
    private List<QueueUserChange__e> accountQEventsList;
    private List<QueueUserChange__e> contactQEventsList;
    private List<QueueUserChange__e> caseQEventsList;

    public QueueUserChangeTriggerHandler() {
        accountQEventsList = new List<QueueUserChange__e>();
        contactQEventsList = new List<QueueUserChange__e>();
        caseQEventsList = new List<QueueUserChange__e>();
    }

    public void processAfterInsert(List<QueueUserChange__e> queueUserChangeEventsList) {
        System.debug('QueueUserChangeTriggerHandler');

        for (QueueUserChange__e changeEvent : queueUserChangeEventsList) {
            if (changeEvent.Type__c.equalsIgnoreCase(QueueConfigurationConstants.EVENT_TYPE_AC)) {
                accountQEventsList.add(changeEvent);
            } else if (changeEvent.Type__c.equalsIgnoreCase(QueueConfigurationConstants.EVENT_TYPE_ACC)) {
                contactQEventsList.add(changeEvent);
            } else if (changeEvent.Type__c.equalsIgnoreCase(QueueConfigurationConstants.EVENT_TYPE_ACOC)) {
                caseQEventsList.add(changeEvent);
            }
        }

        AccountQEventHandler accountQEventHandler = new AccountQEventHandler(accountQEventsList);
        accountQEventHandler.process();

        ContactQEventHandler contactQEventHandler = new ContactQEventHandler(contactQEventsList);
        contactQEventHandler.process();

        CaseQEventHandler caseQEventHandler = new CaseQEventHandler(caseQEventsList);
        caseQEventHandler.process();
    }
}