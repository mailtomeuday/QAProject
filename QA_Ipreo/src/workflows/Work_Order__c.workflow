<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_to_Sales_Ops_Work_Order_with_Requires_UAT_Yes_is_Closed</fullName>
        <ccEmails>salesforce_support@ipreo.com</ccEmails>
        <description>Notification to Sales Ops when a Work Order with Requires UAT = Yes is &quot;Closed - Live&quot; or &quot;UAT Accepted&quot; or &quot;Live (Project Still Open)&quot;</description>
        <protected>false</protected>
        <recipients>
            <recipient>ian.graham@ipreo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>salesrep@epam.com.qa</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Work_Orders/Work_Order_Closed_Notification_To_Sales_Ops</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Send_Closed_Notification_to_Sales_Rep</fullName>
        <description>[Work Order] Send Closed Notification to Sales Rep</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Work_Orders/Work_Order_Closed_Notification</template>
    </alerts>
    <alerts>
        <fullName>Work_Order_Send_WO_Assignment_Notification_to_Owner</fullName>
        <description>[Work Order] Send WO Assignment Notification to Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Work_Orders/Work_Order_Assignment_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Active_Need_to_Be_Updated_to_False</fullName>
        <field>Active__c</field>
        <literalValue>0</literalValue>
        <name>Active Need to Be Updated to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Active_Need_to_Be_Updated_to_True</fullName>
        <field>Active__c</field>
        <literalValue>1</literalValue>
        <name>Active Need to Be Updated to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_is_mail_sent_already_field</fullName>
        <description>Check is mail sent already field when email is already sent.</description>
        <field>Is_Mail_sent_already__c</field>
        <literalValue>1</literalValue>
        <name>Check is mail sent already field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_WO_Est_Completion_Date_To_Today</fullName>
        <description>If Work Order Status starts with Closed, do not validate Est. Completion Date but rather set it to Current Date.</description>
        <field>Est_Completion_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set WO Est Completion Date To Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Work_Order_Completion_Date_to_Today</fullName>
        <description>Set the Work Order &quot;Completion Date&quot; field to today</description>
        <field>Completion_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Work Order Completion Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BWork Order%5D Send Closed Notification</fullName>
        <actions>
            <name>Work_Order_Send_Closed_Notification_to_Sales_Rep</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Live,Closed - Not Live,Closed - Provisioned,Closed - Not Provisioned,Closed - Completed,Closed - Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BWork Order%5D Send WO Assignment Notification</fullName>
        <actions>
            <name>Work_Order_Send_WO_Assignment_Notification_to_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>$User.Id !=  OwnerId</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BWork Order%5D Set Completion Date on Closed Status</fullName>
        <actions>
            <name>Set_Work_Order_Completion_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.Status__c</field>
            <operation>contains</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Set the Completion Date to today when a Work Order is changed to any of the closed Statuses</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BWork Order%5D Update Status to Active When Created</fullName>
        <actions>
            <name>Active_Need_to_Be_Updated_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.Auto_Populated_Active_Status__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update Status When Created. If Auto Populated Active Status = true, update it to Active.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BWork Order%5D Update Status to Inactive When Created</fullName>
        <actions>
            <name>Active_Need_to_Be_Updated_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.Auto_Populated_Active_Status__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Update Status When Created. If Auto Populated Active Status = true, update it to Inactive.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Operations User</fullName>
        <actions>
            <name>Notification_to_Sales_Ops_Work_Order_with_Requires_UAT_Yes_is_Closed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check_is_mail_sent_already_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Work_Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Live,UAT Accepted,Live (Project Still Open)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Work_Order__c.Requires_Implementation_UAT__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Work_Order__c.Is_Mail_sent_already__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Work Order Est Completion Date</fullName>
        <actions>
            <name>Set_WO_Est_Completion_Date_To_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.Status__c</field>
            <operation>startsWith</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
