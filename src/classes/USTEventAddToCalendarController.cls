/**
 * Created by dahl3702 on 11/12/2018.
 */

public with sharing class USTEventAddToCalendarController {

    public List<UST_Event_Instance__c> evtInfo { get; set; }
    public String DTSTART { get; set; }
    public String DTEND { get; set; }
    public String DTSTAMP { get; set; }
    public String TIMEZONE {get;set;}
    public String LOCATION { get; set; }
    public String DESCRIPTION { get; set; }
    public String LONGDESCRIPTION { get; set; }
    public String UUID { get; set; }

    public USTEventAddToCalendarController() {
        DTSTART = '';
        DTEND = '';
        DTSTAMP = '';
        LOCATION = '';
        DESCRIPTION = '';
        LONGDESCRIPTION = '';
        TIMEZONE = 'Central Daylight Time (America/Chicago)';
        UUID = NewGuid();
        String URLinstanceID = ApexPages.currentPage().getParameters().get('instanceID');
        if (!String.isBlank(URLinstanceID)) {
            evtInfo = [
                    SELECT Event_Name__c, Start_Date_Time__c, End_Date_Time__c, Instance_Title__c, Instance_Short_Description__c, Event__r.Event_Short_Listing_Description__c,
                            EVent__r.Event_description__c, Location_Title_Override__c, Event__r.Location_Title__c
                    FROM UST_Event_Instance__c
                    WHERE Id = :URLinstanceID
            ];

            if (evtInfo.size() > 0) {
                DTSTART = evtInfo[0].Start_Date_Time__c.format('yyyyMMdd\'T\'HHmmss\'Z\'');
                DTEND = evtInfo[0].End_Date_Time__c.format('yyyyMMdd\'T\'HHmmss\'Z\'');
                DTSTAMP = Datetime.now().format('yyyyMMdd\'T\'HHmmss\'Z\'');
                DESCRIPTION = evtInfo[0].Event_Name__c;
                if (!String.isBlank(evtInfo[0].Instance_Title__c)) {
                    DESCRIPTION += ' - ' + evtInfo[0].Instance_Title__c;
                }
                LONGDESCRIPTION = DESCRIPTION + evtInfo[0].Event__r.Event_description__c;
                DESCRIPTION += '\n' + evtInfo[0].Event__r.Event_Short_Listing_Description__c;
                DESCRIPTION += '\n' + evtInfo[0].Instance_Short_Description__c;
                if (String.isNotBlank(evtInfo[0].Location_Title_Override__c)) {
                    LOCATION = evtInfo[0].Location_Title_Override__c;
                } else if (String.isNotBlank(evtInfo[0].Event__r.Location_Title__c)){
                    LOCATION = evtInfo[0].Event__r.Location_Title__c;
                }

            }
        }
    }


    private static String kHexChars = '0123456789abcdef';

    public static String NewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i = 0; i < 16; i++) {

            if (i == 4 || i == 6 || i == 8 || i == 10)
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255) - 128) & 255;

            if (i == 6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i == 8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    public static String getCharAtIndex(String str, Integer index) {
        if (str == null) return null;
        if (str.length() <= 0) return str;
        if (index == str.length()) return null;
        return str.substring(index, index + 1);
    }
}


//http://dev-stthomas.cs65.force.com/applicantportal/usteventaddtocalendar?instanceID=a320m0000001I34