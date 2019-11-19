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
        getLookupFeed('counselor', '', '', '', '', '', '','');
        getLookupFeed('counselor', 'MN', '', '', '', '', '','');
        getLookupFeed('counselor', 'MN', 'Minneapolis', '', '', '', '','');
        getLookupFeed('counselor', '', 'Minneapolis', '', '', '', '','');
        getLookupFeed('counselor', 'MN', 'Minneapolis', '', 'USA', '', '','');
        getLookupFeed('counselor', '', '', 'TESTCODE', '', '', '','');
        getLookupFeed('counselor', '', '', '', '', '', '','U24');
        getLookupFeed('bio', '', '', '', '', '', 'Test1 Counselor','');
        getLookupFeed('intl', '', '', '', '', '', '','');
        Test.stopTest();
    }

    private static void getLookupFeed(String type, String state, String city, String school, String nation, String callback, String counselorName, String role) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/applicantportal/services/apexrest/admissioncounselor';
        req.params.put('type', type);
        req.params.put('state', state);
        req.params.put('city', city);
        req.params.put('school', school);
        req.params.put('nation', nation);
        req.params.put('callback', callback);
        req.params.put('name', counselorName);
        req.params.put('role', role);
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

        // Setup 4 Test Users
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> uu = new List<User>();
        Integer UserNum = 0;
        while (uu.size() < 5) {
            UserNum++;
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User u = new User(Alias = uid, Email= uid + '@myorg.com',
                    EmailEncodingKey='UTF-8',
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',
                    FirstName = 'Test' + String.valueOf(UserNum),
                    LastName = 'Counselor',
                    College__c = 'St. Thomas',
                    Major__c ='Poly Sci',
                    Hometown__c = 'St. Paul',
                    About_Me__c =' I\'m just this guy',
                    What_I_Love_About_St_Thomas__c = 'Everything',
                    Words_of_Advice__c = 'Don\t eat yellow snow!');
            uu.add(u);
        }
        insert(uu);

    }
}