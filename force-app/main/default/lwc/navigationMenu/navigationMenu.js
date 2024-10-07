/* eslint-disable no-restricted-globals */
import {
    LightningElement, api, wire, track
} from 'lwc';
// import {
//      openEvents
// } from 'c/utils';
import emcCss from '@salesforce/resourceUrl/EmcCSS';
import logo from '@salesforce/resourceUrl/mBurseCss';
import redirectionURL from '@salesforce/apex/NewAccountDriverController.loginRedirectionADMD';
import getRole from '@salesforce/apex/NewAccountDriverController.getRole';
export default class NavigationMenu extends LightningElement {
    @api driverMenuItem;
    @api driverName;
    @api driverEmail;
    @api profileId;
    @track record;
    roleUser;
    contactId;
    reportId;
    menuLabel;
    subMenuLabel;
    childMenuLabel;
    initialized = false;
    isOut = false;
    isSecondary = false;
    isNotLocked = true;
    scroll = false;
    showButtons = false;
    mileageMenu = false;
    manualMenu = false;
    company = logo + '/mburse/assets/mBurse-Icons/mBurse-logo.png';
    companyShort = logo + '/mburse/assets/mBurse-Icons/mBurse-short.png';
    user = emcCss + '/emc-design/assets/images/Icons/SVG/Green/User.svg';
    _originalAdmin = 'Admin Dashboard';
    _originalDriver = 'Driver Dashboard';
    _admin = 'Admin Dashboard';
    _driver = 'Driver Dashboard';
    _role;
  
    
    get adminText(){
        return this._admin
    }
  
    set adminText(value){
        this._admin = value;
    }
  
    get driverText(){
        return this._driver
    }
  
    set driverText(value){
        this._driver = value;
    }
    
 
  
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
 
    handleSubMenuRedirect(event){
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
        subMenu.forEach((item) => item.classList.remove('active'));
        const selectedMenu = (event.currentTarget !== undefined ) ? event.currentTarget.dataset.name : event;
        for (let i = 0; i < subMenu.length; i++) {
             if (selectedMenu === subMenu[i].dataset.name) {
                subMenu[i].classList.add('active');
                subMenu[i].href = `#${selectedMenu}`;
             }
         }
       
         if(sidebarSubMenu){
             sidebarSubMenu.forEach((el)=>{
                 if(el.className === 'secondary-menu open'){
                     el.classList.toggle("open");
                 }
             })
         }
    }

    handleChildRedirect(event){
        const id = event?.currentTarget?.dataset.id;
        const lockDate = event?.currentTarget?.dataset.date;
        const isLock = event?.currentTarget?.dataset.lock;
        this.reportId = id;
        const message = {
           reportID : this.reportId,
           mileageLockDate: lockDate,
           lockReport:  isLock,
           message: 'navigation' 
        };
        let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
        subMenu.forEach((item) => item.classList.remove('active'));
        const selectedMenu = (event.currentTarget !== undefined ) ? event.currentTarget.dataset.name : event;
        this.childMenuLabel = selectedMenu;
        for (let i = 0; i < subMenu.length; i++) {
             if (selectedMenu === subMenu[i].dataset.name) {
                subMenu[i].classList.add('active');
             }
         }
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if(sidebarSubMenu){
            sidebarSubMenu.forEach((el)=>{
                if(el.className === 'secondary-menu open'){
                    el.classList.toggle("open");
                }
            })
        }
        this.dispatchEvent(
            new CustomEvent("getreport", {
                detail: message
            })
        );
    }
  
