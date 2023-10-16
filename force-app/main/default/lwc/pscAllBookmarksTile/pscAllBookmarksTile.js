import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getVoteCount from '@salesforce/apex/PSCArticleVoteController.getVoteCount';
export default class PscAllBookmarksTile extends NavigationMixin(LightningElement) {
    @api pscArticle;
    @api showFavorite;
    @api knowledgeArticleId;
    @track voteData = {
        downVoteCount: 0,
        upVoteCount: 0
    };

    @wire(getVoteCount, { parentId: '$knowledgeArticleId' })
    voteData(result) {
        if (result.data) {
            if (result.data !== null && result.data !== undefined) {
                this.voteData = result.data;
            }

        }
        else if (result.error) {
            console.log(result.error);
            this.error = result.error;
        }
    }

    handleRefresh() {
        const selectedEvent = new CustomEvent("favclick");
        this.dispatchEvent(selectedEvent);
    }
}