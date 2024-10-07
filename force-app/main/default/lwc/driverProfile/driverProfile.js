import {
    LightningElement,
    api,
    track
} from 'lwc';
import EMC_CSS from '@salesforce/resourceUrl/EmcCSS';
export default class DriverProfile extends LightningElement {
    @api Role;
    @api mileageList;
    @api contactDetails;
    @api GasPrice;
    @api unapproveMileage;
    @api chartInfo;
    @api plMarketing;
    @api accountId;
    isNotify = false;
    isShowMessage = false;
    isInformation = false;
    isExpand = false;
    contactChart;
    notifyList = [];
    fuelPrice;
    fixedAmount;
    renderText;
    variableRate;
    isComplete = false;
    isfuelPrice = true;
    isIncompliance = false;
    formattedReim;
    formattedMileage;
    complianceMileage;
    vehicleValue;
    drivingState;
    mileageUnapproved;
    mileageText = false;
    fuelIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Profile_fuel_pump_45-01.svg';
    umbrellaIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Parameters_100_300_100.svg';
    speedometerIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Parameters_Speedometer.svg';
    calendarIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Parameters_years.svg';
    complianceIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Parameters_In_compliance.svg';
    carIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Parameters_car.svg';
    carImageUrl = EMC_CSS + '/emc-design/assets/images/car.png';
    heckTickUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Parameters_green_heck_mark.svg';
    blurTickUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Parameters_grey_heck_mark.svg';
    locationIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Profile_location_45-01.svg';
    milesIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Profile_miles_45_01.svg';
    moneyIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/Profile_money_45_01.svg';
    // companyIconUrl = EMC_CSS + '/emc-design/assets/images/company-name-img.png';
    flagIconUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/YTD_mileage_flag.svg';
    noNotification = EMC_CSS + '/emc-design/assets/images/no-new-notification.png';
    variableRateUrl = EMC_CSS + '/emc-design/assets/images/Driver-dashboard-icons/graph_45-01.svg';
    connectedCallback() {
        if (this.contactDetails.accountLogo === null && this.contactDetails.accountName === null && this.contactDetails.annualMileages === null && this.contactDetails.annualReim === null && this.contactDetails.carImage === null && this.contactDetails.city === null && this.contactDetails.complianceMileage === null && this.contactDetails.compliancestatus === null && this.contactDetails.contactName === null && this.contactDetails.driverType === null && this.contactDetails.drivingState === null && this.contactDetails.drivingStates === null && this.contactDetails.fixedAmount === null && this.contactDetails.insurance === null && this.contactDetails.insuranceAttchId === null && this.contactDetails.insuranceDate === null && this.contactDetails.mileagemeet === null && this.contactDetails.notimessage === null && this.contactDetails.planInsurance === null && this.contactDetails.planYears === null && this.contactDetails.state === null && this.contactDetails.vehicalType === null && this.contactDetails.vehicleValue === null && this.contactDetails.vehicleage === null && this.contactDetails.vehiclevaluecheck === null && this.contactDetails.zipCode === null) {
            this.isInformation = false;
        } else {
            this.isInformation = true;
            var formatter = new Intl.NumberFormat();
            this.contactChart = this.chartInfo[0];
            var convertedMile;
            // if (this.contactDetails.accountLogo === null || this.contactDetails.accountLogo === undefined) {
            //     this.contactDetails.accountLogo = this.companyIconUrl;
            // }

            if (this.contactDetails.drivingState != null) {
                var state = this.contactDetails.drivingState.split(";");
                // console.log(state);
                this.drivingState = state;
            }

            if (this.contactDetails.fixedAmount === null || this.contactDetails.fixedAmount === undefined) {
                this.fixedAmount = 0;
            } else {
                this.fixedAmount = this.contactDetails.fixedAmount;
            }

            if (this.contactDetails.variableRate === null || this.contactDetails.variableRate === undefined) {
                this.variableRate = 0;
            } else {
                this.variableRate = this.contactDetails.variableRate;
            }

            if (this.GasPrice[0] != undefined) {
                this.fuelPrice = this.GasPrice[0].Fuel_Price__c;
            } else {
                this.isfuelPrice = false;
            }

            if (this.unapproveMileage[0] === undefined) {
                this.mileageUnapproved = 0
                this.mileageText = false;
            } else {
                this.mileageUnapproved = formatter.format(this.unapproveMileage[0].Total_Pending__c);
                this.mileageText = true;
            }
            this.isComplete = (parseFloat(this.contactDetails.annualMileages) >= parseFloat(this.contactDetails.complianceMileage)) ? true : false;
            this.formattedMileage = formatter.format(this.contactDetails.annualMileages);
            this.formattedReim = this.formatNumber(this.contactDetails.annualReim);
            this.renderText = (!this.contactDetails.biWeekContact) ? 'month' : 'bi-weekly'
            if (this.contactDetails.complianceMileage) {
                convertedMile = this.contactDetails.complianceMileage; // this.formatNumber(this.contactDetails.complianceMileage)
                this.complianceMileage = convertedMile;
                // console.log("this.complianceMileage", this.complianceMileage);
            }
            if (this.contactDetails.vehicleValue) {
                this.vehicleValue = this.formatNumber(this.contactDetails.vehicleValue);
            }
            if (this.accountId === this.plMarketing) {
                this.isShowMessage = false;
            } else {
                this.isShowMessage = true;
            }
            this.driverNotification();
        }
    }
    formatNumber(num) {
        if (this.isInformation) {
            if (num != null) {
                return num.replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
            }
        }
    }

