/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This component is used for the desktop view for the GDC Team Page.
 ****************************/
import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'c/gdcmsResourceComponent';
import D3 from '@salesforce/resourceUrl/GDC_MS_D3Libs'; 
import DefaultImage from '@salesforce/resourceUrl/GDCMSDefaultImageNew';

export default class GdcmsTeamBuilderDesktopView extends LightningElement {
    @api orgMembers; 
    selectedMember;
    currentlyDisplayingToast = false;
    chart;
    d3Initialized = false;
    dataFlattened;
    isTrue = true;
    varUndefined = undefined;
    inputSearch;
    showChartSpinner = true;
    showSnackbarWindow = true;


    suggestions = [];
    showSuggestions=false;

    get isDesktopDevice() {
        if (FORM_FACTOR === "Large") {
            return true;
        }
        return false; 
    }

    handleSnackbarToggle(){
        this.showSnackbarWindow = !this.showSnackbarWindow;
    }

    handleChange(event) {
        this.inputSearch = event.target.value;
        if (this.inputSearch.length > 1) {
            let searchedMember = this.dataFlattened.filter(e => e.name.toLowerCase().startsWith(this.inputSearch.toLowerCase()));
            searchedMember.map(e => console.log(e.name));
            this.suggestions = searchedMember.map(e => ({name: e.name, id:e.id}));
            this.showSuggestions=true;
        }
        else{
            this.suggestions = [];
            this.showSuggestions=false;
        }
    }

    handleSelectedMemberChange(event){
        console.log(event.detail);
        this.handleSelectedMember(event.detail);
    }

    @api handleSelectedMember(eId){
        let searchedMemberId = eId;
        this.chart.clearHighlighting();
        this.chart.collapseAll();
        this.chart.setUpToTheRootHighlighted(searchedMemberId).render();
        this.chart.setCentered(searchedMemberId).initialZoom(.7).render();
        this.handleNodeClick(searchedMemberId);
        this.showSuggestions=false;
    } 
    
    handleZoomIn() {
        this.chart.zoomIn();
    }
    handleZoomOut() {
        this.chart.zoomOut();
    }

    

    renderedCallback(){
        if (this.d3Initialized) {
            return;
        }
        this.d3Initialized = true;
        loadScript(D3 + '/d3.js')
        .then(() => {
            Promise.all([loadScript(D3 + '/d3flextree.js'), loadScript(D3 + '/d3orgchart.js')])
            .then(() => {
                console.log(this.orgMembers);
                this.dataFlattened = JSON.parse(JSON.stringify(this.orgMembers));
                this.showChartSpinner = false;
                this.initializeD3OrgChart();
    
             }).catch((error) => {
               this.handleCatch(error);
             })

         }).catch((error) => {
            this.handleCatch(error);
         })
         
       
    }

     

    handleCatch(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading D3',
                message: error.message,
                variant: 'error'
            })
        );
    }

    handleReset() {
        this.chart.clearHighlighting();
        this.chart.compact(true);
        this.chart.collapseAll();
        this.template.querySelector('div.chart-container').innerHTML = '';
        let snackbar = this.template.querySelector('c-gdcms-snackbar');
        if (snackbar)
            snackbar.handleClose();

        setTimeout(() => this.initializeD3OrgChart(), 100);
    }

    handleNodeClick(t) {
        if(!this.showSnackbarWindow)
            return;

        this.selectedMember = this.dataFlattened.filter(mem => t === mem.id)[0];
        let updatedMember = {
            'imageUrl': this.selectedMember.imageUrl,
            'Name': this.selectedMember.name,
            'positionName': this.selectedMember.positionName,
            'Id': this.selectedMember.id
        }
        
        setTimeout(() => this.template.querySelector('c-gdcms-team-member-quick-details-modal').showSnackbar(updatedMember), 100);
    }

    initializeD3OrgChart() {
        try {
            this.chart = new d3.OrgChart()
                .container(this.template.querySelector('div.chart-container'))
                .data(this.dataFlattened)
                .nodeWidth(d => 350)
                .initialZoom(.7)
                .nodeHeight(d => 200)
                .childrenMargin(d => 60)
                .compactMarginBetween(d => 40)
                .compactMarginPair(d => 60)
                .onNodeClick(d => this.handleNodeClick(d))
                .linkUpdate(function (d, i, arr) {
                    d3.select(this)
                        .attr('stroke', d =>
                            d.data._upToTheRootHighlighted ? '#00000080' : '#00000080'
                        )
                        .attr('stroke-width', d =>
                            d.data._upToTheRootHighlighted ? 2 : 1
                        );

                    if (d.data._upToTheRootHighlighted) {
                        d3.select(this).raise();
                    }
                })
                .nodeContent((d, i, arr, state) => this.createNodeContent(d, state))
                .nodeUpdate(
                    function (d, i, arr) {

                        d3.select(this)
                            .select('.node-rect')
                            .attr('height', (d) => (d.data._highlighted || d.data._upToTheRootHighlighted) ? 150 : 180)
                            .attr('y', (d) => (d.data._highlighted || d.data._upToTheRootHighlighted) ? 29 : 0)
                            .attr('stroke', d =>
                                d.data._upToTheRootHighlighted ? '#00000080' : ''
                            )
                            .attr('stroke-width', d =>
                                d.data._upToTheRootHighlighted ? 2 : 1
                            );
                    })
                .compact(true).layout("left").render()
        }
        catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error rendering org chart',
                    message: error.message,
                    variant: 'error'
                })
            );
        }
    }

    createNodeContent(d, state) {
        let nodes;
        let imgStr;
        if(d.data.imageUrl === DefaultImage){
                imgStr = `
                <img src=" ${d.data.imageUrl
                }" style="margin-top:-50px;margin-left:${d.width / 2 - 40}px;height:100px;"   />
                `;
        }
        else{
            imgStr = `
            <img src=" ${d.data.imageUrl
                }" style="margin-top:-50px;margin-left:${d.width / 2 - 50}px;border-radius:100px;width:100px;height:100px;"   />
                `;
        }
        nodes = `<div > 
            <div style="padding-top:30px;background-color:none;margin-left:1px;height:${d.height
                }px;border-radius:2px;overflow:visible"  >
            <div style="height:${d.height -
                32}px;padding-top:0px;background-color:#032e61;">

                ${imgStr}
            
            
            <div style="margin-top:-45px;background-color:#032e61;height:10px;width:100%;border-radius:1px" ></div>

            <div style="padding:40px 15px 12px 15px;text-align:center" >
                <div style="color:#FFFFFF;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-family: 'ITCAvantGarde';font-style: normal;font-weight: 600;font-size: 22px;line-height: 24px;"  > ${d.data.name
                } </div>
                <div style="color:#FFFFFF;margin-top:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis; font-family: 'ITCAvantGarde';font-style: normal;font-weight: 600;font-size: 11px;line-height: 19px;"> ${d.data.positionName
                } </div>
            </div> 
            <div style=" color:#FFFFFF;display:flex;justify-content:space-between;padding-left:15px;padding-right:15px;padding-top: 22px;font-family: 'ITCAvantGarde';font-style: normal;font-weight: 600;font-size: 11px;line-height: 19px;">`;
            if (d.data._totalSubordinates) {
                nodes += `<div  > Manages:  ${d.data._directSubordinates} </div>  <div  > Oversees: ${d.data._totalSubordinates} </div>    `
            }
            nodes += `</div> </div>  </div></div>`
        return nodes;
    }

    handleClose() {
        this.selectedMember = undefined;
    }
}