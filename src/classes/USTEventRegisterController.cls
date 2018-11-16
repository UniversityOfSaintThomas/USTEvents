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
    public boolean eventIsClosed { get; set; }
    public List<String> questionNum { get; set; }
    public List<SelectOption> addPick1 { get; set; }
    public List<SelectOption> addPick2 { get; set; }
    public List<SelectOption> addPick3 { get; set; }
    public List<SelectOption> addPick4 { get; set; }
    public List<SelectOption> addPick5 { get; set; }
    public List<String> selectedPrograms { get; set; }

    public USTEventRegisterController() {
        selectedPrograms = new List<String>();
        //array for looping through additional information questions
        questionNum = new List<String>{
                '1', '2', '3', '4', '5'
        };

        newEvtReg = new UST_Event_Registration__c();
        templateSelected = USTShared.defaultTemplate;
        test = '';
        contactSet = false;
        eventIsClosed = false;
        EvtUserType = UserInfo.getUserType();
        //Get cookie or URL string variable
        evtInfo = USTShared.getUSTEventInfo();

        //Get Instance information
        if (!String.isBlank(evtInfo.instanceID)) {
            evtInstance = [
                    SELECT Id, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Id, Instance_Title__c, Active_Status__c, Capacity__c,
                            Event__r.Event_description__c, Event__r.Audience__c, Start_Date_Time__c, End_Date_Time__c, Current_Available_Capacity__c
                    FROM UST_Event_Instance__c
                    WHERE Id = :evtInfo.instanceID
                    LIMIT 1
            ][0];

            //define Event ID from instanceInfo data
            evtInfo.evtId = evtInstance.Event__r.Id;
            instanceName = evtInstance.Name;
            if (evtInstance.Current_Available_Capacity__c == 0 || evtInstance.Active_Status__c != 'Active') {
                eventIsClosed = true;
            }
        }

        //Get Event Info off of instance master detail id
        if (!String.isBlank(evtInfo.evtId)) {
            eventPage = [
                    SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Audience__c,Include_Time_frame_List__c,
                            Max_Other_Attendees__c, Allow_Other_Attendees__c, College_High_School_Ask__c, Ask_Gender__c, Template__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Ask_If_Parent__c, Ask_Program_Interest__c,
                            Add_Info_Question_Pick_List_1__c, Add_Info_Question_Text_1__c, Add_Info_Question_Type_1__c,
                            Add_Info_Question_Pick_List_2__c, Add_Info_Question_Text_2__c, Add_Info_Question_Type_2__c,
                            Add_Info_Question_Pick_List_3__c, Add_Info_Question_Text_3__c, Add_Info_Question_Type_3__c,
                            Add_Info_Question_Pick_List_4__c, Add_Info_Question_Text_4__c, Add_Info_Question_Type_4__c,
                            Add_Info_Question_Pick_List_5__c, Add_Info_Question_Text_5__c, Add_Info_Question_Type_5__c,
                            Academic_Program_List__c, School__c
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

            addPick1 = createPicklists(eventPage.Add_Info_Question_Pick_List_1__c);
            addPick2 = createPicklists(eventPage.Add_Info_Question_Pick_List_2__c);
            addPick3 = createPicklists(eventPage.Add_Info_Question_Pick_List_3__c);
            addPick4 = createPicklists(eventPage.Add_Info_Question_Pick_List_4__c);
            addPick5 = createPicklists(eventPage.Add_Info_Question_Pick_List_5__c);
        }

        //If the user is logged in use that data
        if ((!String.isBlank(EvtUserType) && EvtUserType != 'Guest' && EvtUserType != 'Standard') || (!String.isBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING')) {
            //Fill in contact information
            Contact userContact = new Contact();
            if (String.isBlank(evtInfo.evtRegId) || evtInfo.evtRegId == 'COMING') {
                userContact = [
                        Select Id, Name, FirstName, LastName, Email, EnrollmentrxRx__Gender__c, MailingStreetLine1__c, MailingStreetLine2__c, MailingState__c,
                                MailingZip__c, MailingCity__c, Home_Phone__c, MobilePhone, Receive_Texts__c, EnrollmentrxRx__High_School__c, EnrollmentrxRx__High_School_Code__c,
                                EnrollmentrxRx__High_School__r.Name, EnrollmentrxRx__High_School__r.EnrollmentrxRx__CEEB_Code__c
                        FROM Contact
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
                newEvtReg.Registrant_College__c = userContact.EnrollmentrxRx__High_School__r.Name;
                newEvtReg.Registrant_College_Code__c = userContact.EnrollmentrxRx__High_School__r.EnrollmentrxRx__CEEB_Code__c;
                newEvtReg.Registrant_High_School__c = userContact.EnrollmentrxRx__High_School__r.Name;
                newEvtReg.Registrant_High_School_Code__c = userContact.EnrollmentrxRx__High_School__r.EnrollmentrxRx__CEEB_Code__c;

                if (userContact.Receive_Texts__c == 'Yes') {
                    newEvtReg.Registrant_Receive_Texts__c = true;
                }
                contactSet = true;
            } else {
                newEvtReg = [
                        SELECT Contact__c, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c, Number_of_Guests__c,
                                Registrant_Gender__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_State__c, Registrant_City__c, Preferred_Visit_Time__c,
                                Registrant_Zip__c, Registrant_Phone__c, Registrant_Mobile_Phone__c, Registrant_College__c, Registrant_College_Code__c, Registrant_College_Year__c,
                                Registrant_High_School__c, Registrant_High_School_Code__c, Registrant_Receive_Texts__c, Registrant_High_School_Grad_Year__c, Registrant_High_School_Not_Found__c,
                                Registrant_College_Not_Found__c, Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c, Registrant_Parent_Phone__c, Registrant_Parent_Status__c,
                                Add_Info_Answer_1__c, Add_Info_Answer_2__c, Add_Info_Answer_3__c, Add_Info_Answer_4__c, Add_Info_Answer_5__c, Registrant_Program_Interest__c
                        FROM UST_Event_Registration__c
                        WHERE id = :evtInfo.evtRegId
                ][0];
            }

            if (EvtUserType != 'Guest') {
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


    public List<SelectOption> getProgramsAvailable() {
        String prgString = eventPage.Academic_Program_List__c;
        String prgSelectedAlready = newEvtReg.Registrant_Program_Interest__c;

        //If program list is empty then get the full list
        If (String.isBlank(prgString)) {
            List<Major__c> schoolProgs = new List<Major__c>();
            if (!String.isBlank(eventPage.School__c)) {
                Id schoolId = eventPage.School__c;
                schoolProgs = [
                        SELECT Id,Name, Major_Name__c,Major_Display_Name__c, Major_Code__c, Program_Offered__r.Program_Code__c, Program_Offered__r.Degree_Level__c
                        FROM Major__c
                        WHERE Status__c = 'Active'
                        AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                        AND Program_Offered__r.Program_Code__c != NULL
                        AND Program_Offered__r.School__c = :schoolId
                        ORDER BY Major_Name__c
                ];
            } else {
                schoolProgs = [
                        SELECT Id,Name, Major_Name__c,Major_Display_Name__c, Major_Code__c, Program_Offered__r.Program_Code__c, Program_Offered__r.Degree_Level__c
                        FROM Major__c
                        WHERE Status__c = 'Active'
                        AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                        AND Program_Offered__r.Program_Code__c != NULL
                        ORDER BY Major_Name__c
                ];
            }
            //turn list into a ; separated string to consume below
            prgString = '';
            For (Major__c prog : schoolProgs) {
                prgString += prog.Major_Display_Name__c + ' - ' + prog.Program_Offered__r.Degree_Level__c + ' (' + prog.Program_Offered__r.Program_Code__c;
                if (!String.isBlank(prog.Major_Code__c)) {
                    prgString += '|' + prog.Major_Code__c;
                }
                prgString += ');';
            }
            prgString = prgString.removeEnd(';');
        }

        List<SelectOption> progSelOpt = new List<SelectOption>();
        progSelOpt.add(new SelectOption('', 'Select...'));

        List<String> prgList = prgString.split(';');
        for (String prg : prgList) {
            progSelOpt.add(
                    new SelectOption(
                            prg,
                            prg.replaceAll('\\(\\w+\\|\\w+\\)|\\(\\w+\\)', '').trim()
                    )
            );
            if (!String.isBlank(prgSelectedAlready)) {
                if (prgSelectedAlready.indexOf(prg) > -1) {
                    selectedPrograms.add(prg);
                }
            }
        }
        return progSelOpt;

    }

//    public List<SelectOption> setProgramsAvailable() {
//        String prgString = eventPage.Academic_Program_List__c;
//        String prgSelectedAlready = newEvtReg.Registrant_Program_Interest__c;
//        List<SelectOption> previousSelected = new List<SelectOption>();
//        previousSelected.add(new SelectOption('Digital Experience (BU_GR_CER|BUDE)', 'Digital Experience'));
//        return previousSelected;
//    }

    public List<SelectOption> GetDropdownOptions(Schema.DescribeFieldResult fieldResult) {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Select...'));
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }

    public List<SelectOption> createPicklists(String returnSepStringList) {
        List<SelectOption> cpl = new List<SelectOption>();
        if (!String.isBlank(returnSepStringList)) {
            cpl.add(new SelectOption('', 'Select...'));
            returnSepStringList = returnSepStringList.Trim();
            returnSepStringList = returnSepStringList.replace('\n\n', '\n');
            String[] splitList = returnSepStringList.split('\n');
            for (String p : splitList) {
                p = p.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                cpl.add(new SelectOption(p, p));
            }
        }
        return cpl;
    }

    public PageReference saveContactRegistration() {
        Integer contactCount = 0;
        String foundID = '';
        String softEmailMatches = '';
        String softFirstLastZipMatches = '';
        boolean newContactCreated = false;
        PageReference optionPage;

        //Record selected programs of interest
        String recordSelPrg = '';
        Pattern TAG_REGEX = Pattern.compile('\\((\\w+|\\w+\\|\\w+)\\)');
        List<String> majorCodes = new List<String>();
        Boolean progSelectionMade = true;

        if (selectedPrograms.isEmpty() && !String.isBlank(eventPage.Academic_Program_List__c)) {
            selectedPrograms = eventPage.Academic_Program_List__c.split(';');
            progSelectionMade = false;
        }

        if (!selectedPrograms.isEmpty()) {
            for (String selPrg : selectedPrograms) {
                recordSelPrg += selPrg + ';';
                Matcher matcher = TAG_REGEX.matcher(selPrg);
                while (matcher.find()) {
                    majorCodes.add(matcher.group(1).trim());
                }
            }
            recordSelPrg.removeEnd(';');

            List<Major__c> majorIdList = [SELECT Id From Major__c Where Prog_Major_Conc_Code__c IN :majorCodes];

            if (majorIdList.size() > 0) {
                for (Integer mc = 0; mc < 4; mc++) {
                    if (mc < majorIdList.size()) {
                        if (mc == 0) {
                            newEvtReg.Registrant_Major__c = majorIdList[0].id;
                        } else {
                            newEvtReg.put('Registrant_Major_' + (mc + 1) + '__c', majorIdList[mc].id);
                        }
                    } else {
                        newEvtReg.put('Registrant_Major_' + (mc + 1) + '__c', '');
                    }
                }
            }
            //get major ids and save them
        }

        if (eventPage.Ask_Program_Interest__c && progSelectionMade) {
            newEvtReg.Registrant_Program_Interest__c = recordSelPrg;
        } else {
            newEvtReg.Registrant_Program_Interest__c = '';
        }

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
            List<Contact> zipContactTest = [
                    SELECT Id
                    FROM Contact
                    WHERE FirstName = :newEvtReg.Registrant_First_Name__c
                    AND LastName = :newEvtReg.Registrant_Last_Name__c
                    AND MailingZip__c = :newEvtReg.Registrant_Zip__c
            ];
            if (zipContactTest.size() > 0) {
                //Soft Match found with zip
                for (Contact c : zipContactTest) {
                    softFirstLastZipMatches += c.Id + ' ';
                }
                contactCount++;
            }
            List<Contact> emailContactTest = [
                    SELECT Id
                    FROM Contact
                    WHERE Email = :newEvtReg.Registrant_Email__c
            ];
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
            newEvtContact.High_School_Expected_Graduation_Year__c = newEvtReg.Registrant_High_School_Grad_Year__c;
            newEvtContact.LeadSource = 'Event';

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
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                    ApexPages.addMessage(myMsg);
                }
                evtInfo.evtRegId = newEvtReg.Id;
            } else {
                //update registration if Registration exists
                try {
                    upsert newEvtReg;
                } catch (Exception ex) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                    ApexPages.addMessage(myMsg);
                }

            }
        }

        if (!String.isBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING') {
            List<UST_Event_Appointment_Type__c> apptTypes = [
                    SELECT Id
                    From UST_Event_Appointment_Type__c
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