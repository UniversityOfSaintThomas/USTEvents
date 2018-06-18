/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventConfirmationController {
    public USTEventShared USTShared = new USTEventShared();
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public UST_Event__C eventPage { get; set; }
    public String templateSelected { get; set; }


    public USTEventConfirmationController() {

        templateSelected =  USTShared.defaultTemplate;
        evtInfo = USTShared.getUSTEventInfo();

        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [SELECT Event_Confirmation_Title__c, Template__c, Event_Confirmation_Description__c, Event_Footer__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c FROM UST_Event__c WHERE Id = :evtinfo.evtId][0];
            templateSelected = eventPage.Template__c;
        }

    }

    public PageReference checkEventDetails() {
        //PageReference resultPageRef =  USTShared.checkForEvent();
        evtInfo = USTShared.getUSTEventInfo();
        if(!String.isBlank(evtInfo.evtRegId)) {
            UST_Event_Registration__c evtReg = [SELECT Id, Status__c FROM UST_Event_Registration__c WHERE id = :evtInfo.evtRegId][0];
            evtReg.Status__c = 'Requested';
            upsert evtReg;
        }

        return null;
    }

}