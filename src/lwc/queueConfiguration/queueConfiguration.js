import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getUsersList from '@salesforce/apex/QueueConfigurationController.getUsersList';
import getUsersInTheQueue from '@salesforce/apex/QueueConfigurationController.getUsersInTheQueue';
import addMemberToTheQueue from '@salesforce/apex/QueueConfigurationController.addMemberToTheQueue';
import getUserGroupInfoList from '@salesforce/apex/QueueConfigurationController.getUserGroupInfoList';
import deleteGroupMember from '@salesforce/apex/QueueConfigurationController.deleteGroupMember';

const actions = [
    { label: 'Delete', name: 'delete' },
];

export default class QueueConfiguration extends LightningElement {    
    @track columnsAll = [{
            label: 'Name',
            fieldName: 'Name',
            type: 'text',
            sortable: false
        },
        {
            label: 'Email',
            fieldName: 'Email',
            type: 'email',
            sortable: false
        }
    ];

    @track columnsInUserGroup = [{
            label: 'Name',
            fieldName: 'userName',
            type: 'text',
            sortable: false
        },
        {
            label: 'Email',
            fieldName: 'email',
            type: 'email',
            sortable: false
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: actions,
                menuAlignment: 'right'
            }
        }
    ];

    @track userId;
    @track queueId;
    @track error;
    @track usersList;
    
    @track userGroupInfoList;

    @wire(getUsersList)
    wiredUsers({
        error,
        data
    }) {
        if (data) {
            this.usersList = data;
        } else if (error) {
            this.error = error;
        }
    }

    /*@wire(getUsersInTheQueue, {queueId: '$queueId'})
    wiredUsersInTheQueue({
        error,
        data
    }) {
        if (data) {
            this.usersList = data;
        } else if (error) {
            this.error = error;
        }
    }*/

    /* @wire(getUserGroupInfoList, {queueId: '$queueId'})
    wiredUserGroupInfoInTheQueue({
        error,
        data
    }) {
        console.log(JSON.stringify(data));
        console.log(JSON.stringify(error));
        if (data) {
            this.userGroupInfoList = data;
        } else if (error) {
            this.error = error;
        }
    }*/

    groupMemberId = '';

    handleUserChange(event){
        console.log('handleUserChange Called 1.8');
        
        this.userId = event.detail;

        console.log(event.detail);
    }

    handleQueueChange(event){
        console.log('handleQueueChange Called 1.10');
        
        this.queueId = event.detail;

        console.log(event.detail);

        this.refreshUserQueueInfoList();
    }

    refreshUserQueueInfoList() {
        console.log('inside refreshUserQueueInfoList 1.1');

        getUserGroupInfoList({ queueId: this.queueId })
        .then((result) => {
            this.userGroupInfoList = result;
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.userGroupInfoList = undefined;
        });

        /*getUserGroupInfoList({queueId : this.queueId}).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'UserGroup List loaded successfully!',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in loading UserGroup List',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });*/
    }

    addUserToTheQueue() {
        console.log('addUserToQueue called 1.4');
        console.log(this.userId);
        console.log(this.queueId);

        addMemberToTheQueue({userId : this.userId, queueId : this.queueId}).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Member added to the queue',
                    variant: 'success'
                })
            );

            // refreshing table data using refresh apex
            //refreshApex(this.userGroupInfoList);
            this.refreshUserQueueInfoList();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in adding member to the queue',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    handleRowAction(event) {
        console.log('handleRowAction called 1.7');
        console.log(JSON.stringify(event));        
        console.log(event.detail.row.groupMemberId);

        const action = event.detail.action;
        const row = event.detail.row;
        
        switch (action.name) {
            case 'show_details':
                alert('Showing Details: ' + JSON.stringify(row));
                break;
            case 'delete':
                console.log('executing delete action');
                this.deleteGroupMemberImperatively(event);
                break;
        }
    }

    deleteGroupMemberImperatively(event) {
        console.log('deleteGroupMemberImperatively deleting record 1.3');

        const recordId = event.detail.row.groupMemberId;
        deleteGroupMember({groupMemberId : recordId}).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted',
                    variant: 'success'
                })
            );

            //refreshApex(this.userGroupInfoList);
            this.refreshUserQueueInfoList();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}