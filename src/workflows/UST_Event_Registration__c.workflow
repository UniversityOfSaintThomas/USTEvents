<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>All_Appointments_Confirmed</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <description>All Appointments Confirmed</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Your_Visit_is_Confirmed</template>
    </alerts>
    <alerts>
        <fullName>Attended_Part_of_Scheduled_Visit</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>Attended Part of Scheduled Visit</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Attended_Part_of_Scheduled_Visit</template>
    </alerts>
    <alerts>
        <fullName>DFC_Info_Session_RSVP_Confirmation</fullName>
        <ccEmails>tlbuford@stthomas.edu</ccEmails>
        <description>DFC Info Session RSVP Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/DFC_Info_Sessions_Saturday_Only</template>
    </alerts>
    <alerts>
        <fullName>DFC_Info_Session_Receipt</fullName>
        <ccEmails>teron.buford@stthomas.edu</ccEmails>
        <description>DFC Info Session Receipt</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/DFC_Info_Sessions_Saturday_Only</template>
    </alerts>
    <alerts>
        <fullName>Fall_Junior_Visit_Day_Receipt_Email</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>Fall Junior Visit Day Receipt Email</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Fall_Junior_Visit_Day_Receipt</template>
    </alerts>
    <alerts>
        <fullName>Fall_Tommie_Days_Confirmation_Email</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>Fall Tommie Days Confirmation Email</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Fall_Tommie_Days_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>Guest_Cancels</fullName>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <description>Guest Cancels</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Guest_Cancels</template>
    </alerts>
    <alerts>
        <fullName>Guest_No_Shows</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>Guest No Shows</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Guest_No_Shows</template>
    </alerts>
    <alerts>
        <fullName>Information_Session_Receipt</fullName>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>Information Session Receipt</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Information_Session_Request_Received</template>
    </alerts>
    <alerts>
        <fullName>UG_Event_Registration_Individual_Visit_Received</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>UG Event Registration Individual Visit Received</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Visit_Request_Received</template>
    </alerts>
    <alerts>
        <fullName>UG_Guest_Attended_Visits</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>UG Guest Attended Visits</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Guest_Attended</template>
    </alerts>
    <alerts>
        <fullName>UG_Visit_Confirmed_Pending_Appointments</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>UG Visit Confirmed Pending Appointments</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Working_on_Visit_Update</template>
    </alerts>
    <alerts>
        <fullName>UG_Visit_Pending_Appointments</fullName>
        <ccEmails>admvisit@stthomas.edu</ccEmails>
        <ccEmails>esvisitcoordinator@stthomas.edu</ccEmails>
        <description>UG Visit Pending Appointments</description>
        <protected>false</protected>
        <recipients>
            <field>Registrant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Registrant_Parent_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>admvisit@stthomas.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Campus_Visit_Emails/Working_on_Visit</template>
    </alerts>
    <fieldUpdates>
        <fullName>All_Appointments_Confirmed</fullName>
        <field>Substatus__c</field>
        <literalValue>All Appointments Confirmed</literalValue>
        <name>All Appointments Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Appointment_Confirmed</fullName>
        <field>Status__c</field>
        <literalValue>Confirmed</literalValue>
        <name>Appointment Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campus_Tour_Location2</fullName>
        <description>Populates Campus Tour Location for AM/PM sessions</description>
        <field>Campus_Tour_Location__c</field>
        <literalValue>Anderson Student Center (ASC)</literalValue>
        <name>Campus Tour Location</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campus_Tour_TIme</fullName>
        <field>Campus_Tour_Time__c</field>
        <formula>IF(ISPICKVAL(Instance__c,&quot;AM&quot;), &quot;10:00 AM&quot;, 
IF(ISPICKVAL(Instance__c, &quot;PM&quot;), &quot;2:00 PM&quot;, &quot;&quot;))</formula>
        <name>Campus Tour TIme</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pending_Appointments</fullName>
        <field>Substatus__c</field>
        <literalValue>Pending Appointments</literalValue>
        <name>Pending Appointments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Presentation_Building</fullName>
        <field>Presentation_Location__c</field>
        <literalValue>O’Shaughnessy Educational Center</literalValue>
        <name>Presentation Building</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Presentation_Location</fullName>
        <description>Populates Presentation Location for AM/PM Sessions</description>
        <field>Presentation_Location__c</field>
        <literalValue>Anderson Student Center (ASC)</literalValue>
        <name>Presentation Location</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Presentation_Time2</fullName>
        <description>Updates Presentation Time</description>
        <field>Presentation_Time__c</field>
        <formula>IF(ISPICKVAL(Instance__c,&quot;AM&quot;), &quot;9:15 AM&quot;, 
IF(ISPICKVAL(Instance__c,&quot;PM&quot;), &quot;1:15 PM&quot;, &quot;&quot;))</formula>
        <name>Presentation Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Attended Part of Scheduled Visit</fullName>
        <actions>
            <name>Attended_Part_of_Scheduled_Visit</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Substatus__c</field>
            <operation>equals</operation>
            <value>Attended - Incomplete</value>
        </criteriaItems>
        <description>If Status=&quot;Confirmed&quot; and Substatus=&quot;Attended - Incomplete&quot; Guest partial of scheduled visit email will be sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DFC Info Session Confirmation</fullName>
        <actions>
            <name>DFC_Info_Session_Receipt</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Dougherty Family College</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Instance_Title__c</field>
            <operation>equals</operation>
            <value>Information Session</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fall Junior Visit Day</fullName>
        <actions>
            <name>Fall_Junior_Visit_Day_Receipt_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Fall Junior Visit Day</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <description>Confirmation email for what an registration come through for events like Fall Junior Visit Day</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fall Tommie Days</fullName>
        <actions>
            <name>Fall_Tommie_Days_Confirmation_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Fall Tommie Days</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <description>Confirmation email for what an registration come through for events like Fall Tommie Days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Guest Cancels</fullName>
        <actions>
            <name>Guest_Cancels</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Substatus__c</field>
            <operation>notEqual</operation>
            <value>No-Show</value>
        </criteriaItems>
        <description>UG visit. Email for Cancel will be sent if guest cancels visit.
