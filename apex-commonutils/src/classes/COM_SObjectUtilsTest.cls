@isTest
private class COM_SObjectUtilsTest {

	static testMethod void getAllFieldsByDynamicSOQLTest (){

		List<Account> accList = new List<Account>();
		accList.add(new Account(Name = 'A',BillingCountry='NL'));
		accList.add(new Account(Name = 'B',BillingCountry='NL'));
		accList.add(new Account(Name = 'C',BillingCountry='US'));
		accList.add(new Account(Name = 'D',BillingCountry='US'));
		accList.add(new Account(Name = 'E',BillingCountry='US'));
		insert accList;
		
		accList = null;

		accList = COM_SObjectUtils.getAllFieldsByDynamicSOQL('Account', 'Name=\'A\'', 10);
		
		system.assertEquals(1,accList.size());
		system.assertEquals('NL',accList[0].get('BillingCountry'));

	}
	
	static testMethod void getIDbyDynamicSOQL (){

		
		List<Account> accList = new List<Account>();
		accList.add(new Account(Name = 'A',BillingCountry='NL'));
		accList.add(new Account(Name = 'B',BillingCountry='NL'));
		accList.add(new Account(Name = 'C',BillingCountry='US'));
		accList.add(new Account(Name = 'D',BillingCountry='US'));
		accList.add(new Account(Name = 'E',BillingCountry='US'));
		insert accList;
		
		Set<ID> accSet = new Set<ID>();

		accSet = COM_SObjectUtils.getIDSetbyDynamicSOQL('Account', 'Name=\'A\'', 10);
		
		system.assertEquals(1,accSet.size());
	//	system.assertEquals('NL',accSet[0].get('BillingCountry'));

	}
	static testMethod void getSelectedFieldsByDynamicSOQL (){

		List<Account> accList = new List<Account>();
		accList.add(new Account(Name = 'A',BillingCountry='NL'));
		accList.add(new Account(Name = 'B',BillingCountry='NL'));
		accList.add(new Account(Name = 'C',BillingCountry='US'));
		accList.add(new Account(Name = 'D',BillingCountry='US'));
		accList.add(new Account(Name = 'E',BillingCountry='US'));
		insert accList;
		
		accList = null;

		accList = COM_SObjectUtils.getSelectedFieldsByDynamicSOQL('name, BillingCountry', 'Account', 'Name=\'A\'', 10);
		
		system.assertEquals(1,accList.size());
		system.assertEquals('NL',accList[0].get('BillingCountry'));

	}
	static testMethod void mapSObjectListOnKeyTest (){
		
		List<Account> acc = new List<Account>();
		acc.add(new Account(Name = 'A',BillingCountry='NL'));
		acc.add(new Account(Name = 'B',BillingCountry='NL'));
		acc.add(new Account(Name = 'C',BillingCountry='US'));
		acc.add(new Account(Name = 'D',BillingCountry='US'));
		acc.add(new Account(Name = 'E',BillingCountry='US'));
		
		Map<String,List<Account>> result = (Map<String,List<Account>>) COM_SObjectUtils.mapSObjectListOnKey(acc, new List<String>{'BillingCountry'});
		
		system.assertEquals(2, result.values().size());
		system.assertEquals(2, result.get('NL').size());
		system.assertEquals(3, result.get('US').size());
		
	}
	
	static testMethod void mapSObjectOnKeyTest (){
		
		List<Account> acc = new List<Account>();
		acc.add(new Account(Name = 'A',BillingCountry='NL'));
		acc.add(new Account(Name = 'B',BillingCountry='NL'));
		acc.add(new Account(Name = 'C',BillingCountry='US'));
		acc.add(new Account(Name = 'D',BillingCountry='US'));
		acc.add(new Account(Name = 'E',BillingCountry='US'));
		
		//Map<String,Account> result = (Map<String,Account>) BDT_Utils.mapSObjectOnKey(acc, new List<String>{'Name'});
		Map<String,SObject> result = (Map<String,SObject>) COM_SObjectUtils.mapSObjectOnKey(acc, new List<String>{'Name'});
		
		system.assertEquals(5, result.values().size());
		system.assertEquals('NL', ((Account)result.get('A')).BillingCountry);
		system.assertEquals('US', result.get('D').get('BillingCountry'));
		
	}
	
	static testMethod void getSetFromListTest () {
		List<Account> acc = new List<Account>();
		acc.add(new Account(Name = 'A',BillingCountry='NL'));
		acc.add(new Account(Name = 'B',BillingCountry='NL'));
		acc.add(new Account(Name = 'C',BillingCountry='US'));
		acc.add(new Account(Name = 'D',BillingCountry='US'));
		acc.add(new Account(Name = 'E',BillingCountry='US'));
		
		Set<Object> result = COM_SObjectUtils.getSetFromList(acc, 'BillingCountry');
		system.assertEquals(2, result.size());
		system.assert(result.contains('NL'));
	}
	static testMethod void getMapfromListObjectTest (){
		
		List<Account> acc = new List<Account>();
		acc.add(new Account(Name = 'A',BillingCountry='NL'));
		acc.add(new Account(Name = 'B',BillingCountry='NL'));
		acc.add(new Account(Name = 'C',BillingCountry='US'));
		acc.add(new Account(Name = 'D',BillingCountry='US'));
		acc.add(new Account(Name = 'E',BillingCountry='US'));
		
		//Map<String,Account> result = (Map<String,Account>) BDT_Utils.mapSObjectOnKey(acc, new List<String>{'Name'});
		Map<String,SObject> result = (Map<String,SObject>) COM_SObjectUtils.getMapfromListObject('name', acc);
		
		system.assertEquals(5, result.values().size());
		system.assertEquals('NL', ((Account)result.get('A')).BillingCountry);
		system.assertEquals('US', result.get('D').get('BillingCountry'));
		
	}
	
	static testMethod void getIDSetFromsObjectListTest () {
		List<Account> accList = new List<Account>();
		accList.add(new Account(Name = 'A',BillingCountry='NL'));
		accList.add(new Account(Name = 'B',BillingCountry='US'));
		insert accList;
		
		Set<Id> result = COM_SObjectUtils.getIDSetFromsObjectList(accList, 'Id');
		system.assertEquals(2, result.size());
	}
}