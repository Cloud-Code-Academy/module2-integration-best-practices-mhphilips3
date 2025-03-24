/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */
public class ExchangeRateService {
    
    // The named credential to use for the callout
    private static final String NAMED_CREDENTIAL = 'ExchangeRate_API';    
    // The base currency to use for exchange rates
    private static final String BASE_CURRENCY = 'USD';

    /**
     * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
     * @return ExchangeRateWrapper containing the response data
     */
    public static ExchangeRateWrapper getLatestRates() {
        // TODO: Implement the method to make a callout to the Exchange Rate API
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:' + NAMED_CREDENTIAL +'/latest/' + BASE_CURRENCY);
        HttpResponse response = http.send(request);

        if(response.getStatusCode() >= 200 && response.getStatusCode() < 300){
            ExchangeRateWrapper rateData = ExchangeRateWrapper.parse(response.getBody());
            // System.debug(rateData);
            return rateData;

        } else {
            throw new CalloutException('Error receiving exchange rates.  Status code: ' + response.getStatusCode());
        }        
    }
    
    /**
     * @description Processes the exchange rate data and creates or updates records
     * @param rateData The wrapper containing exchange rate data
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> processRates(ExchangeRateWrapper rateData) {
        // TODO: Implement the method to process rates and create/update records
        if (rateData == null){
            return new List<Exchange_Rate__c>();
        }
        
        List<Exchange_Rate__c> exRateList = rateData.toExchangeRates();
        upsert exRateList External_Id__c;
        return exRateList;
    }
    
    /**
     * @description Combines getting and processing rates into a single operation
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> updateExchangeRates() {
        // TODO: Implement the method to get and process rates
        // 1. Call getLatestRates to retrieve the data
        ExchangeRateWrapper rateData = getLatestRates();
        // 2. Call processRates to create/update records
        List<Exchange_Rate__c> exRateList = processRates(rateData);
        // 3. Return the processed records        
        return exRateList;
    }
}