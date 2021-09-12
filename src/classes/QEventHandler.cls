/**
 * Created by pankajjakhar on 12/09/21.
 */
public with sharing virtual class QEventHandler {
    public List<QueueUserChange__e> eventsList;
    public List<Account> accountsToInsertList;
    public List<Contact> contactsToInsertList;
    public List<Opportunity> opportunitiesToInsertList;
    public List<Case> casesToInsertList;

    public QEventHandler(List<QueueUserChange__e> eventsList) {
        this.eventsList = eventsList;

        accountsToInsertList = new List<Account>();
        contactsToInsertList = new List<Contact>();
        opportunitiesToInsertList = new List<Opportunity>();
        casesToInsertList = new List<Case>();
    }

    public void processCommon() {
        for (QueueUserChange__e changeEvent : eventsList) {
            QueueUserChangeEventHandler.EventBody body =
                    (QueueUserChangeEventHandler.EventBody) JSON.deserialize(changeEvent.Body__c,
                            QueueUserChangeEventHandler.EventBody.class);


            accountsToInsertList.add(createUncommittedAccount(body.firstName + body.lastName));
        }

        insert accountsToInsertList;

        for (Account accountRecord : accountsToInsertList) {
            Contact contactRecord = createUncommittedContact(accountRecord.Id, accountRecord.Name, '', '');

            contactsToInsertList.add(contactRecord);
        }

        insert contactsToInsertList;
    }

    public virtual Account createUncommittedAccount(String accountName) {
        Account accountRecord = new Account();
        accountRecord.Name = accountName;

        return accountRecord;
    }

    public virtual Contact createUncommittedContact(Id accountId, String firstName,
            String lastName, String phone) {
        Contact contactRecord = new Contact();
        contactRecord.FirstName = firstName;
        contactRecord.LastName = lastName;

        return contactRecord;
    }

    public virtual Opportunity createUncommittedOpportunity(Id accountId, Id contactId, String name) {
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.AccountId = accountId;
        opportunityRecord.ContactId = contactId;
        opportunityRecord.Name = name;

        return opportunityRecord;
    }

    public virtual Case createUncommittedCase(Id accountId, Id contactId, String subject) {
        Case caseRecord = new Case();
        caseRecord.AccountId = accountId;
        caseRecord.ContactId = contactId;
        caseRecord.Subject = subject;

        return caseRecord;
    }

    /**
     * Notifies external service.
     * curl -v -X POST 'https://test-sf-push.free.beeceptor.com/my/api/path'
     * -H 'Content-Type: application/json' -d '{"data":"Hello Beeceptor"}'
     */
    public void notifyExternalSystem() {
        ExternalCallOutJob job = new ExternalCallOutJob(casesToInsertList);
        Database.executeBatch(job, 10);
    }
}