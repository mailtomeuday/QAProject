<BDSFEntityMapping>
<entityMap source="ContactWithFocusData" target="Contact">
	<fieldMap source="FirstName" target="FirstName" />
	<fieldMap source="LastName" target="LastName" />
	<fieldMap source="Email" target="BDEmail__c" />
	<fieldMap source="Fax" target="BDFax__c" />
    	<fieldMap source="RoleName" target="Title" />
    	<fieldMap source="Phone" target="BDPhone__c" />
   	<fieldMap source="Biography" target="Description" />
	<fieldMap source="AddressZip" target="MailingPostalCode" />
	<fieldMap source="AddressCountry" target="MailingCountry" />
	<fieldMap source="AddressState" target="MailingState" />
	<fieldMap source="AddressCity" target="MailingCity" />
  	<fieldMap mappingType="expression" source="{0} {1}" target="MailingStreet">
      		<expressionParameter source="AddressLine1" />
      		<expressionParameter source="AddressLine2" />
    	</fieldMap>
	</entityMap>
<entityMap source="Contact411Data" target="Contact">
    	<fieldMap source="FirstName" target="FirstName" />
    	<fieldMap source="LastName" target="LastName" />
	<fieldMap source="Email" target="BDEmail__c" />
	<fieldMap source="Fax" target="BDFax__c" />
    	<fieldMap source="RoleName" target="Title" />
    	<fieldMap source="Phone" target="BDPhone__c" />
	<fieldMap source="AddressZip" target="MailingPostalCode" />
	<fieldMap source="AddressCountry" target="MailingCountry" />
	<fieldMap source="AddressState" target="MailingState" />
	<fieldMap source="AddressCity" target="MailingCity" />
	<fieldMap mappingType="expression" source="{0} {1}" target="MailingStreet">
		<expressionParameter source="AddressLine1" />
		<expressionParameter source="AddressLine2" />
	</fieldMap>
	</entityMap>
<entityMap source="ContactWithFocusData" target="Lead">
   	<fieldMap source="FirstName" target="FirstName" />
    	<fieldMap source="LastName" target="LastName" />
	<fieldMap source="Company.Name" target="Company" />
    	<fieldMap source="Company.Website" target="Website" />
	<fieldMap source="Company.TypeName" target="BDTypeName__c" />
	<fieldMap source="Email" target="BDEmail__c" />
	<fieldMap source="Fax" target="BDFax__c" />
    	<fieldMap source="RoleName" target="Title" />
    	<fieldMap source="Phone" target="BDPhone__c" />
    	<fieldMap source="Biography" target="Description" />
	<fieldMap source="AddressZip" target="PostalCode" />
	<fieldMap source="AddressCountry" target="Country" />
	<fieldMap source="AddressState" target="State" />
	<fieldMap source="AddressCity" target="City" />
	<fieldMap mappingType="expression" source="{0} {1}" target="Street">
		<expressionParameter source="AddressLine1" />
		<expressionParameter source="AddressLine2" />
	</fieldMap>
	</entityMap>
<entityMap source="CompanyWithFocusData" target="Account">
	<fieldMap source="Name" target="Name" />
	<fieldMap source="Fax" target="BDFax__c" />
    	<fieldMap source="Phone" target="BDPhone__c" />
	<fieldMap source="Website" target="Website" />
    	<fieldMap source="Overview" target="Description" />
	<fieldMap source="IsBuySide" target="BDIsBuySide__c" />
	<fieldMap source="IsSellSide" target="BDIsSellSide__c" />
	<fieldMap source="TypeName" target="BDTypeName__c" />
	<fieldMap source="AddressCity" target="BillingCity" />
	<fieldMap source="AddressCountry" target="BillingCountry" />
	<fieldMap source="AddressState" target="BillingState" />
	<fieldMap source="AddressZip" target="BillingPostalCode" />
	<fieldMap mappingType="expression" source="{0} {1}" target="BillingStreet">
		<expressionParameter source="AddressLine1" />
		<expressionParameter source="AddressLine2" />
	</fieldMap>
	</entityMap>
<entityMap source="Company411Data" target="Account">
	<fieldMap source="Name" target="Name" />
	<fieldMap source="Fax" target="Fax" />
	<fieldMap source="Phone" target="Phone" />
	<fieldMap source="Website" target="Website" />
	<fieldMap source="IsBuySide" target="BDIsBuySide__c" />
	<fieldMap source="IsSellSide" target="BDIsSellSide__c" />
	<fieldMap source="TypeName" target="BDTypeName__c" />
	<fieldMap source="AddressCity" target="BillingCity" />
	<fieldMap source="AddressCountry" target="BillingCountry" />
	<fieldMap source="AddressState" target="BillingState" />
	<fieldMap source="AddressZip" target="BillingPostalCode" />
	<fieldMap mappingType="expression" source="{0} {1}" target="BillingStreet">
		<expressionParameter source="AddressLine1" />
		<expressionParameter source="AddressLine2" />
	</fieldMap>
	</entityMap>
<entityMap source="CompanyWithFocusData" target="Lead">
	<fieldMap source="Name" target="LastName" />
	<fieldMap source="Name" target="Company" />
	<fieldMap source="Fax" target="Fax" />
	<fieldMap source="Phone" target="Phone" />
	<fieldMap source="TypeName" target="BDTypeName__c" />
	<fieldMap source="Website" target="Website" />
    	<fieldMap source="Overview" target="Description" />
	<fieldMap source="AddressCity" target="City" />
	<fieldMap source="AddressCountry" target="Country" />
	<fieldMap source="AddressState" target="State" />
	<fieldMap source="AddressZip" target="PostalCode" />
	<fieldMap mappingType="expression" source="{0} {1}" target="Street">
		<expressionParameter source="AddressLine1" />
		<expressionParameter source="AddressLine2" />
	</fieldMap>
	</entityMap>
</BDSFEntityMapping>