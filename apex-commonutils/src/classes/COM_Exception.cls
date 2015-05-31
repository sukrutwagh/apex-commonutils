/**
 * @author 	Sukrut Wagh
 * @date 	06/24/2014 
 * @description Custom Exception class defined for error code support.
 *				All the common error codes can be registered in COM_ErrorCode.
 *				In case you have defined application specific error codes, you may choose to define app specific exception class that extend from this exception class.
*/

public class COM_Exception extends Exception {

	private COM_ErrorCode code;
	
	/**
	* @author 	Sukrut Wagh
	* @date 	06/24/2014
	* @description Returns the error code associated with the exception.
	*			   Note that there could be none associated with the exception at times & this method may return null.  
	* @return COM_ErrorCode 
	*/
	public COM_ErrorCode getCode() {
		return this.code;
	}
	
	/**
	* @author 	Sukrut Wagh
	* @date 	06/24/2014
	* @description Instantiates a exception object with an error code & message.
	* @param code 		error code
	* @param message 	message string
	*/
	public COM_Exception(COM_ErrorCode code,String message) {
		this.setMessage(message);
		this.code = code;
	}
	
	/**
	* @author 	Sukrut Wagh
	* @date 	06/24/2014
	* @description Instantiates a exception object with an error code,message & an exception cause.
	* @param code 		error code
	* @param message 	message string
	* @param cause		cause associated with the exception
	*/
	public COM_Exception(COM_ErrorCode code, String message, Exception cause) {
		this.setMessage(message);
		this.code = code;
		this.initCause(cause);
	}
	
}