/**
 * Custom metadata driven - versioning, deployable
 * Namespaced - delegated content management
 * Deep link ready
 * Translation ready
 * Selections tracked - AI-ready
 */

/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import getSettings from '@salesforce/apex/SolutionFinder.getSettings';
import saveSettings from '@salesforce/apex/SolutionFinderSettings.saveSettings';
import getContext from '@salesforce/apex/SolutionFinderContext.getContext';
import { subscribe } from 'lightning/empApi';
import { getTranslations } from './translationManager';

// Permissions
import hasCreateOption from '@salesforce/customPermission/Create_Solution_Finder_Option';
import hasEditOption from '@salesforce/customPermission/Edit_Solution_Finder_Option';
import hasEditSolution from '@salesforce/customPermission/Edit_Solution_Finder_Solution';
import hasCreateRecommendation from '@salesforce/customPermission/Create_Solution_Finder_Recommendation';
import hasDeleteRecommendation from '@salesforce/customPermission/Delete_Solution_Finder_Recommendation';

import saveConfiguration from '@salesforce/apex/SolutionFinderConfigurations.saveConfiguration';
import saveActivity from '@salesforce/apex/SolutionFinderActivity.saveActivity';

import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

const ROLE_USER = "User";
const ROLE_CONTRIBUTOR = "Contributor";
const ROLE_ADMINISTRATOR = "Administrator";

const CTIVITY_CONFIGURATION_SAVED = 'Configuration Saved';
const ACTIVITY_EXPORT_VIEWED = 'Export Viewed';
const ACTIVITY_OPTION_SELECTED = 'Option Selected';

export default class SolutionFinder extends NavigationMixin(LightningElement) {

    currentPageReference;
    urlParameters;

    @track project;
    @track savedSolutions = [];

    @track selectedOption = {
        namespace: null,
        name: null
    };
    @track settings = {};
    @track context = {};

    @track translatedQuestion;
    @track translatedOptions;

    @track permissionEditOption;

    @track visualization = "list";
    @track displayInit = false;
    @track displayOptionForm = false;
    @track displayFeedbackForm = false;
    @track displayExport = false;
    @track displayEditRecommendations = false;
    @track displayEditBuzzWords = false;
    @track displaySave = false;
    @track displayProjectSummary = false;
    @track optionToEdit;
    @track isLoading = false;
    translations;
    permissions = {};

    addOption = {
        id: "ADD_NEW",
        title: "Add New",
        description: "Create a new answer to the question above"
    };

    connectedCallback() {
        this.initSettings();
        //this.initPermissions();
        this.initTranslations();
        this.subscribeToPlatformEvents();
    }

    @wire(CurrentPageReference)
    currentPageReference;

    renderedCallback() {
        if (this.currentPageReference && this.currentPageReference.attributes && this.currentPageReference.attributes.attributes && this.currentPageReference.attributes.attributes.selectedOption) {
            let requestedOption = this.currentPageReference.attributes.attributes.selectedOption;
            if (requestedOption.name != this.selectedOption.name) {
                this.selectedOption = requestedOption;
                this.updateContext();
            }
        }
    }

    initSettings() {
        getSettings()
            .then(data => {
                this.settings = data;
                if (!this.settings.namespace) {
                    this.displayInit = true;
                } else {
                    this.selectedOption = {
                        namespace: this.settings.parentNamespace,
                        name: this.settings.parentName
                    };
                    this.updateContext();
                }
            })
            .catch(error => {
                console.log("Error getting settings: " + error);
            })
    }

    initTranslations() {
        this.translations = getTranslations();
    }

    updateContext() {
        getContext({ namespace: this.selectedOption.namespace, name: this.selectedOption.name, cacheBuster: new Date().getTime() })
            .then(data => {
                this.context = data;
                this.initPermissions();
                this.translateContext();
                this.isLoading = false;
            })
            .catch(error => {
                console.log("Error getting context: " + error);
                console.log("Error getting context: " + JSON.stringify(error));
                this.isLoading = false;
            })
    }

