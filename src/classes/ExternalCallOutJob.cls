/**
 * Created by pankajjakhar on 12/09/21.
 */

public with sharing class ExternalCallOutJob implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private List<Case> casesList;
    public List<ExternalMessageData> externalMessageDataList;

    private Set<Id> caseIdsSet;

    public class ExternalMessageData {
        public String accountName;
        public String caseNumber { get; set; }
    }

    public ExternalCallOutJob(List<Case> casesList) {
        this.casesList = casesList;
        caseIdsSet = new Set<Id>();
        externalMessageDataList = new List<ExternalMessageData>();

        for (Case caseRecord : casesList) {
            caseIdsSet.add(caseRecord.Id);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String query = ' SELECT Id, ' +
                '     Name, ' +
                '     Subject, ' +
                '     CaseNumber ' +
                ' FROM Case ' +
                ' WHERE ID IN :caseIdsSet ';

        System.debug(LoggingLevel.DEBUG, 'ExternalCallOutJob.start -> query: ' + query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<Case> casesList) {
        System.debug(LoggingLevel.DEBUG, 'ExternalCallOutJob.execute -> casesList.size(): ' + casesList.size());

        ExternalCallOutHandler handler = new ExternalCallOutHandler(casesList);
        handler.notifyExternalSystem();
    }

    public void finish(Database.BatchableContext batchableContext) {
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [
                SELECT Id,
                        Status,
                        NumberOfErrors,
                        JobItemsProcessed,
                        TotalJobItems,
                        CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :batchableContext.getJobId()
        ];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                a.CreatedBy.Email
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail.setPlainTextBody
                ('The batch Apex job processed ' + a.TotalJobItems +
                        ' batches with ' + a.NumberOfErrors + ' failures.');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
}