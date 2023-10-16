/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used for the search functionality in team builder component.
 ****************************/
import { LightningElement, api } from 'lwc';
import {debounceCustomEvent} from 'c/gdcmsPerformanceImproveLibrary';
export default class GdcmsTeamBuilderSearch extends LightningElement {

    @api orgMembers = [];
    @api isDesktopDevice = false;
    inputSearch;
    suggestions;
    showSuggestions = false;

    requestOngoing = false;
    typingTimer;


    async handleChange(event) {
        console.log(this.inputSearch)
        this.inputSearch = event.target.value;
        if (this.inputSearch.length > 1) {
            let searchedMembers = this.orgMembers.filter(e => e.name.toLowerCase().startsWith(this.inputSearch.toLowerCase()));
            if (this.isDesktopDevice) {
                this.suggestions = searchedMembers.map(e => ({ name: e.name, id: e.id }));
                this.showSuggestions = true;
            }
            else {
               /* clearTimeout(this.typingTimer);
                this.typingTimer = setTimeout(() => {
                        this.dispatchEvent(new CustomEvent("updateselectedmembers", {
                            detail: searchedMembers
                        }));
                    }, 500)
                 */
                    let eventObject = {
                        eventName:'updateselectedmembers',
                        doneTypingInterval : 500
                    };
                   await debounceCustomEvent.call(eventObject,searchedMembers);
            }
        }
        else {
            this.suggestions = [];
            this.showSuggestions = false;
            if (!this.isDesktopDevice) {
                
                /*clearTimeout(this.typingTimer);
                this.typingTimer = setTimeout(() => {
                    this.dispatchEvent(new CustomEvent("resetselectedmembers"));
                    }, 500)
                */
                    let eventObject = {
                        eventName:"resetselectedmembers",
                        doneTypingInterval : 500
                    };
                    await debounceCustomEvent.call(eventObject);
            }

        }
    }

    handleSelectedMember(event) {
        let searchedMemberId = event.currentTarget.dataset.id;
        this.showSuggestions = false;
        const selectedEvent = new CustomEvent("selectedmemberchange", {
            detail: searchedMemberId
        });
        this.dispatchEvent(selectedEvent);
        this.inputSearch = '';
    }
}