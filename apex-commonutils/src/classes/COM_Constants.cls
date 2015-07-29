/**
 * @author 	Sukrut Wagh
 * @date 	06/24/2014 
 * @description Constants that can be shared across apps
 *				Prefix date constants with DF & date time with DTF
*/

public with sharing class COM_Constants {
	
    public static final String COMMA = ',';
    
	/**
	 * @description Sfdc saves datetime fields in UTC with ISO date time format
	*/
	public static final String DTF_ISO_8601 = 'DTF_ISO_8601';
	
	/**
	 * @description Key for Sfdc environment.
	*/
	public static final String ENV = 'ENV';
	
	public static final String SERVICE_CLASS = 'SERVICE_CLASS';
	
	/**
	* @author 	Sukrut Wagh
	* @date 	06/24/2014
	* @description semi-colon separated email addressess used by COM_IntegrationSchedulable during creation of COM_IntegrationBatch instances 
	*/	
	public static final String INT_BATCH_DEFAULT_EMAIL_RECIPIENT = 'INT_BATCH_DEFAULT_EMAIL_RECIPIENT';
	
	private static final Map<String, String> defaults = new Map<String,String> {DTF_ISO_8601 => 'yyyy-MM-dd\'T\'hh:mm:ss\'Z\'', ENV => 'DEV'};
	
	/**
	 * @description Returns the constant value. Constant is looked up in custom settings. If not found, default value is returned.
	 * @param		key
	*/
	public static String getConstant(String key) {
		String val = '';
		if(COM_Utils.isNotEmpty(key)) {
			val = (COM_Utils.isNotEmpty(COM_CS__c.getValues(key)) && COM_Utils.isNotEmpty(COM_CS__c.getValues(key).Value__c)) ?
					COM_CS__c.getValues(key).Value__c : defaults.get(key);
		}
		return val;
	}

}