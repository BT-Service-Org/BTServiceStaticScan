import { LightningElement, api, track } from 'lwc';

export default class GdcmsComboboxWithSearch extends LightningElement {

    // api variables 
    _options = [];
    @api selectedValue;
    @api label;
    @api minChar = 2;
    @api disabled = false;
    @api multiSelect = false;
    // track variables
    @track value;
    @track optionData;
    @track searchString;
    @track message;
    @track showDropdown = false;
    @api required = false;

    @api
    get options() {
        return this._options;
    }

    set options(items) {
        this.showDropdown = false;
        this._options = items;
        var optionData = this._options ? (JSON.parse(JSON.stringify(this._options))) : null;
        var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
        if (value) {
            var searchString;
            var count = 0;
            optionData.map(option => {
                if (this.multiSelect) {
                    if (value.includes(option.value)) {
                        option.selected = true;
                        count++;
                    }
                } else {
                    if (option.value == value) {
                        searchString = option.label;
                    }
                }
            });

            this.searchString = this.multiSelect ? count + ' Option(s) Selected' : searchString;

        }
        this.value = value;
        this.optionData = optionData;
    }

    handleKeyup(event) {
        this.searchString = event.target.value;
        if (this.searchString && this.searchString.length > 0) {
            this.message = '';
            if (this.searchString.length >= this.minChar) {
                var flag = true;
                this.optionData.map(option => {
                    if (option.label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        option.isVisible = true;
                        flag = false;
                    } else {
                        option.isVisible = false;
                    }
                });
                if (flag) {
                    this.message = "No results found for '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
    }

    handleSelect(event) {
        var selectedVal = event.currentTarget.dataset.id;
        if (selectedVal) {
            var count = 0;
            var options = JSON.parse(JSON.stringify(this.optionData));
            options.map(option => {
                if (option.value === selectedVal) {
                    if (this.multiSelect) {
                        if (this.value.includes(option.value)) {
                            this.value.splice(this.value.indexOf(option.value), 1);
                        } else {
                            this.value.push(option.value);
                        }
                        option.selected = option.selected ? false : true;
                    } else {
                        this.value = option.value;
                        this.searchString = option.label;
                    }
                }
                if (option.selected) {
                    count++;
                }
            });
            this.optionData = options;

            if (this.multiSelect) {
                this.searchString = count + ' Option(s) Selected';
                event.preventDefault();
            }
            else {
                this.showDropdown = false;
            }

        }
    }

    handleClick() {
        if (this.disabled == false && this._options) {
            this.message = '';
            this.searchString = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            options.map(option => {
                option.isVisible = true;
            });
            if (options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }

    handleRemove(event) {
        var value = event.currentTarget.name;
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        options.map(option => {
            if (option.value === value) {
                option.selected = false;
                this.value.splice(this.value.indexOf(option.value), 1);
            }
            if (option.selected) {
                count++;
            }
        });
        this.optionData = options;
        if (this.multiSelect)
            this.searchString = count + ' Option(s) Selected';

        this.publishSelect();
    }

    handleBlur() {
        var previousLabel;
        var count = 0;
        this.optionData.map(option => {
            if (option.value === this.value) {
                previousLabel = option.label;
            }
            if (option.selected) {
                count++;
            }
        });
        this.searchString = this.multiSelect ? count + ' Option(s) Selected' : previousLabel;

        this.showDropdown = false;
        this.publishSelect();
    }

    publishSelect() {
        if (this.value) {
            this.dispatchEvent(new CustomEvent('select', {
                detail: {
                    'value': this.value
                }
            }));
        }
    }

    @api
    handleRemoveAll() {
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        options.map(option => {
                option.selected = false;
                this.value.splice(this.value.indexOf(option.value), 1);
        });
        this.optionData = options;
        if(this.multiSelect)
            this.searchString = count + ' Option(s) Selected';
        this.publishSelect();
    }
}