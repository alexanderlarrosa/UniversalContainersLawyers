public with sharing class ucl_dailyInvokeProcessor {
    ucl_ScheduleInvokeExternalData invoke = new ucl_ScheduleInvokeExternalData();
    // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    String sch = '0 0 22 * * ?';
    String jobID = System.schedule('Invoke External data', sch, invoke);
}