    translateContext() {
        this.translatedQuestion = this.translate(this.context);
        this.translateOptions();
    }

    translateOptions() {
        if (this.context && this.context.options) {
            let translatedOptions = [];
            var option;
            for (let i = 0; i < this.context.options.length; i++) {
                option = this.context.options[i];
                translatedOptions.push(this.translate(option));
            }
            this.translatedOptions = translatedOptions;
        }
    }

    translate(obj) {
        var answerTranslation = {};
        var questionTranslation = {};
        if (obj.answerLabel && this.translations[obj.answerLabel]) {
            answerTranslation = this.translations[obj.answerLabel];
        }
        if (obj.questionLabel && this.translations[obj.questionLabel]) {
            questionTranslation = this.translations[obj.questionLabel];
        }
        return {
            namespace: obj.namespace,
            name: obj.name,
            title: answerTranslation.title ? answerTranslation.title : obj.title,
            description: answerTranslation.description ? answerTranslation.description : obj.description,
            nextQuestion: questionTranslation.nextQuestion ? questionTranslation.nextQuestion : obj.nextQuestion,
            helpText: questionTranslation.helpText ? questionTranslation.helpText : obj.helpText
        };
    }

    initPermissions() {
        this.permissions = {
            createOption: this.context && this.context.role === ROLE_ADMINISTRATOR,
            editOption: this.context && this.context.role === ROLE_ADMINISTRATOR,
            editSolution: this.context && this.context.role === ROLE_ADMINISTRATOR,
            createRecommendation: this.context && (this.context.role === ROLE_ADMINISTRATOR || this.context.role === ROLE_CONTRIBUTOR),
            deleteRecommendation: this.context && this.context.role === ROLE_ADMINISTRATOR,
            createBuzzWord: this.context && (this.context.role === ROLE_ADMINISTRATOR || this.context.role === ROLE_CONTRIBUTOR),
            deleteBuzzWord: this.context && this.context.role === ROLE_ADMINISTRATOR
        };
        /*
        this.permissions = {
            createOption: hasCreateOption === true,
            editOption: hasEditOption === true,
            editSolution: hasEditSolution === true,
            createRecommendation: hasCreateRecommendation === true,
            deleteRecommendation: hasDeleteRecommendation === true
        };
        */
    }

    platformEventCallback(response) {
        if (!this.settings.namespace) {
            this.initSettings();
        } else {
            this.updateContext();
        }
    }

    subscribeToPlatformEvents() {
        subscribe('/event/Solution_Finder_Event__e', -1, this.platformEventCallback.bind(this))
            .then(response => {
                // no action necessary
            })
            .catch(error => {
                console.log("Error subscribing to platform events: " + error);
            })
    }

    get projectName() {
        return this.project ? this.project.name : "Select a Project";
    }

    get history() {
        let list = [];
        if (this.context && this.context.history) {
            list = this.context.history;
        }
        return list;
    }

    get displayWizard() {
        return (!this.displayInit &&
            !this.displayOptionForm &&
            !this.displayProjectSummary &&
            !this.displayFeedbackForm &&
            !this.displayExport &&
            !this.displayEditRecommendations &&
            !this.displayEditBuzzWords &&
            !this.displaySave);
    }

    get displayExportButton() {
        return this.selectedOption.name != null;
    }

    get displayContextualSidebar() {
        return this.selectedOption.name != null;
    }

    get currentQuestion() {
        let question = '';
        if (this.translatedQuestion && this.translatedQuestion.question) {
            question = this.translatedQuestion.question;
        } else if (this.context != null) {
            question = this.context.question;
        }
        return question;
    }

    get currentHelpText() {
        let helpText = '';
        if (this.translatedQuestion && this.translatedQuestion.helpText) {
            helpText = this.translatedQuestion.helpText;
        } else if (this.context != null) {
            helpText = this.context.helpText;
        }
        return helpText;
    }

