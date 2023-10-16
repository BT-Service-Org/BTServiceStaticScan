import { LightningElement, api, track } from 'lwc';

const INDENT_SIZE = 20.0;
const STATE_VIEW = "view";
const STATE_EDIT = "edit";
const NO_ACCESS = 'No Access';

export default class SolutionFinderAssignment extends LightningElement {
    @api item;
    @api assignments;
    @api parentRole;
    @api selectedRole;

    @api indent = 0;

    @track state = STATE_VIEW;

    get children() {
        return this.item && this.item.items ? this.item.items : [];
    }

    get style() {
        let totalIndent = Number(INDENT_SIZE) * Number(this.indent);
        var style = "padding-left: " + totalIndent + "px;";
        if (this.role == NO_ACCESS) {
            style += "color: #eb001e;";
        }
        return style;
    }

    get inheritedClass() {
        return this.role === this.parentRole ? "slds-text-color_inverse-weak" : ""
    }

    get roleClass() {
        return this.role === NO_ACCESS ? "slds-text-color_error" : this.inheritedClass;
    }

    get inheritedRole() {
        return this.parentRole ? this.parentRole : NO_ACCESS;
    }

    get role() {
        return this.assignments && this.assignments[this.item.name] ? this.assignments[this.item.name].role : this.inheritedRole;
    }

    get displayViewRole() {
        return this.state === STATE_VIEW;
    }

    get displayEditRole() {
        return this.state === STATE_EDIT;
    }

    get nextIndent() {
        return Number(this.indent) + 1;
    }

    get roleOptions() {
        return [
            { label: 'User', value: 'User' },
            { label: 'Contributor', value: 'Contributor' },
            { label: 'Administrator', value: 'Administrator' },
            { label: '- No Access -', value: 'No Access' }
        ]
    }

    handleRoleClick() {
        this.state = STATE_EDIT;
    }

    handleCancelEdit() {
        this.state = STATE_VIEW;
    }

    handleRoleSelected(event) {
        this.dispatchEvent(new CustomEvent('change', { detail: { item: this.item, role: event.detail.value }}));
        this.state = STATE_VIEW;
    }

    handleRoleChange(event) {
        this.dispatchEvent(new CustomEvent('change', { detail: event.detail }));
    }
}