/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventSubmitController {
    public USTEventShared USTShared = new USTEventShared();
    public String test { get; set; }
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public List<UST_Event_Appointment_Type__c> appts { get; set; }
    public List<UST_Event_Appointments__c> chosenAppts { get; set; }
    public String chosenFormatted { get; set; }
    public UST_Event__C eventPage { get; set; }

    public USTEventSubmitController() {
        test = '';
        //Get cookie or URL string variable
        evtInfo = USTShared.getUSTEventInfo();
        chosenFormatted = '';
        if(!String.isEmpty(evtInfo.evtId)) {
            eventPage = [SELECT Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c FROM UST_Event__c WHERE Id = :evtinfo.evtId][0];
        }

        if (!String.isBlank(evtinfo.evtRegId)) {
            chosenAppts = [SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Appointment_Title__c FROM UST_Event_Appointments__c WHERE Event_Registration__c = :evtinfo.evtRegId ORDER BY Appointment_Title__c];
            if (chosenAppts.size() > 0) {
                chosenFormatted += '<ul id="choosenAppointments">';
                for (UST_Event_appointments__c cappt : chosenAppts) {
                    chosenFormatted += '<li>';
                    chosenFormatted += cappt.Appointment_Title__c;
                    if (!String.isEmpty(cappt.Appointment_Type__c)) {
                        chosenFormatted += '<br/><em>' + cappt.Appointment_Type__c + '</em>';
                    }
                    chosenFormatted += '</li>';
                }
                chosenFormatted += '</ul>';
            }
        }

    }

    public PageReference submitRegistration () {
        //Change Status of registration to complete
        UST_Event_Registration__c evtReg = [SELECT Id, Status__c FROM UST_Event_Registration__c WHERE id = :evtInfo.evtRegId][0];
        evtReg.Status__c = 'Requested';
        upsert evtReg;
        PageReference confirmPage = Page.USTEventConfirmation;
        return confirmPage;
    }

    public PageReference previousPage() {
        List<UST_Event_Appointment_Type__c> apptTypes = [SELECT Id From UST_Event_Appointment_Type__c WHERE UST_Event__c = :evtInfo.evtId];
        PageReference lastPage;
        if (apptTypes.size() == 0) {
            //If no options skip that step
            lastPage = Page.USTEventRegister;
        } else {
            lastPage = Page.USTEventRegistrationOptions;
        }
        // create cookie to pass on to next page
        //Posting along everything we need to build the next page
        String encrytpString = USTShared.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","sessionID":"' + evtInfo.sessionID + '","evtRegId":"' + evtInfo.evtRegId + '","evtId":"' + evtInfo.evtId + '"}', 'USTEvent');
        //String decryptCookie = cookieWork.getDecryptCookie('USTEvent');
        //lastPage.getParameters().put('evt', encrytpString);
        return lastPage;
    }
}