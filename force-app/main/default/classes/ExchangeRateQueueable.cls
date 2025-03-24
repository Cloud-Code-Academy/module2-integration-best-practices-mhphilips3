/**
* @description Queueable class to handle Exchange Rate API callout and data processing.
* This class is enqueued by a scheduled job since callouts are not allowed directly from scheduled Apex.
*/
public with sharing class ExchangeRateQueueable implements Queueable, Database.AllowsCallouts {
    public ExchangeRateQueueable() {
    }

    // execute method for queueable
    public void execute(QueueableContext context){

        // Initialize integration log for tracking callout results
        Integration_Log__c logEntry = new Integration_Log__c();
        logEntry.Integration_Name__c = 'ExchangeRateAPI';
        logEntry.Run_Timestamp__c = Datetime.now();

        try{
            // Fetch and process exchange rate data
            List<Exchange_Rate__c> updatedRates = ExchangeRateService.updateExchangeRates();
            // Log successful outcomes
            logEntry.Status__c = 'Success';
            logEntry.Records_Processed__C = updatedRates.size();
        } catch (Exception e){
            // Log any errors encountered
            logEntry.Status__c = 'Error';
            logEntry.Message__c = 'Error: ' + e.getMessage();
        }
        insert logEntry;
    }
}