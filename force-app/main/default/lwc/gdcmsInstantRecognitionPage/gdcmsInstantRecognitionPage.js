import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getwofData from "@salesforce/apex/GDC_MS_DisplayWallOfFame.getWallOfFameRecords";
import sampleImg from "@salesforce/resourceUrl/GDC_MS_WallofFameImage";
import patOnBack from "@salesforce/label/c.gdcms_Pat_On_Back";

export default class GdcmsInstantRecognitionPage extends NavigationMixin(
	LightningElement
) {
	renderedCallbackCAlled = false;
	defaultImage = sampleImg;
	totalButtons;
	patOnBack = patOnBack + "/embed?authuser=0";

	oneButton = true;
	twoButton = false;
	threeButton = false;
	currentButtonClick;

	diaplayWOF = false;

	@track buttonlst = [];

	@track lstData = [];
	@api AwardCategory;

	get isCustomerSuccess() {
		if (this.AwardCategory && this.AwardCategory == 'Customer Success Team Award') {
			return true;
		}
	}



	/*@wire(getwofData, {})
	getwofDataa({ error, data }) {
		if (data) {
			this.lstData = JSON.parse(JSON.stringify(data));

			console.log(JSON.stringify(this.lstData));
			// for (let i = 0; i < this.lstData.length; i++) {
			//   if (this.lstData[i].gdc_ms_TeamMember__r !== undefined) {
			//     if (this.lstData[i].gdc_ms_TeamMember__r?.gdc_ms_ProfilePhoto__c == null) {
			//       this.lstData[i].gdc_ms_TeamMember__r.gdc_ms_ProfilePhoto__c = this.defaultImage;
			//     }
			//   } else {
			//     console.log('Data -->> ' + this.lstData[i].gdc_ms_SuccessStories__r);
			//   }
			// }

			this.totalButtons =
				parseInt(Math.trunc(this.lstData.length / 4)) +
				parseInt(this.lstData.length % 4 > 0 ? 1 : 0);

			for (let i = 0; i < this.totalButtons; i++) {
				if (i === 0) {
					this.buttonlst.push({ name: "" + i, className: "active " + i });
				} else {
					this.buttonlst.push({ name: "" + i, className: "" + i });
				}
			}

			/* if (this.lstData.length > 4 && this.lstData.length < 9) {
			  this.twoButton = true;
			  this.oneButton = false;
			  this.threeButton = false;
			} else if (this.lstData.length > 9 && this.lstData.length < 13) {
			  this.twoButton = false;
			  this.oneButton = false;
			  this.threeButton = true;
			}
			console.log(this.lstData.length);
		} else if (error || data == null) {
			this.lstData = undefined;
		}
	}*/

	connectedCallback() {
		getwofData({ awardCategory : this.AwardCategory })
			.then(result => {
				console.log('connectedcallback' + JSON.stringify(result));
				let data = result;
				let finalData = [];
				if (data) {
					for (let index = 0; index < data.length; index++) {
						const element = data[index];
						let walloffame = {};
						if (element !== undefined) {
							if (element.gdc_ms_Nominee__r !== undefined) {
								walloffame.gdc_ms_ProfilePhoto__c = this.defaultImage;
								if (element.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c != null) {
									walloffame.gdc_ms_ProfilePhoto__c = element.gdc_ms_Nominee__r.gdc_ms_ProfilePhoto__c;
								}

								if (element.gdc_ms_Nominee__r.Name != null) {
									walloffame.Name = element.gdc_ms_Nominee__r.Name;
								}

								if (element.gdc_ms_Nominee__r.gdc_ms_Designation__c != null) {
									walloffame.gdc_ms_Designation__c = element.gdc_ms_Nominee__r.gdc_ms_Designation__c;
								}
								walloffame.gdc_ms_AwardCategory__c = element.gdc_ms_AwardCategory__c;
								finalData.push(walloffame);
							} else if (element.gdc_ms_SuccessTeamName__r !== undefined) {
								walloffame.gdc_ms_ProfilePhoto__c = this.defaultImage;
								if (element.gdc_ms_SuccessTeamName__r.Name != null) {
									walloffame.Name = element.gdc_ms_SuccessTeamName__r.Name;
								}
								// if (element.gdc_ms_SuccessStories__r.gdc_ms_EngagementTitle__c != null) {
								// 	walloffame.gdc_ms_Designation__c = element.gdc_ms_SuccessStories__r.gdc_ms_EngagementTitle__c;
								// }
								if (element.gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c != null) {
									walloffame.gdc_ms_ProfilePhoto__c = element.gdc_ms_SuccessTeamName__r.gdc_ms_CompanyLogo__c;
								}
								walloffame.gdc_ms_AwardCategory__c = element.gdc_ms_AwardCategory__c;
								finalData.push(walloffame);
							}
						}
					}
					this.lstData = [...finalData];
				}

				this.totalButtons =
					parseInt(Math.trunc(this.lstData.length / 4)) +
					parseInt(this.lstData.length % 4 > 0 ? 1 : 0);

				for (let i = 0; i < this.totalButtons; i++) {
					if (i === 0) {
						this.buttonlst.push({ name: "" + i, className: "active " + i });
					} else {
						this.buttonlst.push({ name: "" + i, className: "" + i });
					}
				}
			}).catch(error => {
				console.log('Error on callback :::: ' + error);
			});
	}

	/*  @wire(getwofData, {})
	lstData;  */

	onButtonClick(event) {
		let slideVal = -92;
		this.currentButtonClick = event.target.dataset.id;
		const slides = this.template.querySelector(".inner");
		for (let i = 0; i < this.totalButtons; i++) {
			if (this.buttonlst[i].name == this.currentButtonClick) {
				slides.style.transform =
					"translateX(" + slideVal * this.buttonlst[i].name + "em)";
				this.buttonlst[i].className = "active " + this.buttonlst[i].name;
			} else {
				this.buttonlst[i].className = "" + this.buttonlst[i].name;
			}
		}
	}

	navigate(event) {
		if (event.currentTarget.dataset.item === "wallOfFame") {
			const topDiv = this.template.querySelector('[data-id="wallOfFame"]');
			topDiv.scrollIntoView({
				behavior: "smooth",
				block: "center",
				inline: "nearest"
			});
		}
		if (event.currentTarget.dataset.item === "patOnBack") {
			const topDiv = this.template.querySelector('[data-id="patOnBack"]');
			topDiv.scrollIntoView({
				behavior: "smooth",
				block: "center",
				inline: "nearest"
			});
		}
	}

	handleClick(event) {
		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url: this.patOnBack
			}
		});
	}

	/* connectedCallback() {
	  let buttonsWrapper = this.template.querySelector(".map");
	  const slides = this.template.querySelector(".inner");
	} */
	/*
	renderedCallback() {
	  if (this.renderedCallbackCAlled) return;
	  let buttonsWrapper = this.template.querySelector(".map");
	  const slides = this.template.querySelector(".inner");

	  /*  if (buttonsWrapper != null) {
		buttonsWrapper.addEventListener("click", (e) => {
		  if (e.target.nodeName === "BUTTON") {
			Array.from(buttonsWrapper.children).forEach((item) =>
			  item.classList.remove("active")
			);

			if (e.target.classList.contains("first")) {
			  slides.style.transform = "translateX(0%)";
			  e.target.classList.add("active");
			} else if (e.target.classList.contains("second")) {
			  slides.style.transform = "translateX(-92em)";
			  e.target.classList.add("active");
			  this.renderedCallbackCAlled = true;
			} else if (e.target.classList.contains("third")) {
			  slides.style.transform = "translateX(-184em)";
			  e.target.classList.add("active");
			  this.renderedCallbackCAlled = true;
			}
		  }
		});
	  }
	} */
}