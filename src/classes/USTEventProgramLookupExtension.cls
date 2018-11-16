/**
 * Created by dahl3702 on 10/22/2018.
 */

public class USTEventProgramLookupExtension {

    public UST_Event__c USTEvt;
    public String progString { get; set; }
    public List<SelectOption> SelectedPrograms { get; set; }
    //public List<SelectOption> SelectedPrograms { set; get; }

    public USTEventProgramLookupExtension(ApexPages.StandardController stdController) {
        USTEvt = (UST_Event__c) stdController.getRecord();

        //get currently selected programs and fill in selected list
        SelectedPrograms = new List<SelectOption>();
        if (!String.isBlank(USTevt.Academic_Program_List__c)) {
            List<String> currentSelected = USTevt.Academic_Program_List__c.split(';');
            for (String selItem : currentSelected) {
                SelectedPrograms.add(new SelectOption(selItem, selItem));
            }
        } else {
            USTevt.Academic_Program_List__c = '';
        }

    }

    public List<SelectOption> getPrograms() {
        // Get a list of programs
        List<SelectOption> programs = new List<SelectOption>();
        List<Major__c> schoolProgs = new List<Major__c>();
        if (!String.isBlank(USTEvt.School__c)) {
            Id schoolId = USTEvt.School__c;
            schoolProgs = [
                    SELECT Id,Name, Major_Display_Name__c, Major_Name__c, Major_Code__c, Program_Offered__r.Program_Code__c
                    FROM Major__c
                    WHERE Status__c = 'Active'
                    AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                    AND Program_Offered__r.Program_Code__c != NULL
                    AND Program_Offered__r.School__c = :schoolId
                    ORDER BY Major_Name__c
            ];
        } else {
            schoolProgs = [
                    SELECT Id,Name, Major_Display_Name__c, Major_Name__c, Major_Code__c, Program_Offered__r.Program_Code__c
                    FROM Major__c
                    WHERE Status__c = 'Active'
                    AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                    AND Program_Offered__r.Program_Code__c != NULL
                    ORDER BY Major_Name__c
            ];
        }
        For (Major__c prog : schoolProgs) {
            String progName = prog.Major_Display_Name__c + ' (' + prog.Program_Offered__r.Program_Code__c;
            if (!String.isBlank(prog.Major_Code__c)) {
                progName += '|' + prog.Major_Code__c;
            }
            progName += ')';
            if (USTevt.Academic_Program_List__c.indexOf(progName) == -1) {
                programs.add(new SelectOption(progName, progName));
            }
        }
        return programs;
    }

    public void save() {
        USTEvt.Academic_Program_List__c = '';
        USTEvt.Program_Filter__c = '';
        upsert USTEvt;
        // build a ; seperated string of selected Programs to insert into Academic_Program_List__c
        String selectString = '';
        String progCodeString = '';
        for (SelectOption p : SelectedPrograms) {
            selectString += p.getValue() + ';';
        }
        if (!String.isBlank(selectString)) {
            Pattern TAG_REGEX = Pattern.compile('\\((\\w+|\\w+\\|\\w+)\\)');
            Matcher matcher = TAG_REGEX.matcher(selectString);
            //loop through found hocks and add only unique
            while (matcher.find()) {
                progCodeString += matcher.group(1) + ';';
            }
            USTEvt.Academic_Program_List__c = selectString;
            USTEvt.Program_Filter__c = progCodeString;
            upsert USTEvt;
        }
    }
}