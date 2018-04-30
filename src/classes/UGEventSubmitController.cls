/**
 * Created by dahl3702 on 4/12/2018.
 */

public with sharing class UGEventSubmitController {
    public UGEventShared UGShared = new UGEventShared();
    public String test { get; set; }
    public UGEventShared.UGEventInfo evtInfo { get; set; }
    public List<UG_Event_Appointment_Type__c> appts { get; set; }
    public List<UG_Event_Appointments__c> chosenAppts { get; set; }
    public String chosenFormatted { get; set; }
    public UG_Event__C eventPage { get; set; }

    public UGEventSubmitController() {
        test = '';
        //Get cookie or URL string variable
        evtInfo = UGShared.getUGEventInfo();
        chosenFormatted = '';
        if(!String.isEmpty(evtInfo.evtId)) {
            eventPage = [SELECT Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c FROM UG_Event__c WHERE Id = :evtinfo.evtId][0];
        }

        if (!String.isBlank(evtinfo.evtRegId)) {
            chosenAppts = [SELECT Id, Appointment_Category__c, UG_Event_Appointment_Type__c, Appointment_Type__c, Appointment_Title__c FROM UG_Event_Appointments__c WHERE Event_Registration__c = :evtinfo.evtRegId ORDER BY Appointment_Title__c];
            if (chosenAppts.size() > 0) {
                chosenFormatted += '<ul id="choosenAppointments">';
                for (UG_Event_appointments__c cappt : chosenAppts) {
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
        UG_Event_Registration__c evtReg = [SELECT Id, Status__c FROM UG_Event_Registration__c WHERE id = :evtInfo.evtRegId][0];
        evtReg.Status__c = 'Requested';
        upsert evtReg;
        PageReference confirmPage = Page.UGEventConfirmation;
        return confirmPage;
    }

    public PageReference previousPage() {
        List<UG_Event_Appointment_Type__c> apptTypes = [SELECT Id From UG_Event_Appointment_Type__c WHERE UG_Event__c = :evtInfo.evtId];
        PageReference lastPage;
        if (apptTypes.size() == 0) {
            //If no options skip that step
            lastPage = Page.UGEventRegister;
        } else {
            lastPage = Page.UGEventRegistrationOptions;
        }
        // create cookie to pass on to next page
        //Posting along everything we need to build the next page
        String encrytpString = UGShared.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","sessionID":"' + evtInfo.sessionID + '","evtRegId":"' + evtInfo.evtRegId + '","evtId":"' + evtInfo.evtId + '"}', 'UGEvent');
        //String decryptCookie = cookieWork.getDecryptCookie('UGEvent');
        //lastPage.getParameters().put('evt', encrytpString);
        return lastPage;
    }
}