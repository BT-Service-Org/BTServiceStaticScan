import { LightningElement, track, wire, api } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import FullCalendarPlugin from "@salesforce/resourceUrl/FullCalendarResource";

import getAppointments from "@salesforce/apex/GDCISB_InterviwerCalender.getInterviwersAppointments";
import saveAppointments from "@salesforce/apex/GDCISB_InterviwerCalender.saveAppointments";
import updateAppointments from "@salesforce/apex/GDCISB_InterviwerCalender.updateAppointments";
import deleteAppointments from "@salesforce/apex/GDCISB_InterviwerCalender.deleteAppointments";
import getEventRecordTypeId from "@salesforce/apex/GDCISB_InterviwerCalender.getEventRecordTypeId";

import USERID from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const PAST_LABEL = 'You are trying to perform action over the Past events';
const FREQUENCY_OPTIONS = [{label:'Does Not Repeat',value:''},{label:'Daily',value:'daily'},{label:'Weekly',value:'weekly'},{label:'Monthly',value:'monthly'}];

export default class GdcisbRecruiterCalender extends LightningElement {
    isResourceLoaded = false;
    calendarElement;
    eventList = [];
    isClickedonEmptySlot = false;
    frequencyOptions = FREQUENCY_OPTIONS;
    @track slotObj ={date:'',start:'',end:'',frequency:'',untill:'',performSameActionOnReccurredSlots:false};
    isClickedonFilledSlot = false;
    currentEventInfo;
    isEventDropped = false;
    warningPopup = false;
    warningLabel;
    @api selectedInterviewers = [];
    @api filters;
    showSpinner = false;
    @track hiringEvents = []; //added by Srikanth
    comments = '';
    fieldName = '';

    get unBookingReasons(){
        return [
            {label: 'Candidate unavailable', value:'Candidate unavailable'},
            {label: 'Interviewer unavailable', value:'Interviewer unavailable'}
        ]
    }

    @wire(getEventRecordTypeId) gdcInterviewSlotRecordTypeId;

    connectedCallback() {
        window.addEventListener( "lightning__showtoast", this.handleResponse.bind(this), false );
        window.addEventListener( "resize", this.makeReactive.bind(this), false );
    }

    handleResponse (){
        this.getAppointmentsFromServer();
    }

    makeReactive(){
        this.calendarElement.setOption('contentHeight', window.innerHeight*0.78);
        this.calendarElement.render();
    }

