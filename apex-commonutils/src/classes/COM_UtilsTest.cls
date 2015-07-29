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
    
    static testMethod void test_getObjUrl() {
        System.assert(COM_Utils.isEmpty(COM_Utils.getObjUrl(null)));
        System.assert(COM_Utils.isEmpty(COM_Utils.getObjUrl(SmartFactory.createSObject('Lead'))));
        Account acc = new Account(Name='Acme Corp', AccountNumber='1', Sic='1');
        insert acc;
        System.assert(COM_Utils.isNotEmpty(COM_Utils.getObjUrl(acc)));
    }
    
    static testMethod void test_getChangedFields() {
    	System.assert(COM_Utils.isEmpty(COM_Utils.getChangedFields(null,null,null)));
    	
    	List<SObject> old = new List<SObject>(); 
    	List<SObject> newz = new List<SObject>();
    	System.assert(COM_Utils.isEmpty(COM_Utils.getChangedFields(old,newz,null)));
        
        Account oldacc1 = new Account(Name='Acme Corp', AccountNumber='1', Sic='1');
        Account oldacc2 = new Account(Name='Acme Corp', AccountNumber='2', Sic='2');
        Account oldacc3 = new Account(Name='Acme Corp', AccountNumber='3', Sic='3');
        Account oldacc4 = new Account(Name='Acme Corp', AccountNumber='4', Sic='4');
        
        Account newacc1 = new Account(Name='Acme Corp', AccountNumber='1', Sic='11');
        Account newacc2 = new Account(Name='Acme Corp', AccountNumber='2', Sic='22');
        Account newacc3 = new Account(Name='Acme Corp', AccountNumber='31', Sic='33');
        Account newacc4 = new Account(Name='Acme Corp4', AccountNumber='4', Sic='44');
    	
        String[] checkForFields = new String[] {'Name','AccountNumber','Sic'};
            
    	old.add(SmartFactory.createSObject('Account'));
    	old.add(SmartFactory.createSObject('Account'));
    	System.assert(COM_Utils.isNotEmpty(COM_Utils.getChangedFields(old,newz,null)));
    	System.assert(COM_Utils.isEmpty(COM_Utils.getChangedFields(old,old,null)));
    	
    	old = new List<SObject>();
    	newz = new List<SObject>();
    	old.add(SmartFactory.createSObject('Account'));
    	newz.add(SmartFactory.createSObject('Contact'));
    	System.assert(COM_Utils.isEmpty(COM_Utils.getChangedFields(old,newz,null)));
    	
    	old = new List<SObject>();
    	newz = new List<SObject>();
    	old.add(oldacc1);
    	newz.add(newacc1);
    	System.assert(COM_Utils.isNotEmpty(COM_Utils.getChangedFields(old,newz,checkForFields)));
        
        old.add(oldacc2);
        old.add(oldacc3);
        old.add(oldacc4);
    	newz.add(newacc2);
        newz.add(newacc3);
        newz.add(newacc4);
    	System.assert(COM_Utils.isNotEmpty(COM_Utils.getChangedFields(old,newz,checkForFields)));
    }
    
    
}