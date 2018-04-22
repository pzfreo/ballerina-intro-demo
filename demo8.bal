// Move all the invocation and tweeting functionality to another function
// call it asynchronously

// To run it:
// ballerina run demo_async.bal --config twitter.toml
// To invoke:
// curl -X POST localhost:9090/
// Invoke many times to show how quickly the function returns
// then go to the browser and refresh a few times to see how gradually new tweets appear

import ballerina/http;
import wso2/twitter;
import ballerina/config;

endpoint twitter:Client twitter {
   clientId: config:getAsString("clientId"),
   clientSecret: config:getAsString("clientSecret"),
   accessToken: config:getAsString("accessToken"),
   accessTokenSecret: config:getAsString("accessTokenSecret"),
   clientConfig:{}   
};

endpoint http:Listener listener {
    port:9090
};

endpoint http:Client homer {
   url:"http://www.simpsonquotes.xyz"
};

@http:ServiceConfig {
   basePath : "/"
}
service<http:Service> asyncTweeter bind listener {
   
   @http:ResourceConfig {
       path : "/",
       methods : ["POST"]
   }
   tweetAsync (endpoint caller, http:Request request) {
       var v = start doTweet();
       http:Response res;
       res.setStringPayload("Async call\n");   
       res.statusCode = 202;    
       _ = caller->respond(res);
   }
}

function doTweet() {
   http:Request req;
   http:Response res;

   var v = homer->get("/quote",req);

   match v {
       http:Response hResp => {
           string status = check hResp.getStringPayload();
           status = "Homer Simpson says: "+ status;
           if (!status.contains("#ballerina")){status=status+" #ballerina";}
           twitter:Status st = check twitter->tweet(status,"","");
           json myJson = {
               text : status,
               id : st.id,
               agent : "ballerina"
           };
           res.setJsonPayload(myJson);
       }
       error err => {
           res.setStringPayload("Call failed.\n");
       }
   }
}
