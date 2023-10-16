public with sharing class MetadataRequest {

    private String objectName;
    private String recordName;
    private String recordLabel;
    private Map<String, Object> properties;

    Metadata.DeployContainer deployContainer;

    public MetadataRequest() {
        this.properties = new Map<String, Object>();
        this.deployContainer = new Metadata.DeployContainer();
    }

    public void init(String objectName, String recordName, String recordLabel) {
        this.objectName = objectName;
        this.recordName = recordName;
        this.recordLabel = recordLabel;
        this.properties = new Map<String, Object>();
    }

    public void setObjectName(String objectName) {
        this.objectName = objectName;
    }

    public void setRecordName(String recordName) {
        this.recordName = recordName;
    }

    public void setRecordLabel(String recordLabel) {
        this.recordLabel = recordLabel;
    }

    public void addProperty(String fieldName, Object value) {
        this.properties.put(fieldName, value);
    }

    public void stage() {

        System.debug('staging: ' + this.deployContainer.getMetadata().size());

        if (this.objectName == null) {
            throw new MetadataException(MetadataException.OBJECT_NAME_MISSING);
        } else if (this.recordName == null) {
            throw new MetadataException(MetadataException.RECORD_NAME_MISSING);
        } else if (this.recordLabel == null) {
            throw new MetadataException(MetadataException.RECORD_LABEL_MISSING);
        }

        Metadata.CustomMetadata metadataRecord = new Metadata.CustomMetadata();
        metadataRecord.fullName = this.objectName + '.' + this.recordName;
        metadataRecord.label = this.recordLabel;

        for (String fieldName : this.properties.keySet()) {
            Metadata.CustomMetadataValue metadataField = new Metadata.CustomMetadataValue();
            metadataField.field = fieldName;
            metadataField.value = this.properties.get(fieldName);
            metadataRecord.values.add(metadataField);
        }

        this.deployContainer.addMetadata(metadataRecord);
    }

    public Id execute() {

        System.debug('Executing: ' + this.deployContainer.getMetadata().size());
        for (Integer i = 0; i < this.deployContainer.getMetadata().size(); i++) {
            System.debug(this.deployContainer.getMetadata()[i]);
        }

        if (this.deployContainer.getMetadata().size() == 0) {
            this.stage();
        }

        Id deployRequestId;
        if (!Test.isRunningTest()) {
            deployRequestId = Metadata.Operations.enqueueDeployment(this.deployContainer, new MetadataResponse());
        }
        return deployRequestId;
    }
}