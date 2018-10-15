/**
 * Created by dahl3702 on 10/2/2018.
 */
@RestResource(urlMapping='/admissioncounselor/*')

global with sharing class AdmissionsCounselorLookup {

    private class CounselorInfo {
        //Name,Email, College__c,Major__c, Hometown__c,About_Me__c,What_I_Love_About_St_Thomas__c,Words_of_Advice__c
        String name { get; set; }
        String email { get; set; }
        String college { get; set; }
        String major { get; set; }
        String hometown { get; set; }
        String about { get; set; }
        String USTLove { get; set; }
        String advice { get; set; }
    }

    @HttpGet
    global static void getAdmissionsCounselorLookup() {
        String feedType = RestContext.request.params.get('type');

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String callback = RestContext.request.params.get('callback');
        String serializedJSON = '';

        if (String.isBlank(callback)) {
            callback = '';
        }

        if (!String.isBlank(feedType)) {
            if (feedType.toLowerCase() == 'states') {
                serializedJSON = JSON.serialize(getObjDefMap(Contact.MailingState__c.getDescribe()));
            } else if (feedType.toLowerCase() == 'cities') {
                serializedJSON = JSON.serialize(getCityList());
            } else if (feedType.toLowerCase() == 'counselor') {
                serializedJSON = JSON.serialize(counselorInformation());
            } else if (feedType.toLowerCase() == 'countries') {
                serializedJSON = JSON.serialize(getObjDefMap(Contact.MailingCountry__c.getDescribe()));
            }
        }

        if (!String.isBlank(callback)) {
            serializedJSON = callback + '(' + serializedJSON + ')';
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    }

    private static List<CounselorInfo> counselorInformation() {
        String state = '';
        String city = '';
        String nation = '';
        String query = '';
        String userLink = '';
        String school = '';
        List<CounselorInfo> ci = new List<CounselorInfo>();
        List<Geographic_Area__c> ga = new List<Geographic_Area__c>();
        List<EnrollmentrxRx__High_School__c> hs = new list<EnrollmentrxRx__High_School__c>();
        List<Id> cUserIds = new List<Id>();
        //Get URL variables
        if (!String.isBlank(RestContext.request.params.get('nation'))) {
            nation = RestContext.request.params.get('nation').toUpperCase();
        }
        if (!String.isBlank(RestContext.request.params.get('state'))) {
            state = RestContext.request.params.get('state').toUpperCase();
        }
        if (!String.isBlank(RestContext.request.params.get('city'))) {
            city = RestContext.request.params.get('city').toLowerCase();
        }
        if (!String.isBlank(RestContext.request.params.get('school'))) {
            school = RestContext.request.params.get('school').toLowerCase();
        }

        //Build query string for SOQL LIKE statement
        if (!String.isBlank(school)) {
            hs = [
                    SELECT UG_Adm_Couns_Working_Sch_for_FYs__r.Staff_Member_Holding_Role__r.id
                    FROM EnrollmentrxRx__High_School__c
                    WHERE EnrollmentrxRx__CEEB_Code__c = :school
            ];
            if (hs.size() > 0) {
                for (EnrollmentrxRx__High_School__c h : hs) {
                    cUserIds.add(h.UG_Adm_Couns_Working_Sch_for_FYs__r.Staff_Member_Holding_Role__r.id);
                }
                ci = grabCounslorList(cUserIds);
            }
        } else {
            // DomesticS
            if (!String.isBlank(nation)) {
                query = 'NATION-' + nation.toLowerCase() + '%';
            } else if (!String.isBlank(city) && !String.isBlank(state)) {
                query = 'CITY-' + ((city + state).toLowerCase().replace('%20','').replace(' ', '')) + '%';
            } else if (!String.isBlank(state)){
                if (state.equalsIgnoreCase('mn') || state.equalsIgnoreCase('wi')) {
                    query = 'CITY-%' + state + '%';
                } else {
                    query = 'STATE-' + state + '%';
                }

            } else {
                query = '%%';
            }

            if (!String.IsBlank(query)) {
                //Get all geo areas that match query like statement (using passed in URL variables)
                ga = [
                        SELECT UG_Counseling_Geographic_Territory__r.UG_Adm_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__c
                        FROM Geographic_Area__c
                        WHERE NAME LIKE :query
                ];

                if (ga.size() > 0) {

                    //Build list of IDs of users (must clean them up as they are HTML links)
                    for (Geographic_Area__c g : ga) {
                        cUserIds.add(g.UG_Counseling_Geographic_Territory__r.UG_Adm_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__c);
                    }
                    ci = grabCounslorList(cUserIds);
                }
            }
        }

        //return cutom object list for JSON serialization
        return ci;
    }

    private static List<CounselorInfo> grabCounslorList(List<Id> cUserIds) {
        List<CounselorInfo> ci = new List<CounselorInfo>();
        List<User> cUser = new List<User>();
        //Get list off all users that match gathered list from geo areas
        if (cUserIds.size() > 0 ) {
            cUser = [
                    SELECT Name, Email, College__c, Major__c, Hometown__c, About_Me__c, What_I_Love_About_St_Thomas__c, Words_of_Advice__c
                    FROM User
                    WHERE Id in :cUserIds
            ];

            //Add queried users to custom object defined in this class
            for (User u : cUser) {
                CounselorInfo addCoun = new CounselorInfo();
                addCoun.name = u.Name;
                addCoun.email = u.Email;
                addCoun.college = (String.isNotBlank(u.College__c) ? u.College__c : '');
                addCoun.major = (String.isNotBlank(u.Major__c) ? u.Major__c : '');
                addCoun.hometown = (String.isNotBlank(u.Hometown__c) ? u.Hometown__c : '');
                addCoun.about = (String.isNotBlank(u.About_Me__c) ? u.About_Me__c : '');
                addCoun.USTLove = (String.isNotBlank(u.What_I_Love_About_St_Thomas__c) ? u.What_I_Love_About_St_Thomas__c : '');
                addCoun.advice = (String.isNotBlank(u.Words_of_Advice__c) ? u.Words_of_Advice__c : '');
                ci.add(addCoun);
            }
        }
        return ci;
    }

    private static Map<String, String> getCityList() {
        String state = '';
        Map<String, String> keyValOut = new Map<String, String>();
        if (!String.isBlank(RestContext.request.params.get('state'))) {
            state = RestContext.request.params.get('state').toUpperCase();
        }
        if (!String.isBlank(state)) {
            List<City__c> cityList = [SELECT Name FROM City__c WHERE State_Code__c = :state ORDER BY Name DESC];
            For (City__c city : cityList) {
                keyValOut.put(city.Name, city.Name);
            }
        }
        return keyValOut;
    }

    private static Map<String, String> getObjDefMap(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> keyValOut = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Integer ii = ple.size() - 1; ii >= 0; ii--) {
            keyValOut.put(ple[ii].getLabel(), ple[ii].getValue());
        }
        return keyValOut;
    }

}