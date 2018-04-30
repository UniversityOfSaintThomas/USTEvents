/**
 * Created by dahl3702 on 4/12/2018.
 */

public with sharing class UGEventConfirmationController {

    public UGEventShared UGShared = new UGEventShared();
    public String test { get; set; }
    public UGEventShared.UGEventInfo evtInfo { get; set; }
    public List<UG_Event_Appointment_Type__c> appts { get; set; }
    public List<UG_Event_Appointments__c> chosenAppts { get; set; }
    public String chosenFormatted { get; set; }
    public UG_Event__C eventPage { get; set; }


    public UGEventConfirmationController() {
        evtInfo = UGShared.getUGEventInfo();
        if(!String.isEmpty(evtInfo.evtId)) {
            eventPage = [SELECT Event_Confirmation_Title__c, Event_Confirmation_Description__c, Event_Footer__c FROM UG_Event__c WHERE Id = :evtinfo.evtId][0];
        }
        //Delete cookie
        Cookie deleteCookie = new Cookie('UGEvent', '',null,0,false); // Note the 0 to delete the cookie
        ApexPages.currentPage().setCookies(new Cookie[]{deleteCookie});
    }
}