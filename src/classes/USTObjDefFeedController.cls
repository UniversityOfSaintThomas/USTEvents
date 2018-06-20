/**
 * Created by dahl3702 on 3/8/2018.
 */

public with sharing class USTObjDefFeedController {
    public String jsonString { get; set; }
    public String feedType { get; set; }

    public USTObjDefFeedController() {
        //Get passed parameters
        Map<String, String> keyValOut = new Map<String, String>();
        jsonString = '';
        feedType = ApexPages.currentPage().getParameters().get('type');
        if (!String.isBlank(feedType)) {
            if (feedType.toLowerCase() == 'highschool') {
                keyValOut = getSchools('High School');
            } else if (feedType.toLowerCase() == 'college') {
                keyValOut = getSchools('College');
            } else if (feedType.toLowerCase() == 'states') {
                keyValOut = getObjDefMap(Contact.MailingState__c.getDescribe());
            } else if (feedType.toLowerCase() == 'cities') {
                keyValOut = getCityList();
            } else if (feedType.toLowerCase() == 'countries') {
                keyValOut = getObjDefMap(Contact.MailingCountry__c.getDescribe());
            } else if (feedType.toLowerCase() == 'gradschools') {
                keyValOut = getUSTSchools();
            } else if (feedType.toLowerCase() == 'gradprograms') {
                keyValOut = getGradPrograms();
            } else if (feedType.toLowerCase() == 'ugmajors') {
                keyValOut = getUGMajors();
            } else if (feedType.toLowerCase() == 'ugactivites') {
                keyValOut = getActivities('Clubs and Organizations');
            } else if (feedType.toLowerCase() == 'ugclubsports') {
                keyValOut = getActivities('Intramurals/Club Sports');
            } else if (feedType.toLowerCase() == 'ugvarsitysports') {
                keyValOut = getActivities('Varsity Sports');
            } else if (feedType.toLowerCase() == 'ugmusic') {
                keyValOut = getActivities('Music');
            }
        }
        if (!keyValOut.isEmpty()) {
            jsonString = JSON.serialize(keyValOut);
        }

    }

    public Map<String, String> getActivities(String ActivityType) {
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

    public Map<String, String> getUGMajors() {
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

    public Map<String, String> getGradPrograms() {
        Map<String, String> keyValOut = new Map<String, String>();
        String schoolId = '';
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('schoolid'))) {
            schoolId = ApexPages.currentPage().getParameters().get('schoolid');
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

    public Map<String, String> getUSTSchools() {
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

    public Map<String, String> getCityList() {
        String state = '';
        Map<String, String> keyValOut = new Map<String, String>();
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('state'))) {
            state = ApexPages.currentPage().getParameters().get('state').toUpperCase();
        }
        if (!String.isBlank(state)) {
            List<City__c> cityList = [SELECT Name FROM City__c WHERE State_Code__c = :state ORDER BY Name DESC];
            For (City__c city : cityList) {
                keyValOut.put(city.Name, city.Name);
            }
        }
        return keyValOut;
    }

    public Map<String, String> getSchools(String recTypeName) {
        List<EnrollmentrxRx__High_School__c> schoolList = new List<EnrollmentrxRx__High_School__c>();
        Map<String, String> keyValOut = new Map<String, String>();
        //List<String> filter = new List<String>();

        String state = '';
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('state'))) {
            state = ApexPages.currentPage().getParameters().get('state');
        }
        String city = '';
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('city'))) {
            city = '%' + ApexPages.currentPage().getParameters().get('city') + '%';
        }

        String filter = '';
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('filter'))) {
            List<String> filterHolder = new List<String>();
            for (String fragment : ApexPages.currentPage().getParameters().get('filter').split(' '))
            {
                filterHolder.add('*' + fragment + '*');
            }
            filter = '{' + (String.Join(filterHolder, ' ')) +'}';
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
                    FIND :filter IN All FIELDS
                            RETURNING EnrollmentrxRx__High_School__c(Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c WHERE RecordType.Name = :recTypeName)
            ][0];
        }

        For (EnrollmentrxRx__High_School__c sch : schoolList) {
            keyValOut.put(sch.EnrollmentrxRx__CEEB_Code__c, sch.Name + ' - ' + sch.EnrollmentrxRx__High_School_City__c + ', ' + sch.EnrollmentrxRx__High_School_State__c);
        }

        return keyValOut;
    }

    public Map<String, String> getObjDefMap(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> keyValOut = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Integer ii = ple.size() - 1; ii >= 0; ii--) {
            keyValOut.put(ple[ii].getLabel(), ple[ii].getValue());
        }
        return keyValOut;
    }

}