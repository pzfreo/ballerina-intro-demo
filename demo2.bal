import ballerina/http;

endpoint http:Listener listener {
    port:9090
};

@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> hello bind listener {
    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    hi (endpoint caller, http:Request request) {
        string payload = check request.getStringPayload();
        http:Response res;
        res.setStringPayload("hello "+ payload +" \n");
        _ = caller -> respond(res);
    }
}