public with sharing class MetadataResponse implements Metadata.DeployCallback {

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {

        /**
         * Potential to react to the details of the job
         * Obviously not currently being used
         *
        Id jobId = context.getCallbackJobId();
         */

        Solution_Finder_Event__e event = new Solution_Finder_Event__e();
        EventBus.publish(event);

        /*
         * Potential to react to the result from the deployment
         * Obviously not currently being used
         * 
        if (result != null) {
            switch on (result.status) {
                when Succeeded {
                    // to do
                }
                when SucceededPartial {
                    // to do
                }
                when Failed {
                    // to do
                }
                when Canceled {
                    // to do
                }
                when Pending, InProgress, Canceling {
                    // to do
                }
            }
        }
        */
    }
}