import ballerina/http;
import wso2/twitter;
import ballerina/config;

endpoint twitter:Client tweeter {
   clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig:{}
};

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
        twitter:Status status = check tweeter -> tweet(payload);
        res.setStringPayload(status.text);
        _ = caller -> respond(res);
    }
}