@isTest
private class COM_NotificationUtilsTest {

    private static void insertTestConfigs() {
        List<NotificationControl__c> configs = new List<NotificationControl__c>();
       	NotificationControl__c config = new NotificationControl__c(Name='Case',Enable__c=true,ToAddressFields__c='SuppliedName,SuppliedCompany',
       									CcAddressFields__c='SuppliedCompany',AdditionalToAddress__c='m8r-kmjvvo@mailinator.com',NotifyOnFields__c='');
		configs.add(config);
		config = new NotificationControl__c(Name='Account',Enable__c=true,ToAddressFields__c='Sic',
       									CcAddressFields__c='',AdditionalToAddress__c='m8r-kmjvvo@mailinator.com',NotifyOnFields__c='');
		configs.add(config);
        config = new NotificationControl__c(Name='Product2',Enable__c=false,ToAddressFields__c='ProductCode',
       									CcAddressFields__c='',AdditionalToAddress__c='m8r-kmjvvo@mailinator.com',NotifyOnFields__c='');
		configs.add(config);
		insert configs;
    }

    static testMethod void notifyChangeTest() {
        
        List<SObject> old = new List<SObject>(); 
    	List<SObject> newz = new List<SObject>();
        
        Account oldacc1 = new Account(Name='Acme Corp', AccountNumber='1', Sic='1');
        Account oldacc2 = new Account(Name='Acme Corp', AccountNumber='2', Sic='2');
        Account oldacc3 = new Account(Name='Acme Corp', AccountNumber='3', Sic='3');
        Account oldacc4 = new Account(Name='Acme Corp', AccountNumber='4', Sic='4');
        
        Account newacc1 = new Account(Name='Acme Corp', AccountNumber='1', Sic='11');
        Account newacc2 = new Account(Name='Acme Corp', AccountNumber='2', Sic='22');
        Account newacc3 = new Account(Name='Acme Corp', AccountNumber='31', Sic='33');
        Account newacc4 = new Account(Name='Acme Corp4', AccountNumber='4', Sic='44');
        
        old.add(oldacc1);
        old.add(oldacc2);
        old.add(oldacc3);
        old.add(oldacc4);
        newz.add(newacc1);
    	newz.add(newacc2);
        newz.add(newacc3);
        newz.add(newacc4);
        
        Test.startTest();
        Integer emailbefore = Limits.getEmailInvocations();
        //COM_NotificationUtils.notifyChange(old, newz);
        system.assertEquals(emailbefore,Limits.getEmailInvocations(),'should not have decreased');
        
        insertTestConfigs();
        COM_NotificationUtils.notifyChange(old, newz);
        Test.stopTest();
        //system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
    }
    
    static testMethod void getConfigTest() {
        insertTestConfigs();
		System.assert(COM_Utils.isEmpty(COM_NotificationUtils.getConfig(null)));
		Account acc = new Account(Name='Test Account');
		System.assert(COM_Utils.isNotEmpty(COM_NotificationUtils.getConfig(acc)));
        System.assertEquals(true, COM_NotificationUtils.getConfig(acc).Enable__c);
        
        SObject cObj = new Case(Subject='Test Case',AccountId=acc.Id,Status = 'Working',Origin = 'Phone');
		System.assert(COM_Utils.isNotEmpty(COM_NotificationUtils.getConfig(cObj)));
        System.assertEquals(true, COM_NotificationUtils.getConfig(cObj).Enable__c);
        
        Product2 product = new Product2(Name='Test Product');
		System.assert(COM_Utils.isNotEmpty(COM_NotificationUtils.getConfig(product)));
        System.assertEquals(false, COM_NotificationUtils.getConfig(product).Enable__c);
        
    }
}