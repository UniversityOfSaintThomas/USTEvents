/**
 * Created by dahl3702 on 6/18/2018.
 */
@RestResource(urlMapping='/ustadmissionsrest/*')

global with sharing class USTRestAdmissions {

    private class programData {
        String title { get; set; }
        String link { get; set; }
        String learningStyle { get; set; }
        String school { get; set; }
        String degreeLevel { get; set; }
        String interest { get; set; }
    }

    @HttpGet
    global static void getUstAdmissionsRest() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String serializedJSON = '';

        String feedType = RestContext.request.params.get('type');
        if (!String.isBlank(feedType)) {
            if (feedType.toLowerCase() == 'highschool') {
                serializedJSON = JSON.serialize(getSchools('High School'));
            } else if (feedType.toLowerCase() == 'college') {
                serializedJSON = JSON.serialize(getSchools('College'));
            } else if (feedType.toLowerCase() == 'states') {
                serializedJSON = JSON.serialize(getObjDefMap(Contact.MailingState__c.getDescribe()));
            } else if (feedType.toLowerCase() == 'cities') {
                serializedJSON = JSON.serialize(getCityList());
            } else if (feedType.toLowerCase() == 'countries') {
                serializedJSON = JSON.serialize(getObjDefMap(Contact.MailingCountry__c.getDescribe()));
            } else if (feedType.toLowerCase() == 'gradschools') {
                serializedJSON = JSON.serialize(getUSTSchools());
            } else if (feedType.toLowerCase() == 'gradprograms') {
                serializedJSON = JSON.serialize(getGradPrograms());
            } else if (feedType.toLowerCase() == 'ugmajors') {
                serializedJSON = JSON.serialize(getUGMajors());
            } else if (feedType.toLowerCase() == 'ugactivities') {
                serializedJSON = JSON.serialize(getActivities('Clubs and Organizations'));
            } else if (feedType.toLowerCase() == 'ugclubsports') {
                serializedJSON = JSON.serialize(getActivities('Intramurals/Club Sports'));
            } else if (feedType.toLowerCase() == 'ugvarsitysports') {
                serializedJSON = JSON.serialize(getActivities('Varsity Sports'));
            } else if (feedType.toLowerCase() == 'ugmusic') {
                serializedJSON = JSON.serialize(getActivities('Music'));
            } else if (feedType.toLowerCase() == 'areaofinterest') {
                serializedJSON = JSON.serialize(getObjDefMap(Major__c.Areas_of_Interest_for_program_finder__c.getDescribe()));
            } else if (feedType.toLowerCase() == 'degree') {
                serializedJSON = JSON.serialize(getObjDefMap(EnrollmentrxRx__Program_Offered__c.Degree_Level__c.getDescribe()));
            } else if (feedType.toLowerCase() == 'learningstyle') {
                serializedJSON = JSON.serialize(getObjDefMap(Major__c.Learning_Style_for_program_finder__c.getDescribe()));
            } else if (feedType.toLowerCase() == 'programfinder') {
                serializedJSON = JSON.serialize(programFinder());
            }
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    }

    private static List<programData> programFinder() {
        String filter = String.isBlank(RestContext.request.params.get('filter')) ? '' : RestContext.request.params.get('filter');
        List<programData> programList = new List<programData>();
        List<Major__c> majorList = new List<Major__c>();
        if (!String.isBlank(filter)) {
            List<String> filterHolder = new List<String>();
            for (String fragment : RestContext.request.params.get('filter').split(' ')) {
                filterHolder.add('*' + fragment + '*');
            }
            filter = String.Join(filterHolder, ' ');
        }


        String interest = (String.isBlank(RestContext.request.params.get('interest')) ? '' : RestContext.request.params.get('interest'));
        String degree = (String.isBlank(RestContext.request.params.get('degree')) ? '' : RestContext.request.params.get('degree'));
        String style = (String.isBlank(RestContext.request.params.get('style')) ? '' : RestContext.request.params.get('style'));
        String school = (String.isBlank(RestContext.request.params.get('school')) ? '' : RestContext.request.params.get('school'));

        if (!String.isBlank(filter)) {
            majorList = [
                    FIND :filter
                    IN ALL FIELDS
                            RETURNING Major__c(
                            Program_Offered__c,
                                    Program_Offered__r.Degree_Level__c,
                                    Major_Display_Name__c,
                                    Program_Offered__r.School__r.Name,
                                    Learning_Style_for_program_finder__c,
                                    Major_Web_URL__c,
                                    Areas_of_Interest_for_program_finder__c
                            WHERE Display_on_Program_Finder__c = true
                    )
            ][0];
        } else {
            majorList = [
                    SELECT Id,Display_on_Program_Finder__c, Display_on_RFI__c, Major_Display_Name__c, Prog_Major_Conc_Code__c, Program_Code__c, Status__c,
                            Program_Offered__r.Degree_Level__c,Keyword_for_Program_Finder__c,Major_Web_URL__c, Program_Offered__r.Program_Code__c,
                            Areas_of_Interest_for_program_finder__c,Learning_Style_for_program_finder__c, Program_Offered__r.School__r.Name
                    FROM Major__c
                    WHERE Display_on_Program_Finder__c = true
            ];
        }

        for (Major__c m : majorList) {
            Boolean addTolist = false;

            if (String.isblank(interest + degree + style + school)) {
                addTolist = true;
            }

            if (
                    (!String.isBlank(m.Areas_of_Interest_for_program_finder__c) && m.Areas_of_Interest_for_program_finder__c.contains(interest))
                            &&
                            (!String.isBlank(m.Program_Offered__r.Degree_Level__c) && m.Program_Offered__r.Degree_Level__c == degree)
                    ) {
                addTolist = true;
            }

            if (!String.isBlank(m.Program_Offered__r.Degree_Level__c) && m.Program_Offered__r.Degree_Level__c == degree) {
                addTolist = true;
            } else if (!String.isBlank(m.Program_Offered__r.Degree_Level__c) && m.Program_Offered__r.Degree_Level__c != degree) {
                addTolist = false;
            }
            if (!String.isBlank(m.Learning_Style_for_program_finder__c) && m.Learning_Style_for_program_finder__c.contains(style)) {
                addTolist = true;
            }
            if (!String.isBlank(m.Program_Offered__r.School__r.Name) && m.Program_Offered__r.School__r.Name == school) {
                addTolist = true;
            }

            if (addTolist) {
                programData pd = new programData();
                pd.title = m.Major_Display_Name__c;
                pd.link = (!String.isBlank(m.Major_Web_URL__c) ? m.Major_Web_URL__c : '');
                pd.degreeLevel = (!String.isBlank(m.Program_Offered__r.Degree_Level__c) ? m.Program_Offered__r.Degree_Level__c : '');
                pd.learningStyle = (!String.isBlank(m.Learning_Style_for_program_finder__c) ? m.Learning_Style_for_program_finder__c : '');
                pd.school = (!String.isBlank(m.Program_Offered__r.School__r.Name) ? m.Program_Offered__r.School__r.Name : '');
                pd.interest = (!String.isBlank(m.Areas_of_Interest_for_program_finder__c) ? m.Areas_of_Interest_for_program_finder__c : '');
                programList.add(pd);
            }
        }
        return programList;
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
        List<EnrollmentrxRx__Program_Offered__c> schoolProgs = new List<EnrollmentrxRx__Program_Offered__c>();
        if (!String.isBlank(RestContext.request.params.get('schoolid'))) {
            schoolId = RestContext.request.params.get('schoolid');
            schoolProgs = [
                    SELECT Program_Code__c, Name
                    FROM EnrollmentrxRx__Program_Offered__c
                    WHERE School__c = :schoolId
                    AND Status__c = 'Active'
                    AND Program_Code__c != NULL
            ];
        } else {
            schoolProgs = [
                    SELECT Program_Code__c, Name
                    FROM EnrollmentrxRx__Program_Offered__c
                    WHERE Status__c = 'Active'
                    AND Program_Code__c != NULL
            ];
        }
        For (EnrollmentrxRx__Program_Offered__c prog : schoolProgs) {
            keyValOut.put(prog.Program_Code__c, prog.Name);
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
            filter = String.Join(filterHolder, ' ');
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
                    IN ALL FIELDS
                            RETURNING EnrollmentrxRx__High_School__c(Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c WHERE RecordType.Name = :recTypeName)
            ][0];

            System.Debug('-=-=0-0-0--- SCHOOL LIST SIZE: ' + schoolList.size() + ' FILTER: ' + filter);
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