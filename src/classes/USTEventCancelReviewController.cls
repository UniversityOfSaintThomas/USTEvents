/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventCancelReviewController {
    public USTEventShared USTShared = new USTEventShared();
    public String outString {get;set;}
    public UST_Event_Registration__c evt {get;set;}
    public List<UST_Event_Appointments__c> appt {get;set;}
    public String eventDesc {get;set;}
    public String templateSelected { get; set; }

    public USTEventCancelReviewController() {
        templateSelected =  USTShared.defaultTemplate;
        String regId = ApexPages.currentPage().getParameters().get('regId');

        if (!String.isBlank(regId)) {
            evt = [SELECT id, Status__c, Name, Event__r.Name, Event__r.Event_description__c,
                    Event__r.Event_Footer__c, Event__r.Event_Cancel_Review_Title__c,
                    Event__r.Event_Cancel_Review_Description__c, Event__r.Event_Cancelled_Notification_Text__c,
                    Event__r.Template__c, Event__r.Event_Home_Link_Title__c, Event__r.Event_Home_Link_URL__c
            FROM UST_Event_Registration__c WHERE id = :regId][0];
            
            templateSelected = evt.Event__r.Template__c;

            if (evt != null) {
                appt = [SELECT Id, Appointment_Title__c, Appointment_Category__c, Appointment_Type__c FROM UST_Event_Appointments__c WHERE Event_Registration__c = :regId];
            }
        }
    }


    public PageReference cancelRegistration() {
        if (evt != null) {
            evt.Status__c = 'Cancelled';
            upsert evt;
        }
        pageReference pg = new pageReference(ApexPages.currentPage().getURL());
        pg.getParameters().put('regid',evt.id);
        pg.setRedirect(TRUE);
        return pg;
    }

}