    // Redercallback method will load FullCalendar Plugin Javascripts and CSS.
    renderedCallback() {
        if (this.isResourceLoaded) {
            return;
        }

        this.isResourceLoaded = true;

        Promise.all([
            loadStyle(this, FullCalendarPlugin + "/packages/core/main.css"),
            loadScript(this, FullCalendarPlugin + "/packages/core/main.js"),
        ])
            .then(() => {
                Promise.all([
                    loadStyle(this, FullCalendarPlugin + "/packages/daygrid/main.css"),
                    loadScript(this, FullCalendarPlugin + "/packages/daygrid/main.js"),
                ])
                    .then(() => {
                        Promise.all([
                            loadStyle(this, FullCalendarPlugin + "/packages/timegrid/main.css"),
                            loadScript(this, FullCalendarPlugin + "/packages/timegrid/main.js"),
                        ])
                            .then(() => {
                                Promise.all([
                                    loadScript(this, FullCalendarPlugin + "/packages/interaction/main.js"),
                                ])
                                    .then(() => {
                                        this.getAppointmentsFromServer();
                                    })
                                    .catch((error) => {
                                        console.error({
                                            message: "Error occured loading interaction",
                                            error,
                                        });
                                    });
                            })
                            .catch((error) => {
                                console.error({ message: "Error occured loading timegrid", error });
                            });
                    })
                    .catch((error) => {
                        console.error({ message: "Error occured loading daygrid", error });
                    });
            })
            .catch((error) => {
                console.error({
                    message: "Error occured on loading core files",
                    error,
                });
            });
    }
    // get record information from Salesforce Server.
    getAppointmentsFromServer() {
        this.hiringEvents = [];
        getAppointments({interviewers:this.selectedInterviewers, filter:this.filters})
        .then((resposne) => {
            this.generateEventJson(resposne);
        })
        .catch((error) => {
            console.error({
                message: "Error occured on getCalendarEventsFromServer",
                error,
            });
        });
    }
    // genrates the JSON using the response from server
    generateEventJson(resposne) {
        let eventList = [];
        resposne.forEach((event) => {
            let obj = {
                id: event.recordId,
                start: event.startTime,
                end: event.endTime,
                title: event.name,
                reccuredSlot: event.isItReccuredEvent,
                reccuredSlotId: event.reccuredSlotId,
                status: event.status,
                typeOfSlot: event.typeOfSlot
            };
            if(new Date(event.endTime) < new Date() && event.typeOfSlot !== 'Hiring Event'){
                obj.color ='lightgray';
                obj.textColor ='black';
                eventList.push(obj);
            }else if(event.status === 'Booked'){
                eventList.push(obj);
            }else if(event.typeOfSlot === 'Emergency'){
                obj.color ='red';
                obj.title = 'Emergency Slot'
                eventList.push(obj);
            }
            //added by srikanth
            else if(event.typeOfSlot === 'Hiring Event') {
                this.hiringEvents.push(event.startTime.split(' ')[0]);
            }
            else{
                obj.color ='green';
                eventList.push(obj);
            }
        });
        this.eventList = eventList;
        this.initCalendar(eventList);
    }
    // initiate the Calendar in the DOM.
    initCalendar(eventList) {
        let self = this;
        const calendarEl = this.template.querySelector("div.fullcalendar");
        calendarEl.innerHTML = '';
        let calendar = new FullCalendar.Calendar(calendarEl, {
            plugins: ["timeGrid", "dayGrid","interaction"],
            defaultView: "timeGridWeek",
            height: "parent",
            displayEventTime: false,
            header: {
                left: "prev, next",
                center: "title",
                right: "today timeGridDay, timeGridWeek, dayGridMonth",
            },
            events: eventList,
            titleFormat: { month: "short", day: "numeric", year: "numeric" },
            minTime: "08:00:00",
            maxTime: "20:00:00",
            height: 'auto',
            slotDuration: '01:00',
            timeZone: 'local',
            eventClick: function(info) {
                if(info.event.end < new Date()){
                    self.warningLabel = PAST_LABEL;
                    self.warningPopup = true;
                    return;
                }
                self.slotObj["start"] = info.event.start.toISOString();
                self.slotObj["end"] = info.event.end.toISOString();
                self.isClickedonFilledSlot = true;
                self.comments = '';
                self.fieldName = '';
                self.currentEventInfo = info;
            },
            navLinks: true,
            allDaySlot: false,
            scrollTime: '08:00:00',
            contentHeight: window.innerHeight*0.78,
            eventLimit: true,
            selectable: true,
            select: function(info) {
                if(info.end < new Date()){
                    self.warningLabel = PAST_LABEL
                    self.warningPopup = true;
                    return;
                }
                let isoStartDate = info.start.toISOString();//'2021-12-15T19:30:00.000Z'
                let isoEndDate = info.end.toISOString();
                self.slotObj["start"] = isoStartDate;
                self.slotObj["end"] = isoEndDate;
                self.isClickedonEmptySlot = true;
            },
            //added by srikanth
            dayRender: function (dayRenderInfo) {
                const dd = String(dayRenderInfo.date.getDate()).padStart(2, '0');
                const mm = String(dayRenderInfo.date.getMonth() + 1).padStart(2, '0'); 
                const yyyy = dayRenderInfo.date.getFullYear();
                const givenDate = yyyy + '-' + mm + '-' + dd;
                if(self.hiringEvents.includes(givenDate)) {
                    dayRenderInfo.el.style.backgroundColor = 'orange';
                    dayRenderInfo.el.style.borderColor = 'orange';
                }
            }
        });
        calendar.render();
        self.calendarElement = calendar;
        window.scrollTo(1000, 1000);
        
    }

