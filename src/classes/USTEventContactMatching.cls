// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 2/27/2019.

public with sharing class USTEventContactMatching {


    public USTEventContactMatching() {

    }

    public Map<String, String> USTEventContactMatching(String matchingType, UST_Event_Registration__c evt, String matchingScope) {
        Map<String, String> matchingResult = new Map<String, String>();
        //Direct to correct matching method
        if (!matchingScope.startsWith('No matching')) {
            if (matchingType.equalsIgnoreCase('Undergraduate')) {
                matchingResult = UG_Matching(evt, matchingScope);
            } else if (matchingType.equalsIgnoreCase('UDAR')) {
                matchingResult = UG_Matching(evt, matchingScope);
            } else if (matchingType.equalsIgnoreCase('Graduate')) {
                //Using Undergrad matching for now
                matchingResult = UG_Matching(evt, matchingScope);
            } else {
                matchingResult = UG_Matching(evt, matchingScope);
            }
        }
        return matchingResult;
    }

    private Map<String, String> UG_Matching(UST_Event_Registration__c evt, String matchingScope) {

        String contactId = '';
        String softEmailMatches = '';
        String softFirstLastZipMatches = '';
        boolean newContactCreated = false;
        String query = '';
        doCRUD CRUDtoDo = new doCRUD();

        /* Start the the matching log HTML table */
        String matchLog = '';
        String matchLogHead = '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">';
        matchLogHead += '<thead><tr class="slds-line-height_reset">';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
        matchLogHead += '</tr></thead>';

        String lastName = evt.Registrant_Last_Name__c;
        String email = evt.Registrant_Email__c;

        /* Already have an Id, why work, return */
        if (String.isNotBlank(evt.Contact__r.Id)) {
            contactId = evt.Contact__r.Id;
            return new Map<String, String>{
                    'contactId' => contactId,
                    'softEmailMatches' => '',
                    'softFirstLastZipMatches' => '',
                    'newContactCreated' => String.valueOf(newContactCreated),
                    'matchLog' => ''
            };
        }

        /* HARD MATCH - First 3 letters of first name / preferred first name, last name, and birthdate */
        if (String.isBlank(contactId) && evt.Registrant_Date_of_Birth__c != null && String.isNotBlank(evt.Registrant_Last_Name__c)) {
            /* Get the first three characters of name and preferred name */
            String firstThree = '';
            String prefFirstThree = '';
            if (String.isNotBlank(evt.Registrant_First_Name__c)) {
                firstThree = evt.Registrant_First_Name__c;
                if (firstThree.length() > 3) {
                    firstThree = firstThree.substring(0, 3);
                }
            }

            if (String.isNotBlank(evt.Registrant_Preferred_First_Name__c)) {
                if (prefFirstThree.length() > 3) {
                    prefFirstThree = prefFirstThree.substring(0, 3);
                }
            }

            query = ' SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE (';
            if (String.isNotBlank(firstThree)) {
                query += ' Mailing_First_Name__c LIKE \'' + String.escapeSingleQuotes(firstThree) + '%\' OR';
            }
            if (String.isNotBlank(prefFirstThree)) {
                query += ' Mailing_First_Name__c LIKE \'' + String.escapeSingleQuotes(prefFirstThree) + '%\' OR';
            }
            query = query.removeEnd(' OR');
            query += ' ) ';
            query += ' AND LastName = \'' + String.escapeSingleQuotes(evt.Registrant_Last_Name__c) + '\' ';
            query += ' AND Birthdate = ' + String.valueOf(evt.Registrant_Date_of_Birth__c).removeEnd(' 00:00:00');

            List<Contact> hardContactTest1 = CRUDtoDo.findContacts(query);

            if (hardContactTest1.size() > 0) {
                contactId = hardContactTest1[0].Id;

                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on FIRST NAME (first 3), LAST NAME, BIRTH DATE!</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += UGMatchTD(hardContactTest1[0].Id, hardContactTest1[0].LastName, hardContactTest1[0].FirstName, hardContactTest1[0].Email, hardContactTest1[0].MailingPostalCode, false);
                matchLog += '</tbody></table>';
            }
        }

        //HARD MATCH - Last name and email
        if (String.isBlank(contactId)) {
            List<Contact> hardContactTest2 = CRUDtoDo.emailLastMatch(email, lastName);
            if (hardContactTest2.size() > 0) {
                contactId = hardContactTest2[0].Id;
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on LAST NAME, EMAIL!</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += UGMatchTD(hardContactTest2[0].Id, hardContactTest2[0].LastName, hardContactTest2[0].FirstName, hardContactTest2[0].Email, hardContactTest2[0].MailingPostalCode, false);
                matchLog += '</tbody></table>';
            }
        }

        //Check for already made DUPLICATE emails and attach to matching
        if (String.isBlank(contactId) && (matchingScope.startsWith('Full matching') || String.isBlank(matchingScope))) {
            String[] possibleEmails = new List<String>();
            possibleEmails.add(evt.Registrant_Email__c);
            for (Integer x = 1; x <= 10; x++) {
                possibleEmails.add('Event_Dup_' + String.valueOf(x) + '_' + evt.Registrant_Email__c);
            }
            List<Contact> hardContactTest3 = CRUDtoDo.possibleEmailLastMatches(lastName, possibleEmails);
            if (hardContactTest3.size() > 0) {
                //hard match on first DUP email found.
                contactId = hardContactTest3[0].Id;
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on LAST NAME, EMAIL (Email was duplicate email)</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += UGMatchTD(hardContactTest3[0].Id, hardContactTest3[0].LastName, hardContactTest3[0].FirstName, hardContactTest3[0].Email, hardContactTest3[0].MailingPostalCode, false);
                matchLog += '</tbody></table>';
            }
        }

        if (String.isBlank(contactId) && (matchingScope.startsWith('Full matching') || String.isBlank(matchingScope))) {
            //Check if first name last name zip match
            List<Contact> zipContactTest = CRUDtoDo.zipFirstLastMatch(evt.Registrant_Zip__c, evt.Registrant_Last_Name__c, evt.Registrant_First_Name__c);
            if (zipContactTest.size() > 0) {
                //Soft Match found with zip
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Soft Match on Zip, Last Name, First Name</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                for (Contact c : zipContactTest) {
                    matchLog += UGMatchTD(c.Id, c.LastName, c.FirstName, c.Email, c.MailingPostalCode, true);
                    softFirstLastZipMatches += c.Id + ' ';
                }
                matchLog += '</tbody></table>';
            }
            List<Contact> emailContactTest = CRUDtoDo.emailOnlyMatch(evt.Registrant_Email__c);
            if (emailContactTest.size() > 0) {
                //Soft Match found with email
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Soft Match on Email</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                for (Contact c : emailContactTest) {
                    matchLog += UGMatchTD(c.Id, c.LastName, c.FirstName, c.Email, c.MailingPostalCode, true);
                    softEmailMatches += c.Id + ' ';
                }
                matchLog += '</tbody></table>';
            }
            Contact newEvtContact = createNewContact(evt);
            contactId = newEvtContact.Id;

            matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">New contact created!</div>';
            matchLog += matchLogHead;
            matchLog += '<tbody>';
            matchLog += UGMatchTD(newEvtContact.Id, newEvtContact.LastName, newEvtContact.FirstName, newEvtContact.Email, newEvtContact.MailingPostalCode, false);
            matchLog += '</tbody></table>';
            newContactCreated = true;
            //Create new contact
        }

        return new Map<String, String>{
                'contactId' => contactId,
                'softEmailMatches' => softEmailMatches.abbreviate(255),
                'softFirstLastZipMatches' => softFirstLastZipMatches.abbreviate(255),
                'newContactCreated' => String.valueOf(newContactCreated),
                'matchLog' => matchLog
        };
    }

    private String UGMatchTD(String ContactId, String LastName, String FirstName, String Email, String Zip, Boolean Action) {
        String mOut = '<tr class="slds-hint-parent">';
        mOut += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + LastName + '</a></div></td>';
        mOut += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + FirstName + '</a></div></td>';
        mOut += '<td data-label="Email"><div class="slds-truncate">' + Email + '</div></td>';
        mOut += '<td data-label="Zip"><div class="slds-truncate">' + Zip + '</div></td>';
        if (Action) {
            mOut += '<td data-label="Action"><div class="slds-truncate"><a class="slds-text-link_reset" href="/apex/SummitEventsReparent?regId=[[REGID]]&reparentTo=' + ContactId + '"><span class="slds-text-link">Reparent</span></a></div></td>';
        } else {
            mOut += '<td data-label="Action"><div class="slds-truncate"> --- </div></td>';
        }
        mOut += '</tr>';
        return mOut;
    }

    private Contact createNewContact(UST_Event_Registration__c evt) {
        doCRUD CRUDtoDo = new doCRUD();
        //evt = escapeRegistration(evt);
        Contact newEvtContact = new Contact();
        newEvtContact.LeadSource = 'Event';
        newEvtContact.FirstName = evt.Registrant_First_Name__c;
        newEvtContact.Preferred_First_Name__c = evt.Registrant_Preferred_First_Name__c;
        newEvtContact.LastName = evt.Registrant_Last_Name__c;
        if (String.isNotBlank(evt.Registrant_Gender__c)) {
            if (evt.Registrant_Gender__c.toLowerCase() == 'male' || evt.Registrant_Gender__c.toLowerCase() == 'female') {
                newEvtContact.EnrollmentrxRx__Gender__c = evt.Registrant_Gender__c;
            }
        }
        newEvtContact.MailingStreetLine1__c = evt.Registrant_Street_1__c;
        newEvtContact.MailingStreetLine2__c = evt.Registrant_Street_2__c;
        newEvtContact.MailingCity__c = evt.Registrant_City__c;
        newEvtContact.MailingZip__c = evt.Registrant_Zip__c;
        newEvtContact.MailingState__c = evt.Registrant_State__c;
        newEvtContact.MobilePhone = evt.Registrant_Mobile_Phone__c;
        newEvtContact.HomePhone = evt.Registrant_Phone__c;
        newEvtContact.High_School_Expected_Graduation_Year__c = evt.Registrant_High_School_Grad_Year__c;
        newEvtContact.MailingCountry__c = evt.Registrant_Country__c;
        newEvtContact.MailingState_Province__c = evt.Registrant_State_Province__c;
        newEvtContact.MailingPostalCode__c = evt.Registrant_Postal_Code__c;

        if (evt.Registrant_Date_of_Birth__c != null) {
            newEvtContact.Birthdate = evt.Registrant_Date_of_Birth__c;
        }

        if (!String.isBlank(evt.Registrant_Applicant_Type__c)) {
            newEvtContact.Inquiry_Applicant_Type__c = evt.Registrant_Applicant_Type__c;
        }

        if (!String.isBlank(evt.Registrant_High_School_Code__c) && String.isBlank(evt.Registrant_College_Code__c)) {
            newEvtContact.EnrollmentrxRx__High_School_Code__c = evt.Registrant_High_School_Code__c;
        } else if (!String.isBlank(evt.Registrant_College_Code__c)) {
            newEvtContact.EnrollmentrxRx__High_School_Code__c = evt.Registrant_College_Code__c;
        }

        //Generate all possible emails that could be created, or already exist and put them in a list to limit query and keep out of a loop
        String[] possibleEmails = new List<String>();
        possibleEmails.add(evt.Registrant_Email__c);
        for (Integer x = 1; x <= 10; x++) {
            possibleEmails.add('Event_Dup_' + String.valueOf(x) + '_' + evt.Registrant_Email__c);
        }

        //Check for all possible email matches including dupes
        List<Contact> emailContactTest = CRUDtoDo.possibleEmailMatches(possibleEmails);

        //If query is empty then we are free to use the email provided else we have to creat/check for dup emails
        if (emailContactTest.size() == 0) {
            newEvtContact.Email = evt.Registrant_Email__c;
        } else {
            //add all found emails to a string array
            List<String> foundEmails = new List<String>();
            for (Contact em : emailContactTest) {
                foundEmails.add(em.Email);
            }

            if (!foundEmails.contains(evt.Registrant_Email__c)) {
                //if the registration email isn't in the list use it -- probably won't happen
                newEvtContact.Email = evt.Registrant_Email__c;
            } else {
                //loop through possible emails until one is not found and use it.
                for (String possEm : possibleEmails) {
                    if (!foundEmails.contains(possEm)) {
                        newEvtContact.Email = possEm;
                        break;
                    }
                }
            }
        }

        newEvtContact = CRUDtoDo.addContact(newEvtContact);
        return newEvtContact;
    }

    private without sharing class doCRUD {

        public List<Contact> findContacts(string query) {
            try {
                List<Contact> contactsFound = database.query(query);
                return contactsFound;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
            return null;
        }

        public Contact addContact(Contact contactToAdd) {
            try {
                upsert contactToAdd;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
            return contactToAdd;
        }

        Public List<Contact> emailLastMatch(String email, String last) {
            List<Contact> foundContacts = [SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE LastName = :last AND Email = :email];
            return foundContacts;
        }

        Public List<Contact> possibleEmailLastMatches(String last, List<String> possibleEmails) {
            List<Contact> foundContacts = [SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE LastName = :last AND Email IN :possibleEmails];
            return foundContacts;
        }

        Public List<Contact> possibleEmailMatches(String[] possibleEmails) {
            List<Contact> foundContacts = [SELECT Id, Email FROM Contact WHERE Email IN :possibleEmails];
            return foundContacts;
        }

        public List<Contact> emailOnlyMatch(string email) {
            List<Contact> foundContacts = [SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE Email = :email];
            return foundContacts;
        }

        public List<Contact> zipFirstLastMatch(String zip, String last, String first) {
            List<Contact> foundContacts = [
                    SELECT Id, LastName, FirstName, Email, MailingPostalCode
                    FROM Contact
                    WHERE FirstName = :first
                    AND LastName = :last
                    AND MailingPostalCode = :zip
            ];
            return foundContacts;
        }

    }

}