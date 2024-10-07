import { LightningElement } from "lwc";
import emcUrl from "@salesforce/resourceUrl/mBurseCss";
import svgFile from '@salesforce/resourceUrl/SvgFiles';
import driverDetails from "@salesforce/apex/NewAccountDriverController.getContactDetail";
export default class OnboardingStep extends LightningElement {
  step1Url = svgFile + '/onBoarding/SVG/1.svg';
  step2Url = svgFile + "/onBoarding/SVG/2(admin).svg";
  number1 = emcUrl + "/mburse/assets/Numbers/1.png";
  number2 = emcUrl + "/mburse/assets/Numbers/2.png";
  ismDash = false;
  isRegister = false;
  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }
  proxyToObject(e) {
    return JSON.parse(e);
  }
  connectedCallback() {
    const idParamValue = this.getUrlParamValue(window.location.href, "id");
    const aidParamValue = this.getUrlParamValue(window.location.href, "accid");
    this.contactId = idParamValue;
    this.accountId = aidParamValue;
    driverDetails({ contactId: this.contactId })
      .then((data) => {
        var driverDetailList;
        if (data) {
          driverDetailList = this.proxyToObject(data);
          this.isRegister = (driverDetailList[0].watchMeetingOnBoarding) ? true : false;
          this.ismDash = (driverDetailList[0].mburseDashboardOnBoarding) ? true : false;
        }
      })
      .catch((error) => {
        console.log("Error", error.message);
      });
  }
}