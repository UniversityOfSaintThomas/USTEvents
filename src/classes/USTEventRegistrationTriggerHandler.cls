/**
 * Created by dahl3702 on 10/8/2018.
 */

public with sharing class USTEventRegistrationTriggerHandler implements ITrigger {
    public USTEventRegistrationTriggerHandler() {

    }

    public void beforeInsert() {

    }

    public void afterInsert() {
        doOnStatusChange(Trigger.new, Trigger.oldMap);
    }


    public void beforeUpdate() {

    }

    public void afterUpdate() {
        doOnStatusChange(Trigger.new, Trigger.oldMap);
    }

    public void beforeDelete() {

    }

    public void afterDelete() {

    }

    public void beforeUndelete() {

    }

    public void afterUnDelete() {

    }

    public void bulkBefore() {

    }

    public void bulkAfter() {

    }

    public void andFinally() {

    }

    private void doOnStatusChange(List<UST_Event_Registration__c> regs, Map<Id, Object> oldRegs) {

        Map<Id, Id> affectedIds = new Map<Id, Id>();
        Map<Id, Id> affectedContactIds = new Map<Id, Id>();
        List<UST_Event_Registration__c> affectedRegs = new List<UST_Event_Registration__c>();
        List<Contact> footOnCampus = new List<Contact>();

        for (UST_Event_Registration__c r : regs) {

            //Get old UST_Event_Registration__c by current ID
            UST_Event_Registration__c oldReg = new UST_Event_Registration__c(Status__c = 'new');
            if (oldRegs != null) {
                if (r.Id != null) {
                    oldReg = (UST_Event_Registration__c) oldRegs.get(r.Id);
                }
            }

            //Get all new trigger UST_Event_Registration__c that have a status change by comparing old map
            if (r.Status__c != oldReg.Status__c || r.Substatus__c != oldReg.Substatus__c) {
                affectedIds.put(r.Event__c, r.Event__c);
                affectedRegs.add(r);

                If (r.Status__c == 'Confirmed' && r.Substatus__c == 'Attended') {
                    affectedContactIds.put(r.Id, r.Id);
                }
            }
        }

        List<UST_Event_Registration__c> contactUpdates = [
                SELECT Id, Event_Instance_Date__c, Contact__r.Id, Contact__r.Initial_Foot_on_Campus__c, Contact__r.Last_Time_on_Campus__c, Contact__r.Foot_On_Campus__c
                FROM UST_Event_Registration__c
                WHERE Id IN :affectedContactIds.values()
        ];

        for (UST_Event_Registration__c cu: contactUpdates) {
            Contact footContact = new Contact();
            footContact.id = cu.Contact__r.Id;
            if (cu.Contact__r.Initial_Foot_on_Campus__c == null) {
                footContact.Initial_Foot_on_Campus__c = cu.Event_Instance_Date__c;
                footContact.Last_Time_on_Campus__c = cu.Event_Instance_Date__c;
            } else {
                footContact.Last_Time_on_Campus__c = cu.Event_Instance_Date__c;

            }
            if (cu.Contact__r.Foot_On_Campus__c == false) {
                footContact.Foot_On_Campus__c = true;
            }
            footOnCampus.add(footContact);
        }
        upsert footOnCampus;

        //Get any templates for events that have restistration status changes
        List<UST_Event_Email__c> matchEmail = [
                SELECT Action_Status__c, Action_Sub_status__c, Event__r.id, Letterhead_HTML__c, Email_Subject__c,
                        Email_Content__c, Letterhead_Id__c, Org_Email_Id__c, BCC_Email__c
                FROM UST_Event_Email__c
                WHERE Event__r.Id IN :affectedIds.values()
        ];

        List<Task> activityUpdates = new List<Task>();

        //loop through affected event registrations - have status change from old
        for (UST_Event_Registration__c areg : affectedRegs) {
            //Loop through gather email templates to get template and use registration fields to fill in hooks
            for (UST_Event_Email__c em : matchEmail) {
                Boolean statusMatch = false;
                if (em.Event__r.Id == areg.Event__c && em.Action_Status__c == areg.Status__c) {
                    if (!String.isBlank(em.Action_Sub_status__c)) {
                        if (!String.isBlank(em.Action_Status__c)) {
                            if ((em.Action_Status__c == areg.Status__c) && (em.Action_Sub_status__c == areg.Substatus__c)) {
                                statusMatch = true;
                            }
                        } else if (em.Action_Sub_status__c == areg.Substatus__c) {
                            statusMatch = true;
                        }
                    } else if (!String.isBlank(em.Action_Status__c) && (em.Action_Status__c == areg.Status__c)) {
                        statusMatch = true;
                    }

                    if (statusMatch) {
                        //Get email template
                        String emailContent = em.Email_Content__c;
                        String originalTemplate = '[[DONT_DELETE_CONTENT_HERE]]';
                        if (!String.isBlank(em.Letterhead_HTML__c)) {
                            originalTemplate = em.Letterhead_HTML__c;
                        }


                        //Regex to find all Apex delineators {! }
                        Pattern TAG_REGEX = Pattern.compile('\\{!(.+?)\\}');
                        Matcher matcher = TAG_REGEX.matcher(emailContent);
                        Map<String, String> foundTags = new Map<String, String>();

                        //loop through found hocks and add only unique
                        while (matcher.find()) {
                            foundTags.put(matcher.group(1), matcher.group(1));
                        }

                        for (String ft : foundTags.values()) {
                            //add only found hooks and recreate regex with more percise
                            Pattern TAG_REGEX2 = Pattern.compile('\\{!(' + ft + ')\\}');
                            Matcher matcher2 = TAG_REGEX2.matcher(emailContent);
                            while (matcher2.find()) {

                                //Get the value for hook from registration have to remove any registration object names since we are already in the object
                                String found = matcher2.group(1).replace('UST_Event_Registration__c.', '');
                                try {
                                    found = String.valueOf(areg.get(found));
                                } catch( Exception e) {
                                    found ='';
                                }

                                //replaceAll doesn't like nulls
                                if (String.isBlank(found)) {
                                    found = '';
                                }
                                //replace all hooks with found values from regstration

                                if (matcher2.group(1) == 'UG_Parking_Pass_Link__c' || matcher2.group(1) == 'Add_To_Calendar_Link__c' || matcher2.group(1) == 'Event_Registration_Cancel_Link__c') {
                                    found = found.replace('_HL_ENCODED_', '<a href="');
                                    found = found.replace('_HL__blank_HL_', '</a>');
                                    found = found.replace('_HL_',' target="_blank">');
                                    found = found.replace(' target=', '');
                                }

                                emailContent = matcher2.replaceAll(found);
                            }
                        }

                        //replace text in letterhead template
                        Pattern CONTENT_HOOK = Pattern.compile('\\[\\[DONT_DELETE_CONTENT_HERE\\]\\]');
                        Matcher matcher3 = CONTENT_HOOK.matcher(originalTemplate);
                        while (matcher3.find()) {
                            originalTemplate = matcher3.replaceAll(emailContent);
                        }
                        //send the message
                        sendEmail2(areg.Registrant_Email__c, originalTemplate, emailContent, em.Email_Subject__c, em.Org_Email_Id__c, em.BCC_Email__c);
                        Task nt = new Task();
                        nt.WhatId = areg.id;
                        nt.Type = 'Email';
                        nt.ActivityDate = Date.today();
                        nt.Subject = 'Event status email: ' + em.Action_Status__c + ' - ' + em.Email_Subject__c;
                        nt.Status = 'Completed';
                        nt.Priority = 'Low';
                        activityUpdates.add(nt);
                    }
                }
            }
        }

        if (activityUpdates.size() > 0) {
            insert activityUpdates;
        }
    }

    private void sendEmail2(String EmailTo, String HTMLBody, String PlainBody, String Subject, Id OrgEmailId, String BCCString) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{
                EmailTo
        });
        mail.setSubject(Subject);
        if (!String.isBlank(BCCString)) {
            BCCString = BCCString.replaceAll('\\s+', '');
            List<String> bccList = BCCString.split(',');
            if (bccList.size() > 0) {
                mail.setBccAddresses(bccList);
            }
        }
        mail.setPlainTextBody(plainBody);
        if (String.isBlank(HTMLBody)) {
            mail.setHtmlBody(plainBody);
        } else {
            mail.setHtmlBody(HTMLBody);
        }
        mail.setOrgWideEmailAddressId(OrgEmailId);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
}