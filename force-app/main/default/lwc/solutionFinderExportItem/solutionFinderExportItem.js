import { LightningElement, api } from 'lwc';

export default class SolutionFinderExportItem extends LightningElement {
    @api item;
    @api indent = 0;
    INDENT_SIZE = 20;

    get style() {
        return "padding-left: " + (this.indent * this.INDENT_SIZE) + "px;";
    }

    get nextIndent() {
        return this.indent + 1;
    }
}