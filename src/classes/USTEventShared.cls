/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventShared {
    //private key for encryption
    Private Blob key = Blob.valueOf('TmC%2%4&X9fzG2PrtP7f&6acnc#y7@vW');
    Public String defaultTemplate = 'CastorTemplate2017';

    public class USTEventInfo {
        public String audience { get; set; }
        public String instanceID { get; set; }
        public String evtRegId { get; set; }
        public String evtId { get; set; }
        public String recordTypeName {get;set;}
    }

    public USTEventInfo getUSTEventInfo() {
        //{"audience":"High School Senior","instanceID":"a320m000000A5fOAAS","evtRegId":"a350m0000008q63AAA,"evtId":"a330m0000001SOrAAM"}
        String jsonInput = '';
        USTEventInfo evtInfo = new USTEventInfo();
        String URLaudience = ApexPages.currentPage().getParameters().get('audience');
        String URLinstanceID = ApexPages.currentPage().getParameters().get('instanceID');
        jsonInput = getDecryptCookie('USTEvent');
        if (!String.isBlank(jsonInput)) {
            try {
                evtInfo = (USTEventInfo) JSON.deserialize(jsonInput, USTEventInfo.class);
            } catch (Exception e) {
                //Cookie was un-serializable so delete it
                Cookie deleteCookie = new Cookie('USTEvent', '', null, 0, false); // Note the 0 to delete the cookie
                ApexPages.currentPage().setCookies(new Cookie[]{deleteCookie});
            }
        }
        if (!String.isBlank(URLinstanceID)) {
            if (URLinstanceID.length() > 14) {
                if (URLinstanceID != evtInfo.instanceID) {
                    //event instance has changed so delete cookie and reestablish with new instance
                    Cookie deleteCookie = new Cookie('USTEvent', '', null, 0, false); // Note the 0 to delete the cookie
                    ApexPages.currentPage().setCookies(new Cookie[]{
                            deleteCookie
                    });
                    evtInfo = new USTEventInfo();
                    evtInfo.instanceID = URLinstanceID;
                    if (!String.isBlank(URLaudience)) {
                        evtInfo.audience = URLaudience;
                    }
                    try {
                        UST_Event_Instance__c instanceInfo = [SELECT Event__c, Event__r.RecordType.Name FROM UST_Event_Instance__c WHERE ID = :evtInfo.instanceID][0];
                        evtInfo.evtId = instanceInfo.Event__c;

                    } catch (Exception e) {

                    }
                    createEncryptedCookie('{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"COMING","evtId":"' + evtInfo.evtId + '"}', 'USTEvent');
                }
            }
        }
        //Get record type
        UST_Event_Instance__c recTypeInfo = [SELECT Event__r.RecordType.Name FROM UST_Event_Instance__c WHERE ID = :evtInfo.instanceID][0];
        if (String.isBlank(recTypeInfo.event__r.RecordType.Name)) {
            evtInfo.recordTypeName = 'Undergraduate';
        } else {
            evtInfo.recordTypeName = recTypeInfo.event__r.RecordType.Name;
        }

        //check if regid is there  and whether status it is set to registered. IF so reset cookie if it is.
        if (!String.isBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING') {
            UST_Event_Registration__c evtReg = [SELECT Status__c FROM UST_Event_Registration__c WHERE ID = :evtInfo.evtRegId][0];
            if (evtReg.Status__c != 'Started') {
                //Registration is complete and a new form should be generated.
                createEncryptedCookie('{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"","evtId":"' + evtInfo.evtId + '"}', 'USTEvent');
            }
        }

        //If eventInfo is null return to default page (add to event definition object.

        return evtInfo;
    }

    public PageReference checkForEvent() {
        USTEventInfo evt = new USTEventInfo();
        PageReference myVFPage = null;
        evt = getUSTEventInfo();
        SYSTEM.debug('!!!!!!!!!!!!!!!  EVENT ID : ' + evt.evtId + ' , INSTANCE ID : ' + evt.instanceID + ' , EVENT REG ID : ' + evt.evtRegId);
        if (String.isBlank(evt.evtRegId) || String.isBlank(evt.instanceID)) {
            if (!String.isBlank(evt.evtId)) {
                UST_Event__c eventPage = [SELECT Event_Home_Link_URL__c FROM UST_Event__c WHERE Id = :evt.evtId][0];
                myVFPage = new PageReference(eventPage.Event_Home_Link_URL__c);
                myVFPage.setRedirect(true);
            } else {
                myVFPage = new PageReference('/applicantportal/USTEvent');
                myVFPage.setRedirect(true);
            }
            //Reset the cookie to prevent loop on registration page
            Cookie deleteCookie = new Cookie('USTEvent', '', null, 0, false); // Note the 0 to delete the cookie
            ApexPages.currentPage().setCookies(new Cookie[]{deleteCookie});
            return myVFPage;
        }
        return null;
    }

    public String createEncryptedCookie(String CookieValue, String CookieName) {
        Blob data = Blob.valueOf(CookieValue);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);
        String encodedCipherText = EncodingUtil.base64Encode(encrypted);
        encodedCipherText = EncodingUtil.urlEncode(encodedCipherText, 'UTF-8');
        Cookie USTEventCookie = new Cookie(CookieName, encodedCipherText, null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{
                USTEventCookie
        });
        return encodedCipherText;
    }

    public String getDecryptCookie(String CookieName) {

        Cookie encodedCipherText = ApexPages.currentPage().getCookies().get(CookieName);
        if (encodedCipherText != null) {
            try {
                Blob decrypted = Crypto.decryptWithManagedIV(
                        'AES256',
                        key,
                        EncodingUtil.base64Decode(
                                EncodingUtil.urlDecode(encodedCipherText.getValue(), 'UTF-8')
                        )
                );
                return decrypted.toString();
            } catch (Exception e) {
                return '';
            }
        }
        return '';
    }

    public DateTime adjustForCenteralTime(Datetime dt) {
        //Get the current GMT time and adjust for our timezone
        //tz = TimeZone.getTimeZone('America/Chicago');
        //Timezone adjustment example below:
        //Datetime NowDate = Datetime.now();
        //NowDate = NowDate.addSeconds(tz.getOffset(NowDate)/1000);
        TimeZone tz = TimeZone.getTimeZone('America/Chicago');
        dt = dt.addSeconds(tz.getOffset(dt) / 1000);
        return dt;
    }

    public Map<String, String> getDependentSelectOptions(String parentObjName, String parentFieldName, String dependentFieldName, String parentValue) {
        Map<String, String> dependentItems = new Map<String, String>();
        if (null != parentObjName && null != parentFieldName && null != dependentFieldName && null != parentValue) {
            Schema.DescribeFieldResult dependentField;
            Integer parentValueIndex = -1;

            //FIRST get the Parent PL's index value
            Schema.DescribeSObjectResult objectMeta = Schema.describeSObjects(new String[]{
                    parentObjName
            })[0];
            Schema.SObjectField[] fields = objectMeta.fields.getMap().values();
            for (Schema.SObjectField f : fields) {
                Schema.DescribeFieldResult d = f.getDescribe();
                String fieldname = d.getName().toLowerCase();
                String ftype = String.valueOf(d.getType()).toLowerCase();
                if (fieldname.equals(parentFieldName.toLowerCase()) && ('picklist'.equals(ftype) || 'multipicklist'.equals(ftype))) {
                    Schema.PicklistEntry[] pplvalues = d.getPicklistValues();
                    for (Integer i = 0; i < pplvalues.size(); i++) {
                        if (parentValue.equals(pplvalues[i].getValue())) {
                            parentValueIndex = i;
                            break;
                        }
                    }
                }
                if (fieldname.equals(dependentFieldName.toLowerCase()) && ('picklist'.equals(ftype) || 'multipicklist'.equals(ftype))) {
                    dependentField = d;
                }
            }

            //2nd get the dependent PL values mapped to the target parent PL's value
            if (-1 != parentValueIndex && null != dependentField) {
                Schema.PicklistEntry[] plValues = dependentField.getPicklistValues();
                for (PicklistEntry plv : plValues) {
                    String jsonstr = JSON.serialize(plv);
                    Map<String, String> jMap = (Map<String, String>) JSON.deserialize(jsonstr, Map<String, String>.class);
                    String validFor = jMap.get('validFor');
                    String plvalue = jMap.get('value');
                    String plId = jMap.get('id');
                    if (null != validFor && !''.equals(validFor.trim()) && isDependentValue(parentValueIndex, validFor)) {
                        dependentItems.put(plvalue, plvalue);
                    }
                }
            }
        }
        return dependentItems;
    }

    private static Boolean isDependentValue(Integer index, String validFor) {
        String decoded = EncodingUtil.convertToHex(EncodingUtil.base64Decode(validFor));
        Integer bits = hexToInt(decoded);
        return ((bits & (128 >> Math.mod(index, 8))) != 0);
    }

    private static Map<String, Integer> hexMap = new Map<String, Integer>{
            '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9, 'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 'E' => 14, 'F' => 15, 'a' => 10, 'b' => 11, 'c' => 12, 'd' => 13, 'e' => 14, 'f' => 15
    };

    private static Integer hexToInt(String hex) {
        Integer retVal = 0;
        for (Integer i = 0; i < hex.length(); i += 2) {
            retVal += (hexMap.get(hex.substring(i, i + 1)) * 16) + (hexMap.get(hex.substring(i + 1, i + 2)));
        }
        return retVal;
    }


}