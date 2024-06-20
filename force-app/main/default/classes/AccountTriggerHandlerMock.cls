
global class AccountTriggerHandlerMock implements HttpCalloutMock {
    public Integer statusCode;
    public String body;

    public AccountTriggerHandlerMock(Integer statusCode, String body) {
        this.statusCode = statusCode;
        this.body = body;
    }
    
    global HttpResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setBody(body);
        response.setStatusCode(statusCode);
        return response;
    }
}