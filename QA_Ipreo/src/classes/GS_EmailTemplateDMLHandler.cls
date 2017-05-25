/**************************************************************************************************
 * Name           : GS_EmailTemplateDMLHandler
 * Object         : EmailTemplate
 * Requirement    : 
 * Target         : DML on EmailTemplate
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-13
 * Modify History :
 **************************************************************************************************/
public class GS_EmailTemplateDMLHandler {
    public static EmailTemplate getEmailTemplateByName(String templateName) {
    	return [SELECT  Id
					   ,TemplateType
					   ,TemplateStyle
					   ,Markup
					   ,ApiVersion
					   ,Description
					   ,DeveloperName
					   ,Body
					   ,Encoding
					   ,Subject
					   ,IsActive
					   ,Name
					   ,HtmlValue
					   ,TimesUsed
				FROM EmailTemplate
				WHERE Name =: templateName 
				Limit 1];
    }
}