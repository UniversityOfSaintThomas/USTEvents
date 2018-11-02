/**
 * Created by dahl3702 on 10/30/2018.
 */

public with sharing class USTEventHostAssignementExtension {
    public UST_Event_Appointments__c USTApt;
    public Id instanceID {get;set;}
    public List<UST_Event_Host__c> listHost {get;set;}
    public Id hostId {get;set;}

    public USTEventHostAssignementExtension(ApexPages.StandardController stdController) {
        USTApt = (UST_Event_Appointments__c) stdController.getRecord();
        instanceID = USTApt.Event_Registration__r.Event_Instance__r.Id;
        listHost = [SELECT Name, Host_Type__c, Last_Name__c, First_Name__c, Preferred_Title__c,
                Gender__c, Undergrad_Major__c, Department__c, Contact__c,  Formatted_Time__c,
                Course_Name__c, Building__c, Location__c, Additional_Comments__c, Remaining__c,
                Assigned__c
        From UST_Event_Host__c
        WHERE Event_Instance__c = :instanceID];
    }

    public PageReference assignHost() {
        USTApt.Event_Host__c = hostId;
        upsert USTApt;
        return null;
    }
}