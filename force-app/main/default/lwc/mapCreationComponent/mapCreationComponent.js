/* eslint-disable @lwc/lwc/no-api-reassignments */
import {
  LightningElement,
  api
} from "lwc";
import fetchWayPointPostAPI from "@salesforce/apex/GetDriverData.fetchWayPointPostAPI";
export default class MapCreationComponent extends LightningElement {
  // vfHost = 'https://fullcopy-mburse.cs8.force.com/app/googleMapIframe';
  // origin = 'https://fullcopy-mburse.cs8.force.com';

  @api vfHost;
  @api startLocationLt = "";
  @api startLocationLg = "";
  @api endLocationLt = "";
  @api endLocationLg = "";
  @api tripId;
  @api tripLogApi;
  @api timeZone;
  @api wayPt;
  url = "";
  urlHost = "";

  @api mapAccess() {
    this.handleCallout();
  }

  async handleCallout() {
    var locateList, apiJSON = [], resultArray
    try {
      console.log('inside-api calls-->', this.wayPt);
      if (this.wayPt !== undefined) {
        apiJSON = JSON.parse(this.wayPt);
      } else {
        apiJSON = []
        let result = await fetchWayPointPostAPI({
          tripId: this.tripId,
          apikey: this.tripLogApi
        });
        apiJSON = JSON.parse(result);
      }

      resultArray = (apiJSON != null) ? apiJSON.routes : [];
      console.log('apiCall->', JSON.stringify(resultArray));
      if (resultArray.length > 25) {
        resultArray = resultArray.slice(0, 25);
      }

      let mapLocations = [{
        startLocation: {
          Latitude: this.startLocationLt,
          Longitude: this.startLocationLg
        },
        endLocation: {
          Latitude: this.endLocationLt,
          Longitude: this.endLocationLg
        },
        timeZone: this.timeZone,
        waypoints: resultArray
      }];

      if (
        mapLocations[0].startLocation.Latitude !== undefined &&
        mapLocations[0].endLocation.Latitude !== undefined &&
        mapLocations[0].startLocation.Longitude !== undefined &&
        mapLocations[0].endLocation.Longitude !== undefined
      ) {
        if ((
          mapLocations[0].startLocation.Latitude === 0 &&
          mapLocations[0].endLocation.Latitude === 0 &&
          mapLocations[0].startLocation.Longitude === 0 &&
          mapLocations[0].endLocation.Longitude === 0
        )) {
          console.log('inside apiCall has 0 locations');
          this.vfHost = null;
        } else {
          console.log('inside apiCall has locations->')
          locateList = JSON.stringify(mapLocations);
          this.vfHost = this.urlHost + '?locations=' + locateList;
        }
      } else if ((mapLocations[0].startLocation.Latitude !== undefined && mapLocations[0].startLocation.Longitude !== undefined) ||
        (mapLocations[0].endLocation.Latitude !== undefined && mapLocations[0].endLocation.Longitude !== undefined)) {
        console.log('inside apiCall has locations end->')
        locateList = JSON.stringify(mapLocations);
        this.vfHost = this.urlHost + '?locations=' + locateList;
      } else {
        console.log('inside apiCall vf host empty->');
        this.vfHost = null;
      }

    } catch (err) {
      console.log(err);
    }

  }

  connectedCallback() {
    this.url = window.location.origin;
    this.urlHost = this.url + '/app/googleMapIframe';
  }

}