import { LightningElement, api, track } from 'lwc';
import getLearningResourceData from '@salesforce/apex/PSCSkillsRatingCtrl.getLearningResourceData';

export default class PscSkillSlider extends LightningElement {
    @api skillList = [];
    @track skillsData = [];
    @api groupName;
    @track learningResources = [];
    skillName = '';
    showSpinner = true;

    @api minValue = 0;
    @api maxValue = 5;
    range;
    value = 50;
    showResources = true;
    @api label;

    connectedCallback() {
        this.range = this.maxValue - this.minValue;
        this.paintLevels();
    }

    paintLevels() {
        this.skillList.map(skill => {
            this.skillsData.push(
                {
                    ...skill,
                    curPos: 'left: 0%; width: ' + ((skill.curLevel - this.minValue) / this.range) * 100 + '%',
                    tgtPos: 'left: 0%; width: ' + ((skill.tgtLevel - this.minValue) / this.range) * 100 + '%',
                    curlevelFill: `width:${(skill.curLevel / 5) * 100}%`,
                    curtargetFill: skill.tgtLevel > skill.curLevel ? `width:${((skill.tgtLevel - skill.curLevel) / 5) * 100}%` : 'width:0%',
                    showTarget: skill.curLevel < skill.tgtLevel,
                    totalBarFill: skill.tgtLevel < 5 ? `width:${(skill.tgtLevel / 5) * 100}%` : '60%',
                    entered: skill.curLevel > 0
                }
            );
        });
    }

    showModal(event) {
        const skillId = event.target.dataset.id
        getLearningResourceData({ skillId: skillId }).then(result => {
            if (result.length) {
                this.skillName = result[0].Name;
                this.learningResources = result[0].Learning_Resources_Skills__r;
                this.showResources = this.learningResources && this.learningResources.length ? true :false
                this.showSpinner=false;
            } 

        }).catch((err) => {
            this.showResources = false;

        })
        const modal = this.template.querySelector('c-psc-modal');
        modal.show();
    }
}