    closeEmptySlotModal() {
        // to close modal set isModalOpen tarck value as false
        this.isClickedonEmptySlot = false;
    }

    closeFilledSlotModal(){
        this.isClickedonFilledSlot = false;
        this.comments = '';
        this.fieldName = '';
        this.isEventDropped = false;
        this.slotObj.performSameActionOnReccurredSlots = false;
        if(this.currentEventInfo && this.currentEventInfo.revert){
            this.currentEventInfo.revert();
        }
    }

    generateSlotRequest(recordId){
        let startDate = new Date(this.slotObj.start);
        let endDate = new Date(this.slotObj.end);
        let slots = [];

        if(this.slotObj.frequency === 'daily'){
            slots =[...slots,...this.setTheRepeatedSlots(startDate,endDate,1,recordId)];
        }else if(this.slotObj.frequency === 'weekly'){
            slots =[...slots,...this.setTheRepeatedSlots(startDate,endDate,7,recordId)];
        }else if(this.slotObj.frequency === 'monthly'){
            startDate.setMonth(startDate.getMonth()+1);
            endDate.setMonth(endDate.getMonth()+1);
            if(this.slotObj.untill){
                let untill = new Date(this.slotObj.untill);
                while(endDate < untill){
                    let slotObj = this.generateSlotObject(startDate,endDate);
                    slotObj.GDC_Recurred_Slot_Id__c = recordId;
                    slots.push(slotObj);
                    startDate.setMonth(startDate.getMonth()+1);
                    endDate.setMonth(endDate.getMonth()+1);
                }
            }else{
                for(let i=0;i<5;i++){
                    let slotObj = this.generateSlotObject(startDate,endDate);
                    slotObj.GDC_Recurred_Slot_Id__c = recordId;
                    slots.push(slotObj);
                    startDate.setMonth(startDate.getMonth()+1);
                    endDate.setMonth(endDate.getMonth()+1);
                }
            }
        }
        return slots;
    }

    setTheRepeatedSlots(startDate,endDate,days,recordId){
        let slots = [];
        startDate.setDate(startDate.getDate()+days);
        endDate.setDate(endDate.getDate()+days);
        if(this.slotObj.untill){
            let untill = new Date(this.slotObj.untill);
            while(endDate < untill){
                let slotObj = this.generateSlotObject(startDate,endDate);
                slotObj.GDC_Recurred_Slot_Id__c = recordId;
                slots.push(slotObj);
                startDate.setDate(startDate.getDate()+days);
                endDate.setDate(endDate.getDate()+days);
            }
        }else{
            for(let i=0;i<5;i++){
                let slotObj = this.generateSlotObject(startDate,endDate);
                slotObj.GDC_Recurred_Slot_Id__c = recordId;
                slots.push(slotObj);
                startDate.setDate(startDate.getDate()+days);
                endDate.setDate(endDate.getDate()+days);
            }
        }
        return slots;
    }

    generateSlotObject(startDate,endDate){
        return {
            'sobjectType': 'Event',
            'StartDateTime': startDate.toISOString(),
            'EndDateTime': endDate.toISOString(),
            'GDC_Slot_Status__c': 'Available',
            'RecordTypeId': this.gdcInterviewSlotRecordTypeId.data
        };
    }

    addanEventtoTheCalendar(resposne){
        for(let item of resposne){
            this.calendarElement.addEvent({
                id: item.recordId,
                start: item.startTime,
                end: item.endTime,
                title: 'Emergency Slot',
                reccuredSlot: item.isItReccuredEvent,
                reccuredSlotId: item.reccuredSlotId,
                color:'red',
                typeOfSlot:'Emergency'
            });
        }
    }

