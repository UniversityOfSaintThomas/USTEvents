/**
 * Created by dahl3702 on 9/28/2018.
 */

public with sharing class USTEventAppointmentTriggerHandler implements ITrigger {
    public USTEventAppointmentTriggerHandler() {

    }

    public void beforeInsert() {

    }

    public void afterInsert() {
        getUniqueRegistrationIDs(Trigger.New);
    }

    public void beforeUpdate() {

    }

    public void afterUpdate() {
        getUniqueRegistrationIDs(Trigger.New);
    }

    public void beforeDelete() {

    }

    public void afterDelete() {
        getUniqueRegistrationIDs(Trigger.old);
    }

    public void beforeUndelete() {

    }

    public void afterUnDelete() {
        getUniqueRegistrationIDs(Trigger.old);
    }

    public void bulkBefore() {

    }

    public void bulkAfter() {

    }

    public void andFinally() {

    }

    private void getUniqueRegistrationIDs(List<UST_Event_Appointments__c> newAppts) {
        //Create a mapped list of unique ids
        Map<String, String> uniqueRegIds = new Map<String, String>();
        for (UST_Event_Appointments__c na : newAppts) {
            uniqueRegIds.put(na.Event_Registration__c, na.Event_Registration__c);
        }

        List<UST_Event_Appointments__c> AllAppts = [
                SELECT Id, Name, Appointment_Time__c, Appointment_Time_Formatted__c, Event_Registration__r.Id, Appointment_Status__c,
                        Faculty_Staff_Member__c, Appointment_Title__c
                FROM UST_Event_Appointments__c
                WHERE Event_Registration__r.Id IN :uniqueRegIds.values()
                ORDER BY Event_Registration__r.Id, Appointment_Time__c
        ];

        List<UST_Event_Registration__c> newItineraryRegs = new List<UST_Event_Registration__c>();
        String generatedItinerary = '';
        String generatedAppts = '';
        String tableHead = '';
        if (AllAppts.size() > 0) {
            Boolean appointmentsHaveTime = false;
            for (UST_Event_Appointments__c apptTime : AllAppts) {
                if (!String.isBlank(apptTime.Appointment_Time_Formatted__c)) {
                    appointmentsHaveTime = true;
                }
            }
            tableHead = '<tr>';
            if (appointmentsHaveTime) {
                tableHead += '<th align="left" style="text-align:left;">Time</th>';
            }
            tableHead += '<th align="left" style="text-align:left;">Description</th>';
            tableHead += '</tr>';
            String lastID = AllAppts[0].Id;
            for (Integer i = 0; i < AllAppts.size(); i++) {
                // add all confirmed appointments
                if (allAppts[i].Appointment_Status__c == 'Confirmed') {
                    generatedItinerary += '<tr>';
                    if (appointmentsHaveTime) {
                        generatedItinerary += '<td style="text-align:left;">';
                        if (!String.isBlank(AllAppts[i].Appointment_Time_Formatted__c)) {
                            generatedItinerary += AllAppts[i].Appointment_Time_Formatted__c;
                        }
                        generatedItinerary += '</td>';
                    }

                    generatedItinerary += '<td style="text-align:left;padding-left:10px;">' + AllAppts[i].Appointment_Title__c;
                    if (!String.isBlank(AllAppts[i].Faculty_Staff_Member__c)) {
                        generatedItinerary += ' - ' + AllAppts[i].Faculty_Staff_Member__c;
                    }
                    generatedItinerary += '</td>';
                    generatedItinerary += '</tr>';
                }

                // add all requested appointments
                generatedAppts += '<tr>';

                if (appointmentsHaveTime) {
                    generatedAppts += '<td style="text-align:left;">';
                    if (!String.isBlank(AllAppts[i].Appointment_Time_Formatted__c)) {
                        generatedAppts += AllAppts[i].Appointment_Time_Formatted__c;
                    }
                    generatedAppts += '</td>';
                }

                generatedAppts += '<td style="text-align:left;padding-left:10px;">' + AllAppts[i].Appointment_Title__c;
                if (!String.isBlank(AllAppts[i].Faculty_Staff_Member__c)) {
                    generatedAppts += ' - ' + AllAppts[i].Faculty_Staff_Member__c;
                }
                generatedAppts += '</td>';

                generatedAppts += '</tr>';


                lastId = AllAppts[i].Event_Registration__r.Id;

            }

            if (!String.isBlank(generatedItinerary)) {
                generatedItinerary = '<table>' + tableHead + generatedItinerary + '</table>';
            }

            if (!String.isBlank(generatedAppts)) {
                generatedAppts = '<table>' + tableHead + generatedAppts + '</table>';
            }

            newItineraryRegs.add(new UST_Event_Registration__c(id = AllAppts[AllAppts.size() - 1].Event_Registration__r.Id, Generated_Itinerary__c = generatedItinerary, Generated_Requested_Appointments__c = generatedAppts));
        }
        upsert newItineraryRegs;
    }
}