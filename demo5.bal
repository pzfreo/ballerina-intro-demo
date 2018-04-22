import ballerina/http;
import wso2/twitter;
import ballerina/config;
import ballerinax/kubernetes;

@kubernetes:Service{
   serviceType:"NodePort",
   name:"ballerina-demo"
}


endpoint http:Listener listener {
    port:9090
};

endpoint twitter:Client tweeter {
   clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig:{}
};

@kubernetes:Deployment {
   image: "demo/ballerina-demo",
   name: "ballerina-demo"
}

@kubernetes:ConfigMap{
    ballerinaConf: "../twitter.toml"
}

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
        if (!payload.contains("#ballerina")) {
            payload = payload + " #ballerina";
        }
        http:Response res;
        twitter:Status status = check tweeter -> tweet(payload);
        json js = {
            key: "value",
            twitterId: status.id,
            twitterText: status.text
        };
        res.setJsonPayload(js);
        _ = caller -> respond(res);
    }
}