/**
 * Created by dahl3702 on 6/18/2018.
 */
@RestResource(urlMapping='/ustadmissionsrest/*')

global with sharing class USTRestAdmissions {

    private class programData {
        String majorId { get; set; }
        String programId { get; set; }
        String schoolId { get; set; }
        String title { get; set; }
        String link { get; set; }
        String learningStyle { get; set; }
        String school { get; set; }
        String degreeLevel { get; set; }
        String interest { get; set; }
        String programCode { get; set; }
        String programMajorCode { get; set; }
        String major { get; set; }
        String minor { get; set; }
        String keywords { get; set; }
        String majorConcentration { get; set; }
        String concentration { get; set; }
        String preprofessional { get; set; }
    }

    @HttpGet
    global static void getUstAdmissionsRest() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String callback = RestContext.request.params.get('callback');
        String serializedJSON = '';

        if (String.isBlank(callback)) {
            callback = '';
        }

        String feedType = RestContext.request.params.get('type');
        if (String.isNotBlank(feedType)) {
            if (feedType.equalsIgnoreCase('highschool')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=highschool
                serializedJSON = JSON.serialize(getSchools('High School'));

            } else if (feedType.equalsIgnoreCase('college')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=college
                serializedJSON = JSON.serialize(getSchools('College'));

            } else if (feedType.equalsIgnoreCase('states')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=states
                serializedJSON = JSON.serialize(getObjDefMap(Contact.MailingState__c.getDescribe()));

            } else if (feedType.equalsIgnoreCase('cities')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=cities
                serializedJSON = JSON.serialize(getCityList());

            } else if (feedType.equalsIgnoreCase('countries')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/ustadmissionsrest.json?type=countries
                serializedJSON = JSON.serialize(getObjDefMap(Contact.MailingCountry__c.getDescribe()));

            } else if (feedType.equalsIgnoreCase('gradschools')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=gradschools
                serializedJSON = JSON.serialize(getUSTSchools());

            } else if (feedType.equalsIgnoreCase('gradprograms')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=gradprograms
                serializedJSON = JSON.serialize(getGradPrograms());

            } else if (feedType.equalsIgnoreCase('ugmajors')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=ugmajors
                serializedJSON = JSON.serialize(getUGMajors());

            } else if (feedType.equalsIgnoreCase('ugactivities')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=ugmajors
                serializedJSON = JSON.serialize(getActivities('Clubs and Organizations'));

            } else if (feedType.equalsIgnoreCase('ugclubsports')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=ugclubsports
                serializedJSON = JSON.serialize(getActivities('Intramurals/Club Sports'));

            } else if (feedType.equalsIgnoreCase('ugvarsitysports')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=ugvarsitysports
                serializedJSON = JSON.serialize(getActivities('Varsity Sports'));

            } else if (feedType.equalsIgnoreCase('ugmusic')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=ugmusic
                serializedJSON = JSON.serialize(getActivities('Music'));

            } else if (feedType.equalsIgnoreCase('areaofinterest')) {
                serializedJSON = JSON.serialize(getObjDefMap(Major__c.Areas_of_Interest_for_program_finder__c.getDescribe()));
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=areaofinterest

            } else if (feedType.equalsIgnoreCase('degree')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=degree
                serializedJSON = JSON.serialize(getObjDefMap(EnrollmentrxRx__Program_Offered__c.Degree_Level__c.getDescribe()));

            } else if (feedType.equalsIgnoreCase('learningstyle')) {
                // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=degree
                serializedJSON = JSON.serialize(getObjDefMap(Major__c.Learning_Style_for_program_finder__c.getDescribe()));
            } else if (feedType.equalsIgnoreCase('programfinder')) {
                serializedJSON = JSON.serialize(programFinder('all'));
            } else if (feedType.equalsIgnoreCase('ugprogramfinder')) {
                serializedJSON = JSON.serialize(programFinder('ug'));
            } else if (feedType.equalsIgnoreCase('gradprogramfinder')) {
                serializedJSON = JSON.serialize(programFinder('grad'));
            } else if (feedType.equalsIgnoreCase('ugschools')) {
                serializedJSON = JSON.serialize(getObjDefMap(Major__c.College_School__c.getDescribe()));
            }
        }
        if (String.isNotBlank(callback)) {
            serializedJSON = callback + '(' + serializedJSON + ')';
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    }

    private static List<programData> programFinder(String pftype) {

        /*
        Major_Display_Name__c
        Display_on_Program_Finder_UG__c (checkbox = TRUE)
        College_School__c (multiselect picklist)
        Keyword_for_Program_Finder__c (text)
        Major_Web_URL__c
        Areas_of_Interest_for_program_finder__c (multiselect picklist))
        Learning_Style_for_program_finder__c (single picklist)
        Pre_Professional_Program__c (checkbox)
        STVMAJR_VALID_MAJOR_IND__c (Y)
        STVMAJR_VALID_MINOR_IND__c (Y)
        */

        List<programData> programList = new List<programData>();
        List<Major__c> majorList = new List<Major__c>();
        String majorQuery = '';

        Boolean rfi_flag = false;

        if (String.isNotBlank(RestContext.request.params.get('rfi'))) {
            rfi_flag = Boolean.valueOf(RestContext.request.params.get('rfi'));
        }

        // Build the query as a string for flexibility
        majorQuery += ' SELECT Id,Display_on_Program_Finder__c, Display_on_RFI__c, Major_Display_Name__c, Prog_Major_Conc_Code__c, Program_Code__c, Status__c, ';
        majorQuery += ' Program_Offered__r.Degree_Level__c, Keyword_for_Program_Finder__c,Major_Web_URL__c, Program_Offered__r.Program_Code__c, College_School__c, STVMAJR_VALID_MAJOR_IND__c, STVMAJR_VALID_MINOR_IND__c, ';
        majorQuery += ' Areas_of_Interest_for_program_finder__c,Learning_Style_for_program_finder__c, Program_Offered__r.School__r.Name, Program_Offered__r.School__c, Pre_Professional_Program__c, STVMAJR_VALID_CONCENTRATN_IND__c, ';
        majorQuery += ' Display_on_RFI_UG__c, Major_Concentration__c, Degree_Level__c ';
        majorQuery += ' FROM Major__c ';
        if (!rfi_flag) {
            if (pftype.equalsIgnoreCase('grad')) {
                majorQuery += ' WHERE Display_on_Program_Finder__c = true AND';
            } else if (pftype.equalsIgnoreCase('ug')) {
                majorQuery += ' WHERE Display_on_Program_Finder_UG__c = true AND';
            } else {
                majorQuery += ' WHERE Display_on_Program_Finder_UG__c = true AND Display_on_Program_Finder__c = true AND';
            }
        } else {
            if (pftype.equalsIgnoreCase('grad')) {
                majorQuery += ' WHERE Display_on_RFI__c = true AND' ;
            } else {
                majorQuery += ' WHERE Display_on_RFI_UG__c = true AND' ;
            }
        }

        // Possible URL variables
        // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=programfinder
        // any combination of the following parameters can be sent to the API request
        // &interest=  <- program of intereest  (Education,Engineering, etc)
        // &degree= <- Master of Science, Certificate,etc
        // &style= <- Learning Style (Traditional,Blended, etc)
        // &school= <- Name of the school (College of Arts and Sciences, Opus College of Business, etc)
        // &schoolId= <- Salesforce ID for a school
        // &filter= <- comma separate list of text that the query will test against the name of the program, major, degree, learning style, and area of interest
        // https://COMMUNITY_SUB_DOMAIN.force.com/applicantportal/services/apexrest/ustadmissionsrest.json?type=programfinder&interest=&degree=&style=&schoolId=&filter=


        if (String.isNotBlank(RestContext.request.params.get('interest'))) {
            String majorInterest = String.valueOf(RestContext.request.params.get('interest'));
            majorQuery += ' Areas_of_Interest_for_program_finder__c  INCLUDES (\'' + majorInterest + '\') AND' ;
        }

        If (String.isNotBlank(RestContext.request.params.get('degree'))) {
            String majorDegree = String.valueOf(RestContext.request.params.get('degree'));
            majorQuery += ' Program_Offered__r.Degree_Level__c = \'' + majorDegree + '\'  AND' ;
        }

        if (String.isNotBlank(RestContext.request.params.get('style'))) {
            String majorStyle = String.valueOf(RestContext.request.params.get('style'));
            majorQuery += ' Learning_Style_for_program_finder__c INCLUDES (\'' + majorStyle + '\') AND' ;
        }

        if (String.isNotBlank(RestContext.request.params.get('school'))) {
            String majorSchool = String.valueOf(RestContext.request.params.get('school'));
            if (pftype.equalsIgnoreCase('grad')) {
                majorQuery += ' Program_Offered__r.School__r.Name = \'' + majorSchool + '\' AND' ;
            } else if (pftype.equalsIgnoreCase('ug')) {
                majorQuery += ' College_School__c INCLUDES (\'' + majorSchool + '\') AND' ;
            }

        }

        if (String.isNotBlank(RestContext.request.params.get('schoolId'))) {
            String majorSchoolId = String.valueOf(RestContext.request.params.get('schoolId'));
            majorQuery += ' Program_Offered__r.School__c = \'' + majorSchoolId + '\' AND' ;
        }

        if (String.isNotBlank(RestContext.request.params.get('program'))) {
            String programName = String.valueOf(RestContext.request.params.get('program'));
            majorQuery += ' Program_Offered__r.Name = \'' + programName + '\' AND' ;
        }

        if (String.isNotBlank(RestContext.request.params.get('minors'))) {
            Boolean minors = false;
            try {
                minors = Boolean.valueOf(RestContext.request.params.get('minors'));
            } catch (Exception e) {
            }
            if (minors) {
                majorQuery += ' (STVMAJR_VALID_MINOR_IND__c = \'Y\' OR STVMAJR_VALID_MINOR_IND__c = \'Yes\') AND' ;
            } else if (!minors) {
                majorQuery += ' (STVMAJR_VALID_MINOR_IND__c = \'N\' OR STVMAJR_VALID_MINOR_IND__c = \'No\') AND' ;
            }
        }

        if (String.isNotBlank(RestContext.request.params.get('concentrations'))) {
            Boolean concentrations = false;
            try {
                concentrations = Boolean.valueOf(RestContext.request.params.get('concentrations'));
            } catch (Exception e) {
            }
            if (concentrations) {
                majorQuery += ' (STVMAJR_VALID_CONCENTRATN_IND__c = \'Y\' OR STVMAJR_VALID_CONCENTRATN_IND__c = \'Yes\') AND' ;
            } else if (!concentrations) {
                majorQuery += ' (STVMAJR_VALID_CONCENTRATN_IND__c = \'N\' OR STVMAJR_VALID_CONCENTRATN_IND__c = \'No\') AND' ;
            }
        }

        if (String.isNotBlank(RestContext.request.params.get('preprofessionals'))) {
            Boolean preprofessionals = false;
            try {
                preprofessionals = Boolean.valueOf(RestContext.request.params.get('preprofessionals'));
            } catch (Exception e) {
            }
            if (preprofessionals) {
                majorQuery += ' Pre_Professional_Program__c = true AND' ;
            } else {
                majorQuery += ' Pre_Professional_Program__c = false AND' ;
            }
        }

        if (String.isNotBlank(RestContext.request.params.get('majors'))) {
            Boolean majors = false;
            try {
                majors = Boolean.valueOf(RestContext.request.params.get('majors'));
            } catch (Exception e) {
            }
            if (majors) {
                majorQuery += ' (STVMAJR_VALID_MAJOR_IND__c = \'Y\' OR  STVMAJR_VALID_MAJOR_IND__c = \'Yes\') AND' ;
            } else if (!majors) {
                majorQuery += ' (STVMAJR_VALID_MAJOR_IND__c = \'N\' OR STVMAJR_VALID_MAJOR_IND__c = \'No\') AND' ;
            }
        }

        majorQuery = majorQuery.removeEnd('AND');

        //split apart the filter on commas and test against the fields in the query
        if (String.isNotBlank(RestContext.request.params.get('filter'))) {
            String majorFilter = String.valueOf(RestContext.request.params.get('filter'));
            majorQuery += ' AND  (';
            List<String> filterList = majorFilter.split(',');
            for (String f : filterList) {
                f = f.replace('+', ' ');
                f = f.replace('%20', ' ');
                System.debug('FILTER IN = ' + f);
//                majorQuery += ' Program_Offered__r.School__r.Name LIKE \'%' + f + '%\' OR ';
                majorQuery += ' Learning_Style_for_program_finder__c LIKE \'%' + f + '%\' OR ';
//                majorQuery += ' Program_Offered__r.Degree_Level__c LIKE \'%' + f + '%\' OR ';
                majorQuery += ' Areas_of_Interest_for_program_finder__c INCLUDES (\'' + f + '\') OR ';
                majorQuery += ' Major_Display_Name__c LIKE \'%' + f + '%\' OR ';
                majorQuery += ' Keyword_for_Program_Finder__c LIKE \'%' + f + '%\' OR ';
//                majorQuery += ' College_School__c IN (\'' + f + '\') OR ' ;
            }
            majorQuery = majorQuery.removeEnd('OR ');
            majorQuery += ' ) ';
        }

        majorQuery = majorQuery.removeEnd('AND');

        majorQuery += ' ORDER BY Major_Display_Name__c';

        System.Debug('================================> ' + majorQuery);

        majorList = database.query(majorQuery);

        System.Debug('MajorList After: ' + MajorList.size());

        //load up the custom object class to send back to be parsed into JSON
        for (Major__c m : majorList) {
            programData pd = new programData();
            pd.title = m.Major_Display_Name__c;
            pd.link = (String.isNotBlank(m.Major_Web_URL__c) ? m.Major_Web_URL__c : '');
            if (pftype.equalsIgnoreCase('grad')) {
                pd.degreeLevel = (String.isNotBlank(m.Program_Offered__r.Degree_Level__c) ? m.Program_Offered__r.Degree_Level__c : '');
            } else {
                pd.degreeLevel = (String.isNotBlank(m.Degree_Level__c) ? m.Degree_Level__c : '');
            }
            pd.learningStyle = (String.isNotBlank(m.Learning_Style_for_program_finder__c) ? m.Learning_Style_for_program_finder__c : '');
            if (pftype.equalsIgnoreCase('ug')) {
                pd.school = (String.isNotBlank(m.College_School__c) ? m.College_School__c : '');
            } else {
                pd.school = (String.isNotBlank(m.Program_Offered__r.School__r.Name) ? m.Program_Offered__r.School__r.Name : '');
            }

            pd.interest = (String.isNotBlank(m.Areas_of_Interest_for_program_finder__c) ? m.Areas_of_Interest_for_program_finder__c : '');
            pd.majorId = (String.isNotBlank(m.Id) ? m.Id : '');
            pd.schoolId = (String.isNotBlank(String.valueOf(m.Program_Offered__r.School__c)) ? String.valueOf(m.Program_Offered__r.School__c) : '');
            pd.programId = (String.isNotBlank(String.valueOf(m.Program_Offered__c)) ? String.valueOf(m.Program_Offered__c) : '');
            pd.programCode = (String.isNotBlank(m.Program_Code__c) ? m.Program_Code__c : '');
            pd.programMajorCode = (String.isNotBlank(m.Prog_Major_Conc_Code__c) ? m.Prog_Major_Conc_Code__c : '');
            pd.major = (String.isNotBlank(m.STVMAJR_VALID_MAJOR_IND__c) && (m.STVMAJR_VALID_MAJOR_IND__c.equalsIgnoreCase('y') || m.STVMAJR_VALID_MAJOR_IND__c.equalsIgnoreCase('yes')) ? 'true' : 'false');
            pd.minor = (String.isNotBlank(m.STVMAJR_VALID_MINOR_IND__c) && (m.STVMAJR_VALID_MINOR_IND__c.equalsIgnoreCase('y') || m.STVMAJR_VALID_MINOR_IND__c.equalsIgnoreCase('yes')) ? 'true' : 'false');
            pd.keywords = (String.isNotBlank(m.Keyword_for_Program_Finder__c) ? m.Keyword_for_Program_Finder__c : '');
            pd.concentration = (String.isNotBlank(m.STVMAJR_VALID_CONCENTRATN_IND__c) && (m.STVMAJR_VALID_CONCENTRATN_IND__c.equalsIgnoreCase('y') || m.STVMAJR_VALID_CONCENTRATN_IND__c.equalsIgnoreCase('yes')) ? 'true' : 'false');
            pd.concentration = (String.isNotBlank(m.STVMAJR_VALID_CONCENTRATN_IND__c) && (m.STVMAJR_VALID_CONCENTRATN_IND__c.equalsIgnoreCase('y') || m.STVMAJR_VALID_CONCENTRATN_IND__c.equalsIgnoreCase('yes')) ? 'true' : 'false');
            pd.preprofessional = (m.Pre_Professional_Program__c == true ? 'true' : 'false');
            pd.majorConcentration = (m.Major_Concentration__c == true ? 'true' : 'false');
            // Pre_Professional_Program__c
            programList.add(pd);
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
                SELECT Major_Code__c, Major_Display_Name__c, Program_Offered__c, Id, Degree_Level__c
                FROM Major__c
                WHERE Major_Code__c != NULL
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
        List<Major__c> schoolProgs = new List<Major__c>();
        if (String.isNotBlank(RestContext.request.params.get('schoolid'))) {
            schoolId = RestContext.request.params.get('schoolid');
            schoolProgs = [
                    SELECT Id,Name, Major_Display_Name__c, Major_Name__c, Major_Code__c, Prog_Major_Conc_Code__c, Program_Offered__r.Program_Code__c
                    FROM Major__c
                    WHERE Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                    AND Program_Offered__r.Program_Code__c != NULL
                    AND Program_Offered__r.School__c = :schoolId
                    ORDER BY Major_Name__c
            ];
        } else {
            schoolProgs = [
                    SELECT Id,Name, Major_Display_Name__c, Major_Name__c, Major_Code__c, Prog_Major_Conc_Code__c, Program_Offered__r.Program_Code__c
                    FROM Major__c
                    WHERE Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                    AND Program_Offered__r.Program_Code__c != NULL
                    ORDER BY Major_Name__c
            ];
        }
        For (Major__c prog : schoolProgs) {
            keyValOut.put(prog.Prog_Major_Conc_Code__c, prog.Major_Display_Name__c);
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
        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = RestContext.request.params.get('state').toUpperCase();
        }
        if (String.isNotBlank(state)) {
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
        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = RestContext.request.params.get('state');
        }
        String city = '';
        if (String.isNotBlank(RestContext.request.params.get('city'))) {
            city = '%' + RestContext.request.params.get('city') + '%';
        }

        String filter = '';
        if (String.isNotBlank(RestContext.request.params.get('filter'))) {
            List<String> filterHolder = new List<String>();
            for (String fragment : RestContext.request.params.get('filter').split(' ')) {
                filterHolder.add('*' + fragment + '*');
            }
            filter = String.Join(filterHolder, ' ');
        }

        if (String.isNotBlank(state) && String.isBlank(city)) {
            schoolList = [
                    SELECT Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c
                    FROM EnrollmentrxRx__High_School__c
                    WHERE EnrollmentrxRx__High_School_State__c = :state
                    AND RecordType.Name = :recTypeName
                    AND Inactive_Flag__c = FALSE
                    ORDER BY Name
            ];
        }
        if (String.isNotBlank(state) && String.isNotBlank(city)) {
            schoolList = [
                    SELECT Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c
                    FROM EnrollmentrxRx__High_School__c
                    WHERE EnrollmentrxRx__High_School_State__c = :state
                    AND EnrollmentrxRx__High_School_City__c LIKE :city
                    AND RecordType.Name = :recTypeName
                    AND Inactive_Flag__c = FALSE
                    ORDER BY Name
            ];
        }
        if (String.isNotBlank(filter)) {
            schoolList = [
                    FIND :filter
                    IN ALL FIELDS
                            RETURNING EnrollmentrxRx__High_School__c(Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c, Inactive_Flag__c WHERE RecordType.Name = :recTypeName AND Inactive_Flag__c = FALSE)
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