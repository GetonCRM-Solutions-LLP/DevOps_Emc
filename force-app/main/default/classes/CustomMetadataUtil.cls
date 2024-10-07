/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description : CustomMetaData Update and result
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/


public with sharing class CustomMetadataUtil implements Metadata.DeployCallback  {
   
   
   /** 
    * ********************************************************
    *  Method for Handle Result of MetaData Update
    * ********************************************************
    */
   public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('Metadata Success Result:' + result);
        } else {
            System.debug('Metadata Failed Result :' + result);
        }
    }


  /** 
    * ********************************************************
    * updateCustomMetadata -
    1. Method for update Custom MetaData
    * ********************************************************
    */

    public static void updateCustomMetadata(String metdataName, String recordDevName, String label, Map<String, Object> metadataFieldValueMap){
        
        /*
        metdataName - MetaData API Name
        recordDevName - Unique Name For Identifiting existing Metadata
        label - MetaData Lable Name
        */
        
        Metadata.CustomMetadata cMetadata = new Metadata.CustomMetadata();
        cMetadata.fullName = metdataName + '.' + recordDevName;
        cMetadata.label = label;
        
        for(String key : metadataFieldValueMap.keySet()){
            Metadata.CustomMetadataValue cMetadataValue = new Metadata.CustomMetadataValue();
            cMetadataValue.Field = key;
            cMetadataValue.Value = metadataFieldValueMap.get(key); 
            cMetadata.values.add(cMetadataValue);
        }
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(cMetadata);

        CustomMetadataUtil callback = new CustomMetadataUtil();
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);

        //call createAndRegisterWebhook method for registering Webhook 
        //GoToWebinarWebhookRegistration.updateWebhookURL();

    }
}