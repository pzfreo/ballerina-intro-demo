import ballerina/http;

endpoint http:Listener listener {
    port:9090
};

service<http:Service> hello bind listener {
    hi (endpoint caller, http:Request request) {
        http:Response res;
        res.setStringPayload("hello world\n");
        _ = caller -> respond(res);
    }
}