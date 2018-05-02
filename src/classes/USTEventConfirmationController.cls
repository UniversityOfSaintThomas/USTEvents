/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventConfirmationController {
    public USTEventShared USTShared = new USTEventShared();
    public String test { get; set; }
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public List<UST_Event_Appointment_Type__c> appts { get; set; }
    public List<UST_Event_Appointments__c> chosenAppts { get; set; }
    public String chosenFormatted { get; set; }
    public UST_Event__C eventPage { get; set; }


    public USTEventConfirmationController() {
        evtInfo = USTShared.getUSTEventInfo();
        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [SELECT Event_Confirmation_Title__c, Template__c, Event_Confirmation_Description__c, Event_Footer__c FROM UST_Event__c WHERE Id = :evtinfo.evtId][0];
        }
        //Delete cookie
        Cookie deleteCookie = new Cookie('USTEvent', '', null, 0, false); // Note the 0 to delete the cookie
        ApexPages.currentPage().setCookies(new Cookie[]{
                deleteCookie
        });
    }

}