import { LightningElement, api } from 'lwc';
import solutionFinderResources from '@salesforce/resourceUrl/SolutionFinderResources';

export default class SolutionFinderFeedbackForm extends LightningElement {
    @api settings;
    @api context;

    get slackIcon() {
        return solutionFinderResources + '/slack_icon.png';
    }

    get slackUrl() {
        return 'https://slack.com/app_redirect?channel=' + this.feedback.slackChannel;
    }

    typeValue = "Help";

    get typeOptions() {
        return [
            { label: "Help", value: "Help" },
            { label: "Solution is incorrect", value: "Solution is incorrect" },
            { label: "New solution recommendation", value: "New solution recommendation" }
        ]
    }

    get feedback() {
        var feedback = {};
        try {
            if (this.context && this.context.history && this.context.history.length > 0) {
                var selection;
                for (let i = 0; i < this.context.history.length; i++) {
                    selection = this.context.history[i];
                    if (selection.feedbackSlackChannel || selection.feedbackEmail) {
                        feedback.slackChannel = selection.feedbackSlackChannel;
                        feedback.email = selection.feedbackEmail;
                    }
                }
            }
        } catch (e) {
            console.log("Error obtaining feedback from context: " + e);
        }
        if (!feedback.slackChannel && !feedback.email) {
            feedback.slackChannel = this.settings.defaultFeedbackSlackChannel;
            feedback.email = this.settings.defaultFeedbackEmail;
        }
        return feedback;
    }

    handleTypeChange(event) {
        this.typeValue = event.detail.value;
    }

    handleSlackClick(event) {
        window.open(this.slackUrl);
    }

    handleEmailClick(event) {
        window.open("mailto:" + this.feedback.email);
    }

    handleSave() {
        alert('This feature is not production ready, yet.');
    }
}