    submitDetails() {
        if(this.performPageValidations() && this.performCustomValidations()){
            this.showSpinner = true;
            let slots = [];
            let slotObj =this.generateSlotObject(new Date(this.slotObj.start),new Date(this.slotObj.end));
            slotObj["GDC_Slot_Type__c"] = 'Emergency';
            slotObj["GDC_Skill_Emergency_Slot__c"] = this.filters.skill;
            slotObj["GDC_Posting_Emergency_Slot__c"] = this.filters.jobPosting;
            slotObj["GDC_Hiring_Managers_Emergency_Slot__c"] = this.filters.hiringManager;
            slots.push(slotObj);
            saveAppointments({slots:slots})
            .then((resposne) => {
                this.isClickedonEmptySlot = false;
                this.addanEventtoTheCalendar(resposne);
                this.showSpinner = false;
            })
            .catch((error) => {
                this.isClickedonEmptySlot = false;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
            });
        }
    }

    relatedEvents(){
        return this.calendarElement.getEvents().filter(row => row.id==this.currentEventInfo.event.id || //Current Event
            row.extendedProps.reccuredSlotId == this.currentEventInfo.event.id || // all the childs if clicked on Parent
            row.id == this.currentEventInfo.event.extendedProps.reccuredSlotId || // parent rec if clicked on child
            (row.extendedProps.reccuredSlotId && row.extendedProps.reccuredSlotId == this.currentEventInfo.event.extendedProps.reccuredSlotId));// all the childs if clicked on child
    }

    bookSlot(){
        let slots = [];
        let slotObj = this.generateSlotObject(new Date(this.slotObj.start),new Date(this.slotObj.end));
        slotObj["Id"] = this.currentEventInfo.event.id;
        slotObj["GDC_Slot_Status__c"] = 'Booked';
        slotObj["GDC_Booking_Comments__c"] = this.comments;
        slotObj["GDC_Reason_for_Unbooking__c"] = '';
        slots.push(slotObj);
        this.showSpinner = true;
        updateAppointments({slots:slots})
            .then((resposne) => {
                this.currentEventInfo.event.setProp('color','#3788d8');
                this.currentEventInfo.event.setExtendedProp('status','Booked');
                this.isClickedonFilledSlot = false;
                this.slotObj.performSameActionOnReccurredSlots = false;
                this.isEventDropped = false;   
                this.showSpinner = false;
            })
            .catch((error) => {
                this.isClickedonFilledSlot = false;
                this.isEventDropped = false;
                this.currentEventInfo.revert();
                this.slotObj.performSameActionOnReccurredSlots = false;
                this.showSpinner = false;
            });
    }