    handleRedirect(event) {
        console.log("Inside redirect#", this.childMenuLabel)
        let menu = this.template.querySelectorAll(".tooltipText");
        let subMenu =  this.template.querySelectorAll(".secondary-menu");
        let subMenuItem = this.template.querySelectorAll(".secondaryMenuItem");
        subMenuItem.forEach((a) => { 
            if(a.dataset.name !== this.subMenuLabel) { 
                if(a.dataset.name !== this.childMenuLabel)
                    a.classList.remove('active') 
            }
        });
        const selectedMenu = (event.currentTarget !== undefined ) ? event.currentTarget.dataset.name : event;
        const selectedMenuId = (event.currentTarget !== undefined ) ? event.currentTarget.dataset.id : event;
        const sidebarSubMenu = this.template.querySelector(`.secondary-menu[data-id="${selectedMenuId}"]`);
        menu.forEach((item) => {
            if(item.dataset.name != this.menuLabel){
                item.classList.remove('active')
                item.setAttribute("aria-expanded", "false") 
            }
            if(item.dataset.name === selectedMenu){
                item.classList.add('isHighLighted');
            }else{
                item.classList.remove('isHighLighted');
            }
        });
        subMenu.forEach((item) => {
            if(item.dataset.id !== selectedMenuId){
                item.classList.remove('open')
            }
        });
        this.childMenuLabel = (selectedMenu === 'Reports') ? this.childMenuLabel : '';
        this.menuLabel = (selectedMenu === 'Notifications') ? selectedMenu : this.menuLabel;
        for (let i = 0; i < menu.length; i++) {
            if (selectedMenuId === menu[i].dataset.id) {
                menu[i].classList.add('active');
                if(menu[i]?.nextElementSibling?.dataset.id === undefined){
                    menu[i].href = `#${selectedMenu}`;
                }
            }
        }
        if(sidebarSubMenu){
            sidebarSubMenu.classList.toggle("open");
            if(sidebarSubMenu.className === 'secondary-menu open'){
                sidebarSubMenu.previousElementSibling.setAttribute("aria-expanded", "true");
            }else{
                sidebarSubMenu.previousElementSibling.setAttribute("aria-expanded", "false");
            }
            
        }
    }

    sessionLocked(){
        this.isOut = false;
        this.isNotLocked = false;
        const sidebar = this.template.querySelector('.sidebar');
        sidebar.classList.add("open");
        sidebar.classList.toggle("pinned");
        if(this.showButtons){
            const textAdmin =  this._originalAdmin;
            const textDriver =  this._originalDriver;
            this._admin = (sidebar.className === 'sidebar pinned open' && textAdmin != undefined) ? textAdmin.substring(0,1) : this._originalAdmin
            this._driver = (sidebar.className === 'sidebar pinned open' && textDriver != undefined) ? textDriver.substring(0,1) : this._originalDriver
        }
        this.dispatchEvent(
                new CustomEvent("sidebar", {
                    detail: sidebar.className
                })
        );
    }

    lockMenu(){
        this.isOut = false;
        this.isNotLocked = false;
        let isSession = sessionStorage.getItem("menuLocked");
        if(!isSession){
            sessionStorage.setItem("menuLocked", true);
        }
        const sidebar = this.template.querySelector('.sidebar');
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if(sidebarSubMenu){
            sidebarSubMenu.forEach((el)=>{
                if(el.className === 'secondary-menu open'){
                    el.classList.toggle("open");
                }
            })
        }
        sidebar.classList.remove("close");
        sidebar.classList.toggle("pinned");
        this.dispatchEvent(
                new CustomEvent("sidebar", {
                    detail: sidebar.className
                })
        );
    }
    unlockMenu(){
        this.isOut = false;
        this.isNotLocked = true;
        sessionStorage.removeItem("menuLocked");
        const sidebar = this.template.querySelector('.sidebar');
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if(sidebarSubMenu){
            sidebarSubMenu.forEach((el)=>{
                if(el.className === 'secondary-menu open'){
                    el.classList.toggle("open");
                }
            })
        }
       
        sidebar.classList.toggle("open");
        sidebar.classList.add("pinned");
        sidebar.classList.add("close");
        setTimeout(() => {
            sidebar.classList.remove("close");
        }, 1000)
       
        this.dispatchEvent(
                new CustomEvent("sidebar", {
                    detail: sidebar.className
                })
        );
    }
  
    @api toggleStyle(value, type) {
        let menu = this.template.querySelectorAll(".tooltipText");
        if(type === 'back'){
            let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
            subMenu.forEach((a) => {a.classList.remove('active')});
            this.childMenuLabel = '';
            console.log("Toggle##", this.childMenuLabel);
        }
        menu.forEach((item) => { 
            item.classList.remove('active')
            item.classList.remove('isHighLighted');
        })
        const sMenu = value;
        this.menuLabel = value;
        this.subMenuLabel = value;
        const sidebarSubMenu = this.template.querySelector(`.secondaryMenuItem[data-name="${sMenu}"]`);
        for (let i = 0; i < menu.length; i++) {
            if (sMenu === menu[i].dataset.name) {
                menu[i].classList.add('active');
                if(sidebarSubMenu && !this.childMenuLabel){
                    sidebarSubMenu.classList.add('active');
                }
               // menu[i].href = `#${sMenu}`;
            }else{
                if(sidebarSubMenu && !this.childMenuLabel){
                    //this.menuLabel = sidebarSubMenu?.previousElementSibling?.dataset.name;
                    if(sidebarSubMenu.dataset.id === menu[i].dataset.id){
                        this.menuLabel = menu[i].dataset.name;
                        sidebarSubMenu.classList.add('active');
                        menu[i].classList.add('active');
                    }
                }
            }
        }
    }
  
