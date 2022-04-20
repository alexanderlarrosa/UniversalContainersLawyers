public with sharing class ucl_ScheduleInvokeExternalData implements Schedulable{



    public static void execute(SchedulableContext ctx) {
        ucl_ConexionData.Call();
    }
    
    
}