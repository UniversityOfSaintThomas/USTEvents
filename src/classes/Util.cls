public class Util {

    private static List<String> debugLog = new List<String>();
    private static Map<String, Id> recordTypeIDsByDevAndSObjNameMap = new Map<String, Id>();
    private static Boolean alreadyRanProgramIDsByNameMap = FALSE;
    private static Map<String, Id> programIDsByNameMap = new Map<String, Id>();
    private static Boolean alreadyRanProfileIDsByNameMap = FALSE;
    private static Map<String, Id> profileIDsByNameMap = new Map<String, Id>();
    private static Map<String, Counselor_Assignment_Setting__mdt> counselorAssignmentSettingsMap = new Map<String, Counselor_Assignment_Setting__mdt>();
    private static List<Counselor_Role__c> counselorRoles;
    private static Map<String, Id> counsRoleIDsByExtId = new Map<String, Id>();
    private static Boolean alreadyRanCounsRoleIdByExtIdMap = FALSE;
    private static Map<Id, Id> userIDsByCounsRoleId = new Map<Id, Id>();
    private static Boolean alreadyRanUserIdByCounsRoleIdMap = FALSE;
    @TestVisible private static Boolean testInvolvesCounselorRoleDMLSoAllowMultipleRuns = FALSE;
    @TestVisible private static Boolean doNotKeepTryingToCreateCounsRolesMapThisTest = FALSE;
    private static Map<String, Id> ugCounsGeoTerrIDsByExtId = new Map<String, Id>();
    private static Map<String, Geographic_Area__c> geoAreasMap = new Map<String, Geographic_Area__c>();
    private static Map<String, Geographic_Area__c> specificGeoAreasMap = new Map<String, Geographic_Area__c>();
    private static final Integer MAXQUERIESFORSPECIFICGEOAREASMAP = 3;
    private static Integer queriesInvokedForSpecificGeoAreasMap = 0;
    private static Map<String, Id> alphaUGTerrsToFACounsIdsMap = new Map<String, Id>();
    private static Pattern twoUpperAlphaPattern =  Pattern.compile('^[A-Z][A-Z]$');
    private static List<nameCase_Exception__c> nceList;
    
    public static void addStringToDebugLog(String s) {
        // System Debug Logs can get hard to read because there is so much going on in this database they can overflow.
        // For quick reference while writing code, add strings you want to "print" here
        // by calling:
        // Util.addStringToDebugLog('Example String To Print');
        // then have your unit test call:
        // System.Assert(FALSE, Util.getDebugLogAsString());
        // then go to https://workbench.developerforce.com/query.php and query
        // SELECT Message FROM ApexTestResult WHERE SystemModstamp >= TODAY AND Outcome='Fail' ORDER BY SystemModstamp DESC NULLS LAST LIMIT 5
        // You will see you strings with triple dashes at the beginning and end of your log, and triple tildes separating the various entries in the log.
        debugLog.add(s);
    }
        
    public static String getDebugLogAsString() {
        return '---' + String.join(debugLog,'~~~') + '---';
    }
    
    public static void clearDebugLog() {
        debugLog.clear();
    }
    
    public static Id getRecordTypeId(String devName, String sObjName) {
        // Returns "NULL" if no RecordType Id identified by strings passed through parameters
        if (recordTypeIDsByDevAndSObjNameMap.isEmpty()) { for (RecordType rt : [SELECT Id, DeveloperName, SObjectType FROM RecordType]) { recordTypeIDsByDevAndSObjNameMap.put((rt.DeveloperName + ';' + rt.SObjectType), rt.Id); } } // Lazy data fetch of entire "RecordType" table into this object's "recordTypeIDsByDevAndSObjNameMap" private variable
        // Grab the relevant ID and return it (or "null" if not found)
        if (recordTypeIDsByDevAndSObjNameMap.containsKey(devName + ';' + sObjName)) { return recordTypeIDsByDevAndSObjNameMap.get(devName + ';' + sObjName); }
        return NULL;
    }
    
    public static Id getProgIdByName(String progName) {
        // Returns "NULL" if no Program ID identified by string passed through parameter
        if ( !alreadyRanProgramIDsByNameMap ) {
            for ( EnrollmentrxRx__Program_Catalog__c p : [SELECT Id, Name FROM EnrollmentrxRx__Program_Catalog__c WHERE Name <> NULL] ) { programIDsByNameMap.put(p.Name, p.Id); }
            alreadyRanProgramIDsByNameMap = TRUE;
        }
        if ( programIDsByNameMap.containsKey(progName) ) { return programIDsByNameMap.get(progName); }
        return NULL;
    } // "Program" as in "Program Catalog" as in "Level" (e.g. UG/G), not as in "Program Offered" (e.g. full-time MBA)
    
    public static Id getProfileIdByName(String profileName) {
        // Returns "NULL" if no Profile ID identified by string passed through parameter
        if ( !alreadyRanProfileIDsByNameMap ) {
            for ( Profile p : [SELECT Id, Name FROM Profile WHERE Name <> NULL] ) { profileIDsByNameMap.put(p.Name, p.Id); }
            alreadyRanProfileIDsByNameMap = TRUE;
        }
        if ( profileIDsByNameMap.containsKey(profileName) ) { return profileIDsByNameMap.get(profileName); }
        return NULL;
    }
    
    @TestVisible private static void insertProgByNameIfNotExists(String progName) {
        if ( [SELECT Id FROM EnrollmentrxRx__Program_Catalog__c WHERE Name = :progName].size() == 0 ) { INSERT new EnrollmentrxRx__Program_Catalog__c(Name=progName); }
    }
    
    public static Id getSObjIdBySettingsCompositeKey(String qualApiName, String objApiName) {
        // Returns "NULL" if no SObject Id identified by strings passed through parameters
        Id idToReturn = NULL;
        if ( counselorAssignmentSettingsMap.isEmpty() ) {
            // Lazy-populate counselorAssignmentSettingsMap
            for ( Counselor_Assignment_Setting__mdt s : [SELECT QualifiedApiName, Object_API_Name__c, Value__c FROM Counselor_Assignment_Setting__mdt] ) { counselorAssignmentSettingsMap.put(s.Object_API_Name__c+'|'+s.QualifiedApiName, s); }
        }
        if ( counselorAssignmentSettingsMap.containsKey(qualApiName+'|'+objApiName) ) {
            if ( qualApiName == 'Counselor_Role__c' ) {
                idToReturn = getCounsRoleIdByExtId(counselorAssignmentSettingsMap.get(qualApiName+'|'+objApiName).Value__c);
            }
            else if ( qualApiName == 'User' ) {
                if ( counselorAssignmentSettingsMap.get(qualApiName+'|'+objApiName).Value__c.startsWith('005') ) { 
                    idToReturn = String.valueOf(counselorAssignmentSettingsMap.get(qualApiName+'|'+objApiName).Value__c);
                }
                else {
                    // If not a hard-coded User ID, presume that Value__c must represent a UST Net Id (note that if this doesn't return a match, it'll be a NULL value)
                    IdToReturn = UtilsNoShare.getCertainTypesOfUserIdByUSTNetId(counselorAssignmentSettingsMap.get(qualApiName+'|'+objApiName).Value__c);
                }
            }
        }
        return idToReturn;
    }

    private static Id getCounsRoleIdByExtId(String extIdString) {
        // Returns "NULL" if no Counselor Role identified by string passed through parameter
        if ( counsRoleIDsByExtId.isEmpty() && (!Test.isRunningTest() || !doNotKeepTryingToCreateCounsRolesMapThisTest) ) { 
            // Lazy-populate counsRoles, taking care not to keep passing over this again and again if in a test that never creates any Counselor Roles
            populateCounselorRoleMapsIfEmpty();
            for (Counselor_Role__c cr : counselorRoles) { counsRoleIDsByExtId.put(cr.Unique_Code__c, cr.Id); }
            //if (!alreadyRanCounsRoleIdByExtIdMap) { alreadyRanCounsRoleIdByExtIdMap = TRUE; }
        }
        if ( counsRoleIDsByExtId.containsKey(extIdString) ) { return counsRoleIDsByExtId.get(extIdString); }
        return NULL;
    }
    
    public static Id getUserIdByCounsRoleId(Id counsRoleRecordId) {
        // Returns "NULL" if no User identified by Id passed through parameter
        if ( userIDsByCounsRoleId.isEmpty() && (!Test.isRunningTest() || !doNotKeepTryingToCreateCounsRolesMapThisTest) ) { 
             // Lazy-populate userIDsByCounsRoleId, taking care not to keep passing over this again and again if in a test that never creates any Counselor Roles
            populateCounselorRoleMapsIfEmpty();
            for (Counselor_Role__c cr : counselorRoles) { if ( cr.Staff_Member_Holding_Role__c <> NULL ) { userIDsByCounsRoleId.put(cr.Id, cr.Staff_Member_Holding_Role__c); } }
            //if (!alreadyRanUserIdByCounsRoleIdMap) { alreadyRanUserIdByCounsRoleIdMap = TRUE; }
        }
        if ( userIDsByCounsRoleId.containsKey(counsRoleRecordId) ) { return userIDsByCounsRoleId.get(counsRoleRecordId); }
        return NULL;
    }
    
    private static void populateCounselorRoleMapsIfEmpty() {
        if ( counselorRoles == NULL || counselorRoles.isEmpty() ) {
            counselorRoles = [SELECT Id, Unique_Code__c, Staff_Member_Holding_Role__c FROM Counselor_Role__c];
        }
    }
    
    public static Id getUGCounsGeoTerrIdByExtId(String extIdString) {
        // Returns "NULL" if no UG Counseling Geographic Territory identified by string passed through parameter
        if ( ugCounsGeoTerrIDsByExtId.isEmpty() ) { for (UG_Counseling_Territory__c t : [SELECT Id, Banner_Territory_Code__c FROM UG_Counseling_Territory__c WHERE Banner_Territory_Code__c LIKE 'GEO-%']) { ugCounsGeoTerrIDsByExtId.put(t.Banner_Territory_Code__c, t.Id); } } // Lazy-populate cugCounsGeoTerrIDsByExtIdounsRoles
        if ( ugCounsGeoTerrIDsByExtId.containsKey(extIdString) ) { return ugCounsGeoTerrIDsByExtId.get(extIdString); }
        return NULL;
    }
    
    public static Map<String, Geographic_Area__c> getGeoAreasMap() {
        if ( geoAreasMap.isEmpty() ) {  
            // Lazy-populate geoAreasMap with full map that is basically a copy of database table
            for ( Geographic_Area__c g : [SELECT Id, ID_Code__c, UG_Counseling_Geographic_Territory__c, UG_Counseling_Geographic_Territory__r.Banner_Territory_Code__c, UG_Counseling_Geographic_Territory__r.UG_Adm_Couns_Working_This_Territory__c, UG_Counseling_Geographic_Territory__r.UG_FinAid_Couns_Working_This_Territory__c, UG_Counseling_Geographic_Territory__r.UG_Adm_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__c, UG_Counseling_Geographic_Territory__r.UG_FinAid_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__c from Geographic_Area__c] ) { geoAreasMap.put(g.ID_Code__c, g); }
        }
        return geoAreasMap;
    }
    
    public static Map<String, Geographic_Area__c> getSpecificGeoAreasMap(Set<String> geoAreaKeysDesired) {
        // Note that this method can return an empty map if none of the "desired" geo-area keys passed as parameters actually exist in the org's data.
        if ( !geoAreasMap.isEmpty() ) {
            return getGeoAreasMap();
        }
        if ( geoAreaKeysDesired <> NULL && !geoAreaKeysDesired.isEmpty() && (specificGeoAreasMap.isEmpty() || !specificGeoAreasMap.keySet().containsAll(geoAreaKeysDesired)) ) {
            if ( queriesInvokedForSpecificGeoAreasMap >= MAXQUERIESFORSPECIFICGEOAREASMAP ) {
                // Short-circuit returning "specificGeoAreasMap" and return whatever the "full table" map is instead if we've done "specific" too many times.
                return getGeoAreasMap();
            }
            else {
                // Lazy-populate geoAreasMap with map of only parameter-matching ID_Code__c values
                queriesInvokedForSpecificGeoAreasMap++; // Increment counter of queries attempted.
                for ( Geographic_Area__c g : [SELECT Id, ID_Code__c, UG_Counseling_Geographic_Territory__c, UG_Counseling_Geographic_Territory__r.Banner_Territory_Code__c, UG_Counseling_Geographic_Territory__r.UG_Adm_Couns_Working_This_Territory__c, UG_Counseling_Geographic_Territory__r.UG_FinAid_Couns_Working_This_Territory__c, UG_Counseling_Geographic_Territory__r.UG_Adm_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__c, UG_Counseling_Geographic_Territory__r.UG_FinAid_Couns_Working_This_Territory__r.Staff_Member_Holding_Role__c from Geographic_Area__c where ID_Code__c in :geoAreaKeysDesired] ) {
                    specificGeoAreasMap.put(g.ID_Code__c, g);
                }
            }
        }
        return specificGeoAreasMap;
    }

    public static Boolean getSpecificGeoAreasHasFlippedToWholeTable() { return (queriesInvokedForSpecificGeoAreasMap >= MAXQUERIESFORSPECIFICGEOAREASMAP); }

    public static Id getFinAidCounsRoleIdByAlphaUGTerrRule(String lastName, Boolean isDomesticFirstYear, Boolean isDomesticTransfer) {
        if ( alphaUGTerrsToFACounsIdsMap.isEmpty() ) {
            // Lazy-populate alphaUGTerrsToFACounsIdsMap with full map
            for ( UG_Counseling_Territory__c t : [SELECT Id, Banner_Territory_Code__c, UG_FinAid_Couns_Working_This_Territory__c FROM UG_Counseling_Territory__c WHERE Banner_Territory_Code__c LIKE 'ALPHA-%' AND UG_FinAid_Couns_Working_This_Territory__c <> NULL] ) { alphaUGTerrsToFACounsIdsMap.put(t.Banner_Territory_Code__c, t.UG_FinAid_Couns_Working_This_Territory__c); }
        }
        Id idToReturn = NULL;
        if ( isDomesticFirstYear==isDomesticTransfer || lastName==NULL ) { return NULL; } // Someone being both FR & TR at the same time doesn't make sense; we can't do much with a blank last name
        // Try to get by 1st letter
        idToReturn = alphaUGTerrsToFACounsIdsMap.get('ALPHA-' + (isDomesticFirstYear?'FR':(isDomesticTransfer?'TR':NULL)) + '_LTR1_' + lastName.left(1).toUpperCase() );
        // If that didn't work, try to get by 1st 2 letters
        if ( idToReturn == NULL ) {
            idToReturn = alphaUGTerrsToFACounsIdsMap.get('ALPHA-' + (isDomesticFirstYear?'FR':(isDomesticTransfer?'TR':NULL)) + '_LTR2_' + lastName.left(2).toUpperCase() );
        }
        // If that didn't work and first two letters of last name aren't pure A-Z, try again with alpha-cleaned last name (removing non-A-Z, replacing accented characters with their equivalents, etc)
        if ( idToReturn == NULL && !(twoUpperAlphaPattern.matcher(lastName.left(2).toUpperCase())).matches() ) {
            String upperNewLast2 = lastName.toUpperCase().replaceAll('[ÁÀÂÄÃÅÆ]','A').replaceAll('[ÉÈÊË]','E').replaceAll('[ÍÌÎÏ]','I').replaceAll('[ÓÒÔÖÕØŒ]','O').replaceAll('[ÚÙÛÜ]','U').replaceAll('Ç','C').replaceAll('Ñ','N').replaceAll('ß','S').replaceAll('[^A-Z]', '').left(2); // A bit rough with some of the letters that should be replaced by 2 letters, but at the moment we don't divide anything but the S's, and there aren't a lot of last names that start with a schluss, and Germans don't really apply to UST often and usually know to transliterate their own names anyway.
            idToReturn = alphaUGTerrsToFACounsIdsMap.get('ALPHA-' + (isDomesticFirstYear?'FR':(isDomesticTransfer?'TR':NULL)) + '_LTR1_' + upperNewLast2.left(1) );
            // If that didn't work, try to get by 1st 2 letters
            if ( idToReturn == NULL ) {
                idToReturn = alphaUGTerrsToFACounsIdsMap.get('ALPHA-' + (isDomesticFirstYear?'FR':(isDomesticTransfer?'TR':NULL)) + '_LTR2_' + upperNewLast2 );
            }
        }
        return idToReturn;
    }
    
    public static Id getGradAppProposedOwnerUserId(String programOfferedCode, String areaOfStudyCode, String applicantLastName) {
        // These are arranged roughly by likelihood / speed of performance, trying to short-circuit less-likely / lower-performance scenarios. -Katie Gumpertz, UST Developer, 2/13/18
        Id idToReturn = NULL;
        if ( programOfferedCode != NULL ) {
            // 1:  See if anyone can be found treating it as a "Grad_CounsByProgCode_" program that uses the whole program code
            idToReturn = getSObjIdBySettingsCompositeKey('User', 'Grad_CounsByProgCode_'+programOfferedCode);
        }
        if ( idToReturn == NULL && programOfferedCode != NULL && 'BU_BA_MS|BU_PT_MBA'.contains(programOfferedCode) ) {
            // 2:  If no luck, See if anyone can be found treating it as a "Grad_Couns_Special" program that uses the whole program code & lastname's first letter
            idToReturn = getSObjIdBySettingsCompositeKey('User', 'Grad_Couns_Special'+('ABCDEFGHIJKLM'.contains(applicantLastName.subString(0,1).toUpperCase()) ? '1' : '2')+'_'+programOfferedCode);
        }
        if ( idToReturn == NULL && areaOfStudyCode != NULL ) { 
            // 3:  If no luck, See if anyone can be found treating it as a "Grad_CounsByAreaOfStudy_" program that uses the prog-mjr concatenation from the "Area of Study code"
            idToReturn = getSObjIdBySettingsCompositeKey('User', 'Grad_CounsByAreaOfStudy_'+areaOfStudyCode.replace('|','_'));
        }
        if ( idToReturn == NULL && programOfferedCode != NULL ) {
            // 4:  If no luck, See if anyone can be found treating it as a "Grad_CounsBySchool_" program that uses the 1st part of the program code
            idToReturn = getSObjIdBySettingsCompositeKey('User', 'Grad_CounsBySchool_'+programOfferedCode.replaceFirst('^(.*)_.*_.*$','$1'));
        }
        if ( idToReturn == NULL && programOfferedCode != NULL ) {
            // 5:  If no luck, See if anyone can be found treating it as a "Grad_CounsBySubSchool_" program that uses 1st & 2nd parts of the program code
            idToReturn = getSObjIdBySettingsCompositeKey('User', 'Grad_CounsBySubSchool_'+programOfferedCode.replaceFirst('^(.*_.*)_.*$','$1'));
        }
        return idToReturn;
    }
        
    
    public static List<SObject> computeRecordsWhereAnythingImportantChanged(List<SObject> newRecords, Map<Id, SObject> oldRecordsById, Set<Schema.SObjectField> fieldsToCheck) {
        List<SObject> newRecordsThatChangedFromOld = new List<SObject>();
        if ( fieldsToCheck == NULL || fieldsToCheck.isEmpty() ) { return newRecordsThatChangedFromOld; }
        if ( newRecords == NULL || oldRecordsById == NULL ) { return newRecordsThatChangedFromOld; }
        for ( SObject record : newRecords ) {
            if ( record == NULL ) { continue; }
            SObject oldRecord = oldRecordsById.get(record.Id);
            if ( oldRecord == NULL ) { continue; }
            checkForFieldChange(record, oldRecord, fieldsToCheck, newRecordsThatChangedFromOld);
        }
        return newRecordsThatChangedFromOld;
    }
    
    private static void checkForFieldChange(SObject newObj, SObject oldObj, Set<Schema.SObjectField> fieldsToCheck, List<SObject> newRecordsThatChangedFromOld) {
        for ( Schema.SObjectField field : fieldsToCheck ) {
            try {
                if ( newObj.get(field) != oldObj.get(field) ) { 
                    newRecordsThatChangedFromOld.add(newObj);
                    return; // Any "change" in the fieldset suffices to short-circuit further inspection
                }
            }
            catch (SObjectException e) {} // No-op is fine ... if a field isn't populated in the execution context, we'll consider it "unchanged"
        }
    }

    public static String findCaseException(String buildName, List<String> spaceNames, String nameField){
        if ( nceList == NULL ) {
            nceList = [Select Id, Name, Exception_Value__c, Replace_With__c,NumChar__c, CaseModify__c, Value_Location__c, Contact_Field_Name__c, RecordTypeId, RecordType.Name
                       from NameCase_Exception__c Limit 1000];//unlikely to have even 100 namecase exceptions, but leaving plenty of room. 
        } // Lazy-populate nceList
        System.debug('nceList.size() = '+nceList.size());
        //Id rtId = Schema.sObjectType.NameCase_Exception__c.getRecordTypeInfosByName().get('Fixed Word Exception').getRecordTypeId();
        for (NameCase_Exception__c nce : nceList){
            System.debug('nce record type name: '+nce.RecordType.Name);
        	String exValue = nce.Exception_Value__c;
            String vLoc = nce.Value_Location__c;
            String nField = nce.Contact_Field_Name__c;
            String replaceValue = nce.Replace_With__c;
            Integer numChar = (Integer) nce.NumChar__c;
            String caseModify = nce.CaseModify__c;
            System.debug(exValue+'; '+vLoc+'; '+nField+'; '+replaceValue+'; '+numChar+'; '+caseModify);
            if (nField == 'All' || nameField.toLowerCase() == nField.toLowerCase()){
                if (nce.RecordType.Name == 'Fixed Word Exception'){ // REWORK THIS TO ENSURE SPACES REMAIN WHERE THEY SHOULD IN THE NAME
                    //System.debug('pre-buildName is '+buildName.toLowerCase()+'; exValue is '+exValue.toLowerCase()+' '+'; vLoc is '+vLoc.toLowerCase());
                    //System.debug(buildName.toLowerCase().startsWith(exValue.toLowerCase()+' '));
                    if (vLoc.trim().toLowerCase().startsWith('startswith') && buildName.toLowerCase().startsWith(exValue.toLowerCase()+' ') ||
                        vLoc.trim().toLowerCase().startsWith('endswith') && buildName.toLowerCase().endsWith(' '+exValue.toLowerCase()) ||
                        vLoc.trim().toLowerCase().startsWith('equals') && buildName.toLowerCase().contains(' '+exValue.toLowerCase()+' ')){
                            if (replaceValue != null){
                                //System.debug('buildName is '+buildName);
                                //System.debug('buildName replace is '+buildName.replace(exValue,replaceValue));
                                buildName = buildName.replace(exValue,replaceValue);
                            }
                                
                    }
                    //System.debug('post-buildName is '+buildName);
                    //return buildName;
                } else if (nce.RecordType.Name == 'Dynamic Exception'){
                    
                    String newName = '';
                    //String mod = nce.ModifyCase__c;
                    Integer i = 0;
                    for (String sn :buildName.split(' ',-1)){
                        System.debug('sn is '+sn);
                        if (numChar != null){
                            System.debug(numChar);
                            //Integer num = Integer.valueOf(nce.numLetter__c);
                            if (vLoc.toLowerCase() == 'startswith' && sn.toLowerCase().startsWith(exValue.toLowerCase()) ||
                                vLoc.toLowerCase() == 'endswith' && sn.toLowerCase().endsWith(exValue.toLowerCase()) ||
                                vLoc.toLowerCase() == 'contains' && sn.toLowerCase().contains(exValue.toLowerCase())){
                                System.debug('gets to vLoc check');
                                newName += sn.substring(0, numChar - 1);
                                newName += (caseModify == 'lower')? sn.substring(numChar - 1, numChar).toLowerCase() : sn.substring(numChar - 1, numChar).toUpperCase();
                                newName += sn.substring(numChar);
                            } else {
                                newName += sn;
                            }
                            
                            if (i < spaceNames.size() - 1){
                                newName += ' ';
                                i++;
                            }
                        }
                    }
                    buildName = newName;
                }
            }
        }
        
        return buildName;
    }
    
    @TestVisible private static void insertCertainBaselineDataForTestsIfNotPresent() {
        // This method should be invoked near the beginning of any "test method" that will need to
        // INSERT EnrollmentrxRx__Enrollment_Opportunity__c records or INSERT Student Profile-typed User records
        // so that they can run without enclosing them within a "See All Data" context. -Katie Gumpertz, UST Developer, 1/2/18
        
        // Insert 2 EnrollmentrxRx__Program_Catalog__c records:  UG & Grad
        // (necessary to enable the INSERTion of EnrollmentrxRx__Enrollment_Opportunity__c because ApplicationTriggerHandler.copyCertainUG... looks for "ugProg" in the database)
        // Not too many SOQL queries & DML actions, but refactor if we get over 2 to be more like the 43+ record EnrollmentrxRx__Configuration_Settings__c insertion.
        {
            EnrollmentrxRx__Program_Catalog__c ugProg;
            if ([SELECT Id FROM EnrollmentrxRx__Program_Catalog__c WHERE Name='Undergraduate'].size()>0) { ugProg = [SELECT Id FROM EnrollmentrxRx__Program_Catalog__c WHERE Name='Undergraduate'][0]; }
            else {
                ugProg = new EnrollmentrxRx__Program_Catalog__c(Name='Undergraduate', Display_Order__c=1, EnrollmentrxRx__Description__c='All undergraduate programs -- potentially used for majors of interest.');
                INSERT new List<EnrollmentrxRx__Program_Catalog__c>{ugProg}; {}
            }
            EnrollmentrxRx__Program_Catalog__c gradProg;
            if ([SELECT Id FROM EnrollmentrxRx__Program_Catalog__c WHERE Name='Graduate'].size()>0) { gradProg = [SELECT Id FROM EnrollmentrxRx__Program_Catalog__c WHERE Name='Graduate'][0]; }
            else {
                gradProg = new EnrollmentrxRx__Program_Catalog__c(Name='Graduate', Display_Order__c=2, EnrollmentrxRx__Description__c='Graduate programs');
                INSERT new List<EnrollmentrxRx__Program_Catalog__c>{gradProg}; {}
            }
        }
        // Insert 1 EnrollmentrxRx__Enrollment_Rx_Configuration__c record
        // (necessary to enable the INSERTion of EnrollmentrxRx__Enrollment_Opportunity__c because EnrollmentrxRx.EOBeforeUpdate class fails at line 137 without it)
        {
            EnrollmentrxRx__Enrollment_Rx_Configuration__c erxConfig;
            if ([SELECT Id FROM EnrollmentrxRx__Enrollment_Rx_Configuration__c WHERE EnrollmentrxRx__Default__c=TRUE].size() > 0) {erxConfig = [SELECT Id FROM EnrollmentrxRx__Enrollment_Rx_Configuration__c WHERE EnrollmentrxRx__Default__c=TRUE][0];}
            else {
                erxConfig = new EnrollmentrxRx__Enrollment_Rx_Configuration__c(EnrollmentrxRx__Advisor_Goal_1_Status__c='New', EnrollmentrxRx__Advisor_Goal_2_Status__c='Contact Complete', EnrollmentrxRx__Advisor_Goal_4_Status__c='Interview Scheduled', EnrollmentrxRx__Advisor_Goal_6_Status__c='Interview Complete', EnrollmentrxRx__Advisor_Goal_8_Status__c='Application Complete', EnrollmentrxRx__Advisor_Goal_10_Status__c='Enrollment Accepted', EnrollmentrxRx__Advisor_Goal_12_Status__c='Active Student', EnrollmentrxRx__Auto_close_Disposition__c='Interested in Different Term', EnrollmentrxRx__Auto_close_Enrollment_Opportunities_To__c='File Closed', EnrollmentrxRx__Create_Documents_at_Status__c='Application Complete', EnrollmentrxRx__Default__c=TRUE, EnrollmentrxRx__New_Document_Status__c='Required', Name='Default');
                INSERT erxConfig;
            }
        }
        // Insert 43 or so EnrollmentrxRx__Configuration_Settings__c records
        // (necessary to enable the INSERTion of EnrollmentrxRx__Enrollment_Opportunity__c because EnrollmentrxRx.EOBeforeUpdate, EnrollmentrxRx.EOUtil.isClosed, EnrollmentrxRx.EOUtil.isAtOrAfterStatus, EnrollmentrxRx.EODocumentUtil.createDocumentsFor, & EnrollmentrxRx.EODocumentUtil.createAndSaveDocumentsFor Apex classes and EnrollmentrxRx.EOBeforeUpdate Apex trigger all complain otherwise)
        // (necessary to enable the INSERTion of Student Profile-typed User records because Apex classes EnrollmentrxRx.ContactUtil.initializeFieldMaps, EnrollmentrxRx.ContactUtil.contactToStudentInfo, and EnrollmentrxRx.PortalUserUtil.createStudentInfoAndShares, and Apex trigger EnrollmentrxRx.PortalUser, all complain without otherwise)
        // Written to avoid making 43+ separate SOQL queries & DML actions.
        {
            String delim = '~~--~~';
            Set<String> ecsTripletsThatShouldExist = new Set<String>{ // "Triplet" is strings for EnrollmentrxRx__Category__c, EnrollmentrxRx__Name__c, and EnrollmentrxRx__Value__c, in that order.
                ''+delim+'GoogleMapKey'+delim+'ABQIAAAAgPZP6URVNbbqItwgNZH7GxRRVcyUAm6aXx336y8UfpPWLhs6xhRReDXIjSPhgingrzCIziN20wd_dg',
                    'AdmissionsDocumentAfterInsert'+delim+'ShowAdmissionsDocsToAllAdvisors'+delim+'No',
                    'ConfigUtil'+delim+'AdvisorGoal10Status'+delim+'Enrollment Accepted',
                    'ConfigUtil'+delim+'AdvisorGoal12Status'+delim+'Active Student',
                    'ConfigUtil'+delim+'AdvisorGoal1Status'+delim+'New',
                    'ConfigUtil'+delim+'AdvisorGoal2Status'+delim+'Contact Complete',
                    'ConfigUtil'+delim+'AdvisorGoal4Status'+delim+'Interview Scheduled',
                    'ConfigUtil'+delim+'AdvisorGoal6Status'+delim+'Interview Complete',
                    'ConfigUtil'+delim+'AdvisorGoal8Status'+delim+'Application Complete',
                    'ConfigUtil'+delim+'AutoCloseDisposition'+delim+'Interested in Different Term',
                    'ConfigUtil'+delim+'AutoCloseEnrollmentOpportunities'+delim+'File Closed',
                    'ConfigUtil'+delim+'BlocksAdmissionsStatus2'+delim+'Application Complete',
                    'ConfigUtil'+delim+'BlocksAdmissionsStatus3'+delim+'Application Complete',
                    'ConfigUtil'+delim+'ConfigurationName'+delim+'Auto-created config',
                    'ConfigUtil'+delim+'CreateDocumentsAtStatus'+delim+'Contact Complete',
                    'ConfigUtil'+delim+'Doc2Name'+delim+'High School Diploma',
                    'ConfigUtil'+delim+'Doc3Name'+delim+'SAT Report',
                    'ConfigUtil'+delim+'DocName'+delim+'FAFSA',
                    'ConfigUtil'+delim+'DocumentType'+delim+'Financial Aid Document',
                    'ConfigUtil'+delim+'DocumentType2'+delim+'Admissions Document',
                    'ConfigUtil'+delim+'DocumentType3'+delim+'Admissions Document',
                    'ConfigUtil'+delim+'DueDateType'+delim+'Number of days before school term begins',
                    'ConfigUtil'+delim+'DueDateType2'+delim+'Number of days before school term beginsNumber of days after creation',
                    'ConfigUtil'+delim+'DueDateType3'+delim+'Number of days before school term begins',
                    'ConfigUtil'+delim+'NewDocumentStatus'+delim+'Required',
                    'ConfigUtil'+delim+'TermName'+delim+'Example term',
                    'ContactBeforeUpdateBeforeInsert'+delim+'ERxStudentContactRecordType'+delim+'Prospect/Applicant Record Type',
                    'ContactUtil'+delim+'Contact'+delim+'Contact',
                    'ContactUtil'+delim+'StudentInformation'+delim+'Student_Information__c',
                    'EOBeforeUpdate'+delim+'GoalTypeActual'+delim+'Actual',
                    'EODocumentUtil'+delim+'AdmissionsDocument'+delim+'Admissions Document',
                    'EODocumentUtil'+delim+'AdmissionsStatusApproved'+delim+'Approved',
                    'EODocumentUtil'+delim+'DueDateAfterCreation'+delim+'Number of days after creation',
                    'EODocumentUtil'+delim+'FinancialAidDocument'+delim+'Financial Aid Document',
                    'EOUtil'+delim+'AccessLevel'+delim+'Edit',
                    'EOUtil'+delim+'AdmissionsStatusClosed'+delim+'File Closed',
                    'EOUtil'+delim+'AllAdvisorsGroupId'+delim+'00Gj0000000Xxh7',
                    'EOUtil'+delim+'RowCause'+delim+'Manual',
                    'FinancialAidDocumentAfterInsert'+delim+'ShowFinancialAidDocsToAllAdvisors'+delim+'No',
                    'LeadForm'+delim+'CreateUserFromLeadForm'+delim+'No',
                    'PortalUserUtil'+delim+'StudentPortalUser'+delim+'Student Portal User',
                    'SiteHeader'+delim+'StudentPortalURL'+delim+'https://na6.salesforce.com/secur/login_portal.jsp?orgId=00D80000000LeT4&portalId=0608000000068Vh',
                    'SiteRegisterController'+delim+'PortalAccountId'+delim+'001j0000005vEGU'
            }; {}
            Set<String> ecsTripletsThatAlreadyExist = new Set<String>();
            for ( EnrollmentrxRx__Configuration_Settings__c existingECS : [SELECT Id, EnrollmentrxRx__Category__c, EnrollmentrxRx__Name__c, EnrollmentrxRx__Value__c FROM EnrollmentrxRx__Configuration_Settings__c]) {
                ecsTripletsThatAlreadyExist.add(existingECS.EnrollmentrxRx__Category__c+delim+existingECS.EnrollmentrxRx__Name__c+delim+existingECS.EnrollmentrxRx__Value__c);
            }
            ecsTripletsThatShouldExist.removeAll(ecsTripletsThatAlreadyExist); // Note that this is a destructive operation that changes the contents of ecsTripletsThatShouldExist
            List<EnrollmentrxRx__Configuration_Settings__c> enrConfigSetgsToInsert = new List<EnrollmentrxRx__Configuration_Settings__c>();
            List<String> tripletParts = NULL;
            for (String s : ecsTripletsThatShouldExist) {
                tripletParts = NULL;
                tripletParts = s.split(delim);
                enrConfigSetgsToInsert.add(new EnrollmentrxRx__Configuration_Settings__c(EnrollmentrxRx__Category__c=tripletParts[0], EnrollmentrxRx__Name__c=tripletParts[1], EnrollmentrxRx__Value__c=tripletParts[2]));
            }
            if ( enrConfigSetgsToInsert.size() > 0 ) { INSERT enrConfigSetgsToInsert; }
        }
    }
    
}