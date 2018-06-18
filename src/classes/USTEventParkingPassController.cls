/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventParkingPassController {
    public String couponOut { get; set; }
    public String firstName { get; set; }
    public String warning { get; set; }
    private USTEventShared USTShare = new USTEventShared();


    public USTEventParkingPassController() {
        warning = '';
        couponOut = '';
        String regId = ApexPages.currentPage().getParameters().get('regId');
        Datetime todaysDateTime = USTShare.adjustForCenteralTime(Datetime.now());
        Date todaysDate = date.newinstance(todaysDateTime.year(), todaysDateTime.month(), todaysDateTime.day());
        if (!String.isBlank(regId)) {
            UST_Event_Registration__c visitor = [SELECT Date__c, Contact__r.Name, Contact__r.Mailing_First_Name__c, Status__c FROM UST_Event_Registration__c WHERE id = :regId][0];
            if (visitor != null) {
                if (todaysDate <= visitor.Date__c && visitor.Status__c != 'Started' && visitor.Status__c != 'Cancelled') {
                    couponOut += '<p>NAME:&nbsp; ' + visitor.Contact__r.Name + '</p>';
                    couponOut += '<p>DATE VALID:&nbsp; ' + visitor.Date__c.format() + '</p>';
                    firstName = visitor.Contact__r.Mailing_First_Name__c;

                } else {
                    warning = 'Sorry, this parking permit has expired.';
                }
            }
        } else {
            warning = 'Sorry, We could not find your parking permit ID.';
        }
    }
}