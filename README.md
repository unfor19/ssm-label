# ssm-label

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

Attach a label to an SSM Paramater upon changing its value.

## Flow

1. CloudTrail --> CloudWatch Logs --> CloudWatch Event
1. CloudWatch Event triggers Lambda Function
1. Lambda Function, `sls-label-latest` gets details about: actor, parameter value and version
   1. attaches the label `latest` to parameter that was changed
   1. (Optional) Lambda Function attaches the label `previous` to the previous parameter that was changed

## Getting Started

You need to implement the following process in your application

1. On startup, use AWS SDK and fetch all parameters, filter by the label `latest`, save the results to a global variable, for example `parameters`
1. Use the `parameters` variable across your application

## Caveats

1. It takes up to 15 minutes to trigger

## Upcoming Features

1. Lambda Function, `sls-rollback` gets parameter name to filter by, and attaches the label `latest` to all of the versions which posses the label `previous`
1. Lambda Function, `sls-slack` sends a message to a Slack channel with the information about the change - actor, parameter name and version
