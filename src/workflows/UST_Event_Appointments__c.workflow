<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Event_Appointment_Request_Email</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>Event Appointment Request Email</description>
        <protected>false</protected>
        <recipients>
            <field>Appointment_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Appointment_Request</template>
    </alerts>
    <alerts>
        <fullName>We_re_Still_Working</fullName>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>We&apos;re Still Working</description>
        <protected>false</protected>
        <recipients>
            <field>Appointment_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Working_on_Visit_Update</template>
    </alerts>
    <alerts>
        <fullName>Working_on_your_Visit</fullName>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>Working on your Visit</description>
        <protected>false</protected>
        <recipients>
            <field>Appointment_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Working_on_Visit</template>
    </alerts>
    <alerts>
        <fullName>Working_on_your_Visit1</fullName>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>Working on your Visit</description>
        <protected>false</protected>
        <recipients>
            <field>Appointment_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Working_on_Visit</template>
    </alerts>
    <fieldUpdates>
        <fullName>ADM_FA_Staff_Prefill</fullName>
        <description>Pre-fills Faculty/Staff field if Appointment Type is Admissions Visit or FA visit with assigned counselor</description>
        <field>Faculty_Staff_Member__c</field>
        <name>ADM FA Staff Prefill</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ADM_FA_Staff_Prefill1</fullName>
        <field>Faculty_Staff_Member__c</field>
        <formula>IF(ISPICKVAL(Appointment_Type__c, &quot;Admissions Counselor&quot;), Admissions_Counselor__c,
IF(ISPICKVAL(Appointment_Type__c, &quot;Financial Aid Counselor&quot;),  Financial_Aid_Counselor__c,&quot;&quot;))</formula>
        <name>ADM FA Staff Prefill</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Admission_Counselor_Building</fullName>
        <description>Prefills the building field when the Appointment Type is Admissions Counselor</description>
        <field>Building__c</field>
        <literalValue>Office of Admissions</literalValue>
        <name>Admission Counselor Building</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Appointment_DateTime_Prefill</fullName>
        <field>Appointment_Date_Time__c</field>
        <formula>DATETIMEVALUE(Event_Registration__r.Date__c) + 0.25</formula>
        <name>Appointment DateTime Prefill</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Appointment_Date_Prefill</fullName>
        <field>Appointment_Date__c</field>
        <formula>Event_Registration__r.Date__c</formula>
        <name>Appointment Date Prefill</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Appointment_Title</fullName>
        <field>Appointment_Title__c</field>
        <formula>TEXT(Appointment_Type__c)</formula>
        <name>Appointment Title</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FA_Counselor_Building</fullName>
        <description>Sets Building when Appointment Type is FA Counselor</description>
        <field>Building__c</field>
        <literalValue>Office of Financial Aid</literalValue>
        <name>FA Counselor Building</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Registration_Status_Update_Pending_Appt</fullName>
        <description>Updates Registration Substatus to Pending Appointments</description>
        <field>Substatus__c</field>
        <literalValue>Pending Appointments</literalValue>
        <name>Registration Status Update Pending Appt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Event_Registration__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Received</fullName>
        <field>Status__c</field>
        <literalValue>Received</literalValue>
        <name>Update Status to Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Event_Registration__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Admissions FA Visit Prefill</fullName>
        <actions>
            <name>ADM_FA_Staff_Prefill1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Appointments__c.Appointment_Type__c</field>
            <operation>equals</operation>
            <value>Admissions Counselor,Financial Aid Counselor</value>
        </criteriaItems>
        <description>Prefills &quot;Financial Aid Counselor&quot; or &quot;Admissions Counselor&quot; fields on the UST Event Appointment Counselor with Assigned Counselor from the Contact object.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Appointment Date Prefill</fullName>
        <actions>
            <name>Appointment_DateTime_Prefill</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Appointments__c.Appointment_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Pre-fills Appointment Date field on UST Appointment with Date of Visit from the Registration object</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Appointment Type</fullName>
        <actions>
            <name>Appointment_Title</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Appointments__c.Appointment_Title__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Updates Appointment Title field with the Appointment Type for merging into emails and print documents</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Default Admissions Counselor Building</fullName>
        <actions>
            <name>Admission_Counselor_Building</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Appointments__c.Appointment_Type__c</field>
            <operation>equals</operation>
            <value>Admissions Counselor</value>
        </criteriaItems>
        <description>Prepopulates &quot;Building&quot; field on UG Event Appointment object with &quot;Office of Admissions&quot; when Appointment Type = &quot;Admissions Counselor&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Default FA Counselor Building</fullName>
        <actions>
            <name>FA_Counselor_Building</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Appointments__c.Appointment_Type__c</field>
            <operation>equals</operation>
            <value>Financial Aid Counselor</value>
        </criteriaItems>
        <description>Prepopulates &quot;Building&quot; field on UG Event Appointment object with &quot;Office of Financial Aid&quot; when Appointment Type = &quot;Financial Aid Counselor&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Event Appointment Request</fullName>
        <actions>
            <name>Event_Appointment_Request_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>The purpose of this workflow is to automate the request for an appointment based on the Appointment Status of &quot;Requested&quot;.  The email will send to the Appointment Contact Name and Email.</description>
        <formula>ISCHANGED(Appointment_Status__c) &amp;&amp; OR(ISPICKVAL(Appointment_Status__c, &quot;Pending First Request&quot;), ISPICKVAL(Appointment_Status__c, &quot;Pending Second Request&quot;), ISPICKVAL(Appointment_Status__c, &quot;Pending Final Request&quot;)) &amp;&amp; NOT(ISBLANK(Appointment_Contact_Email__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Registration Status Substatus Update Pending with Email</fullName>
        <actions>
            <name>Registration_Status_Update_Pending_Appt</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Appointments__c.Appointment_Status__c</field>
            <operation>equals</operation>
            <value>Pending First Request</value>
        </criteriaItems>
        <description>Updates the Event Registration substatus to Pending Appointments once a First Request has been made on an Appointment and Sends Working on Visit email and schedules Working on Visit Update</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
