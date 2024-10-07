import checkUserName from '@salesforce/apex/ForgotPasswordController.checkUserNameForCommunity';
import resetPasswordForCommunity from '@salesforce/apex/ForgotPasswordController.resetPasswordForCommunity';
import login from '@salesforce/apex/adminLoginController.login';
import { LightningElement, track } from 'lwc';

import Check_Username from '@salesforce/label/c.Check_Username';
import Forgot_Password from '@salesforce/label/c.Forgot_Password';
import Not_Available_any_User from '@salesforce/label/c.Not_Available_any_User';
import mBurse_LOGO from '@salesforce/resourceUrl/EmcCSS';
import SVG_LOGO from '@salesforce/resourceUrl/enternetExplorerSVG';


// import tosterJQuery from '@salesforce/resourceUrl/tosterJQuery';
// import tosterCSS from '@salesforce/resourceUrl/tosterCSS';
// import tosterJS from '@salesforce/resourceUrl/tosterJS';


export default class AdminLoginNew extends LightningElement {

    @track email = '';
    @track pass = '';
    svgURL = `${SVG_LOGO}`
    mBurseLogo = `${mBurse_LOGO}`+'/emc-design/assets/images/logo/mBurse-logo.png';
    backg = "C:\Users\Ekta Mistry\Downloads\Spring Login.png";
    @track errorMSG ='';
    @track responsedata;
    showpassword = false;
    hidepassword = true;
    forgetpassword = false;
    notforgetpassword = true;
    mainclass;

    connectedCallback() {
        const currentDate = new Date();
        const currentMonth = currentDate.getMonth()+1; // 0-based index, January is 0
        console.log("currentMonth",currentMonth)
        if (currentMonth >= 2 && currentMonth <= 4) {
            this.mainclass = 'main_'+'Spring';
        } else if (currentMonth >= 5 && currentMonth <= 7) {
            this.mainclass = 'main_'+'Summer';
        } else if (currentMonth >= 8 && currentMonth <= 10) {
            this.mainclass = 'main_'+'Autumn';
        } else {
            this.mainclass = 'main_'+'Winter';
        }
        
    }

    handleEmailChange(event){
        this.email = event.target.value;
    }
    handlePassChange(event){
        this.pass = event.target.value;
    }

    disableHandleClick(){
        this.template.querySelectorAll('.flat-input').forEach(item=>{
            item.disabled=true;
 
        })
    }

    enableHandleClick(){
        this.template.querySelectorAll('lightning-input').forEach(item=>{
            item.disabled=false;
 
        })
    }

    timeOutFun(){
        disableHandleClick();
        this.errorMSG = 'You are locked out for 15 minutes.';
    }

    showToastEventError(message){
        this.dispatchEvent(
            new CustomEvent("toastErr", {
                detail: message
            })
        );
    }

    showToastEventInfo(message){
        this.dispatchEvent(
            new CustomEvent("toastInfo", {
                detail: message
            })
        );
    }

    handleMouseEnter(){
        this.template.querySelector('.flat-container2').classList.remove('field_label');
        if(this.email.length == 0){
            this.template.querySelector('.flat-container1').classList.add('field_label');
        }
    }
    handleMouseEnterinPass(){
        this.template.querySelector('.flat-container1').classList.remove('field_label');
        if(this.pass.length == 0){
            this.template.querySelector('.flat-container2').classList.add('field_label');
        }
    }

    handleShowPassword(){
        this.showpassword = true;
        this.hidepassword = false;
    }

    handleHidePassword(){
        this.showpassword = false;
        this.hidepassword = true;
    }

