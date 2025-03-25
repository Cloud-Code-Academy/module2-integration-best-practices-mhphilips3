/**
 * @description Wrapper class to deserialize the JSON response from the Exchange Rate API
 * Students will implement the properties and methods to process the data
 */
public class ExchangeRateWrapper {
    
    // TODO: Implement properties to match the JSON structure of the API response    
    // Add properties for base currency
    public String base_code;
    
    // Add property for time last updated
    public String time_last_update_unix;
    
    // Add property for rates (using a map)
    public Map<String, Decimal> conversion_rates;
    
    /**
     * @description Converts the wrapper data to a list of Exchange_Rate__c records
     * @return List<Exchange_Rate__c> The list of exchange rate records
     */
    public List<Exchange_Rate__c> toExchangeRates() {
        // 1. Create a list to hold the Exchange_Rate__c records
        List<Exchange_Rate__c> exRateList = new List<Exchange_Rate__c>();

        // convert the UNIX timestamp to Apex Datetime data type.
        Datetime lastUpdate = Datetime.newInstance(Long.valueOf(time_last_update_unix)*1000);

        // 2. Iterate through the rates map and create Exchange_Rate__c records
        for (String targetCurrency : conversion_rates.keySet()){
            Exchange_Rate__c newExRate = new Exchange_Rate__c();
            newExRate.Base_Currency__c = base_code;
            newExRate.Last_Updated__c = lastUpdate;
            newExRate.Target_Currency__c = targetCurrency;
            newExRate.External_Id__c = base_code + '_' + targetCurrency;
            newExRate.Name = base_code + '--to--' + targetCurrency;
            newExRate.Rate__c = conversion_rates.get(targetCurrency);

            exRateList.add(newExRate);
        }

        // 4. Return the list of records        
        return exRateList;
    }
    
    /**
     * @description Static method to parse the JSON response into the wrapper class
     * @param jsonResponse The JSON response from the API
     * @return ExchangeRateWrapper The parsed wrapper instance
     */
    public static ExchangeRateWrapper parse(String jsonResponse) {
        // TODO: Implement the method to parse the JSON response        
        return (ExchangeRateWrapper)JSON.deserialize(jsonResponse, ExchangeRateWrapper.class);
    }
}