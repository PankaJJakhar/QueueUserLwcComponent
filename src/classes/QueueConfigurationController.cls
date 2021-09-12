/**
 * Created by pankajjakhar on 11/09/21.
 */
public with sharing class QueueConfigurationController {

    public class UserGroupInfo {
        @AuraEnabled
        public Id groupId { get; set; }
        @AuraEnabled
        public Id userIdOrGroupId { get; set; }
        @AuraEnabled
        public Id groupMemberId { get; set; }

        @AuraEnabled
        public String userName { get; set; }
        @AuraEnabled
        public String email { get; set; }

        public UserGroupInfo() {
        }
    }

    @AuraEnabled
    public static List<UserGroupInfo> getUserGroupInfoList(String queueId) {
        List<GroupMember> groupMembersList = [
                SELECT Id,
                        GroupId,
                        UserOrGroupId
                FROM GroupMember
                WHERE GroupId = :queueId
        ];

        Map<Id, GroupMember> userIdToGroupMemberMap = new Map<Id, GroupMember>();

        Set<Id> userIdsSet = new Set<Id>();
        for (GroupMember groupMember : groupMembersList) {
            Id recordId = groupMember.UserOrGroupId;

            // Not a user Id.
            if ((recordId + '').contains('005') == false) continue;

            userIdsSet.add(groupMember.UserOrGroupId);
        }

        Map<Id, User> userIdToRecordMap = new Map<Id, User>([
                SELECT Id,
                        Name,
                        Email
                FROM User
                WHERE Id = :userIdsSet
        ]);


        List<UserGroupInfo> userGroupInfoList = new List<QueueConfigurationController.UserGroupInfo>();

        for (GroupMember groupMember : groupMembersList) {
            Id recordId = groupMember.UserOrGroupId;

            // Not a user Id.
            if ((recordId + '').contains('005') == false) continue;

            User userRecord = userIdToRecordMap.get(recordId);

            UserGroupInfo info = new UserGroupInfo();
            info.userIdOrGroupId = groupMember.UserOrGroupId;
            info.groupMemberId = groupMember.Id;
            info.groupId = groupMember.GroupId;
            info.userName = userRecord.Name;
            info.email = userRecord.Email;

            userGroupInfoList.add(info);
        }

        return userGroupInfoList;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUsersList() {
        return [
                SELECT Id,
                        Name,
                        Email
                FROM User
                WHERE IsActive = TRUE
        ];
    }

    @AuraEnabled
    public static void addMemberToTheQueue(String userId, String queueId) {
        GroupMember member = new GroupMember();
        member.GroupId = queueId;
        member.UserOrGroupId = userId;

        insert member;

        QueueUserChangeEventHandler.EventBody eventBody = new QueueUserChangeEventHandler.EventBody();
        eventBody.userId = userId;
        eventBody.queueId = queueId;

        List<User> userList = [
                SELECT Id, FirstName, LastName
                FROM User
                WHERE ID = :userId
        ];

        // Assuming queueId is valid.
        User selectedUser = userList[0];

        List<Group> queuesList = [
                SELECT Id, Name
                FROM Group
                WHERE ID = :queueId
        ];

        // Assuming queueId is valid.
        Group selectedGroup = queuesList[0];

        String type = '';
        if (selectedGroup.Name.equalsIgnoreCase(QueueConfigurationConstants.QUEUE_NAME_ACCOUNT_Q)) {
            type = QueueConfigurationConstants.EVENT_TYPE_AC;
        } else if (selectedGroup.Name.equalsIgnoreCase(QueueConfigurationConstants.QUEUE_NAME_CONTACT_Q)) {
            type = QueueConfigurationConstants.EVENT_TYPE_ACC;
        } else if (selectedGroup.Name.equalsIgnoreCase(QueueConfigurationConstants.QUEUE_NAME_CASE_Q)) {
            type = QueueConfigurationConstants.EVENT_TYPE_ACOC;
        }

        QueueUserChangeEventHandler.createEvent(type, eventBody);
    }

    @AuraEnabled
    public static Boolean deleteGroupMember(String groupMemberId) {

        List<GroupMember> groupMembersList = [
                SELECT Id,
                        GroupId,
                        UserOrGroupId
                FROM GroupMember
                WHERE Id = :groupMemberId
        ];

        System.debug('groupMembersList.size(): ' + groupMembersList.size());

        delete groupMembersList;

        return true;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUsersInTheQueue(String queueId) {
        List<GroupMember> groupMembersList = [
                SELECT Id,
                        GroupId,
                        UserOrGroupId
                FROM GroupMember
                WHERE GroupId = :queueId
        ];

        Set<Id> userIdsSet = new Set<Id>();
        for (GroupMember groupMember : groupMembersList) {
            Id recordId = groupMember.UserOrGroupId;

            // Not a user Id.
            if ((recordId + '').contains('005') == false) continue;

            userIdsSet.add(groupMember.UserOrGroupId);
        }


        return [
                SELECT Id,
                        Name,
                        Email
                FROM User
                WHERE Id = :userIdsSet
        ];
    }
}