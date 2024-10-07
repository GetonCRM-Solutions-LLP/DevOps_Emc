import { LightningElement,api,track,wire} from 'lwc';
import createGoToWebinar from "@salesforce/apex/GoToWebinarController.createGoToWebinar";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import Account_Name from '@salesforce/schema/Account.Name';
	
import { NavigationMixin } from 'lightning/navigation';

const fields = [Account_Name];
export default class GoToWebinar extends LightningElement {

    goToWebinarId;
    submitDisable;

    subject;
    description;
    startTime;
    endTime;
    accountId;
    

    @api recordId;
    webinarDetails ={};

    @track textValue = "Learn about your new vehicle reimbursement plan, the mBurse Plan of Vehicle Reimbursements. The training session will cover the following topics: \r\n 1. How mBurse works \r\n 2. What you need to do \r\n 3. Mileage capture \r\n We look forward to sharing more information about your new reimbursement program.";

    @wire(getRecord, { recordId: '$accountId', fields })
    account;

    connectedCallback(){
        //do something
        
        const urlParams = new URLSearchParams(window.location.search);
        this.accountId = urlParams.get('id');
   }  

    handleSubjectChange(event){
        this.subject = event.target.value;
    }
    handleDescriptionChange(event){
        this.description = event.target.value;
    }
    handleStartTimeChange(event){
        this.startTime = event.target.value;
    }
    handleEndTimeChange(event){
        this.endTime = event.target.value;
    }
    get accountName() {
        console.log('Account name: ',this.accountId);
        let accName = getFieldValue(this.account.data, Account_Name );
        let appendName = 'Driver Meeting';
        return accName+" "+appendName;
        //return getFieldValue(this.account.data, Account_Name );
    }
   

    handleSubmit(event){
        event.preventDefault();  
        const objChild = this.template.querySelector('c-toast');  
        
       console.log('Account ID: ',this.accountId);
       console.log('Subject: ',this.template.querySelector("[data-field='subject']").value);
       console.log('Description: ',this.template.querySelector("[data-field='description']").value);
       console.log('Start Time: ',this.startTime);
       console.log('End Time: ',this.endTime);
        //console.log('accountId',accountId);
     
        createGoToWebinar({ 
            accountId: this.accountId ,
            subject : this.template.querySelector("[data-field='subject']").value,
            description : this.template.querySelector("[data-field='description']").value,
            startTime : this.startTime,
            endTime : this.endTime
        })
        .then((result) => {
            console.log({result});
            console.log('Id:',result.success);
            if(result.hasOwnProperty('success')){
                 objChild.showToast('Success', 'Webinar Created Successfully','success', true);
            }else{
                objChild.showToast('Error', result.error,'error', true);
            }
           // this.contacts = result;
            this.error = undefined; 
        })
        .catch((error) => {
            console.log({error});
            objChild.showToast('Error', 'Some Error Accured','error', true);
            // this.error = error;
            // this.contacts = undefined;
        });
    }
}