    handleRegister(event){
        console.log("handleRegister")
        
        console.log("handleRegister",this.pass + this.email)
        // const objChild = this.template.querySelector('c-toast');  
        if(this.email.length == 0){
            this.showToastEventError('Please enter work email address.');
        }else if(this.pass.length == 0){
            this.showToastEventError('Please enter password');
        }else{
            login({
                username: this.email ,
                password: this.pass
            })
            .then((result) => {
                console.log('result::---->',result); 
                // console.log('result: ',JSON.stringify(result));
                console.log('result.isValid: ',typeof result );
                // returnData = JSON.stringify(result);
                let obj = JSON.parse(result);
                console.log('obj: ',obj);
                console.log('obj.isValid: ',typeof obj);
                console.log('obj.isValid: ',obj.isValid);

                if (obj.isValid == 'valid') {
                    // console.log('result: ',JSON.stringify(result));
                    // console.log('result.isValid: ',result);
                    if (obj.pgReference != null || obj.pgReference != undefined) {
                        console.log('result.isValid: ',obj.pgReference);
                        let pageRefURL = obj.pgReference;
                        pageRefURL = pageRefURL.replace('System.PageReference','');
                        pageRefURL = pageRefURL.replace('[','');
                        pageRefURL = pageRefURL.replace(']','');
                        console.log('pageRef: ',pageRefURL);
                        window.location = pageRefURL;
                    }
                    else{
                        console.log(obj);
                        this.showToastEventError('Your Password Is Incorrect!');
                        this.pass = '';
                        // toastr.error('Your Password Is Incorrect!');
                        // showError('Your Password Is Incorrect!');
                        // objChild.showToast('Error', 'Your Password Is Incorrect!','error', true);

                        if(obj.remainingAttempt != 0){
                            this.errorMSG = 'You have '+ obj.remainingAttempt  +' attempts before you are locked out.';
                            // objChild.showToast('Error', 'You have '+ result.remainingAttempt  +' attempts before you are locked out.','error', true);
                        }else{
                            const myTimeout = setTimeout(timeOutFun, 900000);
                            this.errorMSG ='';
                            this.enableHandleClick();
                            this.showToastEventInfo('You are locked out for 15 minutes.')
                            // toastr.info('You are now locked in. You can try again to Sign in!');
                            // this.errorMSG = 'You are now locked in. You can try again to Sign in!';
                            // objChild.showToast('Error', 'You are locked out for 15 minutes.','error', true);
                        }
                    }
                }
                else{
                    this.showToastEventError('Your Username Or Password Is Incorrect !');
                    // this.email = '';
                    this.pass = '';
                    // toastr.error('Your Username Or Password Is Incorrect !');
                    // showError('Your Username Or Password Is Incorrect !');
                    // objChild.showToast('Error', 'Your Username Or Password Is Incorrect !','error', true);
                }
            })
                .catch((error) => {
                    console.log(error);
                    console.log("catch",JSON.parse(JSON.stringify({error})));
                    this.showToastEventError('Some Error Accured');
                    // this.email = '';
                    this.pass = '';
                    // objChild.showToast('Error', 'Some Error Accured','error', true);
                });
        }
        
    }
    handleClick(){
        this.forgetpassword = true;
        this.notforgetpassword = false;
    }
   
    handleForgotEmail(event){
        this.email = event.target.value;
    }
    handleForgotEmailMouseEnter(){

    }
    handleSubmit(){
        if(this.email.length == 0){
            this.showToastEventError('Please enter work email address.');
        }else{
            console.log("this.email",this.email)
            this.showToastEventInfo(Check_Username)
            setTimeout(() => {
                checkUserName({username : this.email})
                .then(result => {
                    console.log("result",result)
                    if(result == 'valid'){
                    this.showToastEventInfo(Forgot_Password)
                        resetPasswordForCommunity({username : this.email})
                        .then(data => {
                            console.log("data",data.split('[')[1])
                            let test = data.split('[')[1];
                            let url = test.split(']')[0];

                            if(url != null){
                                console.log("url,",window.location.href)
                                window.location.href = url;
                            }
                        })
                        .catch(error => {
                            console.log("error for resetPasswordForCommunity",error)
                        })
                    }else{
                        this.showToastEventError(Not_Available_any_User);
                    }
                })
                .catch(error => {
                    console.log("error for dropdown list",error)
                })
            }, 4000);
        }
    }
}