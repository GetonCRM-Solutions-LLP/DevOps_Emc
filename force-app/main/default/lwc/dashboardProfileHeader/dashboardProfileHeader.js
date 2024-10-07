import { LightningElement,api } from 'lwc';
import logo from '@salesforce/resourceUrl/EmcCSS';

export default class DashboardProfileHeader extends LightningElement {
    @api userName;
    @api pageSource;
    @api driverMenu;
    @api fullName;
    @api companyLogo;
    @api isNavigate;
    @api expirationDate;
    @api unread;
    
    notificationlogo = logo + '/emc-design/assets/images/Icons/PNG/Green/Notifications.png';
  
    @api setSource(value){
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.pageSource = value;
        console.log("source", this.pageSource)
    }

    get expirationToggle(){
        var expirationDate, monthOfExpiration, yearOfExpiration,currentYear, currentMonth, date;
        date = new Date();
        expirationDate = new Date(this.expirationDate);
        monthOfExpiration = expirationDate.getMonth();
        yearOfExpiration = expirationDate.getFullYear();
        currentYear = date.getFullYear();
       // previousMonth = new Date(expirationDate.getFullYear(), expirationDate.getMonth() - 1).getMonth();
        currentMonth = date.getMonth();
        const styledText = (currentMonth === monthOfExpiration && currentYear === yearOfExpiration) ? 'color: #ff0000' : 'color: #909090';
        // : (previousMonth === currentMonth) ? 'color: #FFBF00'
        return styledText
    }

    get expireText(){
        var expirationDate, monthOfExpiration, yearOfExpiration,currentYear, currentMonth, date, isExpired;
        date = new Date();
        expirationDate = new Date(this.expirationDate);
        monthOfExpiration = expirationDate.getMonth();
        yearOfExpiration = expirationDate.getFullYear();
        currentYear = date.getFullYear();
        currentMonth = date.getMonth();
				isExpired = date >= expirationDate;
        const text = (!isExpired) ? 'Your insurance expires on' : 'Your insurance expired';
				console.log("Expiration:", date>=expirationDate);
        return text;
    }

    @api styleHeader(value){
        if(value === 'sidebar open'){
              this.template.querySelector('.welcome-msg').classList.add('extend');
              this.template.querySelector('.welcome-msg').classList.remove('enclose');
              this.template.querySelector('.header-inner').classList.add('expand');
        }else{
            this.template.querySelector('.welcome-msg').classList.add('enclose');
            this.template.querySelector('.welcome-msg').classList.remove('extend');
            this.template.querySelector('.header-inner').classList.remove('expand');
        }
    }

    @api styleLink(val){
        const Item = this.template.querySelectorAll("a");
            Item.forEach((el) =>{
                    if(val === el.name){
                        el.classList.add("is-active")
                    }else{
                        el.classList.remove("is-active")
                    }
            })
    }

    redirectToInsurance(){
        const redirectEvent = new CustomEvent('redirect', {detail: 'Insurance-Upload'});
        this.dispatchEvent(redirectEvent);
    }

    redirectToResource(){
        const redirectEvent = new CustomEvent('resourcenavigate', {detail: 'Videos'});
        this.dispatchEvent(redirectEvent);
    }

    handleContextMenu(evt){
        let name = (evt.srcElement) ? evt.srcElement.name : null
        var url , path;
        // eslint-disable-next-line no-restricted-globals
        url = location;
        path = url.origin + url.pathname + url.search + `#${name}`;
        if(name){
           // eslint-disable-next-line no-restricted-globals
           location.replace(path)
        }
        console.log('event', evt)
    }

    notificationRedirect(){
        const openEvent = new CustomEvent('notify', {detail: 'Videos'});
        this.dispatchEvent(openEvent);
    }

    renderedCallback(){
            const buttonItem = this.template.querySelectorAll("a");
            buttonItem.forEach((el) =>
                el.addEventListener("click", () => {
                    buttonItem.forEach((el2) => el2.classList.remove("is-active"));
                        el.classList.add("is-active")
                })
            );
    }

    logOut(){
        const logoutEvent = new CustomEvent('logout', {detail: 'logout'});
        this.dispatchEvent(logoutEvent);
    }

}