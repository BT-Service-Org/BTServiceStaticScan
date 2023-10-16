public with sharing class PSCConstants {
    public static final String CONTRACT_TYPE_ORDER_FORM = 'Order Form';
    public static final String CONTRACT_TYPE_SOW = 'SOW';
    public static final String CONTRACT_TYPE_BOTH_ORDER_N_SOW = 'Both Order Form & SOW';
    public static final List<String> PLAYBOOK_CONTRACT_TYPES = new List<String>{CONTRACT_TYPE_ORDER_FORM,CONTRACT_TYPE_SOW,CONTRACT_TYPE_BOTH_ORDER_N_SOW};
    public static final String SOW_PLAYBOOKS_TITLE = 'SOW Playbooks';
    public static final String STAGES_TITLE = 'Stages';
    public static final String PROJECT_ROLES_TITLE = 'Project Roles';
    public static final String PRODUCT_OFFERINGS_TITLE = 'Product Offerings';
    public static final String ORDER_FORM_PLAYBOOKS_TITLE = 'Order Form Playbooks';
    public static final String SOW_FORM_TITLE= 'Statement Of Work (SOW)';
    public static final String ORDER_FORM_TITLE = 'Order Forms';
    public static final String ALL_PLAYBOOKS_TITLE = 'All Playbooks';
    public static final String ALL_STAGES_TITLE = 'All Stages';
    public static final String ALL_PRODUCT_OFFERING_TITLE = 'All Product Offerings';
    public static final String ALL_PROJECT_ROLES_TITLE = 'All Project Roles';
    public static final String CONTRIBUTE_INDUSTRY_LABEL = 'Applicable Industry(s)';
    public static final String CONTRIBUTE_PRODUCT_LABEL = 'Applicable Product(s)';
    public static final String CONTRIBUTE_AUDIENCE_LABEL = 'Target Audience(s)';
    public static final String PRODUCT_CUSTOM_SOBJECT = 'Product_Custom__c';
    public static final String PRODUCT_RECORDTYPE = 'Product';
    public static final String KNOWLEDGE_SOBJECT = 'Knowledge__kav';
    public static final String PSC_KNOWLEDGE_RECORDTYPE = 'PSC_Knowledge';
    public static final String TOTAL_USERS = 'Total Users';
    public static final String USERS_FROM_CENTRAL_SERVICES_BASE = 'Users From Professional Services';
    public static final String USERS_OPTED_FOR_METHODOLOGY = 'Total Methodology Opt-Ins';
    public static final String TOTAL_PUBLISHED_ARTICLES = 'Total Published Articles';
    public static final String TOTAL_DRAFT_ARTICLES = 'Total Draft Articles';
    public static final String ARTICLES_UPVOTES = 'Article Upvotes';
    public static final String ARTICLES_DOWNVOTES = 'Article Downvotes';
    public static final String ARTICLES_FEEDBACK = 'Article Feedback';
    public static final String PUBISHED_ARTICLES_GO_LIVE = 'Total Published After Go-Live';
    
    // this variable is used to rename asset types in contribute functionality
    public static final Map<String, String> PSC_CONTRIBUTE_ASSET_TYPE_LABEL_MAP = new Map<String, String>{
        'Project Deliverables - Discover' => 'Discover',
        'Project Deliverables - Define' => 'Define',
        'Project Deliverables - Design' => 'Design',
        'Project Deliverables - Deploy/ Close' => 'Deploy',
        'Project Deliverables - Deliver' => 'Deliver',
        'Project Deliverables - Pre-Sales' => 'Pre-Sales'
    };

    // this variable is used to rename resource type in contribute functionality
    public static final Map<String, String> PSC_CONTRIBUTE_RESOURCE_TYPE_LABEL_MAP = new Map<String, String>{}; 
}