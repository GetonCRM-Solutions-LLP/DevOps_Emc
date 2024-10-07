import { LightningElement,api,wire } from 'lwc';
import customSettingsForMessage from '@salesforce/apex/NewAccountDriverController.getCustomSettingsForMessage'
export default class FileUploadSpinner extends LightningElement {
    @api showSpinner = false;
    @api fileMessageUrl = '';
    @api isNotCustomSettingMessage = false;
    customMessage;
    @wire(customSettingsForMessage)
    myCustomSettings({ error, data }){
        this.customMessage = data;
        if (data && !this.isNotCustomSettingMessage) {
            this.fileMessageUrl = data.File_Loader__c;
          } else if (error) {
              console.log(error);
          }
    }

    @api messageUrl(fileCategory){
        this.fileMessageUrl = (fileCategory) ? (fileCategory === 'locationFile') ? this.customMessage.File_Upload_Location__c : this.customMessage.File_Loader__c : this.customMessage.File_Loader__c;
    }
}