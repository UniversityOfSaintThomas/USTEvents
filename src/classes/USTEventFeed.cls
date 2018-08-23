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
        public String longDesc {get;set;}
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

        if (feedType == 'audienceDD') {
            res.responseBody = Blob.valueOf(JSON.serialize(getAudienceDD(UST_Event__c.Audience__c.getDescribe())));
        } else if (feedType == 'sexDD') {
            res.responseBody = Blob.valueOf(JSON.serialize(getAudienceDD(Contact.EnrollmentrxRx__Gender__c.getDescribe())));
        } else if (feedType == 'eventList') {
            String evtJSONString = JSON.serialize(getEventList());
            evtJSONString = evtJSONString.replace('"endDate":', '"end":');
            res.responseBody = Blob.valueOf(evtJSONString);
        }
    }

    private static List<eventItem> getEventList() {
        List<eventItem> EventList = new List<eventItem>();
        RestRequest req = RestContext.request;
        String audience = req.params.get('audience');
        String audience2 = req.params.get('audience2');
        String audience3 = req.params.get('audience3');
        String audience4 = req.params.get('audience4');
        String audience5 = req.params.get('audience5');
        String audience6 = req.params.get('audience6');
        String audience7 = req.params.get('audience7');
        Boolean showLongDescription =  false;
        String incomingShowLongDesc = req.params.get('longdesc');
        if (incomingShowLongDesc != null) {
            if (incomingShowLongDesc.toLowerCase() == '1' || incomingShowLongDesc.toLowerCase() == 'true') {
                showLongDescription =  true;
            }
        }
        List<UST_Event_Instance__c> EventInstance = new List<UST_Event_Instance__c>();

        DateTime viewStart = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(-1);
        DateTime viewEnd = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(1);
        if (!String.isBlank(req.params.get('viewStart'))) {
            viewStart = DateTime.valueOf(req.params.get('viewStart'));
        }
        if (!String.isBlank(req.params.get('viewEnd'))) {
            viewEnd = DateTime.valueOf(req.params.get('viewEnd'));
        }

        if (audience == 'all') {
            EventInstance = [
                    SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__R.Event_Status__c, Active_Status__c, Instance_Title__c, Instance_Short_Description__c,
                            Event__r.Event_description__c, Event__r.Event_Short_Listing_Description__c, Event__r.Audience__c, Event__r.Close_Event_Days_Before__c, Start_Date_Time__c, End_Date_Time__c
                    FROM UST_Event_Instance__c
                    WHERE Start_Date_Time__c >= :viewStart
                    AND Event__R.Event_Status__c = 'Active'
                    AND Active_Status__c = 'Active'
                    AND Start_Date_Time__c <= :viewEnd
                    AND (Current_Available_Capacity__c > 0 OR Capacity__c = null)
            ];
        } else {
            EventInstance = [
                    SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__R.Event_Status__c, Active_Status__c, Instance_Title__c, Instance_Short_Description__c,
                            Event__r.Event_description__c, Event__r.Event_Short_Listing_Description__c, Event__r.Audience__c, Event__r.Close_Event_Days_Before__c, Start_Date_Time__c, End_Date_Time__c
                    FROM UST_Event_Instance__c
                    WHERE Start_Date_Time__c >= :viewStart
                    AND Event__R.Event_Status__c = 'Active'
                    AND Active_Status__c = 'Active'
                    AND Start_Date_Time__c <= :viewEnd
                    AND (Current_Available_Capacity__c > 0 OR Capacity__c = null)
                    AND (
                            Event__r.Audience__c INCLUDES (:audience)
                            OR Event__r.Audience__c INCLUDES (:audience)
                            OR Event__r.Audience__c INCLUDES (:audience2)
                            OR Event__r.Audience__c INCLUDES (:audience3)
                            OR Event__r.Audience__c INCLUDES (:audience4)
                            OR Event__r.Audience__c INCLUDES (:audience5)
                            OR Event__r.Audience__c INCLUDES (:audience6)
                            OR Event__r.Audience__c INCLUDES (:audience7)
                    )
            ];
        }


        DateTime regDateOpenDate = null;
        for (UST_Event_Instance__c es : EventInstance) {
            regDateOpenDate = Datetime.now().addDays(-1);
            if (es.Event__r.Close_Event_Days_Before__c != null) {
                regDateOpenDate = Datetime.now().addDays((Integer.valueOf(es.Event__r.Close_Event_Days_Before__c + 1 * -1)));
            }
            eventItem evt = new eventItem();
            evt.ID = es.Id;
            if(es.Event__r.Event_Name__c != null) {
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