/**
 * Created by dahl3702 on 8/09/2018.
 */
@RestResource(urlMapping='/usteventfeed/*')

global with sharing class USTEventFeed {

    private static String feedType { get; set; }
    private static USTEventShared USTShared = new USTEventShared();
    private static Id recTypeId { get; set; }

    private Class eventItem {
        public String ID { get; set; }
        public String title { get; set; }
        public String instanceDesc { get; set; }
        public String description { get; set; }
        public String longDesc { get; set; }
        public Datetime endDate { get; set; }
        public DateTime start { get; set; }
        public String eventUrl { get; set; }
        public Boolean eventClosed { get; set; }
        public String className { get; set; }
        public String locationTitle { get; set; }
        public String locationType { get; set; }
        public String locationAddress { get; set; }
        public String locationMapLink { get; set; }
        public String locationBuilding { get; set; }
        public String feedButtonText { get; set; }
        public String sponsors { get; set; }
        public Integer capacityTotal { get; set; }
        public Integer capacityRemaining { get; set; }
        public boolean excludeSearchTag { get; set; }
    }

    @HttpGet
    global static void getUSTEventFeed() {
        feedType = RestContext.request.params.get('feedType');
        String recType = RestContext.request.params.get('rectype');

        if (String.isNotBlank(recType)) {
            List<RecordType> recTypeList = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'UST_Event__c' AND Name = :recType];
            if (recTypeList.size() > 0) {
                recTypeId = recTypeList[0].Id;
            }
        }
        RestResponse res = RestContext.response;
        String callback = RestContext.request.params.get('callback');
        String serializedJSON = '';

        if (String.isBlank(callback)) {
            res.addHeader('Content-Type', 'application/json');
            callback = '';
        } else {
            res.addHeader('Content-Type', 'application/javascript');
        }

        if (String.isNotBlank(feedType)) {
            if (feedType.equalsIgnoreCase('audienceDD')) {
                serializedJSON = JSON.serialize(getAudienceDD(UST_Event__c.Audience__c.getDescribe()));
            } else if (feedType.equalsIgnoreCase('sexDD')) {
                serializedJSON = JSON.serialize(getAudienceDD(Contact.EnrollmentrxRx__Gender__c.getDescribe()));
            } else if (feedType.equalsIgnoreCase('eventList')) {
                serializedJSON = JSON.serialize(getEventList());
                serializedJSON = serializedJSON.replace('"endDate":', '"end":');
            } else if (feedType.equalsIgnoreCase('parameterKey')) {
                serializedJSON = JSON.serialize(getOptions());
            }
        }
        if (String.isNotBlank(callback)) {
            serializedJSON = callback + '(' + serializedJSON + ')';
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    }


    private static List<eventItem> getEventList() {
        List<eventItem> EventList = new List<eventItem>();
        RestRequest req = RestContext.request;
        String eventQuery = '';
        eventQuery += ' SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__r.Event_Status__c, Active_Status__c, Instance_Title__c, Instance_Short_Description__c, Event__r.Program_Filter__c, Event__r.Alternate_Registration_URL__c, ';
        eventQuery += ' Event__r.Location_Title__c, Event__r.Location_Type__c, Event__r.Location_Address__c, Event__r.Location_Map_Link__c, Event__r.Building__c, Event__r.Event_description__c, Event__r.Community_Base_URL__c, ';
        eventQuery += ' Building_Override__c, Alternate_Registration_URL_Override__c, Location_Address_Override__c, Location_Map_Link_Override__c, Location_Title_Override__c, Location_Type_Override__c,  ';
        eventQuery += ' Event__r.Event_Short_Listing_Description__c, Event__r.Audience__c, Event__r.Close_Event_Days_Before__c, Start_Date_Time__c, End_Date_Time__c, Event__r.School__r.Name, Event__r.Event_Sponsor__c, ';
        eventQuery += ' Event__r.Feed_Registration_Button_Text__c, Feed_Registration_Button_Text_Override__c, Capacity__c, Current_Available_Capacity__c, Event__r.Exclude_Search_Engine_Tag__c,Exclude_Search_Engine_Tag_Override__c, ';
        eventQuery += ' Event__r.Where_to_Display__c, Event__r.Category__c, Event__r.Keep_Registration_Open_During_Event__c, Event__r.Event_Type__c';
        eventQuery += ' FROM UST_Event_Instance__c';
        eventQuery += ' Where Event__R.Event_Status__c = \'Active\' ';
        eventQuery += ' AND Active_Status__c = \'Active\' ';
        eventQuery += ' AND (Current_Available_Capacity__c > 0 OR Capacity__c = null) ';
        eventQuery += ' AND Event__r.Audience__c EXCLUDES (\'No Audience\') ';

        // build and sanitize the where statement that have variables

        // get start and end view times convert string to datetime then convert back into string to sanitize
        DateTime viewStart = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(-1);
        DateTime viewEnd = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(1);
        ///.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String formattedViewStart;
        String formattedViewEnd;

        if (String.isNotBlank(req.params.get('viewStart'))) {
            String viewStartString = req.params.get('viewStart').trim();
            if (!viewStartString.containsIgnoreCase(' ')) {
                viewStartString = viewStartString + ' 00:00:00';
            }
            viewStart = DateTime.valueOf(viewStartString);
        }
        if (String.isNotBlank(req.params.get('viewEnd'))) {
            String viewEndString = req.params.get('viewEnd').trim();
            if (!viewEndString.containsIgnoreCase(' ')) {
                viewEndString = viewEndString + ' 23:59:59';
            }
            viewEnd = DateTime.valueOf(req.params.get('viewEnd'));
        }
        formattedViewStart = viewStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        formattedViewEnd = viewEnd.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        eventQuery += ' AND Start_Date_Time__c >= ' + formattedViewStart + ' ';
        eventQuery += ' AND Start_Date_Time__c <= ' + formattedViewEnd + ' ';

        //build and sanitize

        //get event based on event id
        String eventId = req.params.get('eventId');
        Id evtId = null;
        try {
            evtId = (Id) eventId;
            eventId = String.valueOf(evtId);
        } catch (Exception e) {
            eventId = null;
        }
        if (String.isNotBlank(eventId)) {
            eventQuery += ' AND Event__r.id = \'' + eventId + '\' ';
        }

        //Audience filter (can be comma separated)
        String audience = req.params.get('audience');
        if (audience != 'all' && String.isNotBlank(audience)) {
            eventQuery += ' AND Event__r.Audience__c INCLUDES (' + sanitizeIncludeList(audience) + ') ';
        }

        //Sponsor filter (can be comma separated)
        String sponsor = req.params.get('sponsor');
        if (String.isNotBlank(sponsor)) {
            eventQuery += ' AND Event__r.Event_Sponsor__c INCLUDES (' + sanitizeIncludeList(sponsor) + ') ';
        }

        //Display on filter (can be comma separated)
        String displayOn = req.params.get('displayon');
        System.debug('DISPLAY ON IN: ' + displayOn);
        if (String.isNotBlank(displayOn)) {
            eventQuery += ' AND Event__r.Where_to_Display__c INCLUDES (' + sanitizeIncludeList(displayOn) + ') ';
        }

        //Category filter (can be comma separated)
        String category = req.params.get('category');
        if (String.isNotBlank(category)) {
            eventQuery += ' AND Event__r.Category__c INCLUDES (' + sanitizeIncludeList(category) + ') ';
        }

        //Event Type filter. Only accepts one.
        String eventType = req.params.get('type');
        if (String.isNotBlank(eventType)) {
            eventQuery += ' AND Event__r.Event_Type__c = \'' + String.escapeSingleQuotes(eventType) + '\' ';
        }

        //Program filter (can be comma separated)
        String program = req.params.get('program');
        if (String.isNotBlank(program)) {
            eventQuery += ' AND (' + sanitizeProgramOrLikeList(program) + ') ';
        }

        //School filter (can be comma separated)
        String school = req.params.get('school');
        if (String.isNotBlank(school)) {
            eventQuery += ' AND (' + sanitizeOrLikeList(school, 'Event__r.School__r.Name') + ') ';
        }

        //School filter (can be comma separated)
        String building = req.params.get('building');
        if (String.isNotBlank(building)) {
            eventQuery += ' AND (' + sanitizeOrLikeList(building, 'Event__r.Building__c') + ') ';
        }

        //get filter with like soql concatinated program,location, school, location address, location type
        String filter = req.params.get('filter');
        if (String.isNotBlank(filter)) {
            eventQuery += ' AND  (';
            List<String> filterList = filter.split(',');
            for (String f : filterList) {
                eventQuery += ' Event__r.Program_Filter__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.Program_Filter_2__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.Program_Filter_3__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.Location_Title__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.Location_Address__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.Building__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.School__r.Name LIKE \'%' + f + '%\' OR ';
            }
            eventQuery = eventQuery.removeEnd('OR ');
            eventQuery += ' ) ';
        }

        if (String.isNotBlank(recTypeId)) {
            eventQuery += ' AND Event__r.RecordType.Id = \'' + String.valueOf(recTypeId) + '\' ';
        }

        String incomingShowLongDesc = req.params.get('longdesc');
        Boolean showLongDescription = false;
        if (incomingShowLongDesc != null) {
            if (incomingShowLongDesc.toLowerCase() == '1' || incomingShowLongDesc.toLowerCase() == 'true') {
                showLongDescription = true;
            }
        }

        eventQuery += ' ORDER BY Start_Date_Time__c ';

        List<UST_Event_Instance__c> EventInstance = new List<UST_Event_Instance__c>();

        System.debug(eventQuery);

        Try {
            EventInstance = database.query(eventQuery);
        } Catch (Exception ex) {
//            List<eventItem> errorEvent = new List<eventItem>();
//            eventItem ei = new eventItem();
//            ei.title = 'Exception Error';
//            ei.description = ex.getMessage();
//            errorEvent.add(ei);
//            ei = new eventItem();
//            ei.title = 'Query';
//            ei.description =eventQuery;
//            errorEvent.add(ei);
//            Return errorEvent;
        }


        Date compareCloseDate = null;
        for (UST_Event_Instance__c es : EventInstance) {
            compareCloseDate = Date.today();
            if (es.Event__r.Close_Event_Days_Before__c != null && es.Event__r.Close_Event_Days_Before__c != 0) {
                compareCloseDate = compareCloseDate.addDays((Integer.valueOf(es.Event__r.Close_Event_Days_Before__c) + 1));
            }
            eventItem evt = new eventItem();
            evt.ID = es.Id;
            if (es.Event__r.Event_Name__c != null) {
                evt.title = es.Event__r.Event_Name__c;
            } else {
                evt.title = es.Event__r.Name;
            }

            if (es.Instance_Title__c != null) {
                evt.title += ' - ' + es.Instance_Title__c;
            }

            if (String.isNotBlank(es.Instance_Short_Description__c)) {
                evt.instanceDesc = es.Instance_Short_Description__c;
            } else {
                evt.instanceDesc = '';
            }

            evt.excludeSearchTag = false;

            if (es.Event__r.Exclude_Search_Engine_Tag__c || es.Exclude_Search_Engine_Tag_Override__c) {
                evt.excludeSearchTag = true;
            }

            if (String.isNotBlank(es.Feed_Registration_Button_Text_Override__c)) {
                evt.FeedButtonText = es.Feed_Registration_Button_Text_Override__c;
            } else if (String.isNotBlank(es.Event__r.Feed_Registration_Button_Text__c)) {
                evt.FeedButtonText = es.Event__r.Feed_Registration_Button_Text__c;
            } else {
                evt.FeedButtonText = 'Register';
            }

            if (String.isNotBlank(es.Location_Type_Override__c)) {
                evt.locationType = es.Location_Type_Override__c;
            } else if (String.isNotBlank(es.Event__r.Location_Type__c)) {
                evt.locationType = es.Event__r.Location_Type__c;
            } else {
                evt.locationType = '';
            }

            if (String.isNotBlank(es.Event__r.Event_Sponsor__c)) {
                evt.sponsors = es.Event__r.Event_Sponsor__c;
            } else {
                evt.sponsors = '';
            }

            if (String.isNotBlank(es.Event__r.Building__c)) {
                evt.locationBuilding = es.Event__r.Building__c;
            } else {
                evt.locationBuilding = '';
            }

            if (String.isNotBlank(es.Event__r.Event_Short_Listing_Description__c)) {
                evt.description = es.Event__r.Event_Short_Listing_Description__c;
            } else {
                evt.description = '';
            }

            if (showLongDescription) {
                evt.longDesc = es.Event__r.Event_description__c;
            } else {
                evt.longDesc = '';
            }

            if (Integer.valueOf(es.Capacity__c) != null) {
                evt.capacityTotal = Integer.valueOf(es.Capacity__c);
            } else {
                evt.capacityTotal = 0;
            }

            if (Integer.valueOf(es.Current_Available_Capacity__c) != null) {
                evt.capacityRemaining = Integer.valueOf(es.Current_Available_Capacity__c);
            } else {
                evt.capacityRemaining = 0;
            }

            if (es.Start_Date_Time__c != null) {
                evt.start = USTShared.adjustForCenteralTime(es.Start_Date_Time__c);
            }
            if (es.End_Date_Time__c != null) {
                evt.endDate = USTShared.adjustForCenteralTime(es.End_Date_Time__c);
            }

            if (String.isNotBlank(es.Event__r.Location_Title__c) || String.isNotBlank(es.Location_Title_Override__c)) {
                if (String.isNotBlank(es.Location_Title_Override__c)) {
                    evt.locationTitle = es.Location_Title_Override__c;
                } else {
                    evt.locationTitle = es.Event__r.Location_Title__c;
                }
            } else {
                evt.locationTitle = '';
            }

            if (String.isNotBlank(es.Event__r.Location_Address__c) || String.isNotBlank(es.Location_Address_Override__c)) {
                if (String.isNotBlank(es.Location_Address_Override__c)) {
                    evt.locationAddress = es.Location_Address_Override__c;
                } else {
                    evt.locationAddress = es.Event__r.Location_Address__c;
                }
            } else {
                evt.locationAddress = '';
            }

            if (String.isNotBlank(es.Event__r.Location_Map_Link__c) || String.isNotBlank(es.Location_Map_Link_Override__c)) {
                if (String.isNotBlank(es.Location_Map_Link_Override__c)) {
                    evt.locationMapLink = es.Location_Map_Link_Override__c;
                } else {
                    evt.locationMapLink = es.Event__r.Location_Map_Link__c;
                }
            } else {
                evt.locationMapLink = '';
            }

            Date startDate = date.newInstance(evt.start.year(), evt.start.month(), evt.start.day());
            Date endDate = date.newInstance(evt.endDate.year(), evt.endDate.month(), evt.endDate.day());

            Boolean eventIsClosed = false;
            if (es.Event__r.Keep_Registration_Open_During_Event__c) {
                if (endDate < compareCloseDate && endDate != compareCloseDate) {
                    eventIsClosed = true;
                }
            } else if (startDate <= compareCloseDate) {
                eventIsClosed = true;
            }

            if (eventIsClosed) {
                evt.eventClosed = true;
                evt.eventUrl = 'javascript:void(0);';
                evt.className = 'eventClosed';
            } else {
                evt.eventClosed = false;
                if (String.isNotBlank(es.Event__r.Alternate_Registration_URL__c) || String.isNotBlank(es.Alternate_Registration_URL_Override__c)) {
                    if (String.isNotBlank(es.Alternate_Registration_URL_Override__c)) {
                        evt.eventUrl = es.Alternate_Registration_URL_Override__c;
                    } else {
                        evt.eventUrl = es.Event__r.Alternate_Registration_URL__c;
                    }

                } else {
                    evt.eventUrl = es.Event__r.Community_Base_URL__c + 'USTEventRegister?instanceID=' + es.Id;
                }
                evt.className = 'eventOpened';
            }

            EventList.add(evt);
        }
        return EventList;
    }

    private static String sanitizeIncludeList(String listIn) {
        String listOut = '';
        if (String.isNotBlank(listIn)) {
            List<String> listInList = new List<String>();
            listInList = listIn.split(',');
            for (String listItem : listInList) {
                listOut += '\'' + String.escapeSingleQuotes(listItem.trim()) + '\',';
            }
            listOut = listOut.removeEnd(',');

            return listOut;
        }
        return '';
    }

    private static String sanitizeProgramOrLikeList(String listIn) {
        if (String.isNotBlank(listIn)) {
            String listOut = '';
            List<String> listInList = new List<String>();
            listInList = listIn.split(',');
            for (String listItem : listInList) {
                listOut += ' ( Event__r.Program_Filter__c LIKE \'%' + String.escapeSingleQuotes(listItem.trim()) + '%\' ) OR ';
                listOut += ' ( Event__r.Program_Filter_2__c LIKE \'%' + String.escapeSingleQuotes(listItem.trim()) + '%\' ) OR ';
                listOut += ' ( Event__r.Program_Filter_3__c LIKE \'%' + String.escapeSingleQuotes(listItem.trim()) + '%\' ) OR ';
            }
            listOut = listOut.removeEnd(' OR ');
            return listOut;
        }
        return '';
    }

    private static String sanitizeOrLikeList(String listIn, String fieldToCompare) {
        if (String.isNotBlank(listIn)) {
            String listOut = '';
            List<String> listInList = new List<String>();
            listInList = listIn.split(',');
            for (String listItem : listInList) {
                listOut += ' ( ' + fieldToCompare + ' LIKE \'%' + String.escapeSingleQuotes(listItem.trim()) + '%\' ) OR ';
            }
            listOut = listOut.removeEnd(' OR ');
            return listOut;
        }
        return '';
    }


    //eventQuery += ' Event__r.Program_Filter__c LIKE \'%' + f + '%\' OR ';

    private static Map<String, String> getAudienceDD(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> fieldMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            fieldMap.put(f.getLabel(), f.getValue());
        }
        return fieldMap;
    }

    private static List<String> getObjectItemList(Schema.DescribeFieldResult fieldResult) {
        List<String> fieldMap = new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            fieldMap.add(f.getValue());
        }
        return fieldMap;
    }

    private class optionList {
        String parameter;
        String description;
        List<String> options;
    }

    private static List<optionList> getOptions() {
        List<optionList> allOptions = new List<optionList>();

        //FeedType
        allOptions.add(makeOption('feedType', new List<String>{
                'audienceDD', 'sexDD', 'eventList', 'parameterKey'
        }, 'Must be included to get any feed (&feedType= one of these items)'));

        //Record Types
        List<RecordType> recTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'UST_Event__c'];
        List<String> recTypeNames = new List<String>();
        for (RecordType rt : recTypeList) {
            recTypeNames.add(rt.Name);
        }

        doCRUD CRUDtoDo = new doCRUD();

        allOptions.add(makeOption('rectype', recTypeNames, 'filters on salesforce record type (&rectype= one of these items)'));

        //View start
        allOptions.add(makeOption('viewStart', new List<String>{
                Datetime.now().addMonths(-1).format()
        }, 'The date scope of the feed start. Defaults to current month -1. (&viewStart=)'));

        //View end
        allOptions.add(makeOption('viewEnd', new List<String>{
                Datetime.now().addMonths(1).format()
        }, 'The date scope of the feed end. Defaults to current month +1. (&viewEnd=)'));

        //eventId
        allOptions.add(makeOption('eventId', new List<String>{
        }, 'Shows only the instances under the event umbrella (&eventId= Salesforce Id for the event)'));

        //audience
        allOptions.add(makeOption('audience', getObjectItemList(UST_Event__c.Audience__c.getDescribe()), 'Filters on audiences (&audience= single or coma separated list of these items)'));

        //Event type
        allOptions.add(makeOption('type', getObjectItemList(UST_Event__c.Event_Type__c.getDescribe()), 'Filters on event type (&type= single item only)'));

        //sponsor
        allOptions.add(makeOption('sponsor', getObjectItemList(UST_Event__c.Event_Sponsor__c.getDescribe()), 'Filters on sponsor (&sponsor= single or coma separated list of these items)'));

        //displayon
        allOptions.add(makeOption('displayon', getObjectItemList(UST_Event__c.Where_to_Display__c.getDescribe()), 'Filters on where in the digital world you want to display events(&displayon= single or coma separated list of these items)'));

        //category
        allOptions.add(makeOption('category', getObjectItemList(UST_Event__c.Category__c.getDescribe()), 'Filters category picklist events (&category= single or coma separated list of these items)'));

        //longdesc
        allOptions.add(makeOption('longdesc', new List<String>{
                'true', 'false', '0', '1'
        }, 'If set to 1 or true will show the long description of the event'));

        //program
        allOptions.add(makeOption('program', CRUDtoDo.getPrograms(), 'Filters program list of events (&program= single or coma separated list of these items)'));

        //program
        allOptions.add(makeOption('school', CRUDtoDo.getSchools(), 'Filters school list of events (&school= single or coma separated list of these items)'));

        //filter
        allOptions.add(makeOption('filter', new List<String>{
                'Program_Filter', 'Location_Title', 'Location_Address', 'Building', 'School_Name'
        }, 'Filter searches with a like statement all of these items together. (&filter= single or coma separated list of these items)'));

        //filter-Location
        allOptions.add(makeOption('filter+location', new List<String>{
                'Program_Filter', 'Location_Title', 'Location_Address', 'Building', 'School_Name'
        }, 'Filter searches with a like statement all of these items. (&filter= single or coma separated list of these items)'));

        //filter-Program
        allOptions.add(makeOption('filter+program', CRUDtoDo.getPrograms(), 'Programs are filter on program code add the code before the equal sign to your filter list to get events in that program. (&filter=PROGRAM|CODE single or coma separated list of these items'));

        //filter-Building
        allOptions.add(makeOption('filter+building', getObjectItemList(UST_Event__c.Building__c.getDescribe()), 'Filter searches with a like statement all of these items. (&filter= single or coma separated list of these items)'));

        //filter-School name
        allOptions.add(makeOption('filter+school', CRUDtoDo.getSchools(), 'Filter searches with a like statement all of these items. (&filter= single or coma separated list of these items)'));
        return allOptions;
    }

    private static optionList makeOption(String options, List<String> items, String description) {
        optionList newOption = new optionList();
        newOption.parameter = options;
        newOption.description = description;
        newOption.options = items;
        return newOption;
    }

    private without sharing class doCRUD {
        private List<String> getPrograms() {
            List<Major__c> allPrograms = [
                    SELECT Major_Display_Name__c, Prog_Major_Conc_Code__c, Program_Code__c, Status__c, Program_Offered__r.Degree_Level__c, College_School__c, Program_Offered__r.School__r.Name, Degree_Level__c
                    FROM Major__c
                    WHERE Status__c = 'Active'
                    AND (Display_on_RFI_UG__c = true OR Display_on_RFI__c = true)
                    ORDER BY Program_Offered__r.Degree_Level__c, Major_Display_Name__c
            ];
            List<String> allProgramsList = new List<String>();
            String programString = '';
            for (Major__c program : allPrograms) {
                programString = program.Prog_Major_Conc_Code__c;
                programString += ' = ' + program.Major_Display_Name__c;
                programString += ' - ' + program.Degree_Level__c;
                allProgramsList.add(programString);
            }
            return allProgramsList;
        }

        private List<String> getSchools() {
            List<EnrollmentrxRx__School__c> allSchools = [
                    SELECT Id, Name, Active_Display_on_Portal__c
                    FROM EnrollmentrxRx__School__c
                    WHERE Active_Display_on_Portal__c = TRUE
            ];
            List<String> allSchoolsList = new List<String>();
            for (EnrollmentrxRx__School__c school : allSchools) {
                allSchoolsList.add(school.Name);
            }
            return allSchoolsList;
        }
    }

}