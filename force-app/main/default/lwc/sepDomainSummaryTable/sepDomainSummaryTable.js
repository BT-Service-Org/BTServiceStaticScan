import LightningDatatable from 'lightning/datatable';

import capabilityComplexityIndicatorTable from './capabilityComplexityIndicatorTable.html';


export default class SepDomainSummaryTable extends LightningDatatable {
    static customTypes = {
        
        capabilityComplexityIndicatorTable: {
            template: capabilityComplexityIndicatorTable,
            standardCellLayout: false,
            typeAttributes: ['complexityValue'],
        }
    };

}