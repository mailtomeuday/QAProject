<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Contract_Billing_City</fullName>
        <field>Billing_City__c</field>
        <formula>Billing_Account__r.BillingCity</formula>
        <name>Set Contract Billing City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contract_Billing_Country</fullName>
        <field>Billing_Country__c</field>
        <formula>Billing_Account__r.BillingCountry</formula>
        <name>Set Contract Billing Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contract_Billing_State</fullName>
        <field>Billing_State_Province__c</field>
        <formula>Billing_Account__r.BillingState</formula>
        <name>Set Contract Billing State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contract_Billing_Street</fullName>
        <field>Billing_Street__c</field>
        <formula>Billing_Account__r.BillingStreet</formula>
        <name>Set Contract Billing Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contract_Billing_Zip</fullName>
        <field>Billing_Zip_Postal_Code__c</field>
        <formula>Billing_Account__r.BillingPostalCode</formula>
        <name>Set Contract Billing Zip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Evergreen_to_Checked_on</fullName>
        <field>Evergreen__c</field>
        <literalValue>Yes</literalValue>
        <name>Set Evergreen to Checked on</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BContract%5D Set BIlling Street</fullName>
        <actions>
            <name>Set_Contract_Billing_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW()&amp;&amp; ISBLANK(  Billing_Street__c )) ||  (Not( ISNEW() ) &amp;&amp; ISCHANGED( Billing_Account__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>%5BContract%5D Set Billing City</fullName>
        <actions>
            <name>Set_Contract_Billing_City</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW()&amp;&amp; ISBLANK( Billing_City__c)) ||  (Not( ISNEW() ) &amp;&amp; ISCHANGED( Billing_Account__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>%5BContract%5D Set Billing Country</fullName>
        <actions>
            <name>Set_Contract_Billing_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW()&amp;&amp; ISBLANK(  Billing_Country__c )) ||  (Not( ISNEW() ) &amp;&amp; ISCHANGED( Billing_Account__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>%5BContract%5D Set Billing State</fullName>
        <actions>
            <name>Set_Contract_Billing_State</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW()&amp;&amp; ISBLANK(  Billing_State_Province__c )) ||  (Not( ISNEW() ) &amp;&amp; ISCHANGED( Billing_Account__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>%5BContract%5D Set Billing Zip</fullName>
        <actions>
            <name>Set_Contract_Billing_Zip</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW()&amp;&amp; ISBLANK(  Billing_Zip_Postal_Code__c )) ||  (Not( ISNEW() ) &amp;&amp; ISCHANGED( Billing_Account__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>%5BContract%5D Set Evergreen to Checked on</fullName>
        <actions>
            <name>Set_Evergreen_to_Checked_on</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract__c.Evergreen_Period__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When the evergreen period field is chosen, evergreen should be set to &apos;Yes&apos;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
