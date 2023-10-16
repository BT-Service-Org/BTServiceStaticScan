import LightningDatatable from 'lightning/datatable';
import { LightningElement,api } from 'lwc';

import progressRing from './progressRing.html';

export default class CustomDatatableComp extends LightningDatatable {
@api value;

    static customTypes = {
        proRing:{
            template:progressRing ,
            typeAttributes: ['percentage','style', 'title']
        }
    };
        
}