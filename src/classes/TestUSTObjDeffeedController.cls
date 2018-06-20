/**
 * Created by dahl3702 on 3/19/2018.
 */
@isTest
public with sharing class TestUSTObjDeffeedController {
    @testSetup static void insertCertainBaselineDataForTestsIfNotPresent() {
        Util.insertCertainBaselineDataForTestsIfNotPresent();
    }

    private static String newschoolId { get; set; }

    static testMethod void testUSTFeeds() {

        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/applicantportal/USTObjDefFeed'));
        ApexPages.currentPage().getParameters().put('type', 'highschool');
        USTObjDefFeedController feed = new USTObjDefFeedController();

        //Get majors
        EnrollmentrxRx__Program_Offered__c prog = New EnrollmentrxRx__Program_Offered__c(Name='Undeclared BA');
        insert prog;

        Major__c maj= new Major__c( Major_code__c = 'TEST', Major_Display_Name__c = 'Test Display', Program_offered__c = prog.Id, Status__c = 'Active');
        insert maj;

        ApexPages.currentPage().getParameters().put('type', 'ugmajors');
        feed = new USTObjDefFeedController();

        //Get activities
        Activities__c activ = new Activities__c( Club_type__c = 'Clubs and Organizations', Club_Description__c= 'Test',  Display_on_Portal__c = 'Yes');
        insert activ;
        ApexPages.currentPage().getParameters().put('type', 'ugactivites');
        feed = new USTObjDefFeedController();

        ApexPages.currentPage().getParameters().put('type', 'ugclubsports');
        feed = new USTObjDefFeedController();

        ApexPages.currentPage().getParameters().put('type', 'ugvarsitysports');
        feed = new USTObjDefFeedController();

        ApexPages.currentPage().getParameters().put('type', 'ugmusic');
        feed = new USTObjDefFeedController();

        //Get geo location stuff
        ApexPages.currentPage().getParameters().put('type', 'states');
        feed = new USTObjDefFeedController();

        ApexPages.currentPage().getParameters().put('type', 'countries');
        feed = new USTObjDefFeedController();

        City__c cityList = new City__c(Name='Minneapolis', State_Code__c='mn');
        insert cityList;
        ApexPages.currentPage().getParameters().put('state', 'mn');
        ApexPages.currentPage().getParameters().put('type', 'cities');
        feed = new USTObjDefFeedController();

        //Get schools
        //school test data
        EnrollmentrxRx__High_School__c hs = new EnrollmentrxRx__High_School__c(Name='TEST', EnrollmentrxRx__CEEB_Code__c='000', EnrollmentrxRx__High_School_State__c='mn', EnrollmentrxRx__High_School_City__c='minneapolis');
        Id hsRecTypeID = Schema.SObjectType.EnrollmentrxRx__High_School__c.getRecordTypeInfosByName().get('High School').getRecordTypeId();
        hs.RecordTypeId = hsRecTypeID;
        insert hs;
        //without city
        ApexPages.currentPage().getParameters().put('state', 'mn');
        ApexPages.currentPage().getParameters().put('type', 'college');
        feed = new USTObjDefFeedController();

        //with city
        ApexPages.currentPage().getParameters().put('city', 'minneapolis');
        ApexPages.currentPage().getParameters().put('state', 'mn');
        ApexPages.currentPage().getParameters().put('type', 'highschool');
        feed = new USTObjDefFeedController();

        ApexPages.currentPage().getParameters().put('filter', 'Beth');
        feed = new USTObjDefFeedController();

        //Get Grad programs
        //Grad school data first school than school info with id
        EnrollmentrxRx__School__c gs = new EnrollmentrxRx__School__c(Name='TEST', Active_Display_on_Portal__c=true, Display_Order__c=1);
        insert gs;
        ApexPages.currentPage().getParameters().put('type', 'gradschools');
        feed = new USTObjDefFeedController();

        EnrollmentrxRx__Program_Offered__c gspo = new EnrollmentrxRx__Program_Offered__c(Program_Code__c='TEST', Name='TEST',Status__c='Active', School__c = gs.Id);
        insert gspo;

        ApexPages.currentPage().getParameters().put('type', 'gradprograms');
        ApexPages.currentPage().getParameters().put('schoolid', gs.Id);
        feed = new USTObjDefFeedController();


    }

}