Status=&quot;Cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Guest No Shows</fullName>
        <actions>
            <name>Guest_No_Shows</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Substatus__c</field>
            <operation>equals</operation>
            <value>No-Show</value>
        </criteriaItems>
        <description>UG visit. Sends &quot;Guest No Show&quot; email when Status = &quot;Cancelled&quot; and Substatus = &quot;No-Show&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Open House Confirmation</fullName>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Instance__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Fall Tommie Day</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <description>Fall Tommie Days and Junior Visit day registrations</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pending Appointments</fullName>
        <actions>
            <name>Pending_Appointments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(Total_Appointments__c &lt;&gt;  Total_Confirmed_Appointments__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Total Appointments Confirmed</fullName>
        <actions>
            <name>All_Appointments_Confirmed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>All_Appointments_Confirmed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Appointment_Confirmed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When Appointments are set to Status as &quot;Confirmed&quot; or &quot;Unavailable&quot; and Total Appointments and Total Confirmed Appointments are equal the Status will update to &quot;Confirmed&quot;</description>
        <formula>(Total_Appointments__c &gt; 0 &amp;&amp; Total_Confirmed_Appointments__c &gt; 0) &amp;&amp;  (Total_Appointments__c =  Total_Confirmed_Appointments__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UG Campus Individual Visit Receipt</fullName>
        <actions>
            <name>UG_Event_Registration_Individual_Visit_Received</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Personalized Visit</value>
        </criteriaItems>
        <description>When student submits visit request for an Personalized Visit an email receipt of registration is sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UG Campus Information Session Receipt</fullName>
        <actions>
            <name>Information_Session_Receipt</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Information Session</value>
        </criteriaItems>
        <description>When student submits visit request for an Information Session an email receipt of registration is sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UG Guest Attended Visit</fullName>
        <actions>
            <name>UG_Guest_Attended_Visits</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Substatus__c</field>
            <operation>equals</operation>
            <value>Attended</value>
        </criteriaItems>
        <description>UG visit.  Guest attended the fully scheduled visit and email follow-up sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UG Individual Visit Confirmed Pending Appointments</fullName>
        <actions>
            <name>UG_Visit_Confirmed_Pending_Appointments</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Substatus__c</field>
            <operation>equals</operation>
            <value>Pending Appointments</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Personalized Visit</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Information Session</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UG Individual Visit Pending Appointments</fullName>
        <actions>
            <name>UG_Visit_Pending_Appointments</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>UST_Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Received</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Substatus__c</field>
            <operation>equals</operation>
            <value>Pending Appointments</value>
        </criteriaItems>
        <criteriaItems>
            <field>UST_Event_Registration__c.Event_Name__c</field>
            <operation>equals</operation>
            <value>Personalized Visit</value>
        </criteriaItems>
        <description>When Status is &quot;Received&quot; and Substatus is &quot;Pending Appointments&quot; (Not all appointments have been marked &quot;Confirmed&quot; or &quot;Unavailable&quot;) an email updating the student that the visit is still being worked on is queued.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UG_Visit_Pending_Appointments</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
