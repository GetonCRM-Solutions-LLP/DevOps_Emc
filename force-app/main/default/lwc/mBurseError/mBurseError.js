import { LightningElement, api } from 'lwc';

export default class MBurseError extends LightningElement {
    /* stores error message */
    @api message;
}