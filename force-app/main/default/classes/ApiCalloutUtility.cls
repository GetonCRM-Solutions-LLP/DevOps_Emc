/**
@author Divya Ghodasara
@date 22nd Jan 2019
@description ApiCalloutUtility is used to api call.
*/
public class ApiCalloutUtility
{

	public ApiCalloutUtility()
	{

	}
	/**
	@author Divya Ghodasara
	@date 22nd Jan 2019
	@description executeCallout is used to get responce of request
	@param String apiKey to use strore apikey
	@param String method to use set method(like get,post,put)
	@param String endPoint set endpoint of request
	@param String resourceName set parameters of request
	@param String body set body of request(for put and post method)
	*/
	public static HttpResponse executeCallout(String apiKey,String method, String endPoint,String resourceName,String body)
	{
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		HttpResponse res;
		if(resourceName == 'HeaderBasic'){
			req.setHeader('Authorization', 'Basic ' + apiKey);
		} else {
			req.setHeader('Authorization', 'apikey ' + apiKey);
		}
		req.setHeader('Content-Type', 'application/json');
		req.setTimeout(120000);
		req.setMethod(method);
		if(method=='GET')
		{
			endPoint = endPoint+resourceName;
		}
		else if(method=='POST' ||method=='PUT' || method == 'DELETE')
		{
			req.setBody(body);    
		}
		req.setEndpoint(endPoint);
		system.debug('req'+req);
		res= h.send(req);
		system.debug('response--> '+ res );
		return res;
 	}	
}