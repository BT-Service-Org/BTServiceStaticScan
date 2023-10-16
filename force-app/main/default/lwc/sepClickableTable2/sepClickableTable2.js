import LightningDatatable from 'lightning/datatable';

import sepClickableTable2ColorCell from './sepClickableTable2ColorCell.html';


export default class SepClickableTable2 extends LightningDatatable {
    static customTypes = {
        
        clickablecolorcell: {
            template: sepClickableTable2ColorCell,
            standardCellLayout: false,
            typeAttributes: ['cellcontent','cellselected','cellcolumn','cellquestionid', 'cellquestionanswerid'],
        }
    };

}