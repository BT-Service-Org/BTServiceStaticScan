public with sharing class PSCMethodologyDefaultCtrl {
    @AuraEnabled
    public static Object getMethodologyFormData() {
        Map<String, Object> inputs = new Map<String, Object>();
        Flow.Interview.PSCAssignMethodologyPersmissionSet flow1 = new Flow.Interview.PSCAssignMethodologyPersmissionSet(inputs);
        flow1.start();
        return flow1.getVariableValue('success_var');
    }
}