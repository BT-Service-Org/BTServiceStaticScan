import { LightningElement, api } from 'lwc';
import saveOption from '@salesforce/apex/SolutionFinderOption.saveOption';

export default class SolutionFinderOptionForm extends LightningElement {
    @api settings;
    @api parent;
    @api optionToEdit;
    title;
    name;
    description;
    nextQuestion;
    nextQuestionHelpText;
    feedbackSlackChannel;
    feedbackEmail;
    isLoaded = false;

    connectedCallback() {
        if (this.optionToEdit != null) {
            this.parent = {
                namespace: this.optionToEdit.parentNamespace,
                name: this.optionToEdit.parentName
            };
            this.title = this.optionToEdit.title;
            this.name = this.optionToEdit.name;
            this.description = this.optionToEdit.description;
            this.nextQuestion = this.optionToEdit.nextQuestion;
            this.nextQuestionHelpText = this.optionToEdit.nextQuestionHelpText;
            this.feedbackSlackChannel = this.optionToEdit.feedbackSlackChannel;
            this.feedbackEmail = this.optionToEdit.feedbackEmail;
        }
    }

    renderedCallback() {
        if (!this.isLoaded) {
            let firstInput = this.template.querySelector('lightning-input');
            if (firstInput) {
                firstInput.focus();
            }
            this.isLoaded = true;
        }
    }

    handleCancel() {
        this.closeWindow();
    }

    handleTitleChange(event) {
        this.title = event.target.value;
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleNextQuestionChange(event) {
        this.nextQuestion = event.target.value;
    }

    handleNextQuestionHelpTextChange(event) {
        this.nextQuestionHelpText = event.target.value;
    }

    handleFeedbackSlackChannelChange(event) {
        this.feedbackSlackChannel = event.target.value;
    }

    handleFeedbackEmailChange(event) {
        this.feedbackEmail = event.target.value;
    }

    handleSave() {
        saveOption({
            namespace: this.settings.namespace,
            name: this.name,
            parentNamespace: this.parent.namespace,
            parentName: this.parent.name,
            title: this.title,
            description: this.description,
            nextQuestion: this.nextQuestion,
            nextQuestionHelpText: this.nextQuestionHelpText,
            feedbackSlackChannel: this.feedbackSlackChannel,
            feedbackEmail: this.feedbackEmail
        })
            .then(data => {
                this.waitForSave(data);
            })
            .catch(error => {
                console.log("Error saving option: " + JSON.stringify(error));
            })
    }

    waitForSave(jobId) {
        this.dispatchEvent(new CustomEvent("submit"));
    }
}