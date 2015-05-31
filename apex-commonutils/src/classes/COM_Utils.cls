/**
* @author 		Sukrut Wagh
* @date			06/24/24
* @description	Utility class providing boiler plate reusable methods
*/

global class COM_Utils {
	
	global static final String EMPTY = '';

	/**
	 * @author 		Sukrut Wagh
	 * @date		06/24/24
	 * @description Determins if the object is null/empty. 
	 *				Supported object types: String, List.
	 * 				Note: Set<String> is not recognized as an instanceof Set<object> and 
	 * 		 		Map<String,String> is not recognized as an instanceof Map<Object,Object>
	 * @param obj
	 * @return boolean
	 */
	global static Boolean isNotEmpty(final Object obj) {
		if(null != obj) {
			if(obj instanceof String) {
				return String.isBlank((String)obj) ? false : true;
			} else if(obj instanceof List<Object>) {
				return (((List<Object>)obj).isEmpty()) ? false : true;
			} /*else if(obj instanceof Set<Object>) {
				return (((Set<Object>)obj).isEmpty()) ? false : true;
			} else if(obj instanceof Map<Object,Object>) {
				return (((Map<Object,Object>)obj).isEmpty()) ? false : true;
			}*/
			return true;
		}
		return false;
	}
	
	global static Boolean isEmpty(final Object obj) {
		return !isNotEmpty(obj);
	}
	
	/**
	* @description Converts the list to a String. Values are separated by the separator character.
	* @param l			list of string
	* @param separator	separator character
	* @param wrapStr	optional. In case the value has to be wrappep/surronded by a string. 
	*					e.g: when wrapStr=quote & separator=comma, returned string will be in format 'val 1','val 2'
	*/
	global static String toString(final List<String> l, final String separator, String wrapStr) {
		String resp = '';
		if(COM_Utils.isEmpty(wrapStr)){
			wrapStr = '';
		}
		if(COM_Utils.isNotEmpty(l) && COM_Utils.isNotEmpty(separator)) {
			for(String val : l) {
				resp += wrapStr+val+wrapStr+separator;
			}
			if(resp.endsWith(separator)) {
				resp = resp.removeEndIgnoreCase(separator);
			}
		}
		return resp;
	}
	
	/**
	* @description Converts the Set to a String. Values are separated by the separator character.
	* @param s			Set of string
	* @param separator	separator character
	* @param wrapStr	optional. In case the value has to be wrappep/surronded by a string. 
	*					e.g: when wrapStr=quote & separator=comma, returned string will be in format 'val 1','val 2'
	*/
	global static String toString(final Set<String> s, final String separator, String wrapStr) {
		String resp = '';
		if(null != s && s.size() > 0) {
			resp = toString(new List<String>(s),separator,wrapStr);
		}
		return resp;
	}
	
	/**
	* @description Converts the list to a String. Values are separated by the separator character.
	* @param l			list of Object
	* @param separator	separator character
	* @param wrapStr	optional. In case the value has to be wrappep/surronded by a string. 
	*					e.g: when wrapStr=quote & separator=comma, returned string will be in format 'val 1','val 2'
	*/
	global static String toString(final List<Object> l, final String separator, String wrapStr) {
		String resp = '';
		if(COM_Utils.isEmpty(wrapStr)){
			wrapStr = '';
		}
		if(COM_Utils.isNotEmpty(l) && COM_Utils.isNotEmpty(separator)) {
			for(Object val : l) {
				resp += wrapStr+String.valueOf(val)+wrapStr+separator;
			}
			if(resp.endsWith(separator)) {
				resp = resp.removeEndIgnoreCase(separator);
			}
		}
		return resp;
	}
	
	/**
	* @description Converts the Set to a String. Values are separated by the separator character.
	* @param s			Set of Object
	* @param separator	separator character
	* @param wrapStr	optional. In case the value has to be wrappep/surronded by a string. 
	*					e.g: when wrapStr=quote & separator=comma, returned string will be in format 'val 1','val 2'
	*/
	global static String toString(final Set<Object> s, final String separator, String wrapStr) {
		String resp = '';
		if(null != s && s.size() > 0) {
			resp = toString(new List<Object>(s),separator,wrapStr);
		}
		return resp;
	}
	
    /**
    * @description	Returns the sObject type API name without __c suffix
	* @param soType The sObjectType for which the name to be obtained.
	* @return String - The API name without __c suffix.    
    */
    global static String getObjectName(Schema.sObjectType soType) {
    	String typeName = null;
    	if(isNotEmpty(soType)) {
    		String originalTypeName = soType.getDescribe().getName();
	    	typeName = originalTypeName;
	    	if (originalTypeName.toLowerCase().endsWith('__c')) {
	    		Integer index = originalTypeName.toLowerCase().indexOf('__c');
	    		typeName = originalTypeName.substring(0, index);
	    	}
    	}
    	return typeName;
    }
    
    /**
	* @description Returns the sObject type API name.
	* @param SObject The SObject for which the name to be obtained.
	* @return String - The type name.
	*/
	global static String getSObjectTypeName(SObject so) {
		String soTypeName = null;
		if(isNotEmpty(so)) {
			soTypeName = so.getSObjectType().getDescribe().getName();
		}
		return soTypeName;
	}
	
	/**
	* @description Enum for Sfdc environments.
	*/
	global Enum Env { DEV, CI, TEST, UAT, PROD }
	
	/**
	* @description Returns the list of valid environments.
	*/
	global static Set<COM_Utils.Env> getEnvs() {
		return new Set<COM_Utils.Env>{COM_Utils.Env.DEV,COM_Utils.Env.CI,COM_Utils.Env.TEST,COM_Utils.Env.UAT,COM_Utils.Env.PROD};
	}
	
	/**
    * @description	Determines the type of organization. Defaults to Env.DEV if unable to determine.
	* @return Enum: Env. 
    */
	global static Env getEnv() {
		Env env = COM_Utils.Env.DEV;
		String envStr = COM_Constants.getConstant(COM_Constants.ENV);
		if(COM_Utils.Env.CI.name().equalsIgnoreCase(envStr)) {
			env = COM_Utils.Env.CI;
		} else if (COM_Utils.Env.TEST.name().equalsIgnoreCase(envStr)) {
			env = COM_Utils.Env.TEST;
		} else if (COM_Utils.Env.UAT.name().equalsIgnoreCase(envStr)) {
			env = COM_Utils.Env.UAT;
		} else if (COM_Utils.Env.PROD.name().equalsIgnoreCase(envStr)) {
			env = COM_Utils.Env.PROD;
		}
		return env;
	}
	
	/**
    * @description	Determines if the organization is a sandbox
	* @return isSandbox.    
    */
	global static Boolean isSandbox() {
		Boolean isSandbox = true;
		isSandbox = Env.PROD != getEnv();
		/**
		* URL.getSalesforceBaseUrl().getHost().left(2).equalsIgnoreCase('cs');
		* The above version will not work as PRA uses custom domain url's.
		* TODO: select Id, IsSandbox from Organization limit 1  [In Summer '14, (version 31.0)]
		* Change to the above implementation once we are at version 31.0
		*/
		return isSandbox;
	}
	
}