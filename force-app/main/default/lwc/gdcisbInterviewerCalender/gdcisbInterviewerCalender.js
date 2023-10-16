import { LightningElement, wire, track } from "lwc";
import { CurrentPageReference } from 'lightning/navigation';
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import FullCalendarPlugin from "@salesforce/resourceUrl/FullCalendarResource";

import saveReoccurenceAppointMents from "@salesforce/apex/GDCISB_InterviwerCalender.saveReoccurenceAppointMents";
import deleteGoogleEvent from "@salesforce/apex/GDCGCalLibrary.deleteGoogleEvent";
import updateGoogleEvents from "@salesforce/apex/GDCGCalLibrary.updateGoogleEvents";
import insertEvents from "@salesforce/apex/GDCGCalLibrary.insertEvents";
import gapiConnect from "@salesforce/apex/GDCISB_InterviwerCalender.gapiConnect";
import gapiGetToken from "@salesforce/apex/GDCISB_InterviwerCalender.gapiGetToken";
import getInterviewer from "@salesforce/apex/GDCISB_InterviwerCalender.getInterviewer";
import getAppointments from "@salesforce/apex/GDCISB_InterviwerCalender.getMyAppointments";
import saveAppointments from "@salesforce/apex/GDCISB_InterviwerCalender.saveAppointments";
import updateAppointments from "@salesforce/apex/GDCISB_InterviwerCalender.updateAppointments";
import deleteAppointments from "@salesforce/apex/GDCISB_InterviwerCalender.deleteAppointments";
import gapiGetCalendarList from "@salesforce/apex/GDCISB_InterviwerCalender.gapiGetCalendarList";
import getEventRecordTypeId from "@salesforce/apex/GDCISB_InterviwerCalender.getEventRecordTypeId";
import updateAccessToken from "@salesforce/apex/GDCISB_InterviwerCalender.updateAccessToken";
import deleteOnSFDCWhenDeletedOnGcal from "@salesforce/apex/GDCISB_InterviwerCalender.deleteOnSFDCWhenDeletedOnGcal";

import USERID from '@salesforce/user/Id';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import EVENT_OBJECT from "@salesforce/schema/Event";
import { generateErrors } from 'c/handleErrors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";

const PAST_LABEL = 'You are trying to perform action over the Past events';
const BOOKED_SLOT = 'You Can\'t perform any actions on Booked Slot';
const EMERGENCY_SLOT = 'You Can\'t perform any actions on Emergency Slot';
const RESIZE_EVENT = 'You Can\'t Resize any slot for more than an hour';
const DUPLICATE_SLOT = 'You already have slot over the same time';
const GOOGLE_SLOT = 'You Can\'t perform any actions on Google Calendar Invite';

const FREQUENCY_OPTIONS = [{label:'Does Not Repeat',value:''},{label:'Daily',value:'daily'},{label:'Weekly',value:'weekly'},{label:'Monthly',value:'monthly'}];

export default class GdcisbInterviewerCalender extends LightningElement {
    isResourceLoaded = false;
    calendarElement;
    eventList = [];
    isClickedonEmptySlot = false;
    frequencyOptions = FREQUENCY_OPTIONS;
    authCode;
    token;
    accessToken;
    @track slotObj ={date:'',start:'',end:'',frequency:'',untill:'',performSameActionOnReccurredSlots:false, weekends:true};
    isClickedonFilledSlot = false;
    currentEventInfo;
    isEventDropped = false;
    warningPopup = false;
    warningLabel;
    showSpinner = false;
    @track hiringEvents = []; //added by Srikanth
    googleEvents = [];
    interviewerRecord;

    @wire(getEventRecordTypeId) gdcInterviewSlotRecordTypeId;
    
    @wire(getInterviewer)
    wiredInterviewer({error,data}){
        if(data){
            this.interviewerRecord = data;
            this.getCalendarEvents(this.interviewerRecord.GCalendar_Token__c);
        }
    }

    syncGcal(){
        gapiConnect().then(res=>{
            window.open(res,"_self");
        }).catch(err=>{
            alert(err);
        })
    }

