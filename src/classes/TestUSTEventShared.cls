/**
 * Created by dahl3702 on 6/12/2018.
 */

@isTest
public with sharing class TestUSTEventShared {
    @testSetup static void insertCertainBaselineDataForTestsIfNotPresent() {
        Util.insertCertainBaselineDataForTestsIfNotPresent();
    }
    private static USTEventShared USTShared = new USTEventShared();
    private static USTEventCancelReviewController cancelReviewCtrl;
    private static USTEventConfirmationController confirmCtrl;
    private static USTEventParkingPassController parkingCtrl;
    private static USTEventRegisterController registerCtrl;
    private static USTEventRegistrationOptionsController optionsCtrl;
    private static USTEventSubmitController submitCtrl;
    private static UST_Event__c testEvent;
    private static UST_Event_Instance__c testInstance;
    private static UST_Event_Registration__c testRegistration;
    private static List<UST_Event_Appointment_Type__c> newApptTypes { get; set; }
    private static List<UST_Event_Appointments__c> addToRegAppt{ get; set; }
    private static User testUser;
    private static Contact student;
    private static String audience { get; set; }
    private static String template { get; set; }

    @isTest static void testRegister() {

        Test.startTest();

        //Making bad cookies for exceptions
        String eventForCookie = '{"blah":"blah"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        USTShared.getUSTEventInfo();

        registerCtrl = new USTEventRegisterController();
        registerCtrl.checkEventDetails();
        registerCtrl.checkEventDetails();

        createEventWithRegistration('email');
        eventForCookie = '{"audience":"' + audience + '","instanceID":"' + testInstance.Id + '","evtRegId":"' + testRegistration.id + '","evtId":"' + testEvent.Id + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        registerCtrl = new USTEventRegisterController();
        registerCtrl.saveContactRegistration();

        createEventWithRegistration('lastzip');
        eventForCookie = '{"audience":"' + audience + '","instanceID":"' + testInstance.Id + '","evtRegId":"' + testRegistration.id + '","evtId":"' + testEvent.Id + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        registerCtrl = new USTEventRegisterController();
        registerCtrl.saveContactRegistration();

        createEventWithRegistration('');
        eventForCookie = '{"audience":"' + audience + '","instanceID":"' + testInstance.Id + '","evtRegId":"COMING","evtId":"' + testEvent.Id + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        registerCtrl = new USTEventRegisterController();
        registerCtrl.saveContactRegistration();

        //Log in as portal user
        System.runAs(testUser) {
            eventForCookie = '{"audience":"' + audience + '","instanceID":"' + testInstance.Id + '","evtRegId":"COMING","evtId":"' + testEvent.Id + '"}';
            USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
            registerCtrl = new USTEventRegisterController();

            //Use audience Transfer to set college for school
            eventForCookie = '{"audience":"Transfer","instanceID":"' + testInstance.Id + '","evtRegId":"COMING","evtId":"' + testEvent.Id + '"}';
            USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
            registerCtrl = new USTEventRegisterController();

            //Create event with registraiton ID
            eventForCookie = '{"audience":"Transfer","instanceID":"' + testInstance.Id + '","evtRegId":"' + testRegistration.id + '","evtId":"' + testEvent.Id + '"}';
            USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
            registerCtrl = new USTEventRegisterController();
            registerCtrl.checkEventDetails();
            registerCtrl.getSexDD();
            registerCtrl.getStateDD();
            registerCtrl.getTimeFrame();
            registerCtrl.saveContactRegistration();
        }

        //Submit the registration
        submitCtrl = new USTEventSubmitController();
        submitCtrl.checkEventDetails();
        submitCtrl.previousPage();
        submitCtrl.submitRegistration();

        update testRegistration;
        submitCtrl.submitRegistration();
    }

    @isTest static void testOptions() {
        Test.startTest();
        optionsCtrl = new USTEventRegistrationOptionsController();

        createEventWithRegistration('');
        String eventForCookie = '{"audience":"Transfer","instanceID":"' + testInstance.Id + '","evtRegId":"' + testRegistration.Id + '","evtId":"' + testEvent.Id + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        optionsCtrl = new USTEventRegistrationOptionsController();

        optionsCtrl.checkEventDetails();
        optionsCtrl.previousPage();

        optionsCtrl.incomingApptJSon = '[]';
        optionsCtrl.saveOptions();

        //[{"apptId":"a010m000003EibeAAC","apptCatagory":"","apptType":"","apptText":"","apptTitle":"Multi colored socks for everyone"},{"apptId":"a010m000003EibUAAS","apptCatagory":"","apptType":"","apptText":"","apptTitle":"Red Socks Only"}]

        String jsonAppts = '[';
        for (UST_Event_Appointment_Type__c at : newApptTypes) {
            jsonAppts +='{"apptId":"' + at.Id + '","apptCatagory":"","apptType":"","apptText":"","apptTitle":"' + at.Title__c + '"},';
        }
        jsonAppts = jsonAppts.removeEnd(',');
        jsonAppts += ']';
        optionsCtrl.incomingApptJSon = jsonAppts;
        optionsCtrl.saveOptions();

        //run constructor again to simulate page load after save
        testRegistration.UG_Event_Appointments__r.add(new UST_Event_Appointments__c(Client_Created_Appointment__c = true));
        optionsCtrl = new USTEventRegistrationOptionsController();
    }


    @isTest static void testCancel() {
        createEventWithRegistration('');
        Test.startTest();
        PageReference pageRef = Page.USTEventCancelReview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('regId', testRegistration.Id);
        cancelReviewCtrl = new USTEventCancelReviewController();
        cancelReviewCtrl.cancelRegistration();
    }

    @isTest static void testConfirmation() {
        createEventWithRegistration('');
        Test.startTest();
        //{"audience":"High School Senior","instanceID":"a320m000000A5fOAAS","evtRegId":"a350m0000008q63AAA","evtId":"a330m0000001SOrAAM"}
        String eventForCookie = '{"audience":"' + audience + '","instanceID":"' + testInstance.Id + '","evtRegId":"' + testRegistration.Id + '","evtId":"' + testEvent.Id + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        confirmCtrl = new USTEventConfirmationController();
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        confirmCtrl.checkEventDetails();
    }

    @isTest static void testParkingPass() {
        createEventWithRegistration('');
        Test.startTest();
        parkingCtrl = new USTEventParkingPassController();
        ApexPages.currentPage().getParameters().put('regId', testRegistration.Id);
        parkingCtrl = new USTEventParkingPassController();
        testRegistration.Date__c = testInstance.Start_Date_Time__c.date();
        upsert testRegistration;
        parkingCtrl = new USTEventParkingPassController();
    }

    @isTest static void testFeed() {
        createTestEvent();
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/applicantportal/services/apexrest/usteventfeed';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');

        //Test audience dd request
        req.params.put('feedType', 'audienceDD');
        RestContext.request = req;
        RestContext.response = res;
        USTEventFeed.getUSTEventFeed();

        //Test sex dd request
        req.params.remove('feedType');
        req.params.put('feedType', 'sexDD');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter minus dates
        req.params.remove('feedType');
        req.params.put('feedType', 'eventList');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter with start date
        req.params.put('viewStart', String.valueOf(Datetime.now().addMonths(-1)));
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter with end date
        req.params.put('viewEnd', String.valueOf(Datetime.now().addMonths(1)));
        req.params.put('audience', audience);
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();
    }

    @isTest static void testUSTEventShared() {
        // USTShared = new USTEventShared();
        createEventWithRegistration('');
        String eventForCookie = '{"audience":"Transfer","instanceID":"' + testInstance.Id + '","evtRegId":"' + testRegistration.Id + '","evtId":"' + testEvent.Id + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        ApexPages.currentPage().getParameters().put('instanceID', '000000000000000');
        USTShared.getUSTEventInfo();
    }

    @isTest static void testUSTApptConfirmTigger() {
        createEventWithRegistration('');
        //UST_Event_Appointments__c addingAppointment = new UST_Event_Appointments__c(Event_Registration__c = testRegistration, Appointment_Type__c);
        Test.startTest();
        List<UST_Event_Appointments__c> dataApptAdd = new List<UST_Event_Appointments__c>();
        dataApptAdd.add(
                new UST_Event_Appointments__c(
                        Id = addToRegAppt[0].Id, Appointment_Status__c = 'Confirmed', Faculty_Staff_Member__c = 'Big Top', Appointment_Time__c = Time.newInstance(14,30,0,0)
                )
        );
        dataApptAdd.add(
                new UST_Event_Appointments__c(
                        Id = addToRegAppt[1].Id, Appointment_Status__c = 'Confirmed', Faculty_Staff_Member__c = 'Big Top', Appointment_Time__c = Time.newInstance(16,30,0,0)
                )
        );
        Database.update(dataApptAdd);
        Test.stopTest();
    }

    private static void createTestEvent() {
        audience = 'High School Senior';
        template = 'CastorTemplate2017';
        String hscoll = 'Auto Select on Audience';
        String askGen = 'Ask and require';
        //Create event
        testEvent = new UST_Event__c(
                Name = 'Test Event',
                Event_Status__c = 'Active',
                Event_Name__c = 'Test Event',
                Start_Date__c = Date.today().addDays(1),
                End_Date__c = Date.today().addDays(1),
                Template__c = template,
                Event_Home_Link_Title__c = 'testHome',
                Event_Home_Link_URL__c = '/',
                College_High_School_Ask__c = hscoll,
                Ask_Gender__c = askGen,
                Include_Time_frame_List__c = true,
                Allow_Other_Attendees__c = true,
                Max_Other_Attendees__c = 5,
                Close_Event_Days_Before__c = 0,
                Audience__c = audience);
        insert testEvent;

        //Create appointment  types
        newApptTypes = new List<UST_Event_Appointment_Type__c>();
        newApptTypes.add(new UST_Event_Appointment_Type__c(
                UST_Event__c = testEvent.Id,
                Title__c = 'Test Appointment',
                Appointment_Limits__c = '1',
                Description__c = 'Test description'
        ));

        newApptTypes.add(new UST_Event_Appointment_Type__c(
                UST_Event__c = testEvent.Id,
                Title__c = 'Test Appointment 2',
                Appointment_Limits__c = '1',
                Description__c = 'Test description 2',
                Appointment_Category__c = 'Faculty Visit'
        ));

        newApptTypes.add(new UST_Event_Appointment_Type__c(
                UST_Event__c = testEvent.Id,
                Title__c = 'Test Appointment 3',
                Appointment_Limits__c = '1',
                Description__c = 'Test description 3',
                Registrant_Input__c = 'Text box'
        ));

        newApptTypes.add(new UST_Event_Appointment_Type__c(
                UST_Event__c = testEvent.Id,
                Title__c = 'Test Appointment 4',
                Appointment_Limits__c = '2',
                Description__c = 'Test description 4',
                Registrant_Input__c = 'Required text box'
        ));

        newApptTypes.add(new UST_Event_Appointment_Type__c(
                UST_Event__c = testEvent.Id,
                Title__c = 'Test Appointment 5',
                Appointment_Limits__c = '2',
                Description__c = 'Test description 5',
                Registrant_Input__c = 'Required custom pick list',
                Custom_Picklist__c = 'Pick One\n\nPickTwo'
        ));

        newApptTypes.add(new UST_Event_Appointment_Type__c(
                UST_Event__c = testEvent.Id,
                Title__c = 'Test Appointment 6',
                Appointment_Limits__c = '1',
                Description__c = 'Test description 6',
                Registrant_Input__c = 'Custom pick list',
                Custom_Picklist__c = 'Pick One\n\nPickTwo'
        ));

        insert newApptTypes;


        //Create event instance
        testInstance = new UST_Event_Instance__c(
                Event__c = testEvent.Id,
                Instance_Title__c = 'Test Sesssion',
                Start_Date_Time__c = Datetime.now().addDays(1),
                End_Date_Time__c = Datetime.now().addDays(1).addHours(5),
                Active_Status__c = 'Active',
                Capacity__c = 500
        );
        insert testInstance;
    }

    private static void createEventWithRegistration(String contactType) {
        if (testEvent == null) {
            createTestEvent();
        }
        if (testUser == null) {
            creatTestUser();
        }
        if (contactType == 'lastzip') {
            testRegistration = new UST_Event_Registration__c(
                    Event__c = testEvent.Id,
                    Event_Instance__c = testInstance.Id,
                    Registrant_Email__c = 'notamatch@valleyhill.net',
                    Registrant_First_Name__c = student.firstName,
                    Registrant_Last_Name__c = student.lastname,
                    Registrant_Zip__c = student.mailingpostalcode,
                    Registrant_High_School_Code__c = '000000',
                    Status__c = 'Requested'
            );
        } else if (contactType == 'email') {
            testRegistration = new UST_Event_Registration__c(
                    Event__c = testEvent.Id,
                    Event_Instance__c = testInstance.Id,
                    Registrant_Email__c = student.email,
                    Registrant_First_Name__c = student.firstname,
                    Registrant_Last_Name__c = 'NotaMatch',
                    Registrant_Zip__c = '00000',
                    Registrant_High_School_Code__c = '000000',
                    Registrant_College_Code__c = '000000',
                    Status__c = 'Requested'
            );
        } else if (contactType == 'none') {
            testRegistration = new UST_Event_Registration__c(
                    Event__c = testEvent.Id,
                    Event_Instance__c = testInstance.Id,
                    Registrant_Email__c = 'none@valleyhill.net',
                    Registrant_First_Name__c = 'None',
                    Registrant_Last_Name__c = 'Canmatch',
                    Registrant_Zip__c = '55413',
                    Registrant_College_Code__c = '000000',
                    Status__c = 'Requested'
            );
        } else {
            testRegistration = new UST_Event_Registration__c(
                    Event__c = testEvent.Id,
                    Event_Instance__c = testInstance.Id,
                    Registrant_Email__c = student.email,
                    Registrant_First_Name__c = student.firstname,
                    Registrant_Last_Name__c = student.lastname,
                    Registrant_Zip__c = student.mailingpostalcode,
                    Registrant_College_Code__c = '000000',
                    Status__c = 'Requested'
            );
        }
        insert testRegistration;

        addToRegAppt = new List<UST_Event_Appointments__c>();
        for (UST_Event_Appointment_Type__c nat : newApptTypes) {
            addToRegAppt.add(new UST_Event_Appointments__c (
                    Event_Appointment_Type__c = nat.Id,
                    Event_Registration__c = testRegistration.Id,
                    Client_Created_Appointment__c = true,
                    Appointment_Status__c = 'Registered'
            ));
        }
        insert addToRegAppt;

    }

    private static void creatTestUser() {
        //Querying on profile


        //Creating a student contact
        student = new Contact(
                firstName = 'Freddy',
                lastName = 'McFlintstone',
                Email = 'fredmcflintsone@valleyhill.net',
                MailingStreet = '123 Flinstone Ave',
                MailingCity = 'Bedrock',
                MailingState = 'MN',
                MailingPostalCode = '55418',
                MailingZip__c = '55418',
                MailingCountry = 'US',
                Receive_Texts__c = 'Yes'
        );
        insert student;

        //Creating a test user based on the student
        Profile testProfile = [select id, name from profile where name = 'Student Portal User'][0];
        System.Debug('PROFILE ID: ' + testProfile.Id);
        testUser = new User(
                firstName = student.firstName,
                lastName = student.lastName,
                email = student.email,
                username = student.email,
                alias = 'eTester',
                ProfileId = testProfile.Id,
                contactId = student.Id,
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    }

}