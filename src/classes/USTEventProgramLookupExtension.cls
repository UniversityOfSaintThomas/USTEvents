// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 10/22/2018.

public class USTEventProgramLookupExtension {

    public UST_Event__c USTEvt;
    public List<SelectOption> SelectedPrograms { get; set; }
    public String selectedProgramsString { get; set; }
    public String selectedSchoolId { get; set; }
    public String selectedSchoolName { get; set; }
    public List<SelectOption> Programs { get; set; }

    public USTEventProgramLookupExtension(ApexPages.StandardController stdController) {
        USTEvt = (UST_Event__c) stdController.getRecord();
        currentSelectedPrograms();
        Programs = allPrograms(USTEvt.School__c, USTEvt.School__r.Name);
    }

    public void refreshPrograms() {
        updateProgramRecords(selectedProgramsString);
        currentSelectedPrograms();
        Programs = allPrograms(selectedSchoolId, selectedSchoolName);
    }

    public void currentSelectedPrograms() {
        String bigProgramList = concatenatedProgramFilter();
        List<String> bigProgramArray = new List<String>();
        SelectedPrograms = new List<SelectOption>();
        if (String.isNotBlank(bigProgramList)) {
            bigProgramArray = bigProgramList.split(';');
            List<Major__c> selectedProgramList = [
                    SELECT Prog_Major_Conc_Code__c, Major_Display_Name__c
                    FROM Major__c
                    WHERE Status__c = 'Active'
                    AND Prog_Major_Conc_Code__c IN :bigProgramArray
                    ORDER BY Major_Display_Name__c
            ];

            //Sort like they were initially selected
            List<Major__c> majorIdListSort = new List<Major__c>();
            for (String code : bigProgramArray) {
                for (Major__c mj : selectedProgramList) {
                    if (mj.Prog_Major_Conc_Code__c.equals(code)) {
                        majorIdListSort.add(mj);
                    }
                }
            }
            selectedProgramList = majorIdListSort;

            String programName = '';
            for (Major__c program : selectedProgramList) {
                programName = formattedProgramName(program.Major_Display_Name__c, program.Prog_Major_Conc_Code__c);
                if (String.isNotEmpty(programName)) {
                    selectedPrograms.add(new SelectOption(programName, programName));
                }
            }
        }

    }

    public String concatenatedProgramFilter() {
        String bigProgramList = '';
        if (String.isNotBlank(USTEvt.Program_Filter__c)) {
            bigProgramList += USTEvt.Program_Filter__c;
        }
        if (String.isNotBlank(USTEvt.Program_Filter_2__c)) {
            bigProgramList += USTEvt.Program_Filter_2__c;
        }
        if (String.isNotBlank(USTEvt.Program_Filter_3__c)) {
            bigProgramList += USTEvt.Program_Filter_3__c;
        }
        return bigProgramList;
    }

    public String formattedProgramName(String programName, String programCode) {
        return programName + ' (' + programCode + ')';
    }

    public List<SelectOption> allPrograms(String schoolId, String schoolName) {
        // Get a list of programs
        List<SelectOption> programs = new List<SelectOption>();
        List<Major__c> schoolPrograms = new List<Major__c>();
        if (String.isNotBlank(schoolId)) {
            if (String.isNotBlank(schoolName) && schoolName.equals('Undergraduate')) {
                schoolPrograms = [
                        SELECT Prog_Major_Conc_Code__c, Major_Display_Name__c, Program_Offered__r.Name
                        FROM Major__c
                        WHERE Status__c = 'Active'
                        AND Prog_Major_Conc_Code__c != NULL
                        AND Program_Offered__r.Name = 'Undeclared BA'
                        AND Display_on_RFI_UG__c = true
                        ORDER BY Major_Display_Name__c
                ];
            } else {
                schoolPrograms = [
                        SELECT Prog_Major_Conc_Code__c, Major_Display_Name__c, Program_Offered__r.School__c
                        FROM Major__c
                        WHERE Status__c = 'Active'
                        AND Prog_Major_Conc_Code__c != NULL
                        AND Program_Offered__r.School__c = :schoolId
                        AND Display_on_RFI__c = true
                        ORDER BY Major_Display_Name__c
                ];
            }
        } else {
            schoolPrograms = [
                    SELECT Major_Display_Name__c, Prog_Major_Conc_Code__c
                    FROM Major__c
                    WHERE Status__c = 'Active'
                    AND Prog_Major_Conc_Code__c != NULL
                    AND Display_on_RFI__c = true
                    ORDER BY Major_Display_Name__c
            ];
        }
        For (Major__c program : schoolPrograms) {
            String programDisplay = formattedProgramName(program.Major_Display_Name__c, program.Prog_Major_Conc_Code__c);
            String selectedProgramCodes = concatenatedProgramFilter();
            if (selectedProgramCodes.indexOf(program.Prog_Major_Conc_Code__c) == -1) {
                programs.add(new SelectOption(programDisplay, programDisplay));
            }
        }
        return programs;
    }

    public void save() {
        String selectString = '';
        if (SelectedPrograms != null) {
            for (SelectOption p : SelectedPrograms) {
                selectString += p.getValue() + ';';
            }
            updateProgramRecords(selectString);
        }
    }

    private void updateProgramRecords(String selectString) {
        String programCodeString1 = '';
        String programCodeString2 = '';
        String programCodeString3 = '';
        if (!String.isBlank(selectString)) {
            Pattern TAG_REGEX = Pattern.compile('\\(([^\\)]+)\\)');
            Matcher matcher = TAG_REGEX.matcher(selectString);
            //loop through found hocks and add only unique
            String programCode = '';
            while (matcher.find()) {
                programCode = matcher.group(1);
                if (programCodeString1.length() + programCode.length() >= 255) {
                    if (programCodeString2.length() + programCode.length() >= 255) {
                        programCodeString3 += programCode + ';';
                    } else {
                        programCodeString2 += programCode + ';';
                    }
                } else {
                    programCodeString1 += programCode + ';';
                }
            }
        }
        USTEvt.Program_Filter__c = programCodeString1;
        USTEvt.Program_Filter_2__c = programCodeString2;
        USTEvt.Program_Filter_3__c = programCodeString3;

        update USTEvt;
    }

    public List<SelectOption> getSchools() {
        List<EnrollmentrxRx__School__c> allSchools = [
                SELECT Id, Name, Active_Display_on_Portal__c
                FROM EnrollmentrxRx__School__c
                WHERE Active_Display_on_Portal__c = TRUE
        ];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- select -- '));
        for (EnrollmentrxRx__School__c school : allSchools) {
            options.add(new SelectOption(school.Id, school.Name));
        }
        return options;
    }
}