import { LightningElement, api, track} from 'lwc';
import getContext from '@salesforce/apex/SolutionFinderContext.getContext';
import getTree from '@salesforce/apex/SolutionFinderTree.getTree';

export default class SolutionFinderExport extends LightningElement {
    @api optionName;
    @track context = {};
    @track items = [];

    connectedCallback() {
        this.initContext();
        this.initItems();
    }

    initContext() {
        if (this.optionName == null) {
            console.log("No option - aborting");
            return;
        }
        getContext({ name: this.optionName, cacheBuster: new Date().getTime() })
            .then(data => {
                console.log(data);
                this.context = data;
                this.isLoading = false;
            })
            .catch(error => {
                console.log("Error getting context: " + JSON.stringify(error));
                this.isLoading = false;
            })
    }

    initItems() {
        getTree({ name: this.optionName })
            .then(data => {
                this.items = data.items;
                console.log(JSON.stringify(this.items));
            })
            .catch(error => {
                console.log(error);
            })
    }
}