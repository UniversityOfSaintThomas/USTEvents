/**
 * Created by dahl3702 on 10/2/2018.
 */
@RestResource(urlMapping='/admissioncounselor/*')

global with sharing class AdmissionsCounselorLookup {

    private class CounselorInfo {
        //Name,Email, College__c,Major__c, Hometown__c,About_Me__c,What_I_Love_About_St_Thomas__c,Words_of_Advice__c
        String name { get; set; }
        String email { get; set; }
        String title { get; set; }
        String phone { get; set; }
        String college { get; set; }
        String major { get; set; }
        String hometown { get; set; }
        String about { get; set; }
        String USTLove { get; set; }
        String advice { get; set; }
        string smallPhoto { get; set; }
        string largePhoto { get; set; }
        string address { get; set; }
    }

    @HttpGet
    global static void getAdmissionsCounselorLookup() {
        if (String.isNotBlank(RestContext.request.params.get('type'))) {
            String feedType = String.escapeSingleQuotes(RestContext.request.params.get('type'));
            String serializedJSON = '';

            RestResponse res = RestContext.response;
            String callback = '';

            if (String.isNotBlank(RestContext.request.params.get('callback'))) {
                callback = String.escapeSingleQuotes(RestContext.request.params.get('callback'));
            }

            if (String.isBlank(callback)) {
                res.addHeader('Content-Type', 'application/json');
                callback = '';
            } else {
                res.addHeader('Content-Type', 'application/javascript');
            }

            if (!String.isBlank(feedType)) {
                if (feedType.toLowerCase() == 'counselor') {
                    serializedJSON = JSON.serialize(counselorInformation());
                } else if (feedType.toLowerCase() == 'bio') {
                    String counselorName = RestContext.request.params.get('name');
                    if (String.isNotBlank(counselorName)) {
                        counselorName.replace('%20', ' ');
                        counselorName.replace('+', ' ');
                        serializedJSON = JSON.serialize(counselorByName(counselorName));
                    }
                } else if (feedType.toLowerCase() == 'intl') {
                    doCRUD CRUDToDo = new doCRUD();
                    Counselor_Role__c intlId = CRUDToDo.getIntlCounselorByRole();
                    if (intlId != null) {
                        List<Id> intlIds = new List<Id>();
                        intlIds.add(intlId.Staff_Member_Holding_Role__r.Id);
                        serializedJSON = JSON.serialize(grabCounselorList(intlIds));
                    }

                }
            }

            if (!String.isBlank(callback)) {
                serializedJSON = callback + '(' + serializedJSON + ')';
            }
            res.responseBody = Blob.valueOf(serializedJSON);
        }
    }

    private static List<CounselorInfo> counselorInformation() {
        String state = '';
        String city = '';
        String nation = '';
        String query = '';
        String school = '';
        String territory = '';
        String role = '';
        List<CounselorInfo> ci = new List<CounselorInfo>();
        List<Geographic_Area__c> ga = new List<Geographic_Area__c>();
        List<EnrollmentrxRx__High_School__c> hs = new list<EnrollmentrxRx__High_School__c>();
        List<UG_Counseling_Territory__c> UGTerritories = new List<UG_Counseling_Territory__c>();
        List<Id> cUserIds = new List<Id>();
        doCRUD CRUDToDo = new doCRUD();
        //Get URL variables
        if (String.isNotBlank(RestContext.request.params.get('nation'))) {
            nation = String.escapeSingleQuotes(RestContext.request.params.get('nation')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('state'))) {
            state = String.escapeSingleQuotes(RestContext.request.params.get('state')).toUpperCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('city'))) {
            city = String.escapeSingleQuotes(RestContext.request.params.get('city')).toLowerCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('school'))) {
            school = String.escapeSingleQuotes(RestContext.request.params.get('school')).toLowerCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('territory'))) {
            territory = String.escapeSingleQuotes(RestContext.request.params.get('territory')).toLowerCase();
        }
        if (String.isNotBlank(RestContext.request.params.get('role'))) {
            role = String.escapeSingleQuotes(RestContext.request.params.get('role')).toLowerCase();
        }

        //Build query string for SOQL LIKE statement
        if (String.isNotBlank(school)) {
            hs = CRUDToDo.getSchool(school);
            if (hs.size() > 0) {
                for (EnrollmentrxRx__High_School__c h : hs) {
                    cUserIds.add(h.UG_Adm_Couns_Working_Sch_for_FYs__r.Staff_Member_Holding_Role__r.id);
                }
                ci = grabCounselorList(cUserIds);
            }
        } else if (String.isNotBlank(territory)) {
            UGTerritories = CRUDToDo.getTerrroy(territory);
            if (UGTerritories.size() > 0) {
                for (UG_Counseling_Territory__c ugt : UGTerritories) {
                    cUserIds.add(ugt.UG_Adm_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__r.Id);
                }
                ci = grabCounselorList(cUserIds);
            }
        } else if (String.isNotBlank(role)) {
            role = role + '%';
            List<Counselor_Role__c> counselorByRole = [SELECT Id, Name, Staff_Member_Holding_Role__c FROM Counselor_Role__c WHERE Name LIKE :role];
            if (counselorByRole.size() > 0) {
                for (Counselor_Role__c cbr : counselorByRole) {
                    cUserIds.add(cbr.Staff_Member_Holding_Role__c);
                }
                ci = grabCounselorList(cUserIds);
            }
        } else {
            // DomesticS
            if (String.isNotBlank(nation)) {
                query = 'NATION-' + nation.toLowerCase() + '%';
            } else if (String.isNotBlank(city) && String.isNotBlank(state)) {
                query = 'CITY-' + ((city + state).toLowerCase().replace('%20', '').replace(' ', '')) + '%';
            } else if (String.isNotBlank(state)) {
                if (state.equalsIgnoreCase('mn') || state.equalsIgnoreCase('wi')) {
                    query = 'CITY-%' + state + '%';
                } else {
                    query = 'STATE-' + state + '%';
                }

            } else {
                query = '%%';
            }

            if (String.IsNotBlank(query)) {
                //Get all geo areas that match query like statement (using passed in URL variables)
                ga = CRUDToDo.gaList(query);

                if (ga.size() > 0) {

                    //Build list of IDs of users (must clean them up as they are HTML links)
                    for (Geographic_Area__c g : ga) {
                        cUserIds.add(g.UG_Counseling_Geographic_Territory__r.UG_Adm_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__c);
                    }
                    ci = grabCounselorList(cUserIds);
                }
            }
        }

        //return cutom object list for JSON serialization
        return ci;
    }

    private static List<CounselorInfo> counselorByName(String counselorName) {
        List<User> cUser = new List<User>();
        List<Id> cUserIds = new List<Id>();

        doCRUD CRUDToDo = new doCRUD();
        cUser = CRUDToDo.getCounselorByName(counselorName);

        if (cUser.size() > 0) {
            for (User u : cUser) {
                cUserIds.add(u.Id);
            }
            return grabCounselorList(cUserIds);
        }
        return new List<CounselorInfo>();
    }

    private static List<CounselorInfo> grabCounselorList(List<Id> cUserIds) {
        List<CounselorInfo> ci = new List<CounselorInfo>();
        doCRUD CRUDToDO = new doCRUD();
        List<User> cUser = new List<User>();
        String cascadeUserImage = '';
        //Get list off all users that match gathered list from geo areas
        if (cUserIds.size() > 0) {
            cUser = CRUDToDO.readUserByIdList(cUserIds);

            //Add queried users to custom object defined in this class
            String myDomain = CRUDToDO.getDomain();

            for (User u : cUser) {
                CounselorInfo addCoun = new CounselorInfo();
                cascadeUserImage = u.Name.replace(' ', '_').toLowercase();
                cascadeUserImage = cascadeUserImage + '.jpg';
                addCoun.name = u.Name;
                addCoun.email = u.Email;
                addCoun.college = (String.isNotBlank(u.College__c) ? u.College__c : '');
                addCoun.major = (String.isNotBlank(u.Major__c) ? u.Major__c : '');
                addCoun.hometown = (String.isNotBlank(u.Hometown__c) ? u.Hometown__c : '');
                addCoun.about = (String.isNotBlank(u.About_Me__c) ? u.About_Me__c : '');
                addCoun.USTLove = (String.isNotBlank(u.What_I_Love_About_St_Thomas__c) ? u.What_I_Love_About_St_Thomas__c : '');
                addCoun.advice = (String.isNotBlank(u.Words_of_Advice__c) ? u.Words_of_Advice__c : '');
                addCoun.title = (String.isNotBlank(u.title) ? u.title : '');
                if (String.isNotBlank(u.Extension)) {
                    addCoun.phone = u.phone + ' ext ' + u.Extension;
                } else {
                    addCoun.phone = (String.isNotBlank(u.phone) ? u.phone : '');
                }
                addCoun.address = (String.isNotBlank(u.street) ? (u.street.replace('\n', '<br>') + ' <br>' + u.city + ', ' + u.state + ' ' + u.postalCode) : '');
                addCoun.smallPhoto = 'https://' + myDomain + (String.isNotBlank(u.SmallPhotoUrl) ? u.SmallPhotoUrl : '');
                //addCoun.largePhoto = 'https://' + myDomain + (String.isNotBlank(u.FullPhotoUrl) ? u.FullPhotoUrl : '');
                addCoun.largePhoto = 'https://www.stthomas.edu/_media-library/_locate-counselor/' + cascadeUserImage;
                ci.add(addCoun);
            }
        }
        return ci;
    }

    private without sharing class doCRUD {

        public List<UG_Counseling_Territory__c> getTerrroy(String territory) {
            List<UG_Counseling_Territory__c> UGTerritories = [
                    SELECT Id, UG_Adm_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__r.Id
                    FROM UG_Counseling_Territory__c
                    WHERE Banner_Territory_Code__c = :territory
            ];

            return UGTerritories;
        }
        public List<User> getCounselorByName(String counselorName) {
            List<User> cUser = [
                    SELECT Id,Admissions_Counselor__c
                    FROM User
                    WHERE NAME LIKE :counselorName
                    AND Admissions_Counselor__c = TRUE
            ];
            return cUser;
        }

        public List<User> readUserByIdList(List<Id> cUserIds) {
            List<User> cUser = [
                    SELECT Name, Email, College__c, Major__c, Hometown__c, About_Me__c, What_I_Love_About_St_Thomas__c, Words_of_Advice__c,
                            SmallPhotoUrl, FullPhotoUrl, title, phone, street, state, city, postalCode, Extension, Admissions_Counselor__c
                    FROM User
                    WHERE Id  in :cUserIds
                    AND Admissions_Counselor__c = TRUE
            ];
            return cUser;
        }

        public List<Geographic_Area__c> gaList(String likeQuery) {
            List<Geographic_Area__c> gaList = [
                    SELECT UG_Counseling_Geographic_Territory__r.UG_Adm_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__c
                    FROM Geographic_Area__c
                    WHERE NAME LIKE :likeQuery
            ];
            return gaList;
        }

        public String getDomain() {
            List<Domain> DomainList = [SELECT Domain FROM Domain];
            String myDomain = '';
            if (DomainList.size() > 0) {
                myDomain = DomainList[0].Domain;
            }
            return myDomain;
        }

        // Counselor_Role__c|UG_Adm4Y_Couns_Fallback_for_Intls
        public Counselor_Role__c getIntlCounselorByRole() {
            Id roleId = Util.getSObjIdBySettingsCompositeKey('Counselor_Role__c', 'UG_Adm4Y_Couns_Fallback_for_Intls');
            Counselor_Role__c intlId = null;
            if (String.isNotBlank(roleId)) {
                intlId = [SELECT Id, Staff_Member_Holding_Role__r.Id FROM Counselor_Role__c WHERE id = :roleId][0];
            }
            return intlId;
        }

        public List<EnrollmentrxRx__High_School__c> getSchool(String CEEBCode) {
            List<EnrollmentrxRx__High_School__c> hs = [
                    SELECT UG_Adm_Couns_Working_Sch_for_FYs__r.Staff_Member_Holding_Role__r.id
                    FROM EnrollmentrxRx__High_School__c
                    WHERE EnrollmentrxRx__CEEB_Code__c = :CEEBCode
            ];
            return hs;
        }


    }

}