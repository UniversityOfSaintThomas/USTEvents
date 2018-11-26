/**
 * Created by dahl3702 on 11/26/2018.
 */
@isTest
public with sharing class TestAdmissionsCounselorLookup {
    @testSetup static void insertCertainBaselineDataForTestsIfNotPresent() {
        Util.insertCertainBaselineDataForTestsIfNotPresent();
    }

    @isTest static void testCounselorLookup() {
        createTestData();
        Test.startTest();
        getLookupFeed('states', '', '', '', '', 'test');
        getLookupFeed('cities', '', '', '', '', '');
        getLookupFeed('cities', 'MN', '', '', '', '');
        getLookupFeed('countries', '', '', '', '', '');
        getLookupFeed('counselor', '', '', '', '', '');
        getLookupFeed('counselor', 'MN', '', '', '', '');
        getLookupFeed('counselor', 'MN', 'Minneapolis', '', '', '');
        getLookupFeed('counselor', '', 'Minneapolis', '', '', '');
        getLookupFeed('counselor', 'MN', 'Minneapolis', '', 'USA', '');
        getLookupFeed('counselor', '', '', 'TESTCODE', '', '');
        Test.stopTest();
    }

    private static void getLookupFeed(String type, String state, String city, String school, String nation, String callback) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/applicantportal/services/apexrest/admissioncounselor';
        req.params.put('type', type);
        req.params.put('state', state);
        req.params.put('city', city);
        req.params.put('school', school);
        req.params.put('nation', nation);
        req.params.put('callback', callback);
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;

        AdmissionsCounselorLookup.getAdmissionsCounselorLookup();
    }

    public static void createTestData() {
        EnrollmentrxRx__High_School__c schoolData = new EnrollmentrxRx__High_School__c(
                EnrollmentrxRx__CEEB_Code__c = 'TESTCODE',
                Name = 'TEST'
        );
        insert schoolData;

    }
}