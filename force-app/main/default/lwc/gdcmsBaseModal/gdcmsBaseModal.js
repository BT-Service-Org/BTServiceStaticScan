/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is a reusable modal component currently being used to display all certifications 
 * when we click the "show all button" on profile view(GdcmsTeamMemberProfile Component).
 ****************************/

/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */

import { api, LightningElement } from 'lwc';

export default class GdcmsBaseModal extends LightningElement {

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    isModalOpen = false;
    @api height;
    @api width;
    @api maxHeight;
    @api maxWidth;
    @api showFooter;
    
    renderedCallback(){
        var x = this.template.querySelector('[data-id="modal"')
        if(!(x && x.style)){
            return;
        }
        if(this.height){
            x.style.height = this.height;
            x.style['maxHeight'] = typeof this.maxHeight !== 'undefined' ? this.maxHeight : this.height;
        }
        if(this.width){
            x.style['maxWidth'] = typeof this.maxWidth !== 'undefined' ? this.maxWidth : this.width;
            x.style.width = this.width;
        }
    }


    @api
    displayModal(isModal){
        this.isModalOpen = isModal;
    }

    closeModal(){
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}