    get options() {
        let options = [];
        if (this.translatedOptions != null) {
            options = this.translatedOptions;
        } else if (this.context != null) {
            options = this.context.options;
        }
        return options;
    }

    get recommendations() {
        let recommendations = '';
        if (this.context != null) {
            recommendations = this.context.recommendations;
        }
        return recommendations;
    }

    get buzzWords() {
        let buzzWords = '';
        if (this.context != null) {
            buzzWords = this.context.buzzWords;
        }
        return buzzWords;
    }

    get saveButtonVariant() {
        return this.savedSolutions.length > 0 ? "brand" : "";
    }

    get saveButtonDisabled() {
        return this.savedSolutions.length === 0;
    }

    get backButtonDisabled() {
        return (this.history.length === 0);
    }

    get showEditButtons() {
        return (this.history.length > 0);
    }

    get showEditOptionButton() {
        return this.permissions.editOption && this.showEditButtons;
    }

    get showEditRecommendationsButton() {
        return this.permissions.createRecommendation && this.showEditButtons;
    }

    get showEditBuzzWordsButton() {
        return this.permissions.createBuzzWord && this.showEditButtons;
    }

    get previousSelection() {
        let previousSelection = "";
        if (this.previousSelectedOption != null) {
            previousSelection = this.previousSelectedOption.title;
        }
        return previousSelection;
    }

    get previousSelectedOption() {
        let option;
        if (this.history.length > 0) {
            option = this.history[this.history.length - 1];
        }
        return option;
    }

    get exportUrl() {
        return "Export?namespace=" + this.selectedOption.namespace + "&name=" + this.selectedOption.name;
    }

    hideAllWindows() {
        this.displayInit = false;
        this.displayProjectSummary = false;
        this.displayOptionForm = false;
        this.displayFeedbackForm = false;
        this.displayExport = false;
        this.displayEditRecommendations = false;
        this.displayEditBuzzWords = false;
        this.displaySave = false;
    }

    handleGoBack() {
        if (this.history.length > 0) {
            let lastHistoryOption = this.history[this.history.length - 1];
            if (lastHistoryOption != null && lastHistoryOption.parentName != null) {
                this.selectedOption = {
                    namespace: lastHistoryOption.parentNamespace,
                    name: lastHistoryOption.parentName
                };
            } else {
                this.selectedOption = {};
            }
            this.updateContext();
        }
    }

    handleInitSave(event) {
        saveSettings(event.detail)
            .then(data => {
                this.displayInit = false;
            })
            .catch(error => {
                console.log("Error saving settings: " + error);
            })
    }

    handleEditClicked() {
        this.optionToEdit = this.previousSelectedOption;
        this.displayOptionForm = true;
    }

    handleOptionClicked(event) {
        let selectedOption = event.detail.option;
        this.recordOptionSelectedActivity(this.selectedOption.name, selectedOption.name);
        if (selectedOption != null) {

            /*
             * original version  - updated context - no deep linking available
             */
            this.selectedOption = {
                namespace: selectedOption.namespace,
                name: selectedOption.name
            };
            this.selectedOptionName = selectedOption.name;
            this.updateContext();

            /*
            * The following code opens the LWC with parameters
            * This works, but is not a good user experience.
            *
            var compDetails = {
                componentDef: "c:solutionFinder",
                attributes: {
                    selectedOption: {
                        namespace: selectedOption.namespace,
                        name: selectedOption.name
                    }
                }
            };
            var encodedCompDetails = btoa(JSON.stringify(compDetails));
            window.location.href = "/one/one.app#" + encodedCompDetails;
            */
        }
    }

    handleAddNewClicked() {
        this.optionToEdit = null;
        this.displayOptionForm = true;
    }

    handleFeedbackClick() {
        this.displayFeedbackForm = true;
    }

