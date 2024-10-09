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
    @api roleId;
    @track userIds = [];
    hasRendered = true;
    roleUser;
    contactId;
    reportId;
    menuLabel;
    subMenuLabel;
    childMenuLabel;
    bParentId;
    label = 'Add to bookmarks';
    initialized = false;
    isOut = false;
    isSecondary = false;
    getExcecuted = false;
    isNotLocked = true;
    showButtons = false;

    bookMarkList = [];
    company = logo + '/mburse/assets/mBurse-Icons/mBurse-logo.png';
    companyShort = logo + '/mburse/assets/mBurse-Icons/mBurse-short.png';
    user = emcCss + '/emc-design/assets/images/Icons/SVG/Green/User.svg';
    _originalAdmin = 'Admin Dashboard';
    _originalDriver = 'Driver Dashboard';
    _admin = 'Admin Dashboard';
    _driver = 'Driver Dashboard';
    _role;


    get adminText() {
        return this._admin
    }

    set adminText(value) {
        this._admin = value;
    }

    get driverText() {
        return this._driver
    }

    set driverText(value) {
        this._driver = value;
    }



    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    debounce(fn, delay) {
        let timeout;
        return function() {
          clearTimeout(timeout);
          timeout = setTimeout(() => {
            fn();
          }, delay);
        };
    }

    handleSubMenuRedirect(event) {
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
        subMenu.forEach((item) => item.classList.remove('active'));
        const selectedMenu = (event.currentTarget !== undefined) ? event.currentTarget.dataset.name : event;
        for (let i = 0; i < subMenu.length; i++) {
            if (selectedMenu === subMenu[i].dataset.name) {
                subMenu[i].classList.add('active');
                location.href = location.origin + location.pathname + location.search + `#${selectedMenu}`;
                //subMenu[i].href = `#${selectedMenu}`;
            }
        }

        if (sidebarSubMenu) {
            sidebarSubMenu.forEach((el) => {
                if (el.className === 'secondary-menu open') {
                    el.classList.toggle("open");
                }
            })
        }
    }

    handleChildRedirect(event) {
        const id = event?.currentTarget?.dataset.id;
        const lockDate = event?.currentTarget?.dataset.date;
        const isLock = event?.currentTarget?.dataset.lock;
        this.reportId = id;
        const message = {
            reportID: this.reportId,
            mileageLockDate: lockDate,
            lockReport: isLock,
            message: 'navigation'
        };
        let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
        subMenu.forEach((item) => item.classList.remove('active'));
        const selectedMenu = (event.currentTarget !== undefined) ? event.currentTarget.dataset.name : event;
        this.childMenuLabel = selectedMenu;
        for (let i = 0; i < subMenu.length; i++) {
            if (selectedMenu === subMenu[i].dataset.name) {
                subMenu[i].classList.add('active');
            }
        }
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if (sidebarSubMenu) {
            sidebarSubMenu.forEach((el) => {
                if (el.className === 'secondary-menu open') {
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
        let menu = this.template.querySelectorAll(".tooltipText");
        let subMenu = this.template.querySelectorAll(".secondary-menu");
        let subMenuItem = this.template.querySelectorAll(".secondaryMenuItem");
        subMenuItem.forEach((a) => {
            if (a.dataset.name !== this.subMenuLabel) {
                if (a.dataset.name !== this.childMenuLabel) {
                    a.classList.remove('active')
                }
            }
        });
        const selectedMenu = (event.currentTarget !== undefined) ? event.currentTarget.dataset.name : event;
        const selectedMenuId = (event.currentTarget !== undefined) ? event.currentTarget.dataset.id : event;
        const sidebarSubMenu = this.template.querySelector(`.secondary-menu[data-id="${selectedMenuId}"]`);
        menu.forEach((item) => {
            if (item.dataset.name != this.menuLabel) {
                item.classList.remove('active')
                item.setAttribute("aria-expanded", "false")
            }
            if (item.dataset.name === selectedMenu) {
                item.classList.add('isHighLighted');
            } else {
                item.classList.remove('isHighLighted');
            }
        });
        subMenu.forEach((item) => {
            if (item.dataset.id !== selectedMenuId) {
                item.classList.remove('open')
            }
        });
        this.menuLabel = (selectedMenu === 'Notifications') ? selectedMenu : this.menuLabel;
        for (let i = 0; i < menu.length; i++) {
            if (selectedMenuId === menu[i].dataset.id) {
                menu[i].classList.add('active');
                if (menu[i]?.nextElementSibling?.dataset.id === undefined) {
                    menu[i].href = `#${selectedMenu}`;
                    this.childMenuLabel = (selectedMenu === 'Reports') ? this.childMenuLabel : '';
                }
            }
        }
        if (sidebarSubMenu) {
            sidebarSubMenu.classList.toggle("open");
            if (sidebarSubMenu.className === 'secondary-menu open') {
                sidebarSubMenu.previousElementSibling.setAttribute("aria-expanded", "true");
            } else {
                sidebarSubMenu.previousElementSibling.setAttribute("aria-expanded", "false");
            }

        }
    }

    sessionLocked() {
        this.isOut = false;
        this.isNotLocked = false;
        const sidebar = this.template.querySelector('.sidebar');
        sidebar.classList.add("open");
        sidebar.classList.toggle("pinned");
        if (this.showButtons) {
            const textAdmin = this._originalAdmin;
            const textDriver = this._originalDriver;
            this._admin = (sidebar.className === 'sidebar pinned open' && textAdmin != undefined) ? textAdmin.substring(0, 1) : this._originalAdmin
            this._driver = (sidebar.className === 'sidebar pinned open' && textDriver != undefined) ? textDriver.substring(0, 1) : this._originalDriver
        }
        this.dispatchEvent(
            new CustomEvent("sidebar", {
                detail: sidebar.className
            })
        );
    }

    lockMenu() {
        this.isOut = false;
        this.isNotLocked = false;
        let isSession = sessionStorage.getItem("menuLocked");
        if (!isSession) {
            sessionStorage.setItem("menuLocked", true);
        }
        const sidebar = this.template.querySelector('.sidebar');
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if (sidebarSubMenu) {
            sidebarSubMenu.forEach((el) => {
                if (el.className === 'secondary-menu open') {
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
    unlockMenu() {
        this.isOut = false;
        this.isNotLocked = true;
        sessionStorage.removeItem("menuLocked");
        const sidebar = this.template.querySelector('.sidebar');
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if (sidebarSubMenu) {
            sidebarSubMenu.forEach((el) => {
                if (el.className === 'secondary-menu open') {
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
        const menu = this.template.querySelectorAll(".tooltipText"),
            sMenu = value,
            sidebarSubMenu = this.template.querySelector(`.secondaryMenuItem[data-name="${sMenu}"]`),
            subMenu = this.template.querySelectorAll(".secondaryMenuItem");
        this.menuLabel = value;
        this.subMenuLabel = value;
        if (type === 'back') {
            subMenu.forEach((item) => { item.classList.remove('active') });
            this.childMenuLabel = '';
        }
        menu.forEach((item) => {
            item.classList.remove('active')
            item.classList.remove('isHighLighted');
            if (sMenu === item.dataset.name) {
                item.classList.add('active');
                if (sidebarSubMenu && !this.childMenuLabel) {
                    sidebarSubMenu.classList.add('active');
                }
            } else if (sidebarSubMenu && sidebarSubMenu.dataset.id === item.dataset.id) {
                this.menuLabel = item.dataset.name;
                sidebarSubMenu.classList.add('active');
                item.classList.add('active');
            }

        })
    }

    redirectToHomePage() {
        // eslint-disable-next-line no-restricted-globals
        var url, path;
        url = location;
        path = url.origin + url.pathname + url.search;
        location.replace(path);
        //localStorage.setItem("lastItem", this.bParentId);
    }

    toggleSideBarOut() {
        this.isOut = false;
        var menuCount = 0;
        const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
        if (sidebarSubMenu) {
            sidebarSubMenu.forEach((el => {
                if (el.className === 'secondary-menu open') {
                    menuCount++
                }
            }))
        }
        if (this.isNotLocked && menuCount === 0) {
            const sidebar = this.template.querySelector('.sidebar');
            let menu = this.template.querySelectorAll(".tooltipText");
            let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
            subMenu.forEach((item) => { if (item.dataset.name !== this.subMenuLabel && item.dataset.name !== this.childMenuLabel) { item.classList.remove('active') } });
            menu.forEach((item) => {
                if (item.dataset.name != this.menuLabel) {
                    item.classList.remove('active')
                    item.classList.remove('isHighLighted');
                    item.setAttribute("aria-expanded", "false")
                }
            });
            if (this.showButtons) {
                const textAdmin = this._originalAdmin;
                const textDriver = this._originalDriver;
                this._admin = ((sidebar.className === 'sidebar pinned open' || sidebar.className === 'sidebar pinned close open') && textAdmin != undefined) ? textAdmin.substring(0, 1) : this._originalAdmin
                this._driver = ((sidebar.className === 'sidebar pinned open' || sidebar.className === 'sidebar pinned close open') && textDriver != undefined) ? textDriver.substring(0, 1) : this._originalDriver
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
        if (sidebarSubMenu) {
            sidebarSubMenu.forEach((el => {
                if (el.className === 'secondary-menu open') {
                    menuCount++
                }
            }))
        }
        if (this.isNotLocked && menuCount === 0) {
            const sidebar = this.template.querySelector('.sidebar');
            if (this.showButtons) {
                const textAdmin = this._originalAdmin;
                const textDriver = this._originalDriver;
                this._admin = (sidebar.className === 'sidebar pinned open' && textAdmin != undefined) ? textAdmin.substring(0, 1) : this._originalAdmin
                this._driver = (sidebar.className === 'sidebar pinned open' && textDriver != undefined) ? textDriver.substring(0, 1) : this._originalDriver
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

    logOut() {
        const logoutEvent = new CustomEvent('logout', { detail: 'logout' });
        this.dispatchEvent(logoutEvent);
    }
    redirectToDashboard(Id, Role) {
        redirectionURL({
            contactId: Id,
            adminTab: Role
        })
            .then((result) => {
                //localStorage.setItem("lastItem", this.bParentId);
                let url = location.origin + result;
                window.open(url, '_self');
            })
            .catch((error) => {
                // If the promise rejects, we enter this code block
                console.error(error);
            })
    }

    redirectToDriverProfile() {
        // window.location.href = location.origin + '/app/driverProfileDashboard' + location.search;
        this.redirectToDashboard(this.contactId, false)
        localStorage.setItem("driver", true);
    }

    redirectToProfile() {
        this.redirectToDashboard(this.contactId, true)
        localStorage.setItem("driver", false);
    }

    handleContextMenu = (event) => {
        event.preventDefault();
    }

    getSubItem(arr, menuType, parentid) {
        let data = [];
        let i = 1;
        arr.forEach(f => {
            let tmp = {
                "menuId": i,
                "menu": (f.reportId) ? f.reportName : f.menu,
                "menuLabel": (f.reportId) ? f.reportLabel : f.menuLabel,
                "idOfMenu": f?.menuId,
                "menuClass": "active",
                "parentId": (f.reportId) ? f.reportId : (f.menuLabel === "All Reports") ? f.menuId : parentid,
                "mileageLockDate": (f.reportId) ? f.mileageLockDate : null,
                "lockDate": (f.reportId) ? f.lockDate : null,
                "isNestedMenu": (f.reportId) ? true : false,
                "isBookmark": menuType,
                "pinBookmark": f.pinBookmark
            }
            data.push(tmp);
            i++;
        });
        return data;
    }


    mouseOverLink(event) {
        // this.isOut = false;
        var menuCount = 0;
        let menu = this.template.querySelectorAll(".tooltipText");
        menu.forEach((item) => {
            if (item.dataset.name != this.menuLabel) {
                item.classList.remove('active')
            } else if (item.dataset.name === undefined) {
                item.classList.remove('active')
            }
            item.classList.remove('isHighLighted');
            item.setAttribute("aria-expanded", "false")
        });
        let subMenu = this.template.querySelectorAll(".secondaryMenuItem");
        subMenu.forEach((a) => {
            if (a.dataset.name !== this.subMenuLabel) {
                if (a.dataset.name !== this.childMenuLabel) {
                    a.classList.remove('active')
                }
            }
        }
        );
        const selectedMenuId = (event.currentTarget !== undefined) ? event.currentTarget.dataset.id : event;
        const sidebarSubMenu = this.template.querySelector(`.tooltipText[data-id="${selectedMenuId}"]`);
        const subElement = this.template.querySelectorAll('.secondary-menu');
        if (subElement) {
            subElement.forEach((el => {
                if (el.className === 'secondary-menu open') {
                    menuCount++
                }
            }))
        }
        if (menuCount > 0) {
            sidebarSubMenu.classList.add("active");
            sidebarSubMenu.setAttribute("aria-expanded", "true");
        }
    }
    sideMenuOut() {
        this.isOut = true;
    }

    bookmarkSession() {
        const isDriver = sessionStorage.getItem("isDriver"), userStorage = sessionStorage.getItem("bookmark");
        let itemList = [], uniqueItemList, storageList = (userStorage) ? JSON.parse(userStorage) : [];
        if (this.bookMarkList.length >= 0 && isDriver === 'false') {
            for (let userId of this.userIds) {
                if (userId === this.contactId) {
                    let objFinal = {
                        userId: userId,
                        userMenu: [...this.driverMenuItem],
                        userBookmark: [...this.bookMarkList]
                    }
                    itemList.push(objFinal);
                    if (storageList.length > 0) {
                        let isElement = storageList.filter(item => item.userId !== this.contactId);
                        itemList = isElement.length > 0 ? [...itemList, ...storageList] : [...itemList];
                    }
                }
            }
            uniqueItemList = [...new Set(itemList)];
            sessionStorage.setItem('bookmark', JSON.stringify(uniqueItemList));
        }
    }

    updatePinBookmark(data, targetReportId, boolean) {
        return data.map(menu => {
            if (menu.label === "Plan management") {
                return {
                    ...menu,
                    menuItem: menu.menuItem.map(subMenu => {
                        if (subMenu.menu === "Reports") {
                            return {
                                ...subMenu,
                                subMenuItem: subMenu.subMenuItem.map(reportGroup => {
                                    return {
                                        ...reportGroup,
                                        itemList: reportGroup.itemList.map(item => {
                                            return {
                                                ...item,
                                                currentReports: item.currentReports.map(report => {
                                                    if (report.reportId === targetReportId) {
                                                        return { ...report, pinBookmark: boolean }; // Set pinbookmark to true
                                                    }
                                                    return report;
                                                }),
                                            };
                                        }),
                                    };
                                }),
                            };
                        }
                        return subMenu;
                    }),
                };
            }
            return menu;
        });
    };

    removePinBookmark(data, targetId, boolean) {
        const updatedArray = data.map((v) => ({
            ...v,
            menuItem: v.menuItem.map((item) => {
                if (item.subMenuItem) {
                    return {
                        ...item,
                        subMenuItem: (item.subMenuItem).map((it) => {
                            // Create a new object with the pinBookmark property set based on the condition
                            return it.menuId == targetId
                                ? { ...it, pinBookmark: boolean }
                                : it;
                        })
                    };
                }
                return item
            })
        }));
        return updatedArray;
    }

    addToBookmark(event) {
        event.stopPropagation();
        const parentId = event.currentTarget?.dataset?.parentid, targetId = event.currentTarget.dataset.id, listOfMenu = [...this.driverMenuItem]
        if (parentId && targetId && event.currentTarget?.dataset.type === 'Reporting') {
            const uniqueItems = this.driverMenuItem
                .flatMap(parent => parent.menuItem)
                .filter(child => child.subMenuItem && child.menuLabel !== 'Bookmarks')
                .flatMap(child => child.subMenuItem)
                .flatMap(subItem => subItem.itemList)
                .filter(item => item !== undefined);
            if (uniqueItems.length > 0) {
                const selectedItem = uniqueItems.flatMap(v => v.currentReports
                    .filter(r => r.reportId === targetId)
                ).map(v => ({ ...v, pinBookmark: true }));
                const finalItems = [...this.bookMarkList, ...selectedItem]
                this.bParentId = (localStorage.getItem("lastItem")) ? localStorage.getItem("lastItem") : this.bParentId;
                localStorage.setItem("lastItem", this.bParentId);
                this.bookMarkList = [... new Set(finalItems)];
                const newArray = listOfMenu.map((v) => ({
                    ...v,
                    menuItem: v.menuItem.map((item) => ({
                        ...item,
                        menu: (item.menuLabel === "Bookmarks") ? true : item.menu,
                        subMenuItem: (item.menuLabel === "Bookmarks" ? this.getSubItem(this.bookMarkList, true, this.bParentId) : item.subMenuItem)
                    }))
                }))
                const updatedArray = this.updatePinBookmark(newArray, targetId, true)
                this.driverMenuItem = updatedArray
            }
        } else {
            if (parentId && targetId) {
                const uniqueMenu = this.driverMenuItem
                    .flatMap(parent => parent.menuItem)
                    .filter(child => child.subMenuItem && child.menuLabel !== 'Bookmarks')
                    .flatMap(child => child.subMenuItem)
                    .filter(item => item !== undefined);
                if (uniqueMenu.length > 0) {
                    const selectedMenu = uniqueMenu.filter(d => { return d.menuId == targetId }).map(v => ({ ...v, pinBookmark: true }));
                    const finalMenu = [...this.bookMarkList, ...selectedMenu]
                    this.bookMarkList = [... new Set(finalMenu)];
                    //this.bParentId = parentId;
                    if (selectedMenu.length > 0 && selectedMenu[0]?.menuLabel !== "All Reports") {
                        this.bParentId = parentId;
                        localStorage.setItem("lastItem", this.bParentId);
                    }

                    const menuArray = listOfMenu.map((v) => ({
                        ...v,
                        menuItem: v.menuItem.map((item) => ({
                            ...item,
                            menu: (item.menuLabel === "Bookmarks") ? true : item.menu,
                            subMenuItem: item.menuLabel === "Bookmarks" ? this.getSubItem(this.bookMarkList, true, this.bParentId) : item.subMenuItem
                        }))
                    }))

                    const updatedArray = menuArray.map((v) => ({
                        ...v,
                        menuItem: v.menuItem.map((item) => {
                            if (item.subMenuItem) {
                                return {
                                    ...item,
                                    subMenuItem: (item.subMenuItem).map((it) => {
                                        // Create a new object with the pinBookmark property set based on the condition
                                        return it.menuId == targetId
                                            ? { ...it, pinBookmark: true }
                                            : it;
                                    })
                                };
                            }
                            return item
                        })
                    }));

                    this.driverMenuItem = updatedArray
                }
            }
        }

        this.bookmarkSession();
    }

    removeFromBookmark(event) {
        event.stopPropagation();
        const targetId = event.currentTarget.dataset.id;
        const key = (event.currentTarget?.dataset.mark === 'Report') ? 'parentId' : 'idOfMenu';
        const subKey = (event.currentTarget?.dataset.mark === 'Report') ? 'reportId' : 'menuId';
        let menuList = [...this.driverMenuItem];
        const selectedItem = this.bookMarkList.filter((child) => { return child[subKey] != targetId })
        this.bookMarkList = selectedItem;
        let reducedArray = menuList.map(item => {
            if (item.menuItem) {
                return {
                    ...item,
                    menuItem: item.menuItem.map(m => {
                        if (m.subMenuItem && m.menuLabel === 'Bookmarks') {
                            return {
                                ...m,
                                subMenuItem: m.subMenuItem.reduce((list, subItem) => {
                                    if (subItem[key] != targetId) {
                                        list.push(subItem);
                                    }
                                    return list;
                                }, []),
                                menu: (m.menuLabel === "Bookmarks") ? (m.subMenuItem.length == 1) ? false : m.menu : m.menu
                            };
                        }
                        return m;
                    })
                };
            }
            return item;
        });
        const updatedArray = (event.currentTarget?.dataset.mark === 'Report') ? this.updatePinBookmark(reducedArray, targetId, false) : this.removePinBookmark(reducedArray, targetId, false);
        this.driverMenuItem = updatedArray;
        this.bookmarkSession();
    }

    removeBookmark(event) {
        event.stopPropagation();
        const menuIdToRemove = (event.currentTarget) ? event.currentTarget?.dataset?.parentid : '';
        const targetId = event.currentTarget.dataset.id;
        const idToRemove = (typeof menuIdToRemove === 'string') ? parseInt(menuIdToRemove) : menuIdToRemove;
        let menuList = [...this.driverMenuItem];
        let reducedArray = menuList.map(item => {
            if (item.menuItem) {
                return {
                    ...item,
                    menuItem: item.menuItem.map(m => {
                        if (m.subMenuItem) {
                            return {
                                ...m,
                                subMenuItem: m.subMenuItem.reduce((list, subItem) => {
                                    if (subItem.menuId !== idToRemove) {
                                        list.push(subItem);
                                    }
                                    return list;
                                }, []),
                                menu: (m.menuLabel === "Bookmarks") ? (m.subMenuItem.length == 1) ? false : m.menu : m.menu
                            };
                        }
                        return m;
                    })
                };
            }
            return item;
        });

        const updatedArray = (event.currentTarget?.dataset.mark === 'Report') ? this.updatePinBookmark(reducedArray, targetId, false) : this.removePinBookmark(reducedArray, targetId, false);
        this.driverMenuItem = updatedArray;
        const subKey = (event.currentTarget?.dataset.mark === 'Report') ? 'reportId' : 'menuId';
        const selectedItem = this.bookMarkList.filter((child) => { return child[subKey] != targetId })
        this.bookMarkList = selectedItem;
        this.bookmarkSession();
    }

    handleOutsideClick = (event) => {
        var isOpen = 0
        if (!this.isOut) {
            const sidebarSubMenu = this.template.querySelectorAll('.secondary-menu');
            let menu = this.template.querySelectorAll(".tooltipText");
            // menu.forEach((item) => { item.setAttribute("aria-expanded", "false") });
            menu.forEach((item) => {
                if (item.dataset.name != this.menuLabel) {
                    item.classList.remove('active')
                    item.classList.remove('isHighLighted')
                    item.setAttribute("aria-expanded", "false")
                }
            });
            if (sidebarSubMenu) {
                sidebarSubMenu.forEach((el => {
                    if (el.className === 'secondary-menu open') {
                        isOpen++
                        el.classList.remove("open");
                    }
                }))

                if (this.isNotLocked && isOpen > 0) {
                    const sidebar = this.template.querySelector('.sidebar');
                    if (this.showButtons) {
                        const textAdmin = this._originalAdmin;
                        const textDriver = this._originalDriver;
                        this._admin = (sidebar.className === 'sidebar pinned open' && textAdmin != undefined) ? textAdmin.substring(0, 1) : this._originalAdmin
                        this._driver = (sidebar.className === 'sidebar pinned open' && textDriver != undefined) ? textDriver.substring(0, 1) : this._originalDriver
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

    getStorage() {
        const isDriver = sessionStorage.getItem("isDriver"), storage = sessionStorage.getItem("bookmark"), users = sessionStorage.getItem("idUser");
        let userSession = (users) ? [this.contactId, ...users.split(',')] : [this.contactId];
        this.userIds = [...new Set(userSession)]
        sessionStorage.setItem("idUser", this.userIds);
        let storageList = (storage) ? JSON.parse(storage) : [];
        if (storageList.length > 0 && isDriver === 'false') {
            let isElement = storageList.filter(item => item.userId === this.contactId);
            this.driverMenuItem = (isElement[0]?.userMenu) ? isElement[0]?.userMenu : this.driverMenuItem;
            this.bookMarkList = (isElement[0]?.userBookmark) ? isElement[0]?.userBookmark : this.bookMarkList;
        }
    }


    connectedCallback() {
        /*Get logged in user id */
        const idParamValue = this.getUrlParamValue(location.href, "id"), menuItem = sessionStorage.getItem("menuLocked");
        this.contactId = idParamValue;
        localStorage.setItem("driver", false);
        if (this.roleId) {
            this.showButtons = (this.roleId === 'Driver/Admin' || this.roleId === 'Driver/Manager') ? true : false;
            this._originalAdmin = (this.roleId === 'Driver/Manager') ? 'Manager Dashboard' : 'Admin Dashboard';
            this.debounce(() => {
                if (menuItem) {
                    this.sessionLocked();
                }
            }, 100)(); 
        }

        window.addEventListener('click', this._handler = this.handleOutsideClick.bind(this));
    }

    renderedCallback() {
        const bookmarkBtn = this.template.querySelectorAll(".bookmark-btn"), heightRoleUser = 'calc(100% - 105px)', maxHeightWhenRoleUser = 'calc(100% - 198px)', menu = this.template.querySelector('.menu-wrapper'),
            tooltip = this.template.querySelector('.btooltip');
        bookmarkBtn.forEach(bookmark => {
            bookmark.addEventListener("mouseenter", (evt) => {
                const x = 0, y = evt?.clientY, margin = 22.5;
                this.label = (evt?.toElement?.dataset?.mark !== undefined) ? 'Remove from bookmarks' : 'Add to bookmarks';
                if (y) {
                    const tY = (y - margin) + "px";
                    tooltip.style.transform = `translate(${x}, ${tY})`;
                }
            })
        })
        if (this.roleId && this.showButtons) {
            menu.style.maxHeight = maxHeightWhenRoleUser;
            if(this.hasRendered){
                let sidebar = this.template.querySelector('.sidebar')
                this._admin = (sidebar?.className === 'sidebar pinned') ? (this.roleId === 'Driver/Manager') ? 'M' : 'A' : this._originalAdmin;
                this._driver = (sidebar?.className === 'sidebar pinned') ? 'D' : this._originalDriver
            }
            const [btn, driverBtn] = [this.template.querySelector('.admin-btn'), this.template.querySelector('.driver-btn')],
            isManagerOrAdminProfile = location.pathname === '/app/managerProfileDashboard' || location.pathname === '/app/adminProfileDashboard';
            btn.classList.toggle('active', isManagerOrAdminProfile);
            driverBtn.classList.toggle('active', !isManagerOrAdminProfile);
            if (btn.className.includes('active')) {
                localStorage.setItem("driver", false);
            } else if (driverBtn.className.includes('active')) {
                localStorage.setItem("driver", true);
            } else {
                localStorage.setItem("driver", false);
            }
            let isDriver = localStorage.getItem("driver");
            if (isDriver) {
                sessionStorage.setItem("isDriver", isDriver);
                this.getExcecuted = true;
            }
        } else {
            menu.style.maxHeight = heightRoleUser;
            let isDriver = localStorage.getItem("driver");
            if (isDriver) {
                sessionStorage.setItem("isDriver", isDriver);
            }
        }
        // this.roleId = this.roleId ?? (this.profileId === '00e31000001FRDWAA4' ? 'Manager' : this.roleId);
        if (this.hasRendered && (this.getExcecuted || this.roleId != undefined)) {
            let isDriver = sessionStorage.getItem("isDriver");
            if (isDriver) {
                this.getStorage();
            }
            this.hasRendered = false
        }
    }
}