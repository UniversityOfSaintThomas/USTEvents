/**
 * Created by dahl3702 on 4/3/2018.
 */
public with sharing class UGEventRegistrationOptionsController {
    public UGEventShared UGShared = new UGEventShared();
    public String test { get; set; }
    public UGEventShared.UGEventInfo evtInfo { get; set; }
    public List<UG_Event_Appointment_Type__c> appts { get; set; }
    public List<UG_Event_Appointments__c> chosenAppts { get; set; }
    public String apptFormatted { get; set; }
    public String chosenFormatted { get; set; }
    public String incomingApptJSon { get; set; }
    public UG_Event__C eventPage { get; set; }

    public class incomingAppt {
        String apptId;
        String apptCatagory;
        String apptType;
        String apptText;
        String apptTitle;
    }

    public UGEventRegistrationOptionsController() {
        test = '';
        //Get cookie or URL string variable
        evtInfo = UGShared.getUGEventInfo();
        apptFormatted = '';
        chosenFormatted = '';

        Map<String, Integer> apptCount = new Map<String, Integer>();

        if (!String.isBlank(evtinfo.evtId)) {
            eventPage = [SELECT Event_Appointment_Title__c, Event_Appointment_Description__c, Event_Footer__c FROM UG_Event__c WHERE Id = :evtinfo.evtId][0];
            if (!String.isBlank(evtinfo.evtRegId)) {
                chosenAppts = [SELECT Id, Appointment_Category__c, UG_Event_Appointment_Type__c, Appointment_Type__c, Appointment_Title__c FROM UG_Event_Appointments__c WHERE Event_Registration__c = :evtinfo.evtRegId AND Client_Created_Appointment__c = true];
                for (UG_Event_appointments__c cappt : chosenAppts) {

                    //Keep track of appointment ids to not show in available appointments later
                    if (!String.isBlank(cappt.UG_Event_Appointment_Type__c)) {
                        if (!apptCount.containsKey(cappt.UG_Event_Appointment_Type__c)) {
                            apptCount.put(cappt.UG_Event_Appointment_Type__c, 0);
                        }
                        Integer increment = apptCount.get(cappt.UG_Event_Appointment_Type__c) + 1;
                        apptCount.put(cappt.UG_Event_Appointment_Type__c, increment);
                    }

                    //build chosen appointments for list
                    chosenFormatted += '<div id="appt-' + cappt.Id + '"';
                    chosenFormatted += ' data-apptid="' + cappt.UG_Event_Appointment_Type__c + '"';
                    chosenFormatted += ' data-apptcat="' + cappt.Appointment_Category__c + '"';
                    chosenFormatted += ' data-appttype="' + cappt.Appointment_Type__c + '"';
                    chosenFormatted += ' data-appttitle="' + cappt.Appointment_title__c + '"';
                    chosenFormatted += ' data-appttext="" class="appointmentChoosen"';
                    chosenFormatted += ' >';
                    chosenFormatted += '<p class="appointmentTitle">' + cappt.Appointment_Title__c + '</p>';
                    if (!String.isEmpty(cappt.Appointment_Type__c)) {
                        chosenFormatted += '<p class="appointmentDesc">' + cappt.Appointment_Type__c + '</p>';
                    }
                    chosenFormatted += '<a href="javascript:;" onclick="removeAppt($(this))" class="appointmentRemove" title="Remove Appointment"><i class="fa fa-times-circle" aria-hidden="true"></i><span> Remove</span></span></a>';
                    chosenFormatted += '</div>';

                }
            }

            //Build available appointments
            appts = [SELECT Id, Name, Title__c, Description__c, Appointment_Type__c, Appointment_Category__c, Appointment_Limits__c FROM UG_Event_Appointment_Type__c WHERE UG_Event__c = :evtinfo.evtId];
            for (UG_Event_Appointment_Type__c apt : appts) {
                Integer apptLimit = 1;
                if (!String.isBlank(apt.Appointment_Limits__c)) {
                    apptLimit = Integer.valueOf(apt.Appointment_Limits__c);
                }
                if (apptCount.containsKey(apt.Id)) {
                    apptLimit = apptLimit - (Integer.valueOf(apptCount.get(apt.Id)));
                }
                apptFormatted += '<div id="' + apt.Id + '" data-apptid="' + apt.Id + '" data-apptcat="' + apt.Appointment_Category__c + '" data-appttitle="' + apt.Title__c + '" ';
                apptFormatted += ' data-limit=' + String.valueOf(apptLimit) + ' ';
                if (apptLimit <= 0) {
                    apptFormatted += ' style="display:none;" ';
                } else {
                    apptFormatted += ' data-limit="1" ';
                }
                apptFormatted += 'class="appointment">';
                apptFormatted += '<p class="appointmentTitle"><a href="javascript:;" ><span>' + apt.Title__c + '</span><i class="fa fa-chevron-down" aria-hidden="true"></i></a></p>';
                apptFormatted += '<div class="apptmentDetail">';
                if (!String.isBlank(apt.Description__c)) {
                    apptFormatted += '<p class="appointmentDesc">' + apt.Description__c + '</p>';
                }
                if (apt.Appointment_Category__c != null) {
                    //getDependentSelectOptions(String parentObjName, String parentFieldName, String dependentFieldName, String parentValue)
                    Map<String, String> dependencies = UGShared.getDependentSelectOptions('UG_Event_Appointment_Type__c', 'Appointment_Category__c', 'Appointment_Type__c', apt.Appointment_Category__c);
                    if (dependencies.size() > 1) {
                        apptFormatted += '<select class="appointmentType required">';
                        apptFormatted += '<option value="">Select...</option>';
                        for (String thing : dependencies.keySet()) {
                            apptFormatted += '<option value="' + thing + '">' + dependencies.get(thing) + '</option>';
                        }

                        apptFormatted += '</select>';
                    }
                }
                apptFormatted += '<a href="javascript:;" class="appointmentAdd"><span><i class="fa fa-plus" aria-hidden="true"></i> Add appointment</span></a>';
                apptFormatted += '</div>';
                apptFormatted += '</div>';
            }
        }
    }

    public PageReference saveOptions() {
        //remove old client created appointments
        UG_Event_Appointments__c[] deleteAppt = [SELECT Id, Event_Registration__c, Client_Created_Appointment__c FROM UG_Event_Appointments__c WHERE Event_Registration__c = :evtinfo.evtRegId AND Client_Created_Appointment__c = true];
        try {
            delete deleteAppt;
        } catch (DmlException e) {

        }
        List<incomingAppt> deserializedInvoices = (List<incomingAppt>) JSON.deserialize(incomingApptJSon, List<incomingAppt>.class);
        PageReference submitPage = Page.UGEventSubmit;
        for (incomingAppt appt : deserializedInvoices) {
            UG_event_Appointments__c addAppt = new UG_Event_Appointments__c();
            addAppt.Event_Registration__c = evtInfo.evtRegId;
            addAppt.Appointment_Status__c = 'Registered';
            addAppt.Client_Created_Appointment__c = true;
            addAppt.UG_Event_Appointment_Type__c = appt.apptId;
            if (!String.isBlank(appt.apptCatagory) && appt.apptCatagory != 'null' && appt.apptCatagory != 'undefined') {
                addAppt.Appointment_Category__c = appt.apptCatagory;
            }
            if (!String.isBlank(appt.apptType) && appt.apptType != 'null' && appt.apptType != 'undefined') {
                addAppt.Appointment_Type__c = appt.apptType;
            }
            addAppt.Appointment_title__c = appt.apptTitle;

            upsert addAppt;
        }
        return submitPage;
    }

    public PageReference previousPage() {
        //if (!String.isBlank(eventRegId)) {
        PageReference registerPage = Page.UGEventRegister;
        // create cookie to pass on to next page
        UGEventShared cookieWork = new UGEventShared();
        //Posting along everything we need to build the next page
        String encrytpString = cookieWork.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","sessionID":"' + evtInfo.sessionID + '","evtRegId":"' + evtInfo.evtRegId + '","evtId":"' + evtInfo.evtId + '"}', 'UGEvent');
        //String decryptCookie = cookieWork.getDecryptCookie('UGEvent');
        registerPage.getParameters().put('evt', encrytpString);
        return registerPage;
    }

}