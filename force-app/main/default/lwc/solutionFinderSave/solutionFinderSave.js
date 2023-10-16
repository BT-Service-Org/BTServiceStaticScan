import { LightningElement, api, track } from 'lwc';

export default class SolutionFinderSave extends LightningElement {
    @api savedSolutions;
    groupedSolutions = {};

    connectedCallback() {
        this.groupSolutions();
    }

    groupSolutions() {
        var solutions = {};
        var solution;
        var optionName;
        var solutionName;
        var properties;
        for (let i = 0; i < this.savedSolutions.length; i++) {
            solution = this.savedSolutions[i];
            optionName = solution.option.name;
            solutionName = solution.solution;
            properties = solution.properties;
            if (!solutions[solutionName]) {
                solutions[solutionName] = {};
            }
            if (!solutions[solutionName][optionName]) {
                solutions[solutionName][optionName] = [];
            }
            solutions[solutionName][optionName].push(properties);
        }
        this.groupedSolutions = solutions;
    }

    get items() {
        let items = [];
        var optionRecords;
        var configurationRecords;
        for (const [solution, options] of Object.entries(this.groupedSolutions)) {
            optionRecords = [];
            for (const [option, configurations] of Object.entries(options)) {
                configurationRecords = [];
                for (let i = 0; i < configurations.length; i++) {
                    configurationRecords.push({ name: JSON.stringify(configurations[i]), label: JSON.stringify(configurations[i]), expanded: true });
                }
                optionRecords.push({ name: option, label: option, expanded: true, items: configurationRecords });
            }
            items.push({ name: solution, label: solution, expanded: true, items: optionRecords });
        }
        return items;
    }
}