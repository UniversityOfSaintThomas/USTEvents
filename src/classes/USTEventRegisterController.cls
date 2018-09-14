/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventRegisterController {
    public String test { get; set; }
    public UST_Event_Instance__c evtInstance { get; set; }
    public UST_Event__c eventPage { get; set; }
    public List<UST_Event_Appointment_Type__c> apptTypes { get; set; }
    public String ContactId { get; set; }
    public String instanceName { get; set; }
    public String EvtUserType { get; set; }
    public List<SelectOption> guestAmt { get; set; }
    public UST_Event_Registration__c newEvtReg { get; set; }
    private USTEventShared USTShared = new USTEventShared();
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public String templateSelected { get; set; }
    public boolean contactSet { get; set; }

    public USTEventRegisterController() {
        newEvtReg = new UST_Event_Registration__c();
        templateSelected = USTShared.defaultTemplate;
        test = '';
        contactSet = false;

        EvtUserType = UserInfo.getUserType();
        //Get cookie or URL string variable
        evtInfo = USTShared.getUSTEventInfo();

        //Get Instance information
        if (!String.isBlank(evtInfo.instanceID)) {
            evtInstance = [
                    SELECT Id, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Id, Instance_Title__c,
                            Event__r.Event_description__c, Event__r.Audience__c, Start_Date_Time__c, End_Date_Time__c, Current_Available_Capacity__c
                    FROM UST_Event_Instance__c
                    WHERE Id = :evtInfo.instanceID
                    LIMIT 1
            ][0];

            //define Event ID from instanceInfo data
            evtInfo.evtId = evtInstance.Event__r.Id;
            instanceName = evtInstance.Name;
        }

        //Get Event Info off of instance master detail id
        if (!String.isBlank(evtInfo.evtId)) {
            eventPage = [
                    SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Audience__c,Include_Time_frame_List__c,
                            Max_Other_Attendees__c, Allow_Other_Attendees__c, College_High_School_Ask__c, Ask_Gender__c, Template__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Ask_If_Parent__c
                    FROM UST_Event__c
                    WHERE Id = :evtInfo.evtId
                    LIMIT 1
            ][0];

            //Grab the template if defined
            if (!String.isBlank(eventPage.Template__c)) {
                templateSelected = eventPage.Template__c;
            }

            if (eventPage.Allow_Other_Attendees__c) {
                guestAmt = new List<SelectOption>();
                if (Integer.valueOf(eventPage.Max_Other_Attendees__c) > 0) {
                    for (Integer ma = 0; ma <= Integer.valueOf(eventPage.Max_Other_Attendees__c); ma++) {
                        System.debug(ma);
                        guestAmt.add(new SelectOption(String.valueOf(ma), String.valueOf(ma)));
                    }
                }
            }


            //Get Appoitment Types for event
            apptTypes = [SELECT Id, Title__c, Appointment_Category__c, Appointment_Type__c, Description__c FROM UST_Event_Appointment_Type__c WHERE UST_Event__c = :evtInfo.evtId];
        }

        //If the user is logged in use that data
        if ((!String.isBlank(EvtUserType) && EvtUserType != 'Guest' && EvtUserType != 'Standard') || (!String.isBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING')) {
            //Fill in contact information
            Contact userContact = new Contact();
            if (String.isBlank(evtInfo.evtRegId) || evtInfo.evtRegId == 'COMING') {
                userContact = [
                        Select Id, Name, FirstName, LastName, Email, EnrollmentrxRx__Gender__c, MailingStreetLine1__c, MailingStreetLine2__c, MailingState__c,
                                MailingZip__c, MailingCity__c, Home_Phone__c, MobilePhone, Receive_Texts__c, EnrollmentrxRx__High_School__c, EnrollmentrxRx__High_School_Code__c
                        From Contact
                        Where Id In (
                                Select ContactId
                                From User
                                Where Id = :UserInfo.getUserId()
                        )
                ];
                newEvtReg.Registrant_First_Name__c = userContact.FirstName;
                newEvtReg.Registrant_Last_Name__c = userContact.LastName;
                newEvtReg.Registrant_Email__c = userContact.Email;
                newEvtReg.Registrant_Gender__c = userContact.EnrollmentrxRx__Gender__c;
                newEvtReg.Registrant_Street_1__c = userContact.MailingStreetLine1__c;
                newEvtReg.Registrant_Street_2__c = userContact.MailingStreetLine2__c;
                newEvtReg.Registrant_State__c = userContact.MailingState__c;
                newEvtReg.Registrant_City__c = userContact.MailingCity__c;
                newEvtReg.Registrant_Zip__c = userContact.MailingZip__c;
                newEvtReg.Registrant_Phone__c = userContact.Home_Phone__c;
                newEvtReg.Registrant_Mobile_Phone__c = userContact.MobilePhone;
                newEvtReg.Registrant_College__c = userContact.EnrollmentrxRx__High_School__c;
                newEvtReg.Registrant_College_Code__c = userContact.EnrollmentrxRx__High_School_Code__c;
                newEvtReg.Registrant_High_School__c = userContact.EnrollmentrxRx__High_School__c;
                newEvtReg.Registrant_High_School_Code__c = userContact.EnrollmentrxRx__High_School_Code__c;

                if (userContact.Receive_Texts__c == 'Yes') {
                    newEvtReg.Registrant_Receive_Texts__c = true;
                }
                contactSet = true;
            } else {
                newEvtReg = [
                        SELECT Contact__c, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c,Number_of_Guests__c,
                                Registrant_Gender__c,Registrant_Street_1__c,Registrant_Street_2__c, Registrant_State__c,Registrant_City__c, Preferred_Visit_Time__c,
                                Registrant_Zip__c,Registrant_Phone__c,Registrant_Mobile_Phone__c, Registrant_College__c,Registrant_College_Code__c,Registrant_College_Year__c,
                                Registrant_High_School__c,Registrant_High_School_Code__c, Registrant_Receive_Texts__c, Registrant_High_School_Grad_Year__c, Registrant_High_School_Not_Found__c,
                                Registrant_College_Not_Found__c, Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c, Registrant_Parent_Phone__c, Registrant_Parent_Status__c
                        FROM UST_Event_Registration__c
                        WHERE id = :evtInfo.evtRegId
                ][0];
            }

            if(EvtUserType != 'Guest') {
                contactSet = true;
            }
        }
    }

    public PageReference setParentInfo(String n) {
        return null;
    }

    public PageReference checkEventDetails() {
        return USTShared.checkForEvent();
    }

    public List<SelectOption> getSexDD() {
        return GetDropdownOptions(Contact.EnrollmentrxRx__Gender__c.getDescribe());
    }

    public List<SelectOption> getStateDD() {
        return GetDropdownOptions(Contact.MailingState__c.getDescribe());
    }

    public List<SelectOption> getTimeFrame() {
        return GetDropdownOptions(UST_Event_Registration__c.Preferred_Visit_Time__c.getDescribe());
    }

    public List<SelectOption> getParentStatus() {
        return GetDropdownOptions(UST_Event_Registration__c.Registrant_Parent_Status__c.getDescribe());
    }

    public List<SelectOption> GetDropdownOptions(Schema.DescribeFieldResult fieldResult) {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Select...'));
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }

    public PageReference saveContactRegistration() {
        Integer contactCount = 0;
        String foundID = '';
        String softEmailMatches = '';
        String softFirstLastZipMatches = '';
        boolean newContactCreated = false;
        PageReference optionPage;
        //Test to find if contact already exists - HARD TEST last name and email match

        String lastName = newEvtReg.Registrant_Last_Name__c;
        String email = newEvtReg.Registrant_Email__c;
        List<Contact> hardContactTest = [SELECT Id FROM Contact WHERE LastName = :lastName AND Email = :email];

        if (hardContactTest.size() > 0) {
            test += 'Hard match contact found! ' + hardContactTest[0].Id + '<br>';
            contactId = hardContactTest[0].Id;
            contactCount++;
        } else {
            //Check if first name last name zip match
            List<Contact> zipContactTest = [SELECT Id FROM Contact WHERE FirstName = :newEvtReg.Registrant_First_Name__c AND LastName = :newEvtReg.Registrant_Last_Name__c AND MailingZip__c = :newEvtReg.Registrant_Zip__c];
            if (zipContactTest.size() > 0) {
                //Soft Match found with zip
                for (Contact c : zipContactTest) {
                    softFirstLastZipMatches += c.Id + ' ';
                }
                contactCount++;
            }
            List<Contact> emailContactTest = [SELECT Id FROM Contact WHERE Email = :newEvtReg.Registrant_Email__c];
            if (emailContactTest.size() > 0) {
                //Soft Match found with email
                for (Contact c : emailContactTest) {
                    softEmailMatches += c.Id + ' ';
                }
                contactCount++;
            }

            Contact newEvtContact = new Contact();
            newEvtContact.FirstName = newEvtReg.Registrant_First_Name__c;
            newEvtContact.LastName = newEvtReg.Registrant_Last_Name__c;
            if (emailContactTest.size() > 0) {
                //Check dup number until you find a free one
                String dupMatch = '';
                for (Integer x = 1; x <= 10; x++) {
                    dupMatch = 'Event_Dup_' + String.valueOf(x) + '_';
                    String dupMatchTest = dupMatch + newEvtReg.Registrant_Email__c;
                    List<Contact> dupMatches = [SELECT Id FROM Contact WHERE Email = :dupMatchTest];
                    if (dupMatches.size() <= 0) {
                        break;
                    }
                }
                newEvtContact.Email = dupMatch + newEvtReg.Registrant_Email__c;
            } else {
                newEvtContact.Email = newEvtReg.Registrant_Email__c;
            }
            newEvtContact.EnrollmentrxRx__Gender__c = newEvtReg.Registrant_Gender__c;
            newEvtContact.MailingStreetLine1__c = newEvtReg.Registrant_Street_1__c;
            newEvtContact.MailingStreetLine2__c = newEvtReg.Registrant_Street_2__c;
            newEvtContact.MailingCity__c = newEvtReg.Registrant_City__c;
            newEvtContact.MailingZip__c = newEvtReg.Registrant_Zip__c;
            newEvtContact.MailingState__c = newEvtReg.Registrant_State__c;
            newEvtContact.MobilePhone = newEvtReg.Registrant_Mobile_Phone__c;
            newEvtContact.HomePhone = newEvtReg.Registrant_Phone__c;


            if (!String.isBlank(newEvtReg.Registrant_High_School_Code__c) && String.isBlank(newEvtReg.Registrant_College_Code__c)) {
                newEvtContact.EnrollmentrxRx__High_School_Code__c = newEvtReg.Registrant_High_School_Code__c;
            } else if (!String.isBlank(newEvtReg.Registrant_College_Code__c)) {
                newEvtContact.EnrollmentrxRx__High_School_Code__c = newEvtReg.Registrant_College_Code__c;
            }


            if (newEvtReg.Registrant_Receive_Texts__c = true) {
                newEvtContact.Receive_Texts__c = 'Yes';
            }
            try {
                upsert newEvtContact;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
            contactId = newEvtContact.Id;
            newContactCreated = true;
            //Create new contact
        }
        newEvtReg.Status__c = 'Started';
        newEvtReg.Date__c = Date.valueof(evtInstance.Start_Date_Time__c);
        //Create registration if event Registration does not exist
        if (!String.isBlank(contactId)) {
            if (String.isBlank(evtInfo.evtRegId) || evtInfo.evtRegId == 'COMING') {
                newEvtReg.Event__c = evtInfo.evtId;
                newEvtReg.Event_Instance__c = evtInfo.instanceID;
                newEvtReg.Contact__c = contactId;
                if (newContactCreated) {
                    newEvtReg.New_Contact_Created__c = true;
                    newEvtReg.Contact_Soft_Match_Email__c = softEmailMatches;
                    newEvtReg.Contact_Soft_Match_First_Last_Zip__c = softFirstLastZipMatches;
                }

                try {
                    insert newEvtReg;
                } catch (Exception ex) {
                    //  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                    //  ApexPages.addMessage(myMsg);
                }
                evtInfo.evtRegId = newEvtReg.Id;
            } else {
                //update registration if Registration exists
                try {
                    upsert newEvtReg;
                } catch (Exception ex) {
                    //   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                    //   ApexPages.addMessage(myMsg);
                }

            }
        }

        if (!String.isBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING') {
            List<UST_Event_Appointment_Type__c> apptTypes = [
                    SELECT Id From UST_Event_Appointment_Type__c
                    WHERE UST_Event__c = :evtInfo.evtId
                    AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
            ];
            if (apptTypes.size() == 0) {
                //If no options skip that step
                optionPage = Page.USTEventSubmit;
            } else {
                optionPage = Page.USTEventRegistrationOptions;
            }
            // create cookie to pass on to next page
            //Posting along everything we need to build the next page
            String encrytpString = USTShared.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"' + evtInfo.evtRegId + '","evtId":"' + evtInfo.evtId + '"}', 'USTEvent');
            //optionPage.getParameters().put('evt', encrytpString);
            return optionPage;
        }

        return null;
    }

}