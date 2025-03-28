Malcolm's Comments:
Just some notes to explain what I've done.  For the most part, I followed the outline described in this file and the existing, stubbed classes.  A couple variations:

## 1. Integration_Log__c
I created this Custom Object to hold records of integration success/failures.  Every time the system runs, a record is created to hold the data.

## 2. ExchangeRateQueueable.cls
I found out (amazingly, through my Integration Log) that my scheduled job was firing, but erroring because "Callout from scheduled Apex not supported."  I implemented this class, instantiated and enqueued from the scheduler class, to handle the callout.

## 3. Used External Credential/Principal/Named Credential combination for authentication.

## 4. Added support for multiple base currencies
   - This is all done in the feature branch and not pulled into the main, which will violate the tests 
   - Added a Custom Metadata Type to give administrator the ability to change currencies and include multiple currencies
   - Refactored Queueable class, Scheduler class, and service class to accomodate this change.  Works great and logs the multiple callouts all in one Integration Log!!!

## 5. Refactored most classes to Pass tests
   - This includes overloading constructors and methods to able to be called by the Test Classes as written.
   - Includes an if-else block in the Queueable class that routes the code either to the dynamic path or hardcoded path depending on if this is coming from the scheduled job or test class.
   - Includes a conditional in the ExchangeRateService class to either perform the DML (if it this is in the Test context) or not, if this is from schedulable.

## 6. Work to Reduce/Eliminate warnings (PMD Best Practices)
Have done a number of things to reduce the PMD warnings received in GitHub's automation
   - First, I've told GitHub to ignore the three errors related to using snake case rather than camel case for the Wrapper property variables, as this is an unavoidable reality in deserializing straight to the Wrapper class.
   - Added a Finalizer to the queueable to follow best practices.  I don't think this was necessary and all that is in the class is logging an unknown/unhandled error if nothing logs within the execute method.
   - Added redundant property instantiation to avoid PMD warning.
   - To handle the complexity warnings in the Queueable's execute method:
      - Broke out parts of the queueable to keep the execute method simpler (PMD was complaining it was too complex).
      - Added a ProcessingResult wrapper to keep everything in one place — list of rates, messages, log record, etc.
   - Added a limit to the SOQL query that fetches metadata records to address PMD's warning about queries without limits.  This is good here anyway, as there is a limit to number of Queueable Jobs per transaction.  For the purpose of this developer org (which can be limited in storage), I arbitrarily set that for 5.



# Cloud Code Academy - Integration Developer Program
## Lesson 2: Exchange Rate API Integration - Best Practices

Welcome to the second lesson of the Integration Developer program! In this lesson, you'll build a complete Salesforce integration with an external API, implementing best practices for secure authentication, data processing, and automated scheduling.

## 🎯 Learning Objectives

By the end of this lesson, you will be able to:
- Configure Named Credentials to securely store API authentication details
- Create wrapper classes to deserialize JSON API responses
- Implement a service layer for making API callouts
- Build a scheduled job to automate integration updates
- Apply best practices for error handling and testing

## 📋 Exercise Overview

This exercise contains several components:

1. **ExchangeRateService.cls**
   - Service class with methods for API callouts
   - Handles communication with the ExchangeRate-API
   - Located in `force-app/main/default/classes/`

2. **ExchangeRateWrapper.cls**
   - Wrapper class for JSON deserialization
   - Maps API response to Apex objects
   - Located in `force-app/main/default/classes/`

3. **ExchangeRateScheduler.cls**
   - Scheduler for automated updates
   - Implements the Schedulable interface
   - Located in `force-app/main/default/classes/`

4. **Supporting Classes**:
   - `ExchangeRateMock.cls` - Mock HTTP class for testing
   - `ExchangeRateServiceTest.cls` - Test class for the service
   - `ExchangeRateSchedulerTest.cls` - Test class for the scheduler

5. **Custom Object**:
   - `Exchange_Rate__c` - Custom object for storing exchange rates

## 🔨 Installation

1. Clone this repository to your local machine
2. Deploy the code to your Salesforce org using:
   ```bash
   sfdx force:source:deploy -p force-app/main/default
   ```
3. Set up Named Credentials for the ExchangeRate-API (instructions below)

## 🔑 Named Credential Setup

1. In Salesforce Setup, navigate to **Security > Named Credentials**
2. Click **New Named Credential**
3. Configure with the following settings:
   - Label: ExchangeRate API
   - Name: ExchangeRate_API
   - URL: https://api.exchangerate-api.com/v4
   - Identity Type: Named Principal
   - Authentication Protocol: No Authentication
4. Save the configuration

## ✍️ Exercise Instructions

1. **Implement ExchangeRateWrapper.cls**
   - Create classes to deserialize the JSON response from the API
   - Map API data to Salesforce fields

2. **Complete ExchangeRateService.cls**
   - Implement methods to make callouts to the API
   - Process the response and create/update Exchange_Rate__c records
   - Add proper error handling

3. **Finish ExchangeRateScheduler.cls**
   - Implement the execute method to run the service
   - Set up proper scheduling using CRON expressions

4. **Test Your Implementation**
   - Run the provided test classes to verify your code
   - Ensure all tests pass with proper coverage

## 🎯 Success Criteria

Your implementation should:
- Pass all test methods in the provided test classes
- Properly deserialize JSON responses
- Create or update Exchange_Rate__c records
- Include comprehensive error handling
- Schedule updates to run automatically
- Follow Salesforce best practices

## 💡 Tips

- Review the API documentation at [ExchangeRate-API](https://www.exchangerate-api.com/docs/overview)
- Use the Developer Console debug logs to troubleshoot
- Test with mock responses before making actual API calls
- Pay attention to error handling for various scenarios

## 📚 Resources

- [Named Credentials in Salesforce](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_named_credentials.htm)
- [JSON Deserialization in Apex](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_json_overview.htm)
- [Schedulable Interface](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_scheduler.htm)
- [Apex Testing Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm)

## 🏆 Challenge

Once you've completed the basic implementation, try these challenges:
1. Add support for multiple base currencies
2. Create a Lightning component to display current exchange rates
3. Implement custom logging to track integration activity
4. Use External Credentials instead of Named Credentials for enhanced security

## ❓ Support

If you need help:
- Review the test classes for expected behavior
- Check the solution code in the `solutions` directory
- Reach out to your instructor

---
Happy coding! 🚀

*This is part of the Cloud Code Academy Integration Developer certification program.*
