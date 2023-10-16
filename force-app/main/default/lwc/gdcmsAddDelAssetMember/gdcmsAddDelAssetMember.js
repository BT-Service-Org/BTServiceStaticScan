import { LightningElement, api, track } from 'lwc';

const columns = [
	{ label: 'Role', fieldName: 'gdc_ms_Role__c' },
	{ label: 'Team Member', fieldName: 'gdc_ms_TeamMemberName' },
];

export default class GdcmsAddDelAssetMember extends LightningElement {
	@api reusableAssetId;
	@api isReadOnly;
	staticMemberList;
	@track memberList = [];
	@api itemList


	keyIndex = 0;
	role;
	teamMember;
	columns = columns;
	isContentNotLoaded = true;

	addRow() {
		++this.keyIndex;
		var newItem = [{
			"Id": this.keyIndex + '',
			"gdc_ms_ReusableAsset__c": this.reusableAssetId,
			"gdc_ms_TeamMember__c": null,
			"gdc_ms_Role__c": null
		}];

		this.memberList = this.memberList.concat(newItem);
		//reset var
		this.teamMember = null;
		this.role = null;
	}

	removeRow(event) {
		let isConfirmedDelete = confirm("Are you sure you want to delete this asset member!!");
		if(isConfirmedDelete){
		        this.memberList = this.memberList.filter(function (element) {
			    return element.Id !== event.target.accessKey;
		    });
		}
	}

	handleRole(event) {
		this.role = event.target.value;
		let foundelement = this.memberList.find(ele => ele.Id === event.target.dataset.id);
		foundelement["gdc_ms_Role__c"] = this.role;
		this.memberList = [...this.memberList];
	}
	handleTeamMember(event) {
		this.teamMember = event.target.value;
		let foundelement = this.memberList.find(ele => ele.Id == event.target.dataset.id);
		foundelement.gdc_ms_TeamMember__c = event.target.value;
		this.memberList = [...this.memberList];
	}

	@api passMembersListToParent() {
    	const addMemberEvent = new CustomEvent('addmembers',{detail:this.memberList});
		this.dispatchEvent(addMemberEvent);
    }

	connectedCallback() {
		if (this.isReadOnly && this.itemList != undefined && this.itemList != null) {
			let preparedArr = [];
			this.itemList.forEach(record => {
				let preparedRec = {};
				preparedRec.Id = record.Id;
				preparedRec.gdc_ms_Role__c = record.gdc_ms_Role__c;
				preparedRec.gdc_ms_TeamMemberName = record.gdc_ms_TeamMember__r.Name;
				preparedArr.push(preparedRec);
			});
			this.staticMemberList = preparedArr;
		} else if (!this.isReadOnly) {
            if(this.itemList != undefined && this.itemList != null){
                this.memberList = JSON.parse(JSON.stringify(this.itemList));
                if (this.isReadOnly == undefined) {
                    this.isReadOnly = false;
                }
            }else{
                this.addRow();
            }
		}
		this.isContentNotLoaded = false;
	}

	get isMembersAvailable_ReadOnly(){
		return this.isReadOnly && this.staticMemberList?.length > 0 ? true : false;
	}

	get isMembersAvailable_EditOnly(){
		return !this.isReadOnly && this.memberList?.length > 0 ? true : false;
	}
}