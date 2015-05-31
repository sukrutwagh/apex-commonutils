@isTest
private class COM_UtilsTest {

    static testMethod void test_Empty() {
        System.assert(COM_Utils.isEmpty(null));
        System.assert(COM_Utils.isEmpty('   '));
        System.assert(COM_Utils.isEmpty(new List<String>()));
        System.assert(COM_Utils.isNotEmpty(new List<String> {''}));
    }
    
    static testMethod void test_toString() {
    	List<String> l = null;
    	List<Object> objList = new List<Object>{'a','b'};
    	List<String> strList = new List<String>{'a','b'};
    	String unwrappedStr = 'a,b';
    	String quoteWrappedStr = '\'a\',\'b\'';
    	String comma = ',';
    	String singleQuote = '\'';
    	String separator = null;
    	String wrapStr = null;
        System.assert(COM_Utils.isEmpty(COM_Utils.toString(l,separator,wrapStr)));
        l = strList;
        System.assert(COM_Utils.isEmpty(COM_Utils.toString(l,separator,wrapStr)));
        l = null;
        separator = comma;
        System.assert(COM_Utils.isEmpty(COM_Utils.toString(l,separator,wrapStr)));
        l = strList;
        System.assertEquals(unwrappedStr,COM_Utils.toString(l,separator,wrapStr));
        wrapStr = singleQuote;
        System.assertEquals(quoteWrappedStr,COM_Utils.toString(l,separator,wrapStr));
        
        System.assert(COM_Utils.isNotEmpty(COM_Utils.toString(objList,separator,wrapStr)));
        System.assert(COM_Utils.isNotEmpty(COM_Utils.toString(new Set<Object>(objList),separator,wrapStr)));
    }
    
    static testMethod void test_getObjectName() {
    	Schema.sObjectType soType = null;
    	System.assert(COM_Utils.isEmpty(COM_Utils.getObjectName(soType)));
    	soType = Account.sObjectType;
    	System.assertEquals('Account',COM_Utils.getObjectName(soType));
    	soType = COM_Batch_Queue__c.sObjectType;
    	System.assertEquals('COM_Batch_Queue',COM_Utils.getObjectName(soType));
    }
    
    static testMethod void test_getSObjectTypeName() {
    	SObject so = null;
    	System.assert(COM_Utils.isEmpty(COM_Utils.getSObjectTypeName(so)));
    	so = new Account();
    	System.assertEquals('Account',COM_Utils.getSObjectTypeName(so));
    	so = new COM_Batch_Queue__c();
    	System.assertEquals('COM_Batch_Queue__c',COM_Utils.getSObjectTypeName(so));
    }
    
    static testMethod void test_getEnv() {
    	Set<COM_Utils.Env> validEnvs = COM_Utils.getEnvs();
    	System.assert(COM_Utils.isNotEmpty(COM_Utils.getEnv()));
    	System.assert(validEnvs.contains(COM_Utils.getEnv()));
    }
    
    static testMethod void test_isSandbox() {
    	Set<COM_Utils.Env> validEnvs = COM_Utils.getEnvs();
    	COM_Utils.Env env = COM_Utils.getEnv();
    	if(COM_Utils.Env.PROD != env) {
	    	System.assert(COM_Utils.isNotEmpty(COM_Utils.isSandbox()));
    	}
    }
    
    
}