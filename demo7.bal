import ballerina/http;
import wso2/twitter;
import ballerina/config;
import ballerina/time;

endpoint http:Listener listener {
    port:9090
};

endpoint http:Client homer {
    url: "http://www.simpsonquotes.xyz/",
    timeoutMillis: 1000
};

endpoint twitter:Client tweeter {
    clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig:{}
};

endpoint http:Client homerCB {
    circuitBreaker: {
        rollingWindow: {
            timeWindowMillis:10000,
            bucketSizeMillis:1000
        },
        failureThreshold:0,
        resetTimeMillis:3000,
        statusCodes:[500,502,503,504,507,509,598,599]
    },
    url: "http://www.simpsonquotes.xyz/",
    timeoutMillis:1000

};

@http:ServiceConfig {
    basePath:"/"
}
service<http:Service> tweetService bind listener {

    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    tweet (endpoint caller, http:Request request) {
        
        // call the GET method on the Homer quotes service
        var homerRes =  homerCB->get("/quote", new);
        string payload = "";
        // handle errors
        match homerRes {
            http:Response res => {
                payload = check res.getStringPayload();
                payload = "Homer Simpson says: "+payload;
            }
            error err => {
                payload = "Doh! " + time:currentTime().toString();
            }
        }

        if (!payload.contains("#ballerina")) {
            payload = payload+" #ballerina";
        }

        twitter:Status status = check tweeter -> tweet(payload);
        
        http:Response res;
        json js = { identifier: status.id, tweet: status.text};
        res.setJsonPayload(js);
        _ = caller -> respond(res);
    }
}