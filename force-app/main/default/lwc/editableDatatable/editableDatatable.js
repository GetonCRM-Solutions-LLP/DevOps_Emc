import {LightningElement, api} from 'lwc';
// import { loadStyle } from 'lightning/platformResourceLoader';
// import EDITABLE_CSS from '@salesforce/resourceUrl/EditableComponent';
import updateMileages from '@salesforce/apex/GetDriverData.updateMileages';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class EditableDatatable extends LightningElement {
    @api isopenmodel = false;
    RecordId ;
    drivername ;
    date ;
    mileges ;
    from ;
    to ;
    tags;
    notes;
    Activity;
    DriveTime;
    StayTime;
    StartTime;
    EndTime;
    fromlatitude;
    fromlongitude;
    tolatitude;
    tolongitude;
    tripid;
    triplogapi;
    timezone;
    waypoint;
    isEdit = false;
    showmap = false;
    
    renderedCallback() {
        if(this.isopenmodel == true){
            if(this.isEdit == false){
                let map = this.template.querySelector('c-map-creation-component');
                if(map != null){
                   
                    this.template.querySelector('c-map-creation-component').mapAccess();
                    
                }
            }
        }
    }

    @api openmodal(id , driver , date , milege , from , to ,  tags , notes , activity , drivetime , staytime ,
         fromlatitude , fromlongitude , tolatitude , tolongitude , tripid , triplogapi , timezone , waypoint ,strattime ,endtime) {
        console.log('in open model block:');
        let targetid = id;
        this.isopenmodel = true;
        this.RecordId = id;
        this.drivername = driver;
        this.date = date;
        this.mileges = milege;
        this.from = from;
        this.to = to;
        this.tags = tags;
        this.notes = notes;
        this.Activity = activity;
        this.DriveTime = drivetime;
        this.StayTime = staytime;
        this.fromlatitude = fromlatitude;
        this.fromlongitude = fromlongitude;
        this.tolatitude = tolatitude;
        this.tolongitude = tolongitude;
        this.tripid = tripid;
        this.triplogapi = triplogapi;
        this.timezone = timezone;
        this.waypoint = waypoint;
        this.StartTime  = strattime.substring(0,8);
        this.EndTime = endtime;
        if((fromlatitude && fromlongitude) ||  (tolatitude && tolongitude)){
            this.showmap = true;
        }
        
    }

    keyHandler(event) {
        const keyCode = event.keyCode || event.which;
        const keyValue = String.fromCharCode(keyCode);
        const regex = /^[0-9.]*$/; // Regular expression to match numbers and decimal point
        if (!regex.test(keyValue)) {
          event.preventDefault(); // Prevent input if the key is not a number or decimal point
        }
      }
   
    handleTextAreaInput(event){
        this.notes = event.target.value;
        this.isEdit = true;
    }
    handleDriveTimeChange(event){
        this.DriveTime = event.target.value;
        this.isEdit = true;
    }
    handleStayTimeChange(event){
        this.StayTime = event.target.value;
        this.isEdit = true;
    }
    handleTagChange(event){
        this.tags = event.target.value;
        this.isEdit = true;
    }
    handleSave() {
        if(this.tags.length > 0 || this.notes.length > 0 || this.StayTime.length > 0){
            updateMileages({tripId: this.RecordId,
                tripTag: this.tags,
                activity: this.Activity,
                notes: this.notes,
                staytime: this.StayTime  })
            
                .then(() =>{
                    const selectEvent = new CustomEvent('updateevent', {
                            detail:{ 
                                userid:this.RecordId,
                                usertag:this.tags,
                                usernote:this.notes,
                                userstaytime:this.StayTime,
                                error: 'success'
                            }
                    });
                    this.dispatchEvent(selectEvent);
                    this.isopenmodel = false;
                    this.closeModal();
                })
                .catch(error =>{
                    console.log('in error',error)
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'Something went wrong while updating account',
                            variant: 'error'
                        })
                    )
                })
        }else{
            this.closeModal();
        }
    }
    @api closeModal() {
        console.log('in close')
        this.isopenmodel = false;
        this.isEdit = false;
        const selectEvent = new CustomEvent('mycustomevent', {
        });
       this.dispatchEvent(selectEvent);
    } 
}