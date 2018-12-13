/**
 * Created by dahl3702 on 9/28/2018.
 */

public with sharing class USTEventAppointmentTriggerHandler implements ITrigger {
    public USTEventAppointmentTriggerHandler() {

    }

    public void beforeInsert() {

    }

    public void afterInsert() {
        getUniqueRegistrationIDs((Map<Id, UST_Event_Appointments__c>) Trigger.newMap, (Map<Id, UST_Event_Appointments__c>) Trigger.oldMap);
    }

    public void beforeUpdate() {

    }

    public void afterUpdate() {
        getUniqueRegistrationIDs((Map<Id, UST_Event_Appointments__c>) Trigger.newMap, (Map<Id, UST_Event_Appointments__c>) Trigger.oldMap);
    }

    public void beforeDelete() {

    }

    public void afterDelete() {
        getUniqueRegistrationIDs((Map<Id, UST_Event_Appointments__c>) Trigger.newMap, (Map<Id, UST_Event_Appointments__c>) Trigger.oldMap);
    }

    public void beforeUndelete() {

    }

    public void afterUnDelete() {
        getUniqueRegistrationIDs((Map<Id, UST_Event_Appointments__c>) Trigger.newMap, (Map<Id, UST_Event_Appointments__c>) Trigger.oldMap);
    }

    public void bulkBefore() {

    }

    public void bulkAfter() {

    }

    public void andFinally() {

    }

    private void getUniqueRegistrationIDs(Map<Id, UST_Event_Appointments__c> newAppts, Map<Id, UST_Event_Appointments__c> oldAppts) {
        //Create a mapped list of unique ids
        List<UST_Event_Appointments__c> AllAppts = new List<UST_Event_Appointments__c>();
        Map<String, String> uniqueRegIds = new Map<String, String>();
        if (newAppts != null) {
            for (UST_Event_Appointments__c na : newAppts.values()) {
                uniqueRegIds.put(na.Event_Registration__c, na.Event_Registration__c);
//                if (na.Event_Host__c != oldAppts.get(na.Id).Event_Host__c) {
//                }
            }
        } else {
            for (UST_Event_Appointments__c oa : oldAppts.values()) {
                uniqueRegIds.put(oa.Event_Registration__c, oa.Event_Registration__c);
            }
        }

        AllAppts = [
                SELECT Id, Name, Appointment_Time__c, Appointment_Time_Formatted__c, Event_Registration__r.Id, Event_Registration__r.Event_Name__c, Appointment_Status__c,
                        Faculty_Staff_Member__c, Appointment_Title__c, Event_Host__c, Host_Name__c, Event_Host__r.Assigned__c,
                        Host_Location__c, Building__c, Room__c, Event_Host__r.Time__c, Event_Host__r.Course_Name__c, Event_Host__r.RecordType.Name,
                        Chosen_State__c, Event_Registration__r.Event__r.RecordType.Name, Description__c, Do_Not_Show_Time__c
                FROM UST_Event_Appointments__c
                WHERE Event_Registration__r.Id IN :uniqueRegIds.values()
                ORDER BY Appointment_Time__c ASC, Event_Host__r.Time__c ASC, Appointment_Title__c ASC

                //TODO: If there is no time on the appointment and there is host time use the host time.
        ];

        List<UST_Event_Registration__c> newItineraryRegs = new List<UST_Event_Registration__c>();

        String generatedItinerary = '';
        String generatedAppts = '';
        String tableHead = '';
        String tableHead2 = '';
        Boolean isOvernight = false;


        if (AllAppts.size() > 0) {

            //check if this is an undergrad overnight
            if (AllAppts[0].Event_Registration__r.Event_Name__c.contains('Overnight') &&
                    (AllAppts[0].Event_Registration__r.Event__r.RecordType.Name == 'Undergraduate' || String.isBlank(AllAppts[0].Event_Registration__r.Event__r.RecordType.Name))) {

                isOvernight = true;
            }
            // Generate itinaries

            //Is there time in any of the itinerary so we should show the time column?
            Boolean appointmentsHaveTime = false;
            Boolean appointmentsHaveLocation = false;
            Boolean appointmentsHaveHost = false;
            for (UST_Event_Appointments__c apptTime : AllAppts) {
                if (!String.isBlank(apptTime.Appointment_Time_Formatted__c) && !apptTime.Do_Not_Show_Time__c) {
                    appointmentsHaveTime = true;
                }
                if (!String.isBlank(apptTime.Building__c) ||
                        !String.isBlank(apptTime.Room__c)) {
                    appointmentsHaveLocation = true;
                }
                if (!String.isBlank(apptTime.Host_Name__c) || !String.isBlank(apptTime.Host_Location__c)) {
                    appointmentsHaveHost = true;
                }
            }


            if (appointmentsHaveTime) {
                tableHead += '<th align="left" style="text-align:left;">Time</th>';
            }
            tableHead += '<th align="left" style="text-align:left;">Description</th>';
            if (appointmentsHaveHost) {
                tableHead2 += '<th align="left" style="text-align:left;">Host</th>';
            }
            if (appointmentsHaveLocation) {
                tableHead2 += '<th align="left" style="text-align:left;">Location</th>';
            }

            String lastID = AllAppts[0].Id;
            for (Integer i = 0; i < AllAppts.size(); i++) {

                // add all confirmed appointments
                if (allAppts[i].Appointment_Status__c == 'Confirmed') {
                    generatedItinerary += '<tr>';

                    //Appointment Time
                    if (appointmentsHaveTime) {
                        generatedItinerary += '<td style="text-align:left;">';
                        if (!AllAppts[i].Do_Not_Show_Time__c) {
                            if (!String.isBlank(AllAppts[i].Appointment_Time_Formatted__c)) {
                                generatedItinerary += AllAppts[i].Appointment_Time_Formatted__c;
                            }
                        }
                        generatedItinerary += '</td>';
                    }

                    //Appointment Description
                    generatedItinerary += '<td style="text-align:left;padding-left:10px;">';
                    generatedItinerary += AllAppts[i].Appointment_Title__c + ' - ';
                    if (!String.isBlank(AllAPpts[i].Description__c)) {
                        generatedItinerary += AllAPpts[i].Description__c + ' - ';
                    }
                    generatedItinerary = generatedItinerary.removeEnd(' - ');
                    generatedItinerary += '</td>';

                    //Appointment Host
                    if (appointmentsHaveHost) {
                        generatedItinerary += '<td style="text-align:left;">';

                        if (!String.isBlank(AllAppts[i].Event_Host__r.Course_Name__c)) {
                            generatedItinerary += AllAppts[i].Event_Host__r.Course_Name__c + '<br/>';
                        }
                        if (!String.isBlank(AllAppts[i].Host_Name__c)) {
                            generatedItinerary += AllAppts[i].Host_Name__c + '<br/>';
                        }
                        if (!String.isBlank(AllAppts[i].Host_Location__c)) {
                            generatedItinerary += AllAppts[i].Host_Location__c + '<br/>';
                        }
                        generatedItinerary = generatedItinerary.removeEnd('<br/>');
                        generatedItinerary = generatedItinerary += '</td>';
                    }

                    //Appointment Location
                    if (appointmentsHaveLocation) {
                        generatedItinerary += '<td style="text-align:left;">';
                        if (!String.isBlank(AllAppts[i].Building__c)) {
                            generatedItinerary += AllAppts[i].Building__c + '<br/>';
                        }
                        if (!String.isBlank(AllAppts[i].Room__c)) {
                            generatedItinerary += AllAppts[i].Room__c + '<br/>';
                        }
                        generatedItinerary = generatedItinerary.removeEnd('<br/>');
                        generatedItinerary += '</td>';
                    }

                    generatedItinerary += '</tr>';
                }


                // add all requested appointments
                if (AllAppts[i].Chosen_State__c != 'Added but not shown') {
                    generatedAppts += '<tr>';

                    if (appointmentsHaveTime) {
                        generatedAppts += '<td style="text-align:left;">';
                        if (!AllAppts[i].Do_Not_Show_Time__c) {
                            if (!String.isBlank(AllAppts[i].Appointment_Time_Formatted__c)) {
                                generatedAppts += AllAppts[i].Appointment_Time_Formatted__c;
                            }
                        }
                        generatedAppts += '</td>';
                    }

                    //Appointment Description
                    generatedAppts += '<td style="text-align:left;padding-left:10px;">';
                    generatedAppts += AllAppts[i].Appointment_Title__c + ' - ';
                    if (!String.isBlank(AllAPpts[i].Description__c)) {
                        generatedAppts += AllAPpts[i].Description__c + ' - ';
                    }
                    generatedAppts = generatedAppts.removeEnd(' - ');
                    generatedAppts += '</td>';

                    generatedAppts += '</tr>';


                    lastId = AllAppts[i].Event_Registration__r.Id;
                }

            }

            if (!String.isBlank(generatedItinerary)) {
                generatedItinerary = '<table><tr>' + tableHead + tableHead2 + '</tr>' + generatedItinerary + '</table>';
            }

            if (!String.isBlank(generatedAppts)) {
                generatedAppts = '<table>' + generatedAppts + '</table>';
            }

            newItineraryRegs.add(new UST_Event_Registration__c(id = AllAppts[AllAppts.size() - 1].Event_Registration__r.Id, Generated_Itinerary__c = generatedItinerary, Generated_Requested_Appointments__c = generatedAppts));
        }

        upsert newItineraryRegs;

    }
}