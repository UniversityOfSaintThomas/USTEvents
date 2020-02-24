/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventFeedController {
    public USTEventShared USTShared = new USTEventShared();
    public String jsonString { get; set; }
    public DateTime viewStart { get; set; }
    public DateTime viewEnd { get; set; }
    public String feedType { get; set; }
    public String audience { get; Set; }

    private Class eventItem {
        public String ID { get; set; }
        public String title { get; set; }
        public String sessionDesc { get; set; }
        public String description { get; set; }
        public Datetime endDate { get; set; }
        public DateTime start { get; set; }
        public String eventUrl { get; set; }
        public Boolean eventClosed { get; set; }
        public String className { get; set; }
    }

    public USTEventFeedController() {

        //Get passed parameters
        feedType = ApexPages.currentPage().getParameters().get('feedType');
        audience = ApexPages.currentPage().getParameters().get('audience');


        if (feedType == 'audienceDD') {
            jsonString = getAudienceDD(UST_Event__c.Audience__c.getDescribe());
        } else if (feedType == 'sexDD') {
            jsonString = getAudienceDD(Contact.EnrollmentrxRx__Gender__c.getDescribe());
        } else if (feedType == 'eventList') {
            viewStart = DateTime.valueOf(ApexPages.currentPage().getParameters().get('viewStart'));
            viewEnd = DateTime.valueOf(ApexPages.currentPage().getParameters().get('viewEnd'));
            jsonString = getEventList();
        }
    }

    public String getEventList() {
        String jsonHolder = '';
        /*DateTime regDateOpenDate = null;
        List<UST_Event_Session__c> EventSession = [
                SELECT Id, Event__r.Name, Event__R.Event_Status__c, Active_Status__c, Session_Title__c, Session_Short_Description__c,
                        Event__r.Event_description__c, Event__r.Audience__c, Event__r.Close_Event_Days_Before__c, Start_Date_Time__c, End_Date_Time__c
                FROM UST_Event_Session__c
                WHERE Start_Date_Time__c >= :viewStart
                AND Event__R.Event_Status__c = 'Active'
                AND Active_Status__c = 'Active'
                AND Start_Date_Time__c <= :viewEnd
                AND (Current_Available_Capacity__c > 0 OR Capacity__c = null)
                AND Event__r.Audience__c INCLUDES(:audience)
        ];

        List<eventItem> EventList = new List<eventItem>();
        for (UST_Event_Session__c es : EventSession) {
            regDateOpenDate = Datetime.now().addDays(-1);
            if (es.Event__r.Close_Event_Days_Before__c != null) {
                regDateOpenDate = Datetime.now().addDays((Integer.valueOf(es.Event__r.Close_Event_Days_Before__c + 1 * -1)));
            }
            eventItem evt = new eventItem();
            evt.ID = es.Id;
            evt.title = es.Event__r.Name;
            if (es.Session_Title__c != null) {
                evt.title += ' - ' + es.Session_Title__c;
            }

            evt.sessionDesc = es.Session_Short_Description__c;
            evt.description = es.Event__r.Event_description__c;
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
                evt.eventUrl = '/applicantportal/USTEventRegister?sessionID=' + es.Id;
                evt.className = 'eventOpened';
            }

            EventList.add(evt);
        }
        jsonHolder = JSON.serialize(EventList);
        jsonHolder = jsonHolder.replace('"EndDate":', '"end":');*/
        return jsonHolder;
    }

    public String getAudienceDD(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> fieldMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            fieldMap.put(f.getLabel(), f.getValue());
        }
        return JSON.serialize(fieldMap);
    }

}