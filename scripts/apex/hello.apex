// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

//ExchangeRateService.getLatestRates();

// Datetime dt = ExchangeRateWrapper.processDateTimeString('Sat, 22 Mar 2025 00:00:01 +0000');
// System.debug(dt);

//System.schedule('Manual_Run_ExchangeRateScheduler', '0 0 1 * * ?', new ExchangeRateScheduler());

//System.enqueueJob(new ExchangeRateQueueable());

// Test Code for 5 minutes from now scheduling:

Datetime nowUtc = Datetime.now().addMinutes(2);

Integer minute = nowUtc.minute();
Integer hour = nowUtc.hour();
Integer day = nowUtc.day();
Integer month = nowUtc.month();
Integer year = nowUtc.year();
String cronExp = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
String jobName = 'ExchangeRateTestRun_' + nowUtc.getTime();
System.schedule(jobName, cronExp, new ExchangeRateScheduler());


