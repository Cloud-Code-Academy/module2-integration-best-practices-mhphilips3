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
        System.enqueueJob(new ExchangeRateQueueable());
    }

    /**
     * @description Schedules the job to run at 1 AM daily.
     */
    public static void scheduleJob(){
        String jobName = 'Update Exchange Rates';
        String cronExpression = '0 0 1 * * ?'; // daily at 1:00 AM

        // Avoid duplicate jobs by aborting existing job before scheduling anew
        for(CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName]){
            System.abortJob(ct.Id);  
        }
        System.schedule(jobName, cronExpression, new ExchangeRateScheduler());
    }
}