    redirectToHomePage(){
        // eslint-disable-next-line no-restricted-globals
        var url, path;
        url = location;
        path = url.origin + url.pathname + url.search;
        location.replace(path);
    }

    toggleSideBarOut(){
        this.isOut = false;
        var menuCount = 0;
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if(sidebarSubMenu){
            sidebarSubMenu.forEach((el=>{
                if(el.className === 'secondary-menu open'){
                    menuCount++
                }
            }))
        }
        if(this.isNotLocked && menuCount === 0){   
            const sidebar = this.template.querySelector('.sidebar');
            let menu = this.template.querySelectorAll(".tooltipText");
            let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
            subMenu.forEach((a) => { if(a.dataset.name !== this.subMenuLabel) {  { if(a.dataset.name !== this.childMenuLabel) { a.classList.remove('active') }} }});
            menu.forEach((item) => {
                if(item.dataset.name != this.menuLabel){
                    item.classList.remove('active')
                    item.classList.remove('isHighLighted');
                    item.setAttribute("aria-expanded", "false") 
                }
            });
            if(this.showButtons){
                const textAdmin =  this._originalAdmin;
                const textDriver =  this._originalDriver;
                this._admin = ((sidebar.className === 'sidebar pinned open' || sidebar.className === 'sidebar pinned close open') && textAdmin != undefined) ? textAdmin.substring(0,1) : this._originalAdmin
                this._driver = ((sidebar.className === 'sidebar pinned open' || sidebar.className === 'sidebar pinned close open') && textDriver != undefined) ? textDriver.substring(0,1) : this._originalDriver
            }
            this.dispatchEvent(
                new CustomEvent("sidebar", {
                    detail: sidebar.className
                })
            );
            sidebar.classList.toggle("open");
        }
       
    }
  
    toggleSideBar() {
        this.isOut = true;
        var menuCount = 0;
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if(sidebarSubMenu){
            sidebarSubMenu.forEach((el=>{
                if(el.className === 'secondary-menu open'){
                    menuCount++
                }
            }))
        }
        if(this.isNotLocked && menuCount === 0){
            const sidebar = this.template.querySelector('.sidebar');
            if(this.showButtons){
                const textAdmin =  this._originalAdmin;
                const textDriver =  this._originalDriver;
                this._admin = (sidebar.className === 'sidebar pinned open' && textAdmin != undefined) ? textAdmin.substring(0,1) : this._originalAdmin
                this._driver = (sidebar.className === 'sidebar pinned open' &&  textDriver != undefined) ? textDriver.substring(0,1) : this._originalDriver
            }
            this.dispatchEvent(
                new CustomEvent("sidebar", {
                    detail: sidebar.className
                })
            );
           // sidebar.classList.remove("close");
            sidebar.classList.toggle("open");
        }
        
    }
  
    logOut(){
        const logoutEvent = new CustomEvent('logout', {detail: 'logout'});
        this.dispatchEvent(logoutEvent);
    }
    redirectToDashboard(Id, Role){
        redirectionURL({
            contactId: Id,
            adminTab: Role
        })
        .then((result) => {
            let url = location.origin + result;
            window.open(url, '_self');
        })
        .catch((error) => {
            // If the promise rejects, we enter this code block
            console.log(error);
        })
    }
  
    redirectToDriverProfile(){
      // window.location.href = location.origin + '/app/driverProfileDashboard' + location.search;
      this.redirectToDashboard(this.contactId, false)
    }
  
    redirectToProfile(){
        // if(this.profileId === '00e31000001FRDXAA4'){
        //     window.location.href = location.origin + '/app/managerProfileDashboard' + location.search;
        // }else{
        //     window.location.href = location.origin + '/app/adminProfileDashboard' + location.search;
        // }
        this.redirectToDashboard(this.contactId, true)
    }
  
    handleContextMenu = (event) =>{
       // console.log(event)
        event.preventDefault();
    }
  
