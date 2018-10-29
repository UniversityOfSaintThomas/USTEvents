/**
 * Created by dahl3702 on 8/09/2018.
 */
@RestResource(urlMapping='/usteventfeed/*')

global with sharing class USTEventFeed {

    private static String feedType { get; set; }
    private static USTEventShared USTShared = new USTEventShared();

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
    }

    @HttpGet
    global static void getUSTEventFeed() {
        feedType = RestContext.request.params.get('feedType');
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String callback = RestContext.request.params.get('callback');
        String serializedJSON = '';

        if (String.isBlank(callback)) {
            callback = '';
        }


        if (feedType == 'audienceDD') {
            serializedJSON = JSON.serialize(getAudienceDD(UST_Event__c.Audience__c.getDescribe()));
        } else if (feedType == 'sexDD') {
            serializedJSON = JSON.serialize(getAudienceDD(Contact.EnrollmentrxRx__Gender__c.getDescribe()));
        } else if (feedType == 'eventList') {
            serializedJSON = JSON.serialize(getEventList());
            serializedJSON = serializedJSON.replace('"endDate":', '"end":');
        }
        if (!String.isBlank(callback)) {
            serializedJSON = callback + '(' + serializedJSON + ')';
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    }


    private static List<eventItem> getEventList() {
        List<eventItem> EventList = new List<eventItem>();
        RestRequest req = RestContext.request;
        String eventQuery = '';
        eventQuery += ' SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__R.Event_Status__c, Active_Status__c, Instance_Title__c, Instance_Short_Description__c, ';
        eventQuery += ' Event__r.Event_description__c, Event__r.Event_Short_Listing_Description__c, Event__r.Audience__c, Event__r.Close_Event_Days_Before__c, Start_Date_Time__c, End_Date_Time__c ';
        eventQuery += ' FROM UST_Event_Instance__c ';
        eventQuery += ' WHERE ';
        eventQuery += ' Event__R.Event_Status__c = \'Active\' ';
        eventQuery += ' AND Active_Status__c = \'Active\' ';
        eventQuery += ' AND (Current_Available_Capacity__c > 0 OR Capacity__c = null) ';

        // build and sanitize the where statement that have variables

        // get start and end view times convert string to datetime then convert back into string to sanitize
        DateTime viewStart = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(-1);
        ///.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String formattedViewStart;
        String formattedViewEnd;
        DateTime viewEnd = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(1);
        if (!String.isBlank(req.params.get('viewStart'))) {
            viewStart = DateTime.valueOf(req.params.get('viewStart'));
            formattedViewStart = viewStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
        if (!String.isBlank(req.params.get('viewEnd'))) {
            viewEnd = DateTime.valueOf(req.params.get('viewEnd'));
            formattedViewEnd = viewEnd.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }

        eventQuery += ' AND Start_Date_Time__c >= ' + formattedViewStart + ' ';
        eventQuery += ' AND Start_Date_Time__c <= ' + formattedViewEnd + ' ';

        //build and sanitize

        //get event based on event id
        String eventId = req.params.get('eventId');
        Id evtId = null;
        try {
            evtId = (Id) eventId;
            eventId = String.valueOf(evtId);
        }catch (Exception e) {
            eventId = null;
        }
        if (!String.isBlank(eventId)) {
            eventQuery += ' AND Event__r.id = \'' + eventId + '\' ';
        }

        //get event based on audience (can be comma seperated)
        String audience = req.params.get('audience');
        if (audience != 'all' && !String.isBlank(audience)) {
            List<String> audienceList = new List<String>();
            audienceList  = audience.split(',');
            for (String aud : audienceList) {
                audience = '\'' + String.escapeSingleQuotes(aud) + '\',';
            }
            audience = audience.removeEnd(',');
            eventQuery += ' AND Event__r.Audience__c INCLUDES (' + audience + ') ';
        }


        String incomingShowLongDesc = req.params.get('longdesc');
        Boolean showLongDescription = false;
        if (incomingShowLongDesc != null) {
            if (incomingShowLongDesc.toLowerCase() == '1' || incomingShowLongDesc.toLowerCase() == 'true') {
                showLongDescription = true;
            }
        }

        System.debug('-----------------------------' + eventQuery);

        List<UST_Event_Instance__c> EventInstance = database.query(eventQuery);

        DateTime regDateOpenDate = null;
        for (UST_Event_Instance__c es : EventInstance) {
            regDateOpenDate = Datetime.now().addDays(-1);
            if (es.Event__r.Close_Event_Days_Before__c != null) {
                regDateOpenDate = Datetime.now().addDays((Integer.valueOf(es.Event__r.Close_Event_Days_Before__c + 1 * -1)));
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

            evt.instanceDesc = es.Instance_Short_Description__c;
            evt.description = es.Event__r.Event_Short_Listing_Description__c;
            if (showLongDescription) {
                evt.longDesc = es.Event__r.Event_description__c;
            } else {
                evt.longDesc = '';
            }
            if (es.Start_Date_Time__c != null) {
                evt.start = USTShared.adjustForCenteralTime(es.Start_Date_Time__c);
            }
            if (es.End_Date_Time__c != null) {
                evt.endDate = USTShared.adjustForCenteralTime(es.End_Date_Time__c);
            }

            if (evt.start < regDateOpenDate) {
                evt.eventClosed = true;
                evt.eventUrl = 'javascript:void(0);';
                evt.className = 'eventClosed';
            } else {
                evt.eventClosed = false;
                evt.eventUrl = '/applicantportal/USTEventRegister?instanceID=' + es.Id;
                evt.className = 'eventOpened';
            }

            EventList.add(evt);
        }
        return EventList;
    }

    private static Map<String, String> getAudienceDD(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> fieldMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            fieldMap.put(f.getLabel(), f.getValue());
        }
        return fieldMap;
    }


}