    handleExportClick(event) {
        /*
         * The following code opens the LWC
         *
        var compDetails = {
            componentDef: "c:solutionFinderExport",
            attributes: {
                optionName: this.selectedOptionName 
            }
        }
        var encodedCompDetails = btoa(JSON.stringify(compDetails));
        console.log("encoded: " + encodedCompDetails);
        window.open("/one/one.app#" + encodedCompDetails);
        */
       this.recordExportViewedActivity(this.selectedOption.name);

       let exportUrl = "/apex/SolutionFinderExport?namespace=" + this.selectedOption.namespace + "&name=" + this.selectedOption.name;
       window.open(exportUrl);
    }

    handleEditRecommendations() {
        this.displayEditRecommendations = true;
    }

    handleEditBuzzWords() {
        this.displayEditBuzzWords = true;
    }

    handleCancelClick() {
        this.hideAllWindows();
    }

    handleHistoryOptionClicked(event) {
        let selectedOption = event.detail.option;
        if (selectedOption.parentName == null) {
            this.selectedOption = {};
        } else {
            this.selectedOption = {
                namespace: selectedOption.parentNamespace,
                name: selectedOption.parentName
            };
        }
        this.updateContext();
    }

    handleVisualizationClicked(event) {
        let value = event.detail.visualization;
        this.visualization = value;
    }

    handleFormSubmit() {
        this.isLoading = true;
        this.hideAllWindows();
    }

    handleCloseAddNewForm() {
        this.displayOptionForm = false;
        //window.location.reload();
    }

    handleCreateRecommendation(event) {
        console.log('handing reco - coming soon');
    }

    handleLoading() {
        this.isLoading = true;
    }

    handleDoneLoading() {
        this.isLoading = false;
    }

    handleRecommendationsSave(event) {
        let solutions = event.detail;
        if (solutions && solutions.length > 0) {
            this.saveRecommendations(solutions);
            /*
            for (let i = 0; i < solutions.length; i++) {
                this.savedSolutions.push(solutions[i]);
            }
            */
            this.recordConfigurationSavedActivity(solutions[0].optionName, solutions[0].solutionName, solutions.length);
        }
        this.selectedOption = {
            namespace: null,
            name: null
        };
        this.updateContext();
    }

    saveRecommendations(solutions) {
        if (!this.project) {
            // TO BE UPDATED - Should present project selector/creator
            return;
        }
        for (let i = 0; i < solutions.length; i++) {
            saveConfiguration({ projectId: this.project.id,
                                optionName: solutions[i].optionName,
                                solutionName: solutions[i].solutionName,
                                properties: JSON.stringify(solutions[i].properties) })
                .then(results => {
                    // no action required
                })
                .catch(error => {
                    console.log("Error saving recommendation: " + JSON.stringify(error));
                })
        }
    }

    handleSaveClicked(event) {
        this.displaySave = true;
    }

    handleProjectSelected(event) {
        this.project = event.detail;
    }

    handleViewProjectClick() {
        this.displayProjectSummary = true;
    }

    handleProjectChangeClick(event) {
        this.project = null;
    }

    recordOptionSelectedActivity(parentOptionName, optionName) {
        saveActivity({ recordTypeName: ACTIVITY_OPTION_SELECTED, parentOptionName: parentOptionName, optionName: optionName })
            .then(results => {
                // no action required
            })
            .catch(error => {
                console.log("Error saving activity: " + e);
            })
    }

    recordExportViewedActivity(optionName) {
        saveActivity({ recordTypeName: ACTIVITY_EXPORT_VIEWED, optionName: optionName })
            .then(results => {
                // no action required
            })
            .catch(error => {
                console.log("Error saving activity: " + e);
            })
    }

    recordConfigurationSavedActivity(optionName, solutionName, quantity) {
        saveActivity({ recordTypeName: CTIVITY_CONFIGURATION_SAVED, optionName: optionName, solutionName: solutionName, quantity: quantity })
            .then(results => {
                // no action required
            })
            .catch(error => {
                console.log("Error saving activity: " + e);
            })
    }
}