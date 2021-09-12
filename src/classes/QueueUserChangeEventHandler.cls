/**
 * Created by pankajjakhar on 12/09/21.
 */

public with sharing class QueueUserChangeEventHandler {
    public class EventBody {
        public String userId { get; set; }
        public String queueId { get; set; }

        public String firstName { get; set; }
        public String lastName { get; set; }
    }

    public static void createEvent(String type, EventBody body) {
        QueueUserChange__e queueUserChangeEvent = new QueueUserChange__e();
        queueUserChangeEvent.Type__c = type;
        queueUserChangeEvent.FirstName__c = body.firstName;
        queueUserChangeEvent.LastName__c = body.lastName;
        queueUserChangeEvent.Body__c = JSON.serialize(body);

        Database.SaveResult eventPublishingResult = EventBus.publish(queueUserChangeEvent);

        if (eventPublishingResult.isSuccess()) {
            System.debug('Event Published Successfully.');
        } else {
            for (Database.Error error : eventPublishingResult.getErrors()) {
                System.debug('Error returned: ' +
                        error.getStatusCode() + ' - ' +
                        error.getMessage());
            }
        }
    }
}