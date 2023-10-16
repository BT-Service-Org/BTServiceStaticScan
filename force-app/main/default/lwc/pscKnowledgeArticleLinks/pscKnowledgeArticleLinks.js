import { LightningElement ,api} from 'lwc';

export default class PscKnowledgeArticleLinks extends LightningElement {
    @api items=[];
    @api title;
}