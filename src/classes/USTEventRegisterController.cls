/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventRegisterController {
    public String test { get; set; }
    public UST_Event_Instance__c evtInstance { get; set; }
    public UST_Event__c eventPage { get; set; }
    public String ContactId { get; set; }
    public String instanceName { get; set; }
    public String EvtUserType { get; set; }
    public List<SelectOption> guestAmt { get; set; }
    public UST_Event_Registration__c newEvtReg { get; set; }
    public UST_Event_Registration__c oldEvtReg { get; set; }
    private USTEventShared USTShared = new USTEventShared();
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public String templateSelected { get; set; }
    public Boolean contactSet { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean additionalQuestions { get; set; }
    public List<String> questionNum { get; set; }
    public List<SelectOption> addPick1 { get; set; }
    public List<SelectOption> addPick2 { get; set; }
    public List<SelectOption> addPick3 { get; set; }
    public List<SelectOption> addPick4 { get; set; }
    public List<SelectOption> addPick5 { get; set; }
    public List<String> selectedPrograms { get; set; }
    public String selectedProgramsOne { get; set; }
    public Boolean showAddress { get; set; }
    public Boolean showPhone { get; set; }
    public String applicantType { get; set; }
    public String locationCrumb { get; set; }
    public String eventStartDateTimeCrumb { get; set; }
    public Boolean evtHasAppointments { get; set; }
    public String birthDateString { get; set; }
    public String dataLayerLocationType { get; set; }
    public String JSONLDStartTimeString { get; set; }
    public String JSONLDEndTimeString { get; set; }
    public Boolean excludeSearchTag { get; set; }
    public Boolean adminOpen { get; set; }
    public String oldRegistrationId { get; set; }


    public USTEventRegisterController() {
        selectedPrograms = new List<String>();
        selectedProgramsOne = '';
        //array for looping through additional information questions
        questionNum = new List<String>{
                '1', '2', '3', '4', '5'
        };

        doCRUD CRUDToDo = new doCRUD();

        newEvtReg = new UST_Event_Registration__c();
        templateSelected = USTShared.defaultTemplate;
        test = '';
        contactSet = false;
        eventIsClosed = false;
        additionalQuestions = false;
        showAddress = false;
        showPhone = false;
        locationCrumb = '';

        EvtUserType = UserInfo.getUserType();
        //Get cookie or URL string variable
        evtInfo = USTShared.getUSTEventInfo();

        //Set applicant type if audience is passed
        if (!String.isBlank(evtInfo.audience)) {
            if (evtInfo.audience == 'Transfer' || evtInfo.audience == 'Transfer International') {
                applicantType = 'Transfer';
            } else if (evtInfo.audience == 'High School Senior' || evtInfo.audience == 'High School Junior or Younger' || evtInfo.audience == 'First-Year International' || evtInfo.audience == 'Dougherty Family College (2-Year)') {
                applicantType = 'First-Year';
            }
        }

        //Get Instance information
        if (String.isNotBlank(evtInfo.instanceID)) {
            evtInstance = [
                    SELECT Id, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Id, Instance_Title__c, Active_Status__c, Capacity__c,
                            Event__r.Event_description__c, Event__r.Audience__c, Start_Date_Time__c, End_Date_Time__c, Current_Available_Capacity__c,
                            Location_Type_Override__c, Location_Address_Override__c, Location_Map_Link_Override__c, Location_Title_Override__c,
                            Exclude_Search_Engine_Tag_Override__c
                    FROM UST_Event_Instance__c
                    WHERE Id = :evtInfo.instanceID
                    LIMIT 1
            ][0];

            JSONLDStartTimeString = String.valueOf(evtInstance.Start_Date_Time__c);
            JSONLDEndTimeString = String.valueOf(evtInstance.End_Date_Time__c);
            //changing the date format for Json-LD start and end date

            String dateFormat = 'EEE, d MMM yyyy HH:mm:ss Z';

            JSONLDStartTimeString = evtInstance.Start_Date_Time__c.format(dateFormat);

            JSONLDEndTimeString = evtInstance.End_Date_Time__c.format(dateFormat);

            //define Event ID from instanceInfo data
            evtInfo.evtId = evtInstance.Event__r.Id;
            instanceName = evtInstance.Name;

        }

        //Get Event Info off of instance master detail id
        if (!String.isBlank(evtInfo.evtId)) {
            eventPage = [
                    SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Audience__c,Include_Time_frame_List__c,
                            Max_Other_Attendees__c, Allow_Other_Attendees__c, College_High_School_Ask__c, Ask_Gender__c, Template__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Ask_If_Parent__c, Ask_Registrant_Program_Of_Interest__c,
                            Add_Info_Question_Pick_List_1__c, Add_Info_Question_Text_1__c, Add_Info_Question_Type_1__c,
                            Add_Info_Question_Pick_List_2__c, Add_Info_Question_Text_2__c, Add_Info_Question_Type_2__c,
                            Add_Info_Question_Pick_List_3__c, Add_Info_Question_Text_3__c, Add_Info_Question_Type_3__c,
                            Add_Info_Question_Pick_List_4__c, Add_Info_Question_Text_4__c, Add_Info_Question_Type_4__c,
                            Add_Info_Question_Pick_List_5__c, Add_Info_Question_Text_5__c, Add_Info_Question_Type_5__c,
                            School__c, School__r.Name, Ask_Mailing_Address__c, Ask_Phone__c, Event_Sponsor__c,
                            Applicant_Type__c, Location_Type__c, Location_Title__c, Location_Address__c, Location_Map_Link__c,
                            Tracking_Event_Registration__c, Ask_Date_Of_Birth__c, Event_Type__c, RecordType.Name, Contact_Creation__c,
                            Exclude_Search_Engine_Tag__c, Registration_Email_Restriction__c, Program_Filter__c, Program_Filter_2__c, Program_Filter_3__c,
                            Keep_Registration_Open_During_Event__c, Close_Event_Days_Before__c
                    FROM UST_Event__c
                    WHERE Id = :evtInfo.evtId
                    LIMIT 1
            ][0];

            if (!String.isBlank(eventPage.Applicant_Type__c)) {
                applicantType = eventPage.Applicant_Type__c;
            }

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = USTShared.isEventClosed(eventPage, evtInstance);
            }

            //Figure out if the event is closed.
            if (
                    !String.isBlank(eventPage.Add_Info_Question_Type_1__c) ||
                            !String.isBlank(eventPage.Add_Info_Question_Type_1__c) || !String.isBlank(eventPage.Add_Info_Question_Type_1__c) || !String.isBlank(eventPage.Add_Info_Question_Type_1__c) ||
                            !String.isBlank(eventPage.Add_Info_Question_Type_1__c) || eventPage.Include_Time_frame_List__c || eventPage.Allow_Other_Attendees__c || (eventPage.Ask_Gender__c != 'Do not ask' && eventPage.Ask_Gender__c != null) || (eventPage.Ask_Registrant_Program_Of_Interest__c != 'Do not ask' && eventPage.Ask_Registrant_Program_Of_Interest__c != null)
                    ) {
                additionalQuestions = true;
            }

            String locationTitle = '';
            if (!String.isBlank(evtInstance.Location_Title_Override__c)) {
                locationTitle = evtInstance.Location_Title_Override__c;
            } else if (!String.isBlank(eventPage.Location_Title__c)) {
                locationTitle = eventPage.Location_Title__c;
            }

            String locationMapLink = '';
            if (!String.isBlank(evtInstance.Location_Map_Link_Override__c)) {
                locationMapLink = evtInstance.Location_Map_Link_Override__c;
            } else if (!String.isBlank(eventPage.Location_Map_Link__c)) {
                locationMapLink = eventPage.Location_Map_Link__c;
            }

            String locationAddress = '';
            if (!String.isBlank(evtInstance.Location_Address_Override__c)) {
                locationAddress = evtInstance.Location_Address_Override__c;
            } else if (!String.isBlank(eventPage.Location_Title__c)) {
                locationAddress = eventPage.Location_Title__c;
            }
            dataLayerLocationType = locationAddress;

            if (!String.isBlank(locationTitle) && String.isBlank(locationMapLink)) {
                locationCrumb = locationTitle + '<br/>';
            }

            if (!String.isBlank(locationAddress) && !String.isBlank(locationMapLink)) {
                locationCrumb += ' <a href="' + locationMapLink + '" target="_blank">' + locationAddress + '</a><br/>';
            } else if (!String.isBlank(locationMapLink)) {
                locationCrumb += ' <a href="' + locationMapLink + '" target="_blank">Map</a><br/>';
            }

            if (evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null) {
                eventStartDateTimeCrumb = evtInstance.Start_Date_Time__c.format('MMMM d, YYYY, h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a');
            }

            if (!String.isBlank(locationCrumb)) {
                locationCrumb = locationCrumb.removeEnd('<br/>');
                String eventTime = '';
                if (evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null) {
                    eventTime = evtInstance.Start_Date_Time__c.format('EEEE MMMM dd, YYYY');
                    eventTime += '<br/>' + evtInstance.Start_Date_Time__c.format('h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a') + '<br/>';
                }
                locationCrumb = eventTime + locationCrumb;
                locationCrumb = '<h3>Event Details</h3> <p>' + locationCrumb + '</p>';
            }

            //Check if the Event has appointments and therefore we have to redirect to the appointment page.
            evtHasAppointments = false;
            List<UST_Event_Appointment_Type__c> apptTypes = [
                    SELECT Id
                    FROM UST_Event_Appointment_Type__c
                    WHERE UST_Event__c = :evtInfo.evtId
                    AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = NULL)
            ];
            if (apptTypes.size() > 0) {
                evtHasAppointments = true;
            }

            //Grab the template if defined
            if (!String.isBlank(eventPage.Template__c)) {
                templateSelected = eventPage.Template__c;
            }

            if (eventPage.Allow_Other_Attendees__c) {
                guestAmt = new List<SelectOption>();
                if (Integer.valueOf(eventPage.Max_Other_Attendees__c) > 0) {
                    for (Integer ma = 0; ma <= Integer.valueOf(eventPage.Max_Other_Attendees__c); ma++) {
                        guestAmt.add(new SelectOption(String.valueOf(ma), String.valueOf(ma)));
                    }
                }
            }

            //creating a flag for json-ld
            excludeSearchTag = false;
            if (eventPage.Exclude_Search_Engine_Tag__c || evtInstance.Exclude_Search_Engine_Tag_Override__c) {
                excludeSearchTag = true;
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
                userContact = CRUDToDo.getUserFromContact();

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
                newEvtReg.Registrant_Preferred_First_Name__c = userContact.Preferred_First_Name__c;
                newEvtReg.Registrant_Date_of_Birth__c = userContact.Birthdate;
                if (userContact.Birthdate != null) {
                    birthDateString = userContact.Birthdate.format();
                }

                if (String.isBlank(userContact.Id)) {
                    ContactId = userContact.Id;
                }
                if (userContact.Receive_Texts__c == 'Yes') {
                    newEvtReg.Registrant_Receive_Texts__c = true;
                }
                contactSet = true;
            } else {
                newEvtReg = [
                        SELECT Contact__c, Contact__r.Id, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c, Number_of_Guests__c,
                                Registrant_Gender__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_State__c, Registrant_City__c, Preferred_Visit_Time__c,
                                Registrant_Zip__c, Registrant_Phone__c, Registrant_Mobile_Phone__c, Registrant_College__c, Registrant_College_Code__c, Registrant_College_Year__c,
                                Registrant_High_School__c, Registrant_High_School_Code__c, Registrant_Receive_Texts__c, Registrant_High_School_Grad_Year__c, Registrant_High_School_Not_Found__c,
                                Registrant_College_Not_Found__c, Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c, Registrant_Parent_Phone__c, Registrant_Parent_Status__c,
                                Add_Info_Answer_1__c, Add_Info_Answer_2__c, Add_Info_Answer_3__c, Add_Info_Answer_4__c, Add_Info_Answer_5__c, Registrant_Program_Interest__c, Registrant_Preferred_First_Name__c,
                                Registrant_Date_of_Birth__c, Registrant_Other_Email__c, Registrant_Other_First_Name__c, Registrant_Other_Last_Name__c, Registrant_Other_Phone__c, Registrant_Other_Relationship__c,
                                Registrant_Country__c, Registrant_State_Province__c, Registrant_Postal_Code__c, Registrant_Applicant_Type__c
                        FROM UST_Event_Registration__c
                        WHERE Id = :evtInfo.evtRegId
                ][0];

                if (newEvtReg.Registrant_Date_of_Birth__c != null) {
                    birthDateString = newEvtReg.Registrant_Date_of_Birth__c.format();
                }

                if (String.isNotBlank(newEvtReg.Registrant_Applicant_Type__c)) {
                    applicantType = newEvtReg.Registrant_Applicant_Type__c;
                }

                //for comparison after the form is filled out we keep original queried event the see if key information is changed and matching should be redone.
                oldEvtReg = newEvtReg;
            }


            if (EvtUserType != 'Guest') {
                contactSet = true;
            }
        }

        if (String.isBlank(newEvtReg.Registrant_Country__c)) {
            newEvtReg.Registrant_Country__c = 'United States';
        }

        oldRegistrationId = newEvtReg.Id;
        newEvtReg.Id = null;

    }

    public PageReference checkEventDetails() {
        return USTShared.checkForEvent();
    }

    public List<SelectOption> getSexDD() {
        return PickThePicklist('UST_Event_Registration__c', 'Registrant_Gender__c', true);
    }

    public List<SelectOption> getStateDD() {
        return PickThePicklist('Contact', 'MailingState__c', true);
    }

    public List<SelectOption> getCountryDD() {
        return PickThePicklist('UST_Event_Registration__c', 'Registrant_Country__c', true);
    }

    public List<SelectOption> getTimeFrame() {
        return PickThePicklist('UST_Event_Registration__c', 'Preferred_Visit_Time__c', true);
    }

    public List<SelectOption> getParentStatus() {
        return PickThePicklist('UST_Event_Registration__c', 'Registrant_Parent_Status__c', true);
    }

    public List<SelectOption> getApplicantTypeDD() {
        return PickThePicklist('UST_Event_Registration__c', 'Registrant_Applicant_Type__c', true);
    }

    public List<SelectOption> getRelationshipDD() {
        return PickThePicklist('UST_Event_Registration__c', 'Relationship_to_St_Thomas__c', false);
    }


    public String concatenatedProgramFilter() {
        String bigProgramList = '';
        if (String.isNotBlank(eventPage.Program_Filter__c)) {
            bigProgramList += eventPage.Program_Filter__c.trim();
        }
        if (String.isNotBlank(eventPage.Program_Filter_2__c)) {
            bigProgramList += eventPage.Program_Filter_2__c.trim();
        }
        if (String.isNotBlank(eventPage.Program_Filter_3__c)) {
            bigProgramList += eventPage.Program_Filter_3__c.trim();
        }
        return bigProgramList;
    }


    public List<SelectOption> getProgramsAvailable() {

        doCRUD CRUDToDo = new doCRUD();
        String bigProgramList = concatenatedProgramFilter();
        List<Major__c> majorList = new List<Major__c>();
        List<SelectOption> selectableProgramList = new List<SelectOption>();

        if (String.isNotBlank(bigProgramList)) {
            //Get the defined list of programs from event record
            majorList = CRUDToDo.getSchoolMajorsByShortCode(bigProgramList);
        } else {
            //Get a full list if none have been defined.
            if (!String.isBlank(eventPage.School__c)) {
                Id schoolId = eventPage.School__c;
                majorList = CRUDToDo.getSchoolMajors(schoolId);
            } else {
                majorList = CRUDToDo.getSchoolMajors(null);
            }
        }

        if (majorList.size() > 0) {
            String programName = '';
            String programValue = '';
            selectableProgramList.add(new SelectOption('', 'Select...'));
            for (Major__c major : majorList) {
                if (major != null) {
                    programValue = major.Major_Display_Name__c +  ' - ' + major.Program_Offered__r.Degree_Level__c + ' (' + major.Prog_Major_Conc_Code__c + ')';
                    programName = major.Major_Display_Name__c + ' - ' + major.Program_Offered__r.Degree_Level__c;
                    selectableProgramList.add(new SelectOption(programValue, programName));
                }
            }

            //Populate if selections have already been made
            selectedProgramsOne = '';
            if (String.isNotEmpty(newEvtReg.Registrant_Program_Interest__c)) {
                selectedProgramsOne = newEvtReg.Registrant_Program_Interest__c;
            }

        }
        return selectableProgramList;

    }

    public List<SelectOption> createPicklists(String returnSepStringList) {
        List<SelectOption> cpl = new List<SelectOption>();
        if (!String.isBlank(returnSepStringList)) {
            cpl.add(new SelectOption('', 'Select...'));
            returnSepStringList = returnSepStringList.trim();
            returnSepStringList = returnSepStringList.replace('\n\n', '\n');
            String[] splitList = returnSepStringList.split('\n');
            for (String p : splitList) {
                p = p.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                cpl.add(new SelectOption(p, p));
            }
        }
        return cpl;
    }

    public List<SelectOption> PickThePicklist(String YourObjectName, String YourFieldName, Boolean includeSelect) {
        List<SelectOption> picklists = new List<SelectOption>();
        List<Schema.PicklistEntry> PicklistValues = Schema.getGlobalDescribe().get(YourObjectName).getDescribe().fields.getMap().get(YourFieldName).getDescribe().getPicklistValues();

        if (includeSelect) {
            picklists.add(new SelectOption('', 'Select...'));
        }

        for (Schema.PicklistEntry PicklistValue : PicklistValues) {
            picklists.add(new SelectOption(PicklistValue.getValue(), PicklistValue.getLabel()));
        }

        return picklists;
    }

    public PageReference saveContactRegistration() {

        Boolean newContactCreated = false;
        PageReference optionPage = Page.USTEventRegister;

        //Record selected programs of interest
        Pattern TAG_REGEX = Pattern.compile('\\(([^\\)]+)\\)');
        List<String> majorCodes = new List<String>();

        doCRUD CRUDToDo = new doCRUD();

        if (String.isNotBlank(eventPage.Registration_Email_Restriction__c) && eventPage.Registration_Email_Restriction__c != 'No Limit') {
            UST_Event_Registration__c foundRegistration = CRUDToDo.checkForOtherRegistrations(eventPage.Registration_Email_Restriction__c, newEvtReg.Registrant_Email__c, evtInstance.Id, eventPage.Id);
            if (foundRegistration != null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'It appears you’ve already registered for this event. Please contact the Event Host for more information.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }

        //Record selected programs - get list of defined programs if it exists.
        String bigProgramList = concatenatedProgramFilter();

        //Programs were defined for the event, but the registrant was not asked. Then we apply the top 3 defined programs.
        if (String.isNotBlank(bigProgramList) && (String.isBlank(eventPage.Ask_Registrant_Program_Of_Interest__c) || eventPage.Ask_Registrant_Program_Of_Interest__c.equalsIgnoreCase('Do not ask'))) {
            List<Major__c> missingMajorList = CRUDToDo.getSchoolMajorsByShortCode(bigProgramList);
            Integer xx = 1;
            //List<String>()
            for (Major__c major : missingMajorList) {
                selectedPrograms.add(major.Major_Display_Name__c + ' - ' + major.Program_Offered__r.Degree_Level__c + ' (' + major.Prog_Major_Conc_Code__c + ')');
                if (xx >= 4) {
                    break;
                }
                xx++;
            }
        }

        if (!String.isBlank(selectedProgramsOne)) {
            selectedPrograms.add(selectedProgramsOne);
        }

        if (!selectedPrograms.isEmpty()) {

            //reverse selectedPrograms to record in order of selected
            List<String> reversePrograms = new List<String>();
            for (String rp : selectedPrograms) {
                reversePrograms.add(rp);
            }
            selectedPrograms = reversePrograms;


            //Get the major codes out of the selected program string
            for (String selPrg : selectedPrograms) {
                Matcher matcher = TAG_REGEX.matcher(selPrg);
                while (matcher.find()) {
                    majorCodes.add(matcher.group(1).replace('(', '').replace(')', '').trim());
                }
            }
            //Get the major code IDs and record them to the 4 available major code spots

            //Clear out major codes in case this is a previous page
            newEvtReg.Registrant_Major__c = newEvtReg.Registrant_Major_2__c = newEvtReg.Registrant_Major_3__c = newEvtReg.Registrant_Major_4__c = null;

            List<Major__c> majorIdList = CRUDToDo.getMajorCodes(majorCodes);

            if (majorIdList.size() > 0) {
                for (Integer mc = 0; mc < 4; mc++) {
                    if (mc < majorIdList.size()) {
                        if (mc == 0) {
                            newEvtReg.Registrant_Major__c = majorIdList[0].Id;
                        } else {
                            newEvtReg.put('Registrant_Major_' + (mc + 1) + '__c', majorIdList[mc].Id);
                        }
                    } else {
                        newEvtReg.put('Registrant_Major_' + (mc + 1) + '__c', '');
                    }
                }
            }
            //Record selections to the open picklist for Registrant program of interest.

            newEvtReg.Registrant_Program_Interest__c = String.join(selectedPrograms, ';');
        }

        if (String.isNotBlank(birthDateString)) {
            newEvtReg.Registrant_Date_of_Birth__c = Date.parse(birthDateString);
        }

        if (!String.isBlank(applicantType)) {
            newEvtReg.Registrant_Applicant_Type__c = applicantType;
        }

        //Begin matching based on event record type to get contact ID or create a new contact ID
        USTEventContactMatching matcher = new USTEventContactMatching();
        Map<String, String> matched = new Map<String, String>();

        //Check if last name, email, phone number or DOB changed
        Boolean dataHasChanged = false;
        if (oldEvtReg != null) {
            if (oldEvtReg.Registrant_Date_of_Birth__c != newEvtReg.Registrant_Date_of_Birth__c || oldEvtReg.Registrant_Last_Name__c != newEvtReg.Registrant_Last_Name__c || oldEvtReg.Registrant_Email__c != newEvtReg.Registrant_Email__c || oldEvtReg.Registrant_First_Name__c != newEvtReg.Registrant_First_Name__c) {
                dataHasChanged = true;
            }
        }

        if (String.isNotBlank(evtInfo.evtRegId) && String.isNotBlank(newEvtReg.Contact__r.Id) && !dataHasChanged) {
            matched.put('contactId', newEvtReg.Contact__r.Id);
            ContactId = newEvtReg.Contact__r.Id;
        } else {
            //pass record type and event reg to matcher helper class
            String matchingScope = '';
            if (String.isNotBlank(eventPage.Contact_Creation__c)) {
                matchingScope = eventPage.Contact_Creation__c;
            } else {
                matchingScope = 'Full matching contact creation with duplicate management';
            }
            if (!matchingScope.startsWith('No matching')) {
                matched = matcher.USTEventContactMatching(evtInfo.recordTypeName, newEvtReg, matchingScope);
                //Populate matching results into data - matched may be blank depending on the Contact_Creation__c setting
                if (matched.size() > 0) {
                    if (String.isNotBlank(matched.get('contactId'))) {
                        ContactId = (Id) matched.get('contactId');
                        newContactCreated = Boolean.valueOf(matched.get('newContactCreated'));
                    }
                    newEvtReg.Contact_Soft_Match_Email__c = String.valueOf(matched.get('softEmailMatches'));
                    newEvtReg.Contact_Soft_Match_First_Last_Zip__c = String.valueOf(matched.get('softFirstLastZipMatches'));
                    newEvtReg.Matching_Log__c = String.valueOf(matched.get('matchLog'));
                }
            }
        }

        //Create registration if event Registration does not exist

        if (String.isBlank(evtInfo.evtRegId) || evtInfo.evtRegId == 'COMING') {
            newEvtReg.Status__c = 'Started';
            newEvtReg.Date__c = Date.valueOf(evtInstance.Start_Date_Time__c);
            newEvtReg.Event__c = evtInfo.evtId;
            newEvtReg.Event_Instance__c = evtInfo.instanceID;
            newEvtReg.Contact__c = ContactId;
            if (newContactCreated) {
                newEvtReg.New_Contact_Created__c = true;
            }
            newEvtReg = CRUDToDo.updateRegistration(newEvtReg, null);
            oldRegistrationId = newEvtReg.Id;
            //Update matching log with new ID
            if (String.isNotBlank(newEvtReg.Matching_Log__c)) {
                newEvtReg.Matching_Log__c = newEvtReg.Matching_Log__c.replaceAll('\\[\\[REGID\\]\\]', newEvtReg.Id);
            }
            newEvtReg.Id = null;
        }

        //update registration it may already exist, and matching log has to be updated on new registration inserts
        newEvtReg.Id = null;
        newEvtReg = CRUDToDo.updateRegistration(newEvtReg, oldRegistrationId);
        evtInfo.evtRegId = newEvtReg.Id;

        if (String.isNotBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING') {
            if (evtHasAppointments) {
                optionPage = Page.USTEventRegistrationOptions;
            } else {
                optionPage = Page.USTEventConfirmation;
            }
            // create cookie to pass on to next page
            //Posting along everything we need to build the next page
            USTShared.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"' + evtInfo.evtRegId + '","evtId":"' + evtInfo.evtId + '"}', 'USTEvent');
            //optionPage.getParameters().put('evt', encrytpString);

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                optionPage.setRedirect(true);
                optionPage.getParameters().put('adminopen', ApexPages.currentPage().getParameters().get('adminopen'));
            }
            return optionPage;
        }

        return null;
    }

    private without sharing class doCRUD {

        public UST_Event_Registration__c updateRegistration(UST_Event_Registration__c newEvtReg, String regId) {
            try {
                newEvtReg.Id = regId;
                upsert newEvtReg;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
            return newEvtReg;
        }

        public UST_Event_Registration__c checkForOtherRegistrations(String checkType, String registrationEmail, Id eventInstanceId, Id eventId) {

            String[] notAcceptableStatuses = new List<String>();
            notAcceptableStatuses.add('Cancelled');
            notAcceptableStatuses.add('Started');
            notAcceptableStatuses.add('Status');

            List<UST_Event_Registration__c> foundRegistrations = new List<UST_Event_Registration__c>();
            UST_Event_Registration__c foundRegistration = null;

            if (checkType == 'One registration per instance') {
                foundRegistrations = [
                        SELECT Id, LastModifiedDate, Registrant_Email__c
                        FROM UST_Event_Registration__c
                        WHERE Registrant_Email__c = :registrationEmail
                        AND Event_Instance__c = :eventInstanceId
                        AND Status__c NOT IN :notAcceptableStatuses
                        ORDER BY LastModifiedDate
                ];
            } else if (checkType == 'One registration per event') {
                foundRegistrations = [
                        SELECT Id, LastModifiedDate, Registrant_Email__c
                        FROM UST_Event_Registration__c
                        WHERE Registrant_Email__c = :registrationEmail
                        AND Event__c = :eventId
                        AND Status__c NOT IN :notAcceptableStatuses
                        ORDER BY LastModifiedDate
                ];
            }
            if (foundRegistrations.size() > 0) {
                foundRegistration = foundRegistrations[0];
            }
            return foundRegistration;
        }

        public Contact getUserFromContact() {
            Contact userContact = [
                    SELECT Id, Name, FirstName, LastName, Email, EnrollmentrxRx__Gender__c, MailingStreetLine1__c, MailingStreetLine2__c, MailingState__c,
                            MailingZip__c, MailingCity__c, Home_Phone__c, MobilePhone, Receive_Texts__c, EnrollmentrxRx__High_School__c, EnrollmentrxRx__High_School_Code__c,
                            EnrollmentrxRx__High_School__r.Name, EnrollmentrxRx__High_School__r.EnrollmentrxRx__CEEB_Code__c, Preferred_First_Name__c, Birthdate
                    FROM Contact
                    WHERE Id IN (
                            SELECT ContactId
                            FROM User
                            WHERE Id = :UserInfo.getUserId()
                    )
            ];
            return userContact;
        }

        public List<Major__c> getSchoolMajorsByShortCode(String programListString) {
            List<String> bigProgramArray = new List<String>();
            List<Major__c> majorList = new List<Major__c>();
            if (String.isNotBlank(programListString)) {
                bigProgramArray = programListString.split(';');
                majorList = [
                        SELECT Prog_Major_Conc_Code__c, Major_Display_Name__c, Major__c.Program_Offered__r.Name, Program_Offered__r.Degree_Level__c
                        FROM Major__c
                        WHERE Status__c = 'Active'
                        AND Prog_Major_Conc_Code__c IN :bigProgramArray
                        ORDER BY Major_Display_Name__c
                ];

                List<Major__c> majorIdListSort = new List<Major__c>();
                for (String code : bigProgramArray) {
                    for (Major__c mj : majorList) {
                        if (mj.Prog_Major_Conc_Code__c.equals(code)) {
                            majorIdListSort.add(mj);
                        }
                    }
                }
                majorList = majorIdListSort;
            }
            return majorList;
        }


        public List<Major__c> getSchoolMajors(String schoolId) {

            List<Major__c> majorList = new List<Major__c>();

            List<EnrollmentrxRx__School__c> schoolInfoList = [
                    SELECT Id, Name
                    FROM EnrollmentrxRx__School__c
                    WHERE Id = :schoolId
            ];

            if (schoolInfoList.size() > 0) {
                if (schoolInfoList[0].Name.equalsIgnoreCase('Undergraduate')) {
                    majorList = [
                            SELECT Prog_Major_Conc_Code__c, Major_Display_Name__c, Program_Offered__r.Name, Program_Offered__r.Degree_Level__c
                            FROM Major__c
                            WHERE Status__c = 'Active'
                            AND Prog_Major_Conc_Code__c != NULL
                            AND Program_Offered__r.Name = 'Undeclared BA'
                            AND Display_on_RFI_UG__c = TRUE
                            ORDER BY Major_Display_Name__c
                    ];

                } else {
                    majorList = [
                            SELECT Id, Major_Display_Name__c, Prog_Major_Conc_Code__c, Program_Offered__r.Name, Program_Offered__r.Degree_Level__c
                            FROM Major__c
                            WHERE Status__c = 'Active'
                            AND Prog_Major_Conc_Code__c != NULL
                            AND Program_Offered__r.School__c = :schoolId
                            AND Display_on_RFI__c = TRUE
                            ORDER BY Major_Name__c
                    ];
                }
            }
            return majorList;
        }

        public List<Major__c> getMajorCodes(List<String> majorCodes) {
            List<Major__c> majorIdList = [
                    SELECT Id, Prog_Major_Conc_Code__c
                    FROM Major__c
                    WHERE Prog_Major_Conc_Code__c IN :majorCodes
                    AND (Display_on_RFI__c = TRUE OR Display_on_RFI_UG__c = TRUE)
            ];
            List<Major__c> majorIdListSort = new List<Major__c>(majorIdList.size());
            Integer position = 0;
            for (String code : majorCodes) {
                for (Major__c mj : majorIdList) {
                    if (mj.Prog_Major_Conc_Code__c.equals(code)) {
                        majorIdListSort[position] = mj;
                    }
                }
                position++;
            }
            return majorIdListSort;
        }

    }
}