    unBookSlot(){
        if(this.comments){
            const timeDiff = Math.abs((new Date(this.slotObj.start) - new Date())/36e5);
            if(timeDiff < 3) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Slots can only be unbooked until 3 hours before the interview',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                return;
            }
            const allValid = [...this.template.querySelectorAll('lightning-textarea')]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
            if (!allValid) {
                return;
            }
            
            let slots = [];
            let slotObj = this.generateSlotObject(new Date(this.slotObj.start),new Date(this.slotObj.end));
            slotObj["Id"] = this.currentEventInfo.event.id;
            slotObj["GDC_Slot_Status__c"] = 'Available';
            slotObj["GDC_Reason_for_Unbooking__c"] = this.comments;
            slotObj["GDC_Booking_Comments__c"] = '';
            slots.push(slotObj);
            this.showSpinner = true;
            updateAppointments({slots:slots})
                .then((resposne) => {
                    this.currentEventInfo.event.setProp('color','green');
                    this.currentEventInfo.event.setExtendedProp('status','Available');
                    this.isClickedonFilledSlot = false;
                    this.slotObj.performSameActionOnReccurredSlots = false;
                    this.isEventDropped = false;   
                    this.showSpinner = false;
                    this.comments = '';
                    this.fieldName = '';
                    this.getAppointmentsFromServer();
                })
                .catch((error) => {
                    this.isClickedonFilledSlot = false;
                    this.isEventDropped = false;
                    this.currentEventInfo.revert();
                    this.slotObj.performSameActionOnReccurredSlots = false;
                    this.showSpinner = false;
                    this.fieldName = '';
                    this.comments = '';
                });
            
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select an Unbooking reason',
                variant: 'error',
            }));
        }
    }

    performPageValidations() {
        let checkValid,
            isValid = [...this.template.querySelectorAll('.inputElement')]
            .reduce((validSoFar, inputCmp) => {
                if (/lightning-input|lightning-combobox|lightning-textarea|lightning-radio-group/i.test(inputCmp.nodeName)) {
                    inputCmp.reportValidity();
                    checkValid = inputCmp.checkValidity();
                } 
                return validSoFar && checkValid;
            }, true);

        return isValid;
    }

    handleChange(event){
        let fieldName = event.target.dataset.fieldname;
        let value = event.target.type == 'checkbox' ? event.detail.checked:
            event.target.type == 'number'? parseFloat(event.detail.value) :event.detail.value;
        this.slotObj[fieldName] = value;
        this.performCustomValidations();
    }

    get isItRecursive(){
        return this.slotObj.frequency !== '';
    }

    get isEventsHaveRecurredSlots(){
        return (this.currentEventInfo.event.extendedProps.reccuredSlot || !!this.calendarElement.getEvents().find(row => row.id==this.currentEventInfo.event.id).extendedProps.reccuredSlotId);
    }

    deleteSlot(){
        let events = [];
        let slots = [];
        events.push(this.currentEventInfo.event);
        for(let item of events){
            slots.push({'sobjectType': 'Event','Id': item.id});
        }
        this.showSpinner = true;
        deleteAppointments({slots:slots})
        .then((resposne) => {
            this.isClickedonFilledSlot = false;
            for(let item of events){
                item.remove();
            }
            this.showSpinner = false;
        })
        .catch((error) => {
            this.isClickedonFilledSlot = false;
            this.showSpinner = false;
        });
    }

    get maxDate(){
        let today = new Date();
        today.setFullYear(today.getFullYear()+1);
        return today.toISOString();
    }

    get isBooked(){
        return this.currentEventInfo.event.extendedProps.status == 'Booked';
    }

    closeWarningPopup(){
        this.warningPopup = false;
    }

    get isItaEmergencySlot(){
        return this.currentEventInfo.event.extendedProps.typeOfSlot === 'Emergency';
    }

    get ifItsNotaEmergencySlot(){
        return !this.isItaEmergencySlot;
    }

    updateSlot(){
        if(this.performPageValidations() && this.performCustomValidations()){
            let slots = [];
            let slotObj = this.generateSlotObject(new Date(this.slotObj.start),new Date(this.slotObj.end));
            slotObj["Id"] = this.currentEventInfo.event.id;
            slots.push(slotObj);
            this.showSpinner = true;
            updateAppointments({slots:slots})
            .then((resposne) => {
                this.currentEventInfo.event.setDates(this.slotObj.start,this.slotObj.end);
                this.isClickedonFilledSlot = false;
                this.isEventDropped = false;   
                this.showSpinner = false;
            })
            .catch((error) => {
                this.isClickedonFilledSlot = false;
                this.isEventDropped = false;
                this.currentEventInfo.revert();
                this.showSpinner = false;
            });
        }
    }

    get isTheSlotForMorethanAnHour(){
        let startDate = new Date(this.slotObj.start);
        let enddate = new Date(this.slotObj.end);
        return (enddate-startDate)/1000 > 3600;
    }

    performCustomValidations() {
        let inputCmp = this.template.querySelector(`[data-fieldname="end"]`);
        if(!inputCmp){
            return true;
        }
        if(this.isTheSlotForMorethanAnHour){
            inputCmp.setCustomValidity("Should not create a slot for more than an hour");
            inputCmp.reportValidity();
            return false;
        }else{
            inputCmp.setCustomValidity("");
            inputCmp.reportValidity();
        }
        return true;
    }

    handleCommentsChange(evt) {
        this.fieldName = evt.target.name;
        this.comments = evt.target.value;
    }
}