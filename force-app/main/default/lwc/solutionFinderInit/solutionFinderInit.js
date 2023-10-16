import { LightningElement } from 'lwc';

export default class SolutionFinderInit extends LightningElement {
    settings = {
        namespace: null,
        parentNamespace: null,
        parentName: null,
        feedbackSlackChannel: null,
        feedbackEmail: null
    };

    handleNamespaceChange(event) {
        this.settings.namespace = event.target.value;
    }

    handleParentNamespaceChange(event) {
        this.settings.parentNamespace = event.target.value;
    }

    handleParentNameChange(event) {
        this.settings.parentName = event.target.value;
    }

    handleSlackChannelChange(event) {
        this.settings.feedbackSlackChannel = event.target.value;
    }

    handleEmailChange(event) {
        this.settings.feedbackEmail = event.target.value;
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent("save", { detail: this.settings }));
    }
}