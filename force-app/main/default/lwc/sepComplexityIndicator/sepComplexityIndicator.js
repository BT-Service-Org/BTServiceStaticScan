import { LightningElement, api, track } from 'lwc';

const complexityMap = [
    {value :1, label: 'Very Low'},
    {value :2, label: 'Low'},
    {value :3, label: 'Medium'},
    {value :4, label: 'High'},
    {value :5, label: 'Very High'}
]
export default class SepComplexityIndicator extends LightningElement {
    @api value;
    setIndValue;
    
    constructor(){
        super();
    }

    get visibility() {
        if(this.value === undefined) return false;
        else return true;
    }

    get indicatorValue() {
        this.setIndValue = this.getIndicatiorVal();
        const comp = complexityMap.filter(ele => ele.value == this.setIndValue);
        return comp[0]?.value;
    }

    get complexityLabel(){
        this.setIndValue = this.getIndicatiorVal();
        const comp = complexityMap.filter(ele => ele.value == this.setIndValue);
        return comp[0]?.label;
    }

    getIndicatiorVal() {
        if(this.value !== undefined || this.value !== null) {
            if(typeof(this.value) === 'number') { var complexVal = Math.ceil(this.value); }

            if(complexVal >= 0 && complexVal <= 15) return 1;
            else if(complexVal >= 16 && complexVal <= 40) return 2;
            else if(complexVal >= 41 && complexVal <= 60) return 3;
            else if(complexVal >= 61 && complexVal <= 85) return 4;
            else if(complexVal >= 86 && complexVal <= 100) return 5;
        }else return undefined;
    }
}