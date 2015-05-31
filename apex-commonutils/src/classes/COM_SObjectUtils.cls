public with sharing class COM_SObjectUtils {

	private static final COM_Logger LOGGER = new COM_Logger('COM_SObjectUtils');
	
	/**
	* Query all fields in an object and apply filter
	* @author	Sukrut Wagh
	* @version	29/12/2014
	* @param	String objectName	name of a SalesForce SObject
	* @param	String whereClause	where clause to apply in the query
	* @param	String returnLimit	limit in the query
	* @return	List<sObject>		result of query contains all object attributes
	*/
	public static List<sObject> getAllFieldsByDynamicSOQL (String sobjectName, String whereClause, Integer returnLimit){
		String allFields = '';

		// get all the fields of the object
		Map<String, Schema.SObjectField> objectFields = 
		Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap();
		for(String s : objectFields.keySet()) {
			try {
				allFields += s + ',';
			} catch (Exception e ) {
				LOGGER.debug('Failed to add attribute:'+s);
			}
		}

		// remove tailing comma
		allFields = allFields.removeEnd(',');

		return getSelectedFieldsByDynamicSOQL (allFields, sobjectName, whereClause, returnLimit);
	}
	/**
	* Query ID fields in an object and apply filter
	* @author	Sukrut Wagh
	* @version	29/12/2014
	* @param	String objectName	name of a SalesForce SObject
	* @param	String whereClause	where clause to apply in the query
	* @param	String returnLimit	limit in the query
	* @return	List<sObject>		result of query contains all object attributes
	*/
	public static Set<ID> getIDSetbyDynamicSOQL (String sobjectName, String whereClause, Integer returnLimit){
		
		List<sObject> result = getSelectedFieldsByDynamicSOQL('ID', sobjectName,whereClause, returnLimit);
	
		return getIDSetFromsObjectList(result);
		
	}
	/**
	* Query specfic fields in an object and apply filter
	* @author	Sukrut Wagh
	* @version	29/12/2014
	* @param	String selectedFields	name of a SalesForce SObject fields which could include parent fields
	* @param	String objectName	name of a SalesForce SObject
	* @param	String whereClause	where clause to apply in the query
	* @param	String returnLimit	limit in the query
	* @return	List<sObject>		result of query contains all object attributes
	*/
	public static List<sObject>  getSelectedFieldsByDynamicSOQL (String selectedFields, String sobjectName, String whereClause, Integer returnLimit){
		String soql = 'select ';
		List<sObject> result;


		soql += selectedFields;
		soql += ' from ' + sobjectName;			

		// include where clause
		if (String.isNotBlank(whereClause)) {
			soql += ' where ' + whereClause.removeStart('where');
		}
		//limit number returned record			
		soql += ' limit ' + returnLimit;
			
		try {
			result = Database.query(soql);
		} catch (Exception e) {
			LOGGER.debug('Failed on objectName: ' + sobjectName);
			LOGGER.debug(' whereClause: ' + whereClause);
			LOGGER.debug(' soql: ' + soql);
		}

		return result;
	}
	/**
	  *	Take a list of objects and map it on one or more fields. If the key of
	  *	of the map has multiple fields the key will be separated using a colon (:).
	  * Each key will return a list of SObject.
	  *	@author		Sukrut Wagh
	  *	@version	29/12/2014
	  *	@param		List<sObject> listToMap		List that needs to be converted
	  *	@param		List<String> keysToMap		List of fields that key needs to consist of 
	  *											(can only be of field in SObject and not of a parent object)
	  *	@return	Map<String,List<SObject>>	List mapped on specified fields
	  */
	public static Map<string,list<sObject>> mapSObjectListOnKey (List<sObject> listToMap, List<String> keysToMap) {
		Map<string,list<sObject>> resultMap = new Map<string,list<sObject>> ();
		For (sObject listItem : listToMap) {
			String Key = '';
			For (String keyField : keysToMap) {
				Key += ':' + listItem.get(keyField);
			}
			Key = Key.removeStart(':');
			List<sObject> newList = new List<sObject>();
			If (resultMap.containsKey(Key)) {
				newList = resultMap.remove(Key);
			}
			newList.add(listItem);
			resultMap.put(Key,newList);
		}
		return resultMap;
	}

	/**
	* Take a list of objects and map it on one or more fields. If the key of
	* of the map has multiple fields the key will be seperated using a colon (:)
	* Each key will return a single SObject
	* @author   Sukrut Wagh
	* @version  29/12/2014
	* @param	  List<sObject> listToMap	List that needs to be converted
	* @param	  List<String> keysToMap	List of fields that key needs to consist of 
	*										(can only be of field in SObject and not of a parent object)
	* @return	  Map<String,SObject>		List mapped on specified fields
	*/
	public static Map<string,sObject> mapSObjectOnKey (List<sObject> listToMap, List<String> keysToMap) {
		Map<string,sObject> resultMap = new Map<string,sObject> ();
		For (sObject listItem : listToMap) {
			String Key = '';
			For (String keyField : keysToMap) {
				Key += ':' + String.valueOf(listItem.get(keyField));
			}
			Key = Key.removeStart(':');
			resultMap.put(Key,listItem);
		}
		return resultMap;
	}
	/**
	* Take a list of objects and map it on one fields. This is simple version of top method
	* Each key will return a single SObject
	* @author   Sukrut Wagh
	* @version  29/12/2014	
	* @param	  string field	   Typical is extID fields  
	* @param	  List<sObject> lstObject	List that needs to be converted									
	* @return	  Map<String,SObject>		List mapped on specified fields
	*/
	public static map<string, sObject> getMapfromListObject(string field, list<sObject> lstObject){
   		map<string, sObject> aMap = new map<string, sObject>();
   		for(sObject aObject : lstObject){
   			string f = string.valueOf(aObject.get(field));   			
   			aMap.put(f, aObject);   			
   		}
   		return aMap;
	}
	
	/**
	* Get a set from a list
	* @author	Sukrut Wagh
	* @version	29/12/2014
	* @param	List<SObject> sourceList	List to use for the set
	* @param	String fieldName			Field to create set of
	* @return	Set<Object>					Set of objects based on specified fieldName
	*/
	public static Set<Object> getSetFromList (List<SObject> sourceList, String fieldName){
		Set<Object> result = new Set<Object>();
		For (sObject listItem : sourceList) {
			result.add(listItem.get(fieldName));
		}
		return result;
	}
	
	/**
	* Get a set IDs from a list
	* @author	Sukrut Wagh
	* @version	29/12/2014
	* @param	List<SObject> sourceList	List to use for the set	
	* @return	Set<ID>					Set of Salesforce ID based on specified fieldName
	*/
	public static Set<ID> getIDSetFromsObjectList (List<SObject> sourceList){
		Set<ID> result = new Set<ID>();
		For (sObject listItem : sourceList) {
			result.add((ID)listItem.get('ID'));
		}
		return result;
	}
	
	/**
	* Get a set IDs from a list
	* @author	Sukrut Wagh
	* @version	03/02/2015
	* @param	List<SObject> sourceList	List to use for the set	
	* @return	Set<ID>					Set of Salesforce ID based on specified fieldName
	*/
	public static Set<ID> getIDSetFromsObjectList (List<SObject> sourceList, String fieldName){
		Set<ID> result = new Set<ID>();
		if(COM_Utils.isNotEmpty(sourceList) && COM_Utils.isNotEmpty(fieldName)) {
			for (sObject listItem : sourceList) {
				result.add((ID)listItem.get(fieldName));
			}
		}
		return result;
	}
}