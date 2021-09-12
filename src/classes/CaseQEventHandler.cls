/**
 * Created by pankajjakhar on 12/09/21.
 */

public with sharing class CaseQEventHandler extends QEventHandler {

    public CaseQEventHandler(List<QueueUserChange__e> eventsList) {
        super(eventsList);
    }

    public void process() {
        processCommon();

        for (Contact contactRecord : contactsToInsertList) {
            casesToInsertList.add(createUncommittedCase(contactRecord.AccountId,
                    contactRecord.Id, contactRecord.FirstName));
        }

        insert casesToInsertList;

        for (Contact contactRecord : contactsToInsertList) {
            opportunitiesToInsertList.add(createUncommittedOpportunity(contactRecord.AccountId,
                    contactRecord.Id, contactRecord.Name));
        }

        insert opportunitiesToInsertList;

        notifyExternalSystem();
    }
}