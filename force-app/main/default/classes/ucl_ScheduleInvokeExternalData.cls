public with sharing class ucl_ScheduleInvokeExternalData implements Schedulable{
    public void execute(SchedulableContext ctx) {
        ucl_ConexionData.dataToObject();
    }
}
