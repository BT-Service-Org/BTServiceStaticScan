import { LightningElement, api } from 'lwc';

export default class PscCustomSearchBox extends LightningElement {
    
    queryTerm = '';
    @api placeholder;
    @api searchPageURI;
    @api searchFilter;

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        this.queryTerm = evt.target.value;
        if (isEnterKey) {
            let navUrl = this.searchPageURI+'#q=' + this.queryTerm + (!!this.searchFilter && this.searchFilter !== '' ? this.searchFilter : '');
            window.location.assign(navUrl);
        }
    }

    handleSearch(){
        const inputSearch = this.template.querySelector('[data-id="pscCustomSearch"]');
        this.queryTerm = inputSearch.value || '';
        let navUrl = this.searchPageURI+'#q=' + this.queryTerm + (!!this.searchFilter && this.searchFilter !== '' ? this.searchFilter : '');
        window.location.assign(navUrl);
    }
}