    getCalendarEvents(accessToken){
        this.authCode = new URLSearchParams(window.location.search).get('code');
        if(this.authCode){
            this.showSpinner = true;
            gapiGetToken({authCode : this.authCode}).then(res=>{
                this.accessToken = JSON.parse(res).access_token;
                updateAccessToken({conId : this.interviewerRecord.Id, accessToken : this.accessToken}).then(res=>{
                    window.open('https://sfservices.lightning.force.com/lightning/n/My_Calender',"_self");
                }).catch(err=>{
                    alert(JSON.stringify(err));
                })
            }).catch(err=>{
                alert(err);
                alert(JSON.stringify(err));
            })
        }else{
            gapiGetCalendarList({authCode: accessToken}).then(allCalEvents=>{
                var eventData = JSON.parse(allCalEvents);
                if(eventData.error && eventData.error.message.includes('invalid authentication credentials')){
                    this.syncGcal();
                    return;
                }
                this.accessToken = accessToken;
                this.googleEvents = eventData.items;
                let eventList = this.eventList;
                let deletedEvents = [];
                if(this.googleEvents && this.googleEvents.length > 0){
                    this.googleEvents.forEach((event) => {
                        if(event.summary !== 'Interview Scheduled' && event.status !== 'cancelled'){
                            let obj = {
                                start: event.start.dateTime,
                                end: event.end.dateTime,
                                title: event.summary,
                                typeOfSlot: 'Google Event',
                                color :'white',
                                textColor : '#039BE5',
                                borderColor: '#039BE5'
                            };
                            eventList.push(obj);
                        }
                        /*if(event.summary == 'Interview Scheduled' && event.status == 'cancelled'){
                            let removeIndex = eventList.map(item => item.gcalEventId).indexOf(event.id);
                            if(removeIndex >= 0){
                                deletedEvents.push(eventList.find(item => item.gcalEventId == event.id).id);
                                eventList.splice(removeIndex, 1);
                            }
                        }*/
                    });
                    this.eventList = eventList;
                    this.initCalendar(eventList);
                    /*if(deletedEvents.length > 0){
                        deleteOnSFDCWhenDeletedOnGcal({eventIds : deletedEvents}).then(res=>{
                        }).catch(err=>{
                            alert(JSON.stringify(err));
                        })
                    }*/
                }
            }).catch(err=>{
                alert(JSON.stringify(err));
            })
        }
    }

    connectedCallback() {
        window.addEventListener( "lightning__showtoast", this.handleResponse.bind(this), false );
        window.addEventListener( "resize", this.makeReactive.bind(this), false );
    }

