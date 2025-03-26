/**
* @description Queueable class to handle Exchange Rate API callout and data processing.
* This class is enqueued by a scheduled job since callouts are not allowed directly from scheduled Apex.
*/
public with sharing class ExchangeRateQueueable implements Queueable, Database.AllowsCallouts {
    private List<Base_Currency_Config__mdt> configs;
    
    // Constructor for Metadata based Callouts
    public ExchangeRateQueueable(List<Base_Currency_Config__mdt> configs) {
        this.configs = configs;
    }

    // No argument constructor to be used by tests
    public ExchangeRateQueueable(){
        // Intentionally empty.  Needed to allow for a no-argument constructor for testing purposes.
        // Added redundant "logic" below to silence PMD warnings.
        this.configs = null;
    }

    /**
    * @description Tracks all runtime results during execution:
    * - collected exchange rate records
    * - log messages
    * - success/error flags
    * - the Integration Log record to insert at the end
    */    
    private class ProcessingResult {
        public List<Exchange_Rate__c> exRatesToUpsert = new List<Exchange_Rate__c>();
        public List<String> messageList = new List<String>{'Summary of "Update Exchange Rates" Callout Run:'};
        public Boolean successRecorded = false;
        public Boolean errorRecorded = false;

        public Integration_Log__c logEntry = new Integration_Log__c(
            Integration_Name__c = 'ExchangeRateAPI',
            Run_Timestamp__c = Datetime.now(),
            Records_Processed__c = 0
        );
    }

    // execute method for queueable
    public void execute(QueueableContext context){

        // Instantiate finalizer 
        Finalizer f = new Finalizer();
        System.attachFinalizer(f);

        // Instantiate ProcessResult wrapper to help facilitate processing
        ProcessingResult result = new ProcessingResult();
        Integer count = 0;

        // Essentially decides if this is a test scenario (no configs: if-block) or the production scenario (configs exist: else-block)
        if(configs == null || configs.isEmpty()){
            count++;
            // Hard code USD for test scenario, 1 callout max
            handleSingleCurrency('USD', count, result);
        } else {
            for (Base_Currency_Config__mdt config : configs){
                count ++;
                // Pass in mdt to dynamically establish base currencies for exchange rates
                handleSingleCurrency(config.Base_Currency__c, count, result);
            }
        }
        
        upsertExchangeRates(result); // Outsource to Upsert created Exchange Rate Records
        
        logResults(result); // Outsource to log results of Integration Run
        
        f.hasLogged = true; // Mark that a log has been created (for Finalizer logic)
    }
    
    /**
    * @description Fetches exchange rates for a single base currency and updates the result wrapper.
    * Adds records to the upsert list, appends log messages, and flags success or error.
    * This helps reduce complexity in the main execute() method.
    */
    public void handleSingleCurrency(String baseCurrency, Integer count, ProcessingResult result){
        
        try{
            List<Exchange_Rate__c> updatedRates = ExchangeRateService.updateExchangeRates(baseCurrency);
            result.exRatesToUpsert.addAll(updatedRates);
            result.logEntry.Records_Processed__c += updatedRates.size();
            result.messageList.add(count + '. Successfully updated ' + updatedRates.size() + ' ' + baseCurrency + 'records.');
            result.successRecorded = true;
        } catch (Exception e){
            result.messageList.add(count + '.  Error updating  ' + baseCurrency + ' records. Message: ' + e.getMessage());
            result.errorRecorded = true;
        }
    }
    
    /**
    * @description Performs a single upsert for all collected exchange rate records.
    * If a DML error occurs, adds the error message to the result for later logging.
    */
    private void upsertExchangeRates(ProcessingResult result){
        
        // Upsert collected Exchange Rate Records
        try {
            upsert result.exRatesToUpsert External_Id__c;
        } catch (Exception dmlException){
            result.messageList.add('DML Error inserting Exchange Records: ' + dmlException.getMessage());
        }
    }
    
    /**
    * @description Finalizes and inserts the Integration Log entry.
    * Determines the appropriate status (Success, Partial, or Error) based on the processing outcome.
    */
    private void logResults(ProcessingResult result){

        // Finish constructing, then insert Log Entry Record
        result.logEntry.Message__c = String.join(result.messageList, '\n');

        if (result.successRecorded && result.errorRecorded){
            result.logEntry.Status__c = 'Partial Success';
        } else if (result.successRecorded){
            result.logEntry.Status__c = 'Success';            
        } else{
            result.logEntry.Status__c = 'Error';
        }
        
        insert result.logEntry;
    }

    /**
     * Finalizer method to wrap up queuable with best practices.  This should log
     * an error if nothing has logged from the execute method
     */

    public with sharing class Finalizer implements System.Finalizer{
        public Boolean hasLogged = false;

        public void execute(System.FinalizerContext fc){

            if(!hasLogged){
                Integration_Log__c failLog = new Integration_Log__c();
                failLog.Integration_Name__c = 'ExchangeRateAPI';
                failLog.Run_Timestamp__c = Datetime.now();
                failLog.Status__c = 'Error';
                failLog.Message__c = 'Finalizer ran but nothing was logged during execute(), so something went wrong before the main logic finished.  Possible causes: a limit error, timeout, or the job got killed. No success or error message was recorded, so check this one as a fallback.';

                insert failLog;    
            }
        }
    }
}