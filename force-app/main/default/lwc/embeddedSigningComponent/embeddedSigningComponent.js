import ChangeOwner from '@salesforce/apex/EmbeddedSigningController.ChangeOwner';
import getEmbeddedSigningUrl from '@salesforce/apex/EmbeddedSigningController.getEmbeddedSigningUrl';
import sendEnvelope from '@salesforce/apex/EmbeddedSigningController.sendEnvelope';
import voidEnvelope from '@salesforce/apex/EmbeddedSigningController.voidEnvelope';
import { LightningElement, api } from 'lwc';

export default class EmbeddedSigningComponent extends LightningElement {
    @api recordId;
    
    handleClick() {
        console.log('record id '+this.recordId)
        ChangeOwner({mySourceId :this.recordId})
        .then((x)=>{
            console.log(x+ '-->1');
            if(x){
                voidEnvelope({mySourceId :this.recordId})
                .then((isVoided)=>{
                    console.log(isVoided+ '-->2');
                    if(isVoided){
                        console.log('inside send envelope-->3');
                        sendEnvelope({recordId: this.recordId})
                        .then((envelopeId) => (
                        getEmbeddedSigningUrl({envId: envelopeId,url: window.location.href})
                        ))
                        .then((signingUrl) => {
                            window.location.href = signingUrl;
                        })
                        .catch((error) => {
                            console.log('Error urL ERROR:');
                            console.log(error);
                        })
                    }else{
                        console.log('voiding operation failed')
                    }
                })
                .catch((error) => {
                console.log('Error voided envelope:');
                console.log(error);
                })
            }
        }).catch((error) => {
            console.log('Error  changing owner envelope:');
            console.log(error);
        })
    }
}