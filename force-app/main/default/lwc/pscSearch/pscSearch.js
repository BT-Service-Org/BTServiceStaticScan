import { LightningElement, api } from 'lwc';
export default class PscSearch extends LightningElement {
    queryTerm = '';
    sort;
    @api placeholder;
    @api name;

    connectedCallback() {
        let urlString = location.href;
        let paramStrings = urlString.split('#')[1];
        if (paramStrings !== null && paramStrings !== undefined) {
            let paramArray = paramStrings.split('&');
            if (paramArray.length > 0) {
                for (let each of paramArray) {
                    let eachItem = each.split('=');
                    if (eachItem[0] === 'q') {
                        this.queryTerm = eachItem.length > 0 ? eachItem[1] : '';
                        this.queryTerm=decodeURIComponent(this.queryTerm);
                    }
                    if (eachItem[0] === 'sort') {
                        this.sort = eachItem.length > 0 ? eachItem[1] : '';
                        this.sort=decodeURIComponent(this.sort);
                    }
                }
            }
        }
    }

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
            let navUrl = '/ServicesCentral/s/global-search/%40uri#q=' + this.queryTerm + (this.sort !== undefined && this.sort !== '' ? '&sort=' + this.sort : '');
            window.location.assign(navUrl);

        }
    }
}