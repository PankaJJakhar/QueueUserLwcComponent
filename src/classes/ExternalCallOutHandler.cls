/**
 * Created by pankajjakhar on 12/09/21.
 */

public with sharing class ExternalCallOutHandler {
    public List<Case> casesList;
    public List<ExternalMessageData> externalMessageDataList;

    public class ExternalMessageData {
        public String accountName;
        public String caseNumber { get; set; }
    }

    public ExternalCallOutHandler(List<Case> casesList) {
        this.casesList = casesList;
        externalMessageDataList = new List<ExternalMessageData>();
    }

    /**
     * Notifies external service.
     * curl -v -X POST 'https://test-sf-push.free.beeceptor.com/my/api/path'
     * -H 'Content-Type: application/json' -d '{"data":"Hello Beeceptor"}'
     */
    public void notifyExternalSystem() {
        String payloadToSend = getPayload();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test-sf-push.free.beeceptor.com/my/api/path');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(payloadToSend);

        HttpResponse response = http.send(request);

        // Parse the JSON response
        if(response.getStatusCode() == 200) {
            System.debug('Successful: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    }

    private String getPayload() {
        for (Case caseRecord : casesList) {
            ExternalMessageData data = new ExternalMessageData();
            data.accountName = caseRecord.Subject; // For now, I have kept Account Name in the subject.
            data.caseNumber = caseRecord.CaseNumber;

            externalMessageDataList.add(data);
        }

        return JSON.serialize(externalMessageDataList);
    }
}