    mouseOverLink(event){
       // this.isOut = false;
        var menuCount = 0;
        let menu = this.template.querySelectorAll(".tooltipText");
        menu.forEach((item) => { if(item.dataset.name != this.menuLabel) {item.classList.remove('active')} item.classList.remove('isHighLighted');  item.setAttribute("aria-expanded", "false") });
        let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
        subMenu.forEach((a) => { if(a.dataset.name !== this.subMenuLabel) { if(a.dataset.name !== this.childMenuLabel) { a.classList.remove('active') }}});
        const selectedMenuId = (event.currentTarget !== undefined ) ? event.currentTarget.dataset.id : event;
        const sidebarSubMenu = this.template.querySelector(`.tooltipText[data-id="${selectedMenuId}"]`);
        const subElement = this.template.querySelectorAll('.secondary-menu');
        if(subElement){
            subElement.forEach((el=>{
                if(el.className === 'secondary-menu open'){
                    menuCount++
                }
            }))
        }
        if(menuCount > 0){
            sidebarSubMenu.classList.add("active");
            sidebarSubMenu.setAttribute("aria-expanded", "true");
        }
    }
    sideMenuOut(){
        this.isOut = true;
    }
  
    handleOutsideClick = (event) => {
        var isOpen = 0
        if(!this.isOut){
            const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
            let menu = this.template.querySelectorAll(".tooltipText");
            // menu.forEach((item) => { item.setAttribute("aria-expanded", "false") });
             menu.forEach((item) => {
                 if(item.dataset.name != this.menuLabel){
                     item.classList.remove('active')
                     item.classList.remove('isHighLighted')
                     item.setAttribute("aria-expanded", "false") 
                 }
            });
            if(sidebarSubMenu){
                sidebarSubMenu.forEach((el=>{
                    if(el.className === 'secondary-menu open'){
                        isOpen++
                        el.classList.remove("open");
                    }
                }))
              
                if(this.isNotLocked && isOpen > 0){
                    const sidebar = this.template.querySelector('.sidebar');
                    if(this.showButtons){
                        const textAdmin =  this._originalAdmin;
                        const textDriver =  this._originalDriver;
                        this._admin = (sidebar.className === 'sidebar pinned open' && textAdmin != undefined) ? textAdmin.substring(0,1) : this._originalAdmin
                        this._driver = (sidebar.className === 'sidebar pinned open' &&  textDriver != undefined ) ? textDriver.substring(0,1) : this._originalDriver
                    }
                    sidebar.classList.remove("close");
                    sidebar.classList.remove("open");
                    this.dispatchEvent(
                        new CustomEvent("sidebar", {
                            detail: sidebar.className
                        })
                    );
                }
                
            }
           
        }
        
    }
 
  
    connectedCallback(){
      /*Get logged in user id */
      console.log(typeof window)
      const idParamValue = this.getUrlParamValue(location.href, "id"), menuItem = sessionStorage.getItem("menuLocked");
      this.contactId = idParamValue;
      getRole({
        contactId: this.contactId
      }).then((result)=>{
        this.roleUser = result
        if(this.roleUser){
            let sidebar = this.template.querySelector('.sidebar')
            this.showButtons = (this.roleUser === 'Driver/Admin' || this.roleUser === 'Driver/Manager') ? true : false;
            this._originalAdmin = (this.roleUser === 'Driver/Manager') ? 'Manager Dashboard' : 'Admin Dashboard';
            this._admin = (sidebar.className === 'sidebar pinned') ? (this.roleUser === 'Driver/Manager') ?  'M' : 'A' : this._originalAdmin;
            this._driver = (sidebar.className === 'sidebar pinned') ? 'D': this._originalDriver
            if(menuItem){
                this.sessionLocked();
            }
        }
      }).catch()
      window.addEventListener('click', this._handler = this.handleOutsideClick.bind(this));
    }
  
    renderedCallback() {
        const  heightRoleUser = 'calc(100% - 105px)', maxHeightWhenRoleUser = 'calc(100% - 198px)',  menu = this.template.querySelector('.menu-wrapper'),
        num = 35, tooltips = this.template.querySelectorAll(".tooltip");
        if(this.roleUser && this.showButtons){
              menu.style.maxHeight = maxHeightWhenRoleUser;
              const [btn, driverBtn] = [this.template.querySelector('.admin-btn'), this.template.querySelector('.driver-btn')],
              isManagerOrAdminProfile = location.pathname === '/app/managerProfileDashboard' || location.pathname === '/app/adminProfileDashboard';
              btn.classList.toggle('active', isManagerOrAdminProfile);
              driverBtn.classList.toggle('active', !isManagerOrAdminProfile); 
        }else{
              menu.style.maxHeight = heightRoleUser;
        }
    }
}