    checkForComplianceMileage() {
        if (this.isInformation) {
            //let cMileage = this.contactDetails.mileagemeet;
						let annual = parseFloat(this.contactDetails.annualMileages);
						let compliance = parseFloat(this.contactDetails.complianceMileage);
							console.log('name',annual, compliance)
            if (annual >= compliance) {
								console.log(annual, compliance)
                this.template.querySelector('.annualMileage').classList.add('Incompliance');
                this.template.querySelector('.annualMileage').lastChild.children[1].style.display = 'none';
            } else {
                this.template.querySelector('.annualMileage').lastChild.children[0].style.display = 'none';
            }
        }
    }


    checkForVehicleAge() {
        if (this.isInformation) {
            let vehicleAge = this.contactDetails.vehicleage;
            if (vehicleAge === 'Yes') {
                this.template.querySelector('.vehicle-age').classList.add('Incompliance');
                this.template.querySelector('.vehicle-age').lastChild.children[1].style.display = 'none';
            } else {
                this.template.querySelector('.vehicle-age').lastChild.children[0].style.display = 'none';
            }
        }
    }

    checkForVehicleValue() {
        if (this.isInformation) {
            let vehicleValue = this.contactDetails.vehiclevaluecheck;
            if (vehicleValue === 'Yes') {
                this.template.querySelector('.vehicle-value').classList.add('Incompliance');
                this.template.querySelector('.vehicle-value').lastChild.children[1].style.display = 'none';
            } else {
                this.template.querySelector('.vehicle-value').lastChild.children[0].style.display = 'none';
            }
        }
    }

    checkForInsurance() {
        if (this.isInformation) {
            let insuranceValue = this.contactDetails.insurance;
            if (insuranceValue === 'Yes') {
                this.template.querySelector('.insurance').classList.add('Incompliance');
                this.template.querySelector('.insurance').lastChild.children[1].style.display = 'none';
            } else {
                this.template.querySelector('.insurance').lastChild.children[0].style.display = 'none';
            }
        }
    }

    checkForCompliance() {
        if (this.isInformation) {
            let cValue = this.contactDetails.compliancestatus;
            if (cValue === 'Yes') {
                this.template.querySelector('.compliance').classList.add('Incompliance');
                this.template.querySelector('.compliance').lastChild.children[1].style.display = 'none';
            } else {
                this.template.querySelector('.compliance').lastChild.children[0].style.display = 'none';
            }
        }
    }

    toggleSection() {
        if (this.isInformation) {
            var profile = this.template.querySelector('.dInfoGrid');
            var profileState = profile.className.search('slds-is-open');
            if (profileState == -1) {
                this.isExpand = true;
                profile.classList.remove('slds-is-close');
                profile.classList.add('slds-is-open');
                this.dispatchEvent(
                    new CustomEvent("expandmessage", {
                        detail: "slds-is-open"
                    })
                );
            } else {
                this.isExpand = false;
                this.dispatchEvent(
                    new CustomEvent("expandmessage", {
                        detail: "slds-is-close"
                    })
                );
                profile.classList.add('slds-is-close');
                profile.classList.remove('slds-is-open');
            }
        }
    }

    driverNotification() {
        if (this.isInformation) {
            var notification = [];
            var currentDate = new Date(); /** "2021-07-31" */
            var deadline = 5;
            /** Custom Notification **/
            if (this.contactDetails.notimessage != null) {
                notification.push(this.contactDetails.notimessage);
            }
            /** Driver Notification - 5 days before the mileage Monthly and bi-weekly notifications for upcoming mileage sync  **/
            var mileageMsg;
            var pastDate;
            var fourthOfMonth;
            var monthName;
            fourthOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 4);
            if (currentDate > fourthOfMonth) {
                fourthOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 4);
                pastDate = new Date(fourthOfMonth);
                pastDate.setDate(pastDate.getDate() - deadline);
                monthName = fourthOfMonth.toLocaleString('default', {
                    month: 'long'
                });
            } else {
                pastDate = new Date(fourthOfMonth);
                pastDate.setDate(pastDate.getDate() - deadline);
                monthName = currentDate.toLocaleString('default', {
                    month: 'long'
                });
                // console.log(pastDate, fourthOfMonth);
            }

