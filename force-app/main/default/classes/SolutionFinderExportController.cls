public with sharing class SolutionFinderExportController {

    public String namespace {get;set;}
    public String name {get;set;}
    public SolutionFinderContext context {get;set;}
    public SolutionFinderTree tree {get;set;}
    public List<SolutionFinderOption> history {get;set;}

    public SolutionFinderExportController() {
        this.namespace = ApexPages.currentPage().getParameters().get('namespace');
        this.name = ApexPages.currentPage().getParameters().get('name');
        this.init();
    }

    private void init() {
        this.applySecurity();
        this.initProperties();
    }

    private void applySecurity() {
        this.namespace = String.escapeSingleQuotes(this.namespace);
        this.name = String.escapeSingleQuotes(this.name);
    }

    private void initProperties() {
        this.context = SolutionFinderContext.getContext(this.namespace, this.name, null);
        this.tree = SolutionFinderTree.getTree(this.name);
        this.initHistory();
    }

    private void initHistory() {
        this.history = new List<SolutionFinderOption>();
        for (Integer i = 0; i < this.context.history.size() - 1; i++) {
            this.history.add(this.context.history[i]);
        }
    }
}