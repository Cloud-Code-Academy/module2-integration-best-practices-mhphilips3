/**
 * @description Scheduler class to run the exchange rate update on a schedule
 * Scheduling should be done in Salesforce Setup Apex Classes -> Schedule Apex
 */
global class ExchangeRateScheduler implements Schedulable{
    
    /**
     * @description Executes the scheduled job to update exchange rates
     * @param context The SchedulableContext
     */
    global void execute(SchedulableContext sc) {
        // TODO: Implement the method to update exchange rates
        try{
            List<Exchange_Rate__c> updatedRates = ExchangeRateService.updateExchangeRates();
        } catch (Exception e){
            System.debug('Callout Failed: ' + e.getMessage());
        }
        // 1. Call ExchangeRateService.updateExchangeRates()
        // 2. Add error handling
        // 3. Consider adding logging if available
    }

    /**
     * @description Schedules the job to run at 1 AM daily.
     */

    public static void scheduleJob(){
        String jobName = 'Update Exchange Rates';
        String cronExpression = '0 0 1 * * ?'; // daily at 1:00 AM

        for(CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName]){
            System.abortJob(ct.Id);  // Avoid duplicate jobs by aborting existing job before scheduling anew
        }

        System.schedule(jobName, cronExpression, new ExchangeRateScheduler());
    }
}