            if (currentDate >= pastDate && currentDate < fourthOfMonth) {
                mileageMsg = "Mileage will be automatically synced " + monthName + " 3 at 11:59 PM PST.";
                notification.push(mileageMsg);
            }

            /** Driver Notification - Insurance deadline 5 days before the insurance request dates (Jan 1 and June 30) to support the email that is sent to drivers.  **/
            var insuranceMsg;
            var insuranceMsg1;
            var dateOpt = {
                year: "numeric",
                month: "2-digit",
                day: "2-digit"
            };
            var cDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()).toLocaleDateString('fr-CA', dateOpt);
            var firstMonth = new Date(currentDate.getFullYear(), 0, 1);
            var sixthMonth = new Date(currentDate.getFullYear(), 6, 0);
            var first = new Date(firstMonth.getFullYear(), 0, 1).toLocaleDateString('fr-CA', dateOpt);
            if (cDate > first) {
                firstMonth = new Date(currentDate.getFullYear() + 1, 0, 1);
            }
            var insurancePastDate = new Date(firstMonth);
            insurancePastDate.setDate(insurancePastDate.getDate() - deadline);
            var insuranceEndDate = new Date(sixthMonth);
            insuranceEndDate.setDate(insuranceEndDate.getDate() - deadline);
            if (currentDate >= insurancePastDate && currentDate < firstMonth) {
                insuranceMsg = "Happy Holidays – Don’t forget to upload your insurance dec page next week.";
                notification.push(insuranceMsg);
            }
            if (currentDate >= insuranceEndDate && currentDate < sixthMonth) {
                insuranceMsg1 = "You have to upload your most recent insurance declaration page(s) in 5 days.";
                notification.push(insuranceMsg1);
            }

            /** Driver Notification - 35 days after the first request for insurance (January 31 and July 31) to support a new email that will be sent to all drivers that have not uploaded their insurance.  **/
            var emailMsg;
            var lastDayOfSeventh = new Date(currentDate.getFullYear(), 7, 0).toLocaleDateString('fr-CA', dateOpt);;
            var lastDay = new Date(currentDate.getFullYear(), 1, 0).toLocaleDateString('fr-CA', dateOpt);;
            if (cDate === lastDayOfSeventh || cDate === lastDay) {
                emailMsg = "In 5 days, you could forfeit your fixed amount unless you upload your insurance declaration page(s).";
                notification.push(emailMsg);
            }
            // console.log(notification);

            /** Trigger-based notifications */
            var day = currentDate.getDate();
            var approvalMsg;
            var flaggedMsg;
            var pendingMsg;
            var insuranceUpload;
            var pastDay;
            var nameOfMonth;
            var fourth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 4).toLocaleDateString('fr-CA', dateOpt);
            if (cDate >= fourth) {
                pastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, currentDate.getDate());
                nameOfMonth = pastDay.toLocaleString('default', {
                    month: 'long'
                });
            } else {
                pastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() - 2, currentDate.getDate());
                nameOfMonth = pastDay.toLocaleString('default', {
                    month: 'long'
                });
            }
            var mileageObject;
            this.mileageList.forEach((m) => {
                if (nameOfMonth === m.month) {
                    mileageObject = m;
                }
            })
            // console.log(mileageObject);
            if (mileageObject != undefined) {
                /** Trigger-based notifications - Display mileage approval (total for the month) – should disappear after the lock date or by the 18th of the month */
                if (mileageObject.totalApprove != undefined) {
                    if (mileageObject.lockdate === null && day < 18) {
                        approvalMsg = "For " + nameOfMonth + " you had " + mileageObject.totalApprove + " approved miles";
                        notification.push(approvalMsg);
                    }
                }

                /** Trigger-based notifications - When mileage is flagged for the month (total for the month) until the 18th of the month or the lock date */
                if (mileageObject.totalRejected != undefined) {
                    if ((mileageObject.lockdate != null)) {
                        flaggedMsg = "For " + nameOfMonth + " you had " + mileageObject.totalRejected + " flagged miles";
                        notification.push(flaggedMsg);
                    } else {
                        if (day <= 18) {
                            flaggedMsg = "For " + nameOfMonth + " you had " + mileageObject.totalRejected + " flagged miles";
                            notification.push(flaggedMsg);
                        }
                    }
                }


                /** Trigger-based notifications - Display the total of unapproved mileage (mileage that was unapproved after the 18th or the lock date). This number should be displayed until the 3rd of the next month.*/
                if (mileageObject.totalPending != undefined) {
                    if ((mileageObject.lockdate != null)) {
                        pendingMsg = "For " + nameOfMonth + " you had " + mileageObject.totalPending + " miles that were not yet approved";
                        notification.push(pendingMsg);
                    } else {
                        if (day >= 18) {
                            pendingMsg = "For " + nameOfMonth + " you had " + mileageObject.totalPending + " miles that were not yet approved";
                            notification.push(pendingMsg);
                        }
                    }
                }


            }

            /** Trigger-based notifications - 4.	Thank you for uploading your insurance – immediately after uploading an insurance */

            var isDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()).toLocaleDateString('fr-CA');
            var insuranceDate = this.contactDetails.insuranceDate;
            if (insuranceDate != null) {
                if (isDate === insuranceDate) {
                    insuranceUpload = "Thank you for uploading your insurance, our team will evaluate your insurance by the end of the month"
                    notification.push(insuranceUpload);
                }
            }

            if (this.Role === "Manager") {
                /** Manager Messages notifications */
                var mangerMsg;

                /** Manager Messages notifications - Mileage approval start date – The first of each month before the Monthly and bi-weekly mileage notifications for upcoming mileage sync */
                if (day >= 1 && day < 4) {
                    mangerMsg = " In 3 days, your team’s mileage will be ready for approval.";
                    notification.push(mangerMsg);
                }
                /** Manager Messages notifications - Unapproved mileage – Message */

                if (this.mileageUnapproved != undefined) {
                    mangerMsg = "Your team has " + this.mileageUnapproved + " mileage to be approved";
                    notification.push(mangerMsg);
                }

                //* Manager Messages notifications -  Mileage approval deadline to be approved in 5 days – disappears on the 10th of each month */
                if (day >= 4 && day < 10) {
                    mangerMsg = "Mileage approval deadline to be approved in 5 days";
                    notification.push(mangerMsg);
                }
            }

            for (let index = 0; index < notification.length; index++) {
                const element = {}
                element.Id = index;
                element.message = notification[index];
                this.notifyList.push(element);
            }
            this.isNotify = (this.notifyList.length > 0) ? true : false;
        }
    }

    handleClose(event) {
        if (this.isInformation) {
            var eId = event.target.dataset.id;
            this.template.querySelector(`.slds-notify_alert[data-id="${eId}"]`).classList.add('slds-hide');
        }
    }
    renderedCallback() {
        if (this.isInformation) {
            var status = this.contactDetails.compliancestatus;
            if (status === 'Yes' && this.contactDetails.mileagemeet === 'Yes' && this.contactDetails.vehicleage === 'Yes' && this.contactDetails.vehiclevaluecheck === 'Yes' && this.contactDetails.insurance === 'Yes') {
                if (this.template.querySelector('.vehicle-age') != null && this.template.querySelector('.annualMileage') != null && this.template.querySelector('.vehicle-value') != null && this.template.querySelector('.insurance') != null && this.template.querySelector('.compliance') != null) {
                    this.template.querySelector('.vehicle-age').classList.add('Incompliance');
                    this.template.querySelector('.annualMileage').classList.add('Incompliance');
                    this.template.querySelector('.vehicle-value').classList.add('Incompliance');
                    this.template.querySelector('.insurance').classList.add('Incompliance');
                    this.template.querySelector('.compliance').classList.add('Incompliance');
                    this.template.querySelector('.vehicle-age').lastChild.children[1].style.display = 'none';
                    this.template.querySelector('.annualMileage').lastChild.children[1].style.display = 'none';
                    this.template.querySelector('.vehicle-value').lastChild.children[1].style.display = 'none';
                    this.template.querySelector('.insurance').lastChild.children[1].style.display = 'none';
                    this.template.querySelector('.compliance').lastChild.children[1].style.display = 'none';
                }
            } else {
               // if (this.contactDetails.mileagemeet != null) {
                    this.checkForComplianceMileage();
               // } else {
                   // this.template.querySelector('.annualMileage').lastChild.children[0].style.display = 'none';
               // }

                if (this.contactDetails.vehicleage != null) {
                    this.checkForVehicleAge();
                } else {
                    this.template.querySelector('.vehicle-age').lastChild.children[0].style.display = 'none';
                }

                if (this.contactDetails.vehiclevaluecheck != null) {
                    this.checkForVehicleValue();
                } else {
                    this.template.querySelector('.vehicle-value').lastChild.children[0].style.display = 'none';
                }

                if (this.contactDetails.insurance != null) {
                    this.checkForInsurance();
                } else {
                    this.template.querySelector('.insurance').lastChild.children[0].style.display = 'none';
                }

                if (status != null) {
                    this.checkForCompliance();
                } else {
                    this.template.querySelector('.compliance').lastChild.children[0].style.display = 'none';
                }

            }
        }

    }

}