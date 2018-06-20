/**
 * Created by dahl3702 on 6/18/2018.
 */
@RestResource(urlMapping='/ustadmissionsrest/*')

global with sharing class USTRestAdmissions {

    @HttpGet
    global static Map<String, String> getUstAdmissionsRest() {
        String feedType = RestContext.request.params.get('type');
        if (!String.isBlank(feedType)) {
            if (feedType.toLowerCase() == 'highschool') {
                return getSchools('High School');
            } else if (feedType.toLowerCase() == 'college') {
                return getSchools('College');
            } else if (feedType.toLowerCase() == 'states') {
                return getObjDefMap(Contact.MailingState__c.getDescribe());
            } else if (feedType.toLowerCase() == 'cities') {
                return getCityList();
            } else if (feedType.toLowerCase() == 'countries') {
                return getObjDefMap(Contact.MailingCountry__c.getDescribe());
            } else if (feedType.toLowerCase() == 'gradschools') {
                return getUSTSchools();
            } else if (feedType.toLowerCase() == 'gradprograms') {
                return getGradPrograms();
            } else if (feedType.toLowerCase() == 'ugmajors') {
                return getUGMajors();
            } else if (feedType.toLowerCase() == 'ugactivites') {
                return getActivities('Clubs and Organizations');
            } else if (feedType.toLowerCase() == 'ugclubsports') {
                return getActivities('Intramurals/Club Sports');
            } else if (feedType.toLowerCase() == 'ugvarsitysports') {
                return getActivities('Varsity Sports');
            } else if (feedType.toLowerCase() == 'ugmusic') {
                return getActivities('Music');
            }
        }
        return null;
    }

    global static Map<String, String> getActivities(String ActivityType) {
        Map<String, String> keyValOut = new Map<String, String>();
        List<Activities__c> Activities = [
                SELECT Club_Description__c, Id
                FROM Activities__c
                WHERE Display_on_Portal__c = 'Yes'
                AND Club_Type__c = :ActivityType
                ORDER BY Club_Description__c DESC
        ];
        For (Activities__c act : Activities) {
            keyValOut.put(act.Id, act.Club_Description__c);
        }
        return keyValOut;
    }

    global static Map<String, String> getUGMajors() {
        Map<String, String> keyValOut = new Map<String, String>();
        List<Major__c> UGMajors = [
                SELECT Major_Code__c, Major_Display_Name__c, Program_Offered__c, Id
                FROM Major__c
                WHERE Status__c = 'Active'
                AND Major_Code__c != NULL
                AND Major_Display_Name__c != NULL
                AND Major_Display_Name__c != 'Liberal Arts (DFC)'
                AND Program_Offered__c IN (SELECT Id FROM EnrollmentrxRx__Program_Offered__c WHERE Name = 'Undeclared BA')
                ORDER BY Major_Display_Name__c DESC
        ];
        For (Major__c maj : UGMajors) {
            keyValOut.put(String.valueOf(maj.Major_Code__c), maj.Major_Display_Name__c);
        }
        return keyValOut;
    }

    global static Map<String, String> getGradPrograms() {
        Map<String, String> keyValOut = new Map<String, String>();
        String schoolId = '';
        if (!String.isBlank(RestContext.request.params.get('schoolid'))) {
            schoolId = RestContext.request.params.get('schoolid');
            List<EnrollmentrxRx__Program_Offered__c> schoolProgs = [
                    SELECT Program_Code__c, Name
                    FROM EnrollmentrxRx__Program_Offered__c
                    WHERE School__c = :schoolId
                    AND Status__c = 'Active'
                    AND Program_Code__c != NULL
            ];
            For (EnrollmentrxRx__Program_Offered__c prog : schoolProgs) {
                keyValOut.put(prog.Program_Code__c, prog.Name);
            }
        }
        return keyValOut;
    }

    global static Map<String, String> getUSTSchools() {
        Map<String, String> keyValOut = new Map<String, String>();
        List<EnrollmentrxRx__School__c> schoolList = [
                SELECT Name, Id
                FROM EnrollmentrxRx__School__c
                WHERE Active_Display_on_Portal__c = true
                AND Name != 'Undergraduate'
                ORDER BY Display_Order__c DESC
        ];
        For (EnrollmentrxRx__School__c schl : schoolList) {
            keyValOut.put(schl.Id, schl.Name);
        }
        return keyValOut;
    }

    global static Map<String, String> getCityList() {
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

    global static Map<String, String> getSchools(String recTypeName) {
        List<EnrollmentrxRx__High_School__c> schoolList = new List<EnrollmentrxRx__High_School__c>();
        Map<String, String> keyValOut = new Map<String, String>();
        //List<String> filter = new List<String>();

        String state = '';
        if (!String.isBlank(RestContext.request.params.get('state'))) {
            state = RestContext.request.params.get('state');
        }
        String city = '';
        if (!String.isBlank(RestContext.request.params.get('city'))) {
            city = '%' + RestContext.request.params.get('city') + '%';
        }

        String filter = '';
        if (!String.isBlank(RestContext.request.params.get('filter'))) {
            List<String> filterHolder = new List<String>();
            for (String fragment : RestContext.request.params.get('filter').split(' ')) {
                filterHolder.add('*' + fragment + '*');
            }
            filter = '{' + (String.Join(filterHolder, ' ')) + '}';
        }

        if (!String.isBlank(state) && String.isBlank(city)) {
            schoolList = [
                    SELECT Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c
                    FROM EnrollmentrxRx__High_School__c
                    WHERE EnrollmentrxRx__High_School_State__c = :state
                    AND RecordType.Name = :recTypeName
                    ORDER BY Name
            ];
        }
        if (!String.isBlank(state) && !String.isBlank(city)) {
            schoolList = [
                    SELECT Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c
                    FROM EnrollmentrxRx__High_School__c
                    WHERE EnrollmentrxRx__High_School_State__c = :state
                    AND EnrollmentrxRx__High_School_City__c LIKE :city
                    AND RecordType.Name = :recTypeName
                    ORDER BY Name
            ];
        }
        if (!String.isBlank(filter)) {
            schoolList = [
                    FIND :filter
                    IN All FIELDS
                            RETURNING EnrollmentrxRx__High_School__c(Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c WHERE RecordType.Name = :recTypeName)
            ][0];
        }

        For (EnrollmentrxRx__High_School__c sch : schoolList) {
            keyValOut.put(sch.EnrollmentrxRx__CEEB_Code__c, sch.Name + ' - ' + sch.EnrollmentrxRx__High_School_City__c + ', ' + sch.EnrollmentrxRx__High_School_State__c);
        }

        return keyValOut;
    }

    global static Map<String, String> getObjDefMap(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> keyValOut = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Integer ii = ple.size() - 1; ii >= 0; ii--) {
            keyValOut.put(ple[ii].getLabel(), ple[ii].getValue());
        }
        return keyValOut;
    }

}