    insertEvent(){
        //Call this method when slots are created by interviewers and replace  new Date() with start time and end time
        //Set recurrence if needed, else put it null/ undefined
        insertEvents({authCode: this.accessToken, startDateTime: new Date(this.slotObj.start), 
            endDateTime: new Date(this.slotObj.end), recurrenceRule: ''}).then(res=>{
                let result = JSON.parse(res);
                if(result.error){
                    alert(JSON.stringify(result.error));
                    this.showSpinner = false;
                }else{
                    this.saveAppointments(result.id);
                }
            //**Store this ID on a field on Event object** DONOT LET CREATION OF EVENTS WITHOUT ID for our record type
            //This ID will be later used to update/ delete events
        }).catch(err=>{
            alert(JSON.stringify(err));
        });
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
        getAppointments({})
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
        this.hiringEvents = [];
        resposne.forEach((event) => {
            let obj = {
                id: event.recordId,
                start: event.startTime,
                end: event.endTime,
                title: event.name,
                reccuredSlot: event.isItReccuredEvent,
                reccuredSlotId: event.reccuredSlotId,
                status: event.status,
                typeOfSlot: event.typeOfSlot,
                gcalEventId: event.gcalEventId
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
            /*dateClick: function(info) {
                alert('clicked ' + info.dateStr);
            },*/
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
                self.slotObj["frequency"] = '';
                self.slotObj["weekends"] = true;
                self.isClickedonEmptySlot = true;
            },
            eventClick: function(info) {
                if(info.event.extendedProps.typeOfSlot == 'Google Event'){
                    self.warningLabel = GOOGLE_SLOT;
                    self.warningPopup = true;
                    return;
                }
                if(info.event.end < new Date()){
                    self.warningLabel = PAST_LABEL;
                    self.warningPopup = true;
                    return;
                }
                if(info.event.extendedProps.status == 'Booked'){
                    self.warningLabel = BOOKED_SLOT;
                    self.warningPopup = true;
                    return;
                }
                self.slotObj["start"] = info.event.start.toISOString();
                self.slotObj["end"] = info.event.end.toISOString();
                self.isClickedonFilledSlot = true;
                self.currentEventInfo = info;
            },
            navLinks: true,
            allDaySlot: false,
            scrollTime: '08:00:00',
            contentHeight: window.innerHeight*0.78,
            editable: true,
            eventLimit: true,    
            eventDrop: function(info) {
                if(info.event.extendedProps.typeOfSlot == 'Google Event'){
                    self.warningLabel = GOOGLE_SLOT;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }
                if(info.event.end < new Date() || info.oldEvent.end < new Date()){
                    self.warningLabel = PAST_LABEL;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }
                if(info.event.extendedProps.status == 'Booked'){
                    self.warningLabel = BOOKED_SLOT;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }
                if(info.event.extendedProps.typeOfSlot === 'Emergency'){
                    self.warningLabel = EMERGENCY_SLOT;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }
                self.slotObj["start"] = info.event.start.toISOString();
                self.slotObj["end"] = info.event.end.toISOString();
                self.isEventDropped = true;
                self.currentEventInfo = info;
            },
            eventResize: function(info) {
                self.slotObj["start"] = info.event.start.toISOString();
                self.slotObj["end"] = info.event.end.toISOString();
                self.currentEventInfo = info;
                if(info.event.end < new Date()){
                    self.warningLabel = PAST_LABEL;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }
                /*let resp = self.validateIfAnySlotExistingOverTheSameTimeOnUpdate();
                if(!resp.exists){
                    self.warningLabel = "<span>You already having a slot at <br/><b>"+resp.slot.start +"</b> - <b>" +resp.slot.end + '</b></span>';;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }*/
                if(info.event.extendedProps.status == 'Booked'){
                    self.warningLabel = BOOKED_SLOT;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }
                if(info.event.extendedProps.typeOfSlot === 'Emergency'){
                    self.warningLabel = EMERGENCY_SLOT;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }
                if(self.isTheSlotForMorethanAnHour){
                    self.warningLabel = RESIZE_EVENT;
                    self.warningPopup = true;
                    info.revert();
                    return;
                }
                self.isEventDropped = true;
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
        
    }

    closeEmptySlotModal() {
        // to close modal set isModalOpen tarck value as false
        this.isClickedonEmptySlot = false;
    }

    closeFilledSlotModal(){
        this.isClickedonFilledSlot = false;
        this.isEventDropped = false;
        if(this.currentEventInfo && this.currentEventInfo.revert){
            this.currentEventInfo.revert();
        }
        this.slotObj.performSameActionOnReccurredSlots = false;
    }

    recurrenceRule;
    generateSlotRequest(recordId){
        let startDate = new Date(this.slotObj.start);
        let endDate = new Date(this.slotObj.end);
        let slots = [];

        if(this.slotObj.frequency === 'daily'){
            slots =[...slots,...this.setTheRepeatedSlots(startDate,endDate,1,recordId)];
            this.recurrenceRule = 'RRULE:FREQ=DAILY;COUNT='+(slots.length+1);
        }else if(this.slotObj.frequency === 'weekly'){
            slots =[...slots,...this.setTheRepeatedSlots(startDate,endDate,7,recordId)];
            let days = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
            var dayName = days[startDate.getDay()];
            this.recurrenceRule = 'RRULE:FREQ=WEEKLY;COUNT='+(slots.length+1)+';BYDAY='+dayName;
        }else if(this.slotObj.frequency === 'monthly'){
            startDate.setMonth(startDate.getMonth()+1);
            endDate.setMonth(endDate.getMonth()+1);
            if(this.slotObj.untill){
                let untill = new Date(this.slotObj.untill);
                untill = untill.setDate(untill.getDate()+1);
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
            this.recurrenceRule = 'RRULE:FREQ=MONTHLY;COUNT='+(slots.length+1)+';BYMONTH='+startDate.getDate();
        }
        return slots;
    }

    setTheRepeatedSlots(startDate,endDate,days,recordId){
        let slots = [];
        startDate.setDate(startDate.getDate()+days);
        endDate.setDate(endDate.getDate()+days);
        if(this.slotObj.untill){
            let untill = new Date(this.slotObj.untill);
            untill = untill.setDate(untill.getDate()+1);
            while(endDate < untill){
                let slotObj = this.generateSlotObject(startDate,endDate);
                slotObj.GDC_Recurred_Slot_Id__c = recordId;
                let currentDay = new Date(slotObj.StartDateTime).getDay();
                if(this.slotObj.weekends && days == 1){
                    if(currentDay != 0 && currentDay != 6){
                        slots.push(slotObj);
                    }
                }else{
                    slots.push(slotObj);
                }
                startDate.setDate(startDate.getDate()+days);
                endDate.setDate(endDate.getDate()+days);
            }
        }else{
            for(let i=0;i<5;i++){
                let slotObj = this.generateSlotObject(startDate,endDate);
                slotObj.GDC_Recurred_Slot_Id__c = recordId;
                let currentDay = new Date(slotObj.StartDateTime).getDay();
                if(this.slotObj.weekends && days == 1){
                    if(currentDay != 0 && currentDay != 6){
                        slots.push(slotObj);
                    }
                }else{
                    slots.push(slotObj);
                }
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
            'WhoId': this.interviewerRecord?.Id,
            'RecordTypeId': this.gdcInterviewSlotRecordTypeId.data
        };
    }

    addanEventtoTheCalendar(resposne){
        for(let item of resposne){
            this.calendarElement.addEvent({
                id: item.recordId,
                start: item.startTime,
                end: item.endTime,
                title: item.name,
                reccuredSlot: item.isItReccuredEvent,
                reccuredSlotId: item.reccuredSlotId,
                color:'green'
            });
        }
    }

    performPageValidations() {
        let checkValid,
            isValid = [...this.template.querySelectorAll('.inputElement')]
            .reduce((validSoFar, inputCmp) => {
                if (/lightning-input|lightning-combobox|lightning-textarea|lightning-radio-group/i.test(inputCmp.nodeName)) {
                    inputCmp.setCustomValidity("");
                    inputCmp.reportValidity();
                    checkValid = inputCmp.checkValidity();
                } 
                return validSoFar && checkValid;
            }, true);

        return isValid;
    }

    get isTheSlotForMorethanAnHour(){
        let startDate = new Date(this.slotObj.start);
        let enddate = new Date(this.slotObj.end);
        return (enddate-startDate)/1000 > 3600;
    }

    get isSlotsUpdatedForPastTime(){
        if(new Date(this.slotObj.start) < new Date() || new Date(this.slotObj.end) < new Date()){
            return true;
        }
        return false;
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
        }else if(this.isSlotsUpdatedForPastTime){
            inputCmp.setCustomValidity("You are trying to Update a slot to the past time");
            inputCmp.reportValidity();
            return false;
        }else{
            inputCmp.setCustomValidity("");
            inputCmp.reportValidity();
        }
        return true;
    }

    validateIfAnySlotExistingOverTheSameTime(){
        let slots = [];
        let slotObj =this.generateSlotObject(new Date(this.slotObj.start),new Date(this.slotObj.end));
        slots.push(slotObj);
        slots = [...slots,...this.generateSlotRequest('Test')];
        for(let slot of slots){
            let existingSLot = this.validateIfAnySlot(slot);
            if(existingSLot){
                let errorCmp = this.template.querySelector('.validationMessage');
                if(errorCmp){
                    errorCmp.innerHTML ="<span>You already having a slot at <br/><b>"+existingSLot.start +"</b> - <b>" +existingSLot.end + '</b></span>';
                }
                return false;
            }
        }
        return true;
    }

    validateIfAnySlot(slotObj){
        return this.calendarElement.getEvents().find( item => item.extendedProps.typeOfSlot !== 'Emergency' && item.extendedProps.typeOfSlot !== 'Google Event' && 
                                                                item.id !== slotObj.Id && ((item.start > new Date(slotObj.StartDateTime) && item.start < new Date(slotObj.EndDateTime)) ||
                                                                (new Date(slotObj.EndDateTime) > item.start && new Date(slotObj.EndDateTime) < item.end) ||
                                                                (item.end > new Date(slotObj.StartDateTime) && item.end < new Date(slotObj.EndDateTime)) ||
                                                                (new Date(slotObj.StartDateTime) > item.start && new Date(slotObj.StartDateTime) < item.end) ||
                                                                (new Date(slotObj.StartDateTime).getTime() == item.start.getTime() && new Date(slotObj.EndDateTime).getTime() == item.end.getTime()))
                                                            );
    }

    submitDetails() {
        if(this.performPageValidations() && this.performCustomValidations() && this.validateIfAnySlotExistingOverTheSameTime()){
            this.showSpinner = true;
            this.insertEvent();
        }
    }

    saveAppointments(googleEventId){
        let slots = [];
        let slotObj =this.generateSlotObject(new Date(this.slotObj.start),new Date(this.slotObj.end));
        slotObj.Google_Event_Id__c = googleEventId;
        slots.push(slotObj);
        saveAppointments({slots:slots})
            .then((resposne) => {
                slotObj.Id = resposne[0].recordId;
                slotObj.GDC_Recurred_Slot_Id__c = resposne[0].recordId;
                if(this.slotObj.frequency){
                    slots = [...slots,...this.generateSlotRequest(resposne[0].recordId)];
                    saveReoccurenceAppointMents({slots:slots, accessToken : this.accessToken, recurrenceRule : this.recurrenceRule})
                    .then((resposne) => {
                        this.isClickedonEmptySlot = false;
                        //this.getAppointmentsFromServer();
                        this.addanEventtoTheCalendar(resposne);
                        this.showSpinner = false;
                    })
                    .catch((error) => {
                        this.isClickedonEmptySlot = false;
                        if(this.currentEventInfo && this.currentEventInfo.revert){
                            this.currentEventInfo.revert();
                        }
                        this.showSpinner = false;
                    });
                }else{
                    this.isClickedonEmptySlot = false;
                    this.addanEventtoTheCalendar(resposne);
                    this.showSpinner = false;
                }
            })
            .catch((error) => {
                this.isClickedonEmptySlot = false;
                if(this.currentEventInfo && this.currentEventInfo.revert){
                    this.currentEventInfo.revert();
                }
                this.showSpinner = false;
            });
    }

    relatedEvents(){
        return this.calendarElement.getEvents().filter(row => row.id==this.currentEventInfo.event.id || //Current Event
            row.extendedProps.reccuredSlotId == this.currentEventInfo.event.id || // all the childs if clicked on Parent
            row.id == this.currentEventInfo.event.extendedProps.reccuredSlotId || // parent rec if clicked on child
            (row.extendedProps.reccuredSlotId && row.extendedProps.reccuredSlotId == this.currentEventInfo.event.extendedProps.reccuredSlotId));// all the childs if clicked on child
    }

    generateSlotObjectForUpdate(startDate,endDate){
        return {
            'sobjectType': 'Event',
            'StartDateTime': startDate.toISOString(),
            'EndDateTime': endDate.toISOString(),
            'GDC_Slot_Status__c': 'Available'
        };
    }

    generateSlotsForUpdateCall(){
        let slots = [];
        let slotObj = this.generateSlotObjectForUpdate(new Date(this.slotObj.start),new Date(this.slotObj.end));
        slotObj["Id"] = this.currentEventInfo.event.id;
        slots.push(slotObj);
        
        if(this.isEventsHaveRecurredSlots && this.slotObj.performSameActionOnReccurredSlots){
            let events = this.relatedEvents();
            slots = [];
            let diffStartTime = new Date(this.slotObj.start) - (this.currentEventInfo.oldEvent ? this.currentEventInfo.oldEvent.start : this.currentEventInfo.prevEvent ? this.currentEventInfo.prevEvent.start : this.currentEventInfo.event.start);
            let diffEndTime  = new Date(this.slotObj.end) - (this.currentEventInfo.oldEvent ? this.currentEventInfo.oldEvent.end : this.currentEventInfo.prevEvent ? this.currentEventInfo.prevEvent.end : this.currentEventInfo.event.end);
            for(let event of events){
                let startTime = new Date(event.start.setMilliseconds(diffStartTime));
                let endTime = new Date(event.end.setMilliseconds(diffEndTime));
                if((this.currentEventInfo.oldEvent && this.currentEventInfo.oldEvent.id == event.id) ||
                (this.currentEventInfo.prevEvent && this.currentEventInfo.prevEvent.id == event.id)){
                    startTime = event.start;
                    endTime = event.end;
                }
                let slotObj = this.generateSlotObjectForUpdate(startTime,endTime);
                slotObj["Id"] = event.id;
                slotObj["GDC_Slot_Status__c"] = event.extendedProps.status;
                slots.push(slotObj);
            }
        }
        return slots;
    }

    validateIfAnySlotExistingOverTheSameTimeOnUpdate(){
        let slots = this.generateSlotsForUpdateCall();
        for(let slot of slots){
            let existingSLot = this.validateIfAnySlot(slot);
            let resp ={slot:existingSLot,exists:false};
            if(existingSLot){
                let errorCmp = this.template.querySelector('.validationMessage');
                if(errorCmp){
                    errorCmp.innerHTML ="<span>You already having a slot at <br/><b>"+existingSLot.start +"</b> - <b>" +existingSLot.end + '</b></span>';
                }
                return resp;
            }
        }
        return {exists:true};
    }

    updateSlot(){
        if(this.performPageValidations() && this.performCustomValidations() && this.validateIfAnySlotExistingOverTheSameTimeOnUpdate().exists){
            let slots = this.generateSlotsForUpdateCall();
            let bookedSlots = slots.find(slot => slot.GDC_Slot_Status__c === 'Booked');
            if(bookedSlots){
                let errorCmp = this.template.querySelector('.validationMessage');
                if(errorCmp){
                    errorCmp.innerHTML ="<span>You already having a slot at <br/><b>"+new Date(bookedSlots.StartDateTime) +"</b> - <b>" +new Date(bookedSlots.EndDateTime) + '</b></span>';
                }
                return;
            }
            this.showSpinner = true;
            this.updateGoogleEvents(slots);
        }
    }

    updateGoogleEvents(slots){
        updateGoogleEvents({authCode: this.accessToken, startDateTime: new Date(this.slotObj.start), 
            endDateTime: new Date(this.slotObj.end), eventId:slots[0].Id}).then(res=>{
                let result = JSON.parse(res);
                if(result.error){
                    alert(JSON.stringify(result.error));
                    this.showSpinner = false;
                }else{
                    this.updateAppointments(slots);
                }
            //**Store this ID on a field on Event object** DONOT LET CREATION OF EVENTS WITHOUT ID for our record type
            //This ID will be later used to update/ delete events
        }).catch(err=>{
            alert(JSON.stringify(err));
        });
    }

    updateAppointments(slots){
        updateAppointments({slots:slots})
        .then((resposne) => {
            if(this.isEventsHaveRecurredSlots && this.slotObj.performSameActionOnReccurredSlots){
                let events = this.relatedEvents();
                let diffStartTime = new Date(this.slotObj.start) - (this.currentEventInfo.oldEvent ? this.currentEventInfo.oldEvent.start : this.currentEventInfo.prevEvent ? this.currentEventInfo.prevEvent.start : this.currentEventInfo.event.start);
                let diffEndTime  = new Date(this.slotObj.end) - (this.currentEventInfo.oldEvent ? this.currentEventInfo.oldEvent.end : this.currentEventInfo.prevEvent ? this.currentEventInfo.prevEvent.end : this.currentEventInfo.event.end);
                for(let event of events){
                    let startTime = new Date(event.start.setMilliseconds(diffStartTime));
                    let endTime = new Date(event.end.setMilliseconds(diffEndTime));
                    if((this.currentEventInfo.oldEvent && this.currentEventInfo.oldEvent.id == event.id) ||
                    (this.currentEventInfo.prevEvent && this.currentEventInfo.prevEvent.id == event.id)){
                        startTime = event.start;
                        endTime = event.end;
                    }
                    event.setDates(startTime.toISOString(),endTime.toISOString());
                }
            }else{
                this.currentEventInfo.event.setDates(this.slotObj.start,this.slotObj.end);
            }
            this.isClickedonFilledSlot = false;
            this.slotObj.performSameActionOnReccurredSlots = false;
            this.isEventDropped = false;   
            this.showSpinner = false;
        })
        .catch((error) => {
            this.isClickedonFilledSlot = false;
            this.isEventDropped = false;
            if(this.currentEventInfo && this.currentEventInfo.revert){
                this.currentEventInfo.revert();
            }
            this.slotObj.performSameActionOnReccurredSlots = false;
            this.showSpinner = false;
            /*const event = new ShowToastEvent({
                title: 'Error',
                message: generateErrors(error)[0],
                variant: 'error'
            });
            this.dispatchEvent(event);*/
            alert(generateErrors(error)[0]);
        });
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

    get isItDaily(){
        return this.slotObj.frequency == 'daily';
    }

    get isEventsHaveRecurredSlots(){
        return (this.currentEventInfo.event.extendedProps.reccuredSlot || !!this.calendarElement.getEvents().find(row => row.id==this.currentEventInfo.event.id).extendedProps.reccuredSlotId);
    }

    deleteSlot(){
        let events = [];
        let slots = [];
        
        if(this.isEventsHaveRecurredSlots && this.slotObj.performSameActionOnReccurredSlots){
            events = this.relatedEvents();
        }else{
            events.push(this.currentEventInfo.event);
        }
        for(let item of events){
            slots.push({'sobjectType': 'Event','Id': item.id});
        }
        this.showSpinner = true;
        this.deleteGoogleEvent(slots,events);
    }

    deleteGoogleEvent(slots,events){
        slots.forEach((slot,index) =>{
            deleteGoogleEvent({authCode: this.accessToken, eventId:slot.Id}).then(res=>{
                if(res == '' && index == 0){
                    this.deleteAppointments(slots,events);
                }else if(index == 0){
                    let result = JSON.parse(res);
                    alert(JSON.stringify(result.error));
                    this.showSpinner = false;
                }
            //**Store this ID on a field on Event object** DONOT LET CREATION OF EVENTS WITHOUT ID for our record type
            //This ID will be later used to update/ delete events
        }).catch(err=>{
            alert(JSON.stringify(err));
            this.showSpinner = false;
            });
        });
    }

    deleteAppointments(slots,events){
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

    get minDate(){
        let endDate = new Date(this.slotObj.end);
        //let nextDay = new Date();
        //nextDay.setDate(endDate.getDate()+1);
        return endDate.toISOString();
    }

    closeWarningPopup(){
        this.warningPopup = false;
    }

    get isItaEmergencySlot(){
        return this.currentEventInfo.event.extendedProps.typeOfSlot === 'Emergency';
    }

    get lableForBookSlot(){
        return this.isItaEmergencySlot ? 'Book Slot' : 'Update Slot';
    }

    validateIfAnySlotAlreadyBooked(slotObj){
        return this.calendarElement.getEvents().find( item => item.extendedProps.status === 'Booked' && item.id !== slotObj.Id && ((item.start > new Date(slotObj.StartDateTime) && item.start < new Date(slotObj.EndDateTime)) ||
                                                                (new Date(slotObj.EndDateTime) > item.start && new Date(slotObj.EndDateTime) < item.end) ||
                                                                (item.end > new Date(slotObj.StartDateTime) && item.end < new Date(slotObj.EndDateTime)) ||
                                                                (new Date(slotObj.StartDateTime) > item.start && new Date(slotObj.StartDateTime) < item.end) ||
                                                                (new Date(slotObj.StartDateTime).getTime() == item.start.getTime() && new Date(slotObj.EndDateTime).getTime() == item.end.getTime()))
                                                            );
    }

    bookSlot(){
        let slots = [];
        let slotObj = this.generateSlotObject(new Date(this.slotObj.start),new Date(this.slotObj.end));
        slotObj["Id"] = this.currentEventInfo.event.id;
        slotObj["GDC_Slot_Status__c"] = 'Booked';
        slotObj["GDC_Slot_Type__c"] = 'Regular';
        slotObj["OwnerId"] = USERID;
        slots.push(slotObj);
        let existingSLot =  this.validateIfAnySlotAlreadyBooked(slotObj);
        if(existingSLot){
            let errorCmp = this.template.querySelector('.validationMessage');
            if(errorCmp){
                errorCmp.innerHTML ="<span>You already having a slot at <br/><b>"+existingSLot.start +"</b> - <b>" +existingSLot.end + '</b></span>';
            }
            return;
        }
        this.showSpinner = true;
        updateAppointments({slots:slots})
            .then((resposne) => {
                this.currentEventInfo.event.setProp('color','#3788d8');
                this.currentEventInfo.event.setProp('title',this.interviewerRecord?.Name);
                this.currentEventInfo.event.setExtendedProp('status','Booked');
                this.isClickedonFilledSlot = false;
                this.isEventDropped = false;   
                this.showSpinner = false;
            })
            .catch((error) => {
                this.isClickedonFilledSlot = false;
                this.isEventDropped = false;
                if(this.currentEventInfo && this.currentEventInfo.revert){
                    this.currentEventInfo.revert();
                }
                this.showSpinner = false;
                alert(generateErrors(error)[0]);
            });
    }
}