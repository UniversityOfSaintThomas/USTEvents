/**
 * Created by dahl3702 on 4/29/2019.
 */

global class USTEventRegistration_TDTM extends hed.TDTM_Runnable {

    // the Trigger Handler’s Run method we must provide
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.dmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();
        doCRUD CRUDtoDo = new doCRUD();

        if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert || triggerAction == hed.TDTM_Runnable.Action.AfterUpdate) {
            list<ID> listConId = new list<ID>();
            Map<Id, Id> affectedIds = new Map<Id, Id>();
            Map<Id, Id> affectedContactIds = new Map<Id, Id>();
            List<UST_Event_Registration__c> affectedRegs = new List<UST_Event_Registration__c>();
            List<Contact> footOnCampus = new List<Contact>();
            Map<id, UST_Event_Registration__c> oldListMap = new Map<Id, UST_Event_Registration__c>();
            if (oldlist != null) {
                for (UST_Event_Registration__c ol : (List<UST_Event_Registration__c>) oldlist) {
                    oldListMap.put(ol.Id, ol);
                }
            }
            for (UST_Event_Registration__c r : (List<UST_Event_Registration__c>) newlist) {

                //Get old UST_Event_Registration__c by current ID
                UST_Event_Registration__c oldReg = new UST_Event_Registration__c(Status__c = 'new', Substatus__c = 'new');
                if (oldListMap.size() > 0) {
                    if (r.Id != null) {
                        oldReg = oldListMap.get(r.Id);
                    }
                }

                //Get all new trigger UST_Event_Registration__c that have a status change by comparing old map
                if (String.isNotBlank(oldReg.Id)) {
                    if (r.Status__c != oldReg.Status__c || r.Substatus__c != oldReg.Substatus__c) {
                        affectedIds.put(r.Event__c, r.Event__c);
                        affectedRegs.add(r);
                        If (r.Status__c == 'Confirmed' && r.Substatus__c == 'Attended') {
                            affectedContactIds.put(r.Id, r.Id);
                        }
                    }
                } else {
                    affectedIds.put(r.Event__c, r.Event__c);
                    affectedRegs.add(r);
                    If (r.Status__c == 'Confirmed' && r.Substatus__c == 'Attended') {
                        affectedContactIds.put(r.Id, r.Id);
                    }
                }
            }

            List<UST_Event_Registration__c> contactUpdates = [
                    SELECT Id, Event_Instance_Date__c, Contact__r.Id, Contact__r.Initial_Foot_on_Campus__c, Contact__r.Last_Time_on_Campus__c, Contact__r.Foot_On_Campus__c,
                            Event_Instance__r.Location_Type_Override__c, Event_Instance__r.Event__r.Location_Type__c, Contact__r.LastName
                    FROM UST_Event_Registration__c
                    WHERE Id IN :affectedContactIds.values()
            ];

            for (UST_Event_Registration__c cu : contactUpdates) {
                Set<String> validLocations = new Set<String>{
                        'St. Paul', 'St. Paul - North', 'St. Paul - South', 'Minneapolis'
                };
                String evtLocation = '';
                if (String.isNotBlank(cu.Event_Instance__r.Location_Type_Override__c)) {
                    evtLocation = cu.Event_Instance__r.Location_Type_Override__c;
                } else if (String.isNotBlank(cu.Event_Instance__r.Event__r.Location_Type__c)) {
                    evtLocation = cu.Event_Instance__r.Event__r.Location_Type__c;
                }
                if ((validLocations.contains(evtLocation) || String.isBlank(evtLocation)) && String.isNotBlank(cu.Contact__r.Id)) {
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
            }
            if (footOnCampus.size() > 0) {
                CRUDtoDo.updateContact(footOnCampus);
            }
            //Get any templates for events that have restistration status changes
            List<UST_Event_Email__c> matchEmail = [
                    SELECT Action_Status__c, Action_Sub_status__c, Event__r.id, Letterhead_HTML__c, Email_Subject__c,
                            Email_Content__c, Letterhead_Id__c, Org_Email_Id__c, BCC_Email__c
                    FROM UST_Event_Email__c
                    WHERE Event__r.Id IN :affectedIds.values()
                    AND Action_status__c != Null
                    AND Action_Status__c != '--Inactive--'
            ];

            List<Task> activityUpdates = new List<Task>();
            String[] BCCsToGo = new List<String>();
            //loop through affected event registrations - have status change from old
            for (UST_Event_Registration__c areg : affectedRegs) {
                BCCsToGo = new List<String>();
                //Loop through gather email templates to get template and use registration fields to fill in hooks
                for (UST_Event_Email__c em : matchEmail) {
                    Boolean statusMatch = false;

                    if (em.Event__r.Id.equals(areg.Event__c)) {

                        statusMatch = false;
                        //Check if there is a status and a substatus else just pay attention to status
                        if (!String.isBlank(em.Action_Sub_status__c) && !String.isBlank(areg.Substatus__c)) {
                            if (em.Action_Sub_status__c.equals(areg.Substatus__c) && em.Action_Status__c.equalsIgnoreCase(areg.Status__c)) {
                                // Match made on Sub status
                                statusMatch = true;
                            }
                        } else if (em.Action_Status__c.equals(areg.Status__c) && String.isBlank(em.Action_Sub_status__c) && String.isBlank(areg.Substatus__c)) {
                            // Match made on status
                            statusMatch = true;
                        }

                        //Build the BCC list. No duplicate emails. Split strings.
                        BCCsToGo = addToEmailList(em.BCC_Email__c, BCCsToGo);
                        BCCsToGo = addToEmailList(areg.Registrant_Other_Email__c, BCCsToGo);
                        BCCsToGo = addToEmailList(areg.Registrant_Parent_Email__c, BCCsToGo);
                        BCCsToGo = addToEmailList(areg.BCC_Transactional_Emails__c, BCCsToGo);

                        if (statusMatch) {
                            //Get email template
                            String emailContent = em.Email_Content__c;
                            String originalTemplate = '[[DONT_DELETE_CONTENT_HERE]]';
                            if (!String.isBlank(em.Letterhead_HTML__c)) {
                                originalTemplate = em.Letterhead_HTML__c;
                            }

                            emailContent = emailContent.replace('$', '\\$');
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
                                    } catch (Exception e) {
                                        found = '';
                                    }

                                    //replaceAll doesn't like nulls
                                    if (String.isBlank(found)) {
                                        found = '';
                                    }
                                    //replace all hooks with found values from regstration

                                    if (matcher2.group(1) == 'UG_Parking_Pass_Link__c' || matcher2.group(1) == 'Add_To_Calendar_Link__c' || matcher2.group(1) == 'Event_Registration_Cancel_Link__c') {
                                        found = found.replace('_HL_ENCODED_', '<a href="');
                                        found = found.replace('_HL__blank_HL_', '</a>');
                                        found = found.replace('_HL_', ' target="_blank">');
                                        found = found.replace(' target=', '');
                                    }

                                    emailContent = matcher2.replaceAll(found);
                                }
                            }

                            //put email content (after hooks have been replaced with values) into the email template
                            originalTemplate = originalTemplate.replaceAll('\\[\\[DONT_DELETE_CONTENT_HERE\\]\\]', emailContent);

                            //send the message
                            sendEmail2(areg.Registrant_Email__c, originalTemplate, emailContent, em.Email_Subject__c, em.Org_Email_Id__c, BCCsToGo);

                            //Create an activity task
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
                CRUDtoDo.insertTasks(activityUpdates);
            }
        }
        return dmlWrapper;
    }

    public void sendEmail2(String EmailTo, String HTMLBody, String PlainBody, String Subject, Id OrgEmailId, List<String> BCCList) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(splitEmails(EmailTo));
        //mail.setCcAddresses(BCCList);
        mail.setBccAddresses(BCCList);
        mail.setSubject(Subject);
        mail.setPlainTextBody(plainBody);
        if (String.isBlank(HTMLBody)) {
            mail.setHtmlBody(plainBody);
        } else {
            mail.setHtmlBody(HTMLBody);
        }
        mail.setOrgWideEmailAddressId(OrgEmailId);

        try {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        } catch (Exception e) {
            System.debug(e.getMessage());
        }


    }

    /*
    This method makes sure no duplicate emails make it into our lists causing BCC failures.
    emailList is the list you want to maintain and emailIn is the new emails you want to add.
     */
    public List<String> addToEmailList(String emailsInString, List<String> emailList) {
        if (String.isNotBlank(emailsInString)) {
            List<String> emailsIn = splitEmails(emailsInString);
            for (String email : emailsIn) {
                if (!emailList.contains(email)) {
                    emailList.add(email);
                }
            }
        }
        return emailList;
    }

    public List<String> splitEmails(String emailDelineatedString) {
        List<String> checkedEmails = new List<String>();
        if (String.isNotBlank(emailDelineatedString)) {
            emailDelineatedString = emailDelineatedString.replaceAll('\\s+', ',');
            emailDelineatedString = emailDelineatedString.replaceAll(';', ',');
            List<String> emailList = emailDelineatedString.split(',');
            for (String em : emailList) {
                if (validateEmail(em)) {
                    checkedEmails.add(em);
                }
            }
        }
        return checkedEmails;
    }

    public Boolean validateEmail(String email) {
        Boolean res = false;
        if (String.isNotBlank(email)) {
            // source: http://www.regular-expressions.info/email.html
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(email);
            if (MyMatcher.matches()) {
                res = true;
            }
        }
        return res;
    }

    private without sharing class doCRUD  {

        public void insertTasks(List<Task> newTasks) {
            try {
                upsert newTasks;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }

        private void updateContact(List<Contact> uContacts) {
            try {
                upsert uContacts;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }

    }

}