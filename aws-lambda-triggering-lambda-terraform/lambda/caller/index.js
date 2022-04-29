var AWS = require('aws-sdk');
AWS.config.region = 'us-east-1';
var lambda = new AWS.Lambda();

exports.handler = function(event, context) {
  console.log("Caller triggered...");

  var params = {
    FunctionName: 'callee_lambda', // the lambda function we are going to invoke
    InvocationType: 'Event',
    Payload: JSON.stringify('Hello')
  };

  //     LogType: 'Tail' in params will log to one logstream

  lambda.invoke(params).promise();
  console.log("Caller finishing...");
};