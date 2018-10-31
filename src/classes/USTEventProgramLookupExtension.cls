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
        List<EnrollmentrxRx__Program_Offered__c> schoolProgs = new List<EnrollmentrxRx__Program_Offered__c>();
        if (!String.isBlank(USTEvt.School__c)) {
            Id schoolId = USTEvt.School__c;
            schoolProgs = [
                    SELECT Program_Code__c, Name, School__c
                    FROM EnrollmentrxRx__Program_Offered__c
                    WHERE Status__c = 'Active'
                    AND Program_Code__c != NULL
                    AND School__c = :schoolId
            ];
        } else {
            schoolProgs = [
                    SELECT Program_Code__c, Name, School__c
                    FROM EnrollmentrxRx__Program_Offered__c
                    WHERE Status__c = 'Active'
                    AND Program_Code__c != NULL
            ];
        }
        For (EnrollmentrxRx__Program_Offered__c prog : schoolProgs) {
            String progName = prog.Name + ' (' + prog.Program_Code__c + ')';
            if (USTevt.Academic_Program_List__c.indexOf(progName) == -1) {
                programs.add(new SelectOption(progName, progName));
            }
        }
        return programs;
    }

    public void save() {
        // build a ; seperated string of selected Programs to insert into Academic_Program_List__c
        String selectString = '';
        String progCodeString = '';
        for (SelectOption p : SelectedPrograms) {
            selectString += p.getValue() + ';';
        }
        if (!String.isBlank(selectString)) {
            Pattern TAG_REGEX = Pattern.compile('\\((\\w+)\\)');
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