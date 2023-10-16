import { LightningElement, track } from 'lwc';

export default class GdcmsNominationReviewPage extends LightningElement {
    @track selectedItem = 'trailblazer_nomination';

    trailblazerNomination = false;
    CustomerSuccessNomination = false;
    AchiverNomination = false;

    handleSelect(event) {
        const selected = event.detail.name;

        if (selected === 'trailblazer_nomination') {
            this.trailblazerNomination = true;
            this.CustomerSuccessNomination = false;
            this.AchiverNomination = false;
        } else if (selected === 'customer_success_team_nomination') {
            this.trailblazerNomination = false;
            this.CustomerSuccessNomination = true;
            this.AchiverNomination = false;
        } else if (selected === 'achiever_nomination') {
            this.trailblazerNomination = false;
            this.CustomerSuccessNomination = false;
            this.AchiverNomination = true;
        }
    }
}