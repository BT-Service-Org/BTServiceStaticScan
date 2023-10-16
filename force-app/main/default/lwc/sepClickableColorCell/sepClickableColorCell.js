import { LightningElement,api } from 'lwc';

export default class SepClickableColorCell extends LightningElement {
    @api cellcontent;
    @api cellselected;
    @api cellcolumn; // so we can evaluate which column was actually selected
    @api cellquestionid;
    @api cellquestionanswerid;

    logPrefix = 'SEP --- ';

    @api 
    get cellclass() {
        // use default grey
        var helperclass = 'statusWhite';
        var helpergreen = 'statusGreen';

        let col = this.cellcolumn.col;
        

        /*
        if (this.cellselected){
            helperclass = helpergreen;
        }
        */
        //console.info(this.logPrefix,'debug selected cell is equal to cellcolumn',this.cellselected, col);
        if (this.cellselected == col){
            //console.info(this.logPrefix,'selected cell is equal to cellcolumn',this.cellselected, col);
            helperclass = helpergreen;
        } else {
            //console.info(this.logPrefix,'selected cell is unequal to cellcolumn',this.cellselected, col);
            helperclass = 'statusWhite';
        }
        
        
        
        return helperclass;
    }    

    renderedCallback() {
        //  show values
        //console.log('SepClickableColorCell cellcontent: ',this.cellcontent);
        //console.log('SepClickableColorCell cellquestionid: ',this.cellquestionid);
        //console.log('SepClickableColorCell cellselected: ',this.cellselected);
    }
    clickHandler(){
        // If already selected answer cell is clicked again than deselect the answer
        let selCellColumn = this.cellcolumn.col;
        if(this.cellselected == selCellColumn) {
            this.cellselected = selCellColumn = undefined;
        }

        //check if we have content. If not just return so that no click event will be thrown
        if (this.cellcontent === undefined ) {
            console.info(this.logPrefix,'undefined');
            return;
        }

        const cellclickedEvent = new CustomEvent('cellclicked', { detail: { column: selCellColumn, questionid: this.cellquestionid , questionanswerid: this.cellquestionanswerid}, bubbles: true, composed: true });
        // Dispatches the event.
        this.dispatchEvent(cellclickedEvent);
    }

}