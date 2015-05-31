/**
* @author	 	Sukrut Wagh
* @date 		21/10/2014
* @description	Factory pattern for creating objects of Apex classes
* 				References 
* 				http://www.oodesign.com/factory-pattern.html
* 				http://jessealtman.com/2014/03/dependency-injection-in-apex/
*/
public with sharing class COM_Factory {
	
	private static final COM_Logger LOGGER = new COM_Logger('COM_Factory'); 
    
    /**
	* @author 	Sukrut Wagh
	* @date 	21/10/2014
	* @description Returns a new instance for the requested class.
	* @param className service class name
	* @return object implmentating COM_Service 
	*/
    public static COM_Service getService(final String serviceClassName) {
        String methodName = 'getService';
        LOGGER.entry(methodName);
        COM_Service service = null;
        LOGGER.info('Service Class :'+serviceClassName);
        if(COM_Utils.isNotEmpty(serviceClassName)) {
            Type obType = Type.forName(serviceClassName);
            service = (obType == null) ? null : (COM_Service)obType.newInstance();
        }
        LOGGER.exit(methodName);
        return service;
    }
    

}