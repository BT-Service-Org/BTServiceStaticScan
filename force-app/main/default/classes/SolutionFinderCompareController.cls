public with sharing class SolutionFinderCompareController {
    
    private String namespace;
    private String name;
    public SolutionFinderComparison comparison {get;set;}

    public SolutionFinderCompareController() {
        this.namespace = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('namespace'));
        this.name = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('name'));
        this.init();
    }

    private void init() {
        this.comparison = new SolutionFinderComparison(this.namespace, this.name);
    }
}