/**
 * Created by dahl3702 on 10/8/2018.
 */

public with sharing class USTEventRegistrationTriggerHandler implements ITrigger {
    public USTEventRegistrationTriggerHandler() {

    }

    public void beforeInsert() {

    }

    public void afterInsert() {
        sendSatusEmails(Trigger.new, Trigger.oldMap);
    }


    public void beforeUpdate() {

    }

    public void afterUpdate() {
        sendSatusEmails(Trigger.new, Trigger.oldMap);
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

    private void sendSatusEmails(List<UST_Event_Registration__c> regs, Map<Id, Object> oldRegs) {

        Map<Id, Id> affectedIds = new Map<Id, Id>();
        List<UST_Event_Registration__c> affectedRegs = new List<UST_Event_Registration__c>();

        for (UST_Event_Registration__c r : regs) {

            //Get old UST_Event_Registration__c by current ID
            UST_Event_Registration__c oldReg = new UST_Event_Registration__c(Status__c = 'new');
            if (oldRegs != null) {
                if (r.Id != null) {
                    oldReg = (UST_Event_Registration__c) oldRegs.get(r.Id);
                }
            }

            //Get all new trigger UST_Event_Registration__c that have a status change by comparing old map
            if (r.Status__c != oldReg.Status__c) {
                affectedIds.put(r.Event__c, r.Event__c);
                affectedRegs.add(r);
            }
        }

        //Get any templates for events that have restistration status changes
        List<UST_Event_Email__c> matchEmail = [
                SELECT Action_Status__c, Event__r.id, Letterhead__c, Letterhead_HTML__c, Email_Subject__c, Email_From__c,
                        Email_Content__c, Letterhead_Id__c, Org_Email_Id__c, BCC_Email__c
                FROM UST_Event_Email__c
                WHERE Event__r.Id IN :affectedIds.values()
        ];

        //loop through affected event registrations - have status change from old
        for (UST_Event_Registration__c areg : affectedRegs) {

            //Loop through gather email templates to get template and use registration fields to fill in hooks
            for (UST_Event_Email__c e : matchEmail) {
                if (e.Event__r.Id == areg.Event__c && e.Action_Status__c == areg.Status__c) {
                    //Get email template
                    String emailContent = e.Email_Content__c;
                    String originalTemplate = e.Letterhead_HTML__c;

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
                            found = String.valueOf(areg.get(found));
                            //replaceAll doesn't like nulls
                            if (String.isBlank(found)) {
                                found = '';
                            }
                            //replace all hooks with found values from regstration
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
                    sendEmail2(areg.Registrant_Email__c, originalTemplate, emailContent, e.Email_Subject__c, e.Org_Email_Id__c, e.BCC_Email__c);

                }
            }
        }
    }

    private void sendEmail2(String EmailTo, String HTMLBody, String PlainBody, String Subject, Id OrgEmailId, String BCCString) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{
                EmailTo
        });
        mail.setSubject(Subject);
        if (!String.isBlank(BCCString)) {
            BCCString = BCCString.replaceAll( '\\s+', '');
            List<String> bccList = BCCString.split(',');
            if (bccList.size()>0) {
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