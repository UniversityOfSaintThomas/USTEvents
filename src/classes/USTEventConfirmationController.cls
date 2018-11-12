/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventConfirmationController {
    public USTEventShared USTShared = new USTEventShared();
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public UST_Event__C eventPage { get; set; }
    public UST_Event_Instance__c evtInstance {get;set;}
    public String templateSelected { get; set; }
    public String rName {get;set;}


    public USTEventConfirmationController() {

        templateSelected =  USTShared.defaultTemplate;
        evtInfo = USTShared.getUSTEventInfo();

        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [SELECT Event_Confirmation_Title__c, Event_Name__c, Template__c, Event_Confirmation_Description__c, Event_Footer__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c FROM UST_Event__c WHERE Id = :evtinfo.evtId][0];
            templateSelected = eventPage.Template__c;
            evtInstance = [SELECT Instance_Title__c, Start_Date_Time__c FROM UST_Event_Instance__c WHERE Id = :evtinfo.instanceID LIMIT 1];
        }

    }

    public PageReference checkEventDetails() {
        //PageReference resultPageRef =  USTShared.checkForEvent();
        evtInfo = USTShared.getUSTEventInfo();
        String eventTitle = '';
        if(!String.isBlank(evtInfo.evtRegId)) {
            UST_Event_Registration__c evtReg = [
                    SELECT Id, Status__c, Contact__c, Event_Name__c, Event_Instance_Title__c,
                            Registrant_First_Name__c, Registrant_Last_Name__c,Registrant_Gender__c,
                            Event_Instance_Date__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_City__c,
                            Registrant_State__c, Registrant_Zip__c, Registrant_Email__c, Registrant_High_School_Grad_Year__c,
                            Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c,
                            Registrant_Program_Interest__c, Registrant_Major__c, Registrant_Major_2__c, Registrant_Major_3__c,
                            Registrant_Major_4__c
                    FROM UST_Event_Registration__c
                    WHERE id = :evtInfo.evtRegId
            ][0];
            if (!String.isBlank(evtReg.Event_Instance_Title__c)) {
                eventTitle = evtReg.Event_Name__c + ' - ' + evtReg.Event_Instance_Title__c ;
            } else {
                eventTitle = evtReg.Event_Name__c;
            }
            evtReg.Status__c = 'Requested';
            upsert evtReg;

            //create touchpoint
            Touch_Point__c tp = new Touch_Point__c();
            tp.Contact__c = evtReg.Contact__c;
            tp.Lead_Source__c = 'Event';
            tp.FirstName__c = evtReg.Registrant_First_Name__c;
            tp.LastName__c = evtReg.Registrant_Last_Name__c;
            tp.Gender__c = evtReg.Registrant_Gender__c;
            tp.Event_Name__c = eventTitle;
            tp.Event_date__c = evtReg.Event_Instance_Date__c;
            tp.Street__c = evtReg.Registrant_Street_1__c;
            tp.Street2__c = evtReg.Registrant_Street_2__c;
            tp.City__c = evtReg.Registrant_City__c;
            tp.State__c = evtReg.Registrant_State__c;
            tp.Zip_Postal_Code__c = evtReg.Registrant_Zip__c;
            tp.Email__c = evtReg.Registrant_Email__c;
            tp.HS_Grad_Year__c = evtReg.Registrant_High_School_Grad_Year__c;
            tp.Parent_1_First_Name__c = evtReg.Registrant_Parent_First_Name__c;
            tp.Parent_1_Last_Name__c = evtReg.Registrant_Parent_Last_Name__c;
            tp.Parent_1_Email__c = evtReg.Registrant_Parent_Email__c;
            tp.Major__c = evtReg.Registrant_Major__c;
            tp.Major2__c = evtReg.Registrant_Major_2__c;
            tp.Major3__c = evtReg.Registrant_Major_3__c;
            tp.Major4__c = evtReg.Registrant_Major_4__c;

            if (evtInfo.recordTypeName == 'Undergraduate') {
                tp.Degree_Sought_Program_Catalog__c = 'Undergraduate';
            }
            insert tp;
        }

        return null;
    }


}