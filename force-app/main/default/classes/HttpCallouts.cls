public with sharing class HttpCallouts {

    public static HttpResponseWrapper executeHttpRequest(String endpoint) {
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
       
        return new HttpResponseWrapper(response.getStatusCode(), response.getBody());

    }

    public class HttpResponseWrapper {

        public Integer statusCode;
        public String responseBody;

        public HttpResponseWrapper (Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
    }
}