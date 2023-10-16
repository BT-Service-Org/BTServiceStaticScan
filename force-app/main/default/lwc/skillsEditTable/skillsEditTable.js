import { LightningElement, track, wire} from 'lwc';
import SKILLS_bgImage from '@salesforce/resourceUrl/Skills360backgroundImage';
import loadDefaults from '@salesforce/apex/SkillsEntryController.loadParentDefaults';
import getGrps from '@salesforce/apex/SkillsEntryController.getCSGGrps';
    import UpdateSkillsLabel from '@salesforce/label/c.CSG_Update_Skills_Label';
import getFocusAreas from '@salesforce/apex/SkillsEntryController.getFocusAreas';
import SKILLS_LOGO from '@salesforce/resourceUrl/Skills360Logo';
import { NavigationMixin } from "lightning/navigation";
import skills360DashboardURL from '@salesforce/label/c.Skills360_Dashboard_URL';
import asphelptext from '@salesforce/label/c.Skills_Aspirational_Help_Text';
import focushelptext from '@salesforce/label/c.Skills_Focus_Help_Text';
import rolehelptext from '@salesforce/label/c.CSG_Role_HelpText';


import {loadStyle} from "lightning/platformResourceLoader";

export default class skillsComponent extends NavigationMixin(LightningElement) {
    label = {
        asphelptext,
        focushelptext,
        rolehelptext
        };
    userinfo = {};
    aspSkillStr ;
    focusStr;
    mgrName ;
    activeTab = 'MySkills';
    activesubTab = 'MyTeamSkills';
    showTriggerBatchButton = false;
    UpdateSkill = UpdateSkillsLabel;
    openfocusmodal = false;
    boardingrecid;
    skillslogo = SKILLS_LOGO;
    csggroupname;
    mySkillsView = true;
    teamView = false;
    findskillview = false;
    learningView = false;
    selectedgrp;
    isdashboardvisible = false;
    showTeamsTab = false;
    showDelegateTab = false;
    showTeamSkillsTab = false;
    showManagerTab = false;
    showTablecomp = true;
    @wire(getGrps) grps;
            
    async connectedCallback() {

        loadDefaults()
            .then(result => {
        
                this.userinfo = result.userinfo;
                console.log(this.userinfo+'userinfo');
                if(this.userinfo.Manager != null){
                this.mgrName = this.userinfo.Manager.Name;
                }
                this.focusStr = result.focusareaStr;
                this.showTriggerBatchButton = result.batchButtonEnabled; 
                this.boardingrecid = result.onboardingRecordId;
                this.isdashboardvisible = result.isManagerOrAdmin;
                console.log(this.boardingrecid +'manager'+result.isManager);
                if(result.isManager){
                    this.showTeamsTab = true;
                }
                if(result.isDelegate || result.isManager){
                    this.showTeamSkillsTab = true;
                }
                if(result.isDelegate){
                    this.showDelegateTab = true;
                }
                if(result.isDelegate === true && result.isManager === false){
                    this.activesubTab = 'DelegatedTeamSkills';
                }
                })
                .catch(error => {
                    this.error = error;
                });
                       
                
                    
                    }
    get backgroundStyle() {
        return `min-height: 390px;position: relative; background-position: center;background-size: cover;background-repeat: no-repeat;background-image:url(${SKILLS_bgImage})`;
    }
    get teamSkillbackgroundStyle() {
        return `min-height: 320px;position: relative; background-position: center;background-size: cover;background-repeat: no-repeat;background-image:url(${SKILLS_bgImage})`;
                    }

    handleSelect(event) {
        console.log(event.detail.name+'evt');
        console.dir(event.detail+''+this.template.querySelector('lightning-tree').items[0].label);
        this.selectedgrp = event.detail.name;
        this.template.querySelector('lightning-tree').items[0].expanded = false;
        this.template.querySelector('lightning-tree').items[0].label  = event.detail.name;
        this.template.querySelector('lightning-tree').items[0].name  = event.detail.name;

           
        console.dir(event.detail+''+this.template.querySelector('lightning-tree').items[0].label);
        this.template.querySelector("c-skills-table-component").handleCSGGrpChange(event.detail.name);
    }
    
    hanldeAspValueChange(event){
        this.aspSkillStr = event.detail;
        }
    hanldeChangeView(event){
        var paramVal = event.target.value;
        
        if((event.target.value == undefined || event.target.value == null) &&
           event.detail != null){
               paramVal = event.detail;
    }
        console.log(event.target.value+'In change event'+event.detail);
        this.activeTab = paramVal;
        if(this.activeTab == 'MySkills'){
            this.mySkillsView = true;
                }else{
            this.mySkillsView = false;
                }
        if(this.activeTab == 'TeamSkills'){
            this.teamView = true;
        }else{
            this.teamView = false;
    }
        if(this.activeTab == 'AllSkills'){
            this.findskillview = true;
        }else{
            this.findskillview = false;
        }
        
        if(this.activeTab == 'LearningResources'){
            this.learningView = true;
        }
        else{
             this.learningView = false;
        }
        this.hanldeChangeViewHandler(paramVal);
    }
    hanldeChangeViewHandler(paramVal){
        //hanldeChangeView(event){
        this.activeTab = paramVal;
        
        if(this.activeTab === 'LearningResources'){
            this.showTablecomp = false;
            this.activesubTab = '';
    
        }else{
            this.showTablecomp = true;
            
            if(this.showTeamsTab){
                this.activesubTab = 'MyTeamSkills';
                }
                else{
                    this.activesubTab = 'DelegatedTeamSkills';
            }
        }
        if(this.template.querySelector("c-skills-table-component") != null){

            if(this.activeTab == 'TeamSkills' && this.activesubTab){
                this.template.querySelector("c-skills-table-component").handleCSGGrpChange(this.activesubTab);
            }else if(this.activeTab == 'AllSkills'){
                this.template.querySelector("c-skills-table-component").handleCSGGrpChange(this.selectedgrp ? this.selectedgrp : 'All Skills' );

            }
            else{
                this.template.querySelector("c-skills-table-component").handleCSGGrpChange(paramVal);
        }
        }
    }
    hanldeSubtabChangeView(event){
        console.log(event.target.value+'In change event');
        this.activesubTab = event.target.value;

        if(this.template.querySelector("c-skills-table-component") != null){
            this.template.querySelector("c-skills-table-component").handleCSGGrpChange(event.target.value);
        }
    }


    updateSkillTaxonomyModal(event){
        this.template.querySelector("c-skills-table-component").updateSkillTaxonomyModal();
    }




    handleclick(event){
                 
        this.openfocusmodal = true;
  
            }
    handleModalClosed(){
        this.openfocusmodal = false;

        getFocusAreas()
                .then(result => {
                   
                    
                this.focusStr = result;
                this.template.querySelector("c-skills-table-component").handleCSGGrpChange(this.activeTab);
                
            })
            .catch(error => {
                this.error = error;
        }); 
                } 
    
    get findskillbackgroundStyle() {
        return `min-height: 320px;position: relative; background-position: center;background-size: cover;background-repeat: no-repeat;height: 270px;background-image:url(${SKILLS_bgImage})`;
    }

    get isAspBlank(){
        if(this.aspSkillStr == null || this.aspSkillStr == '' || this.aspSkillStr == undefined){
            return true;
        }else{
            return false;
        }
                }
                
    handleNavigate() {
        const config = {
            type: 'standard__webPage',
                attributes: {
                    url: skills360DashboardURL
    }	
        };
            this[NavigationMixin.Navigate](config);
    }
}