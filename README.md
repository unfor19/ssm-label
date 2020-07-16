# ssm-label

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

Attach the label `latest` when AWS SSM Parameter is created or updated. This is useful for applications which load AWS SSM Parameters on startup.

## Getting Started

### Deploy

[![Launch in Virginia](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png) Virginia us-east-1](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://ssm-label.s3-eu-west-1.amazonaws.com/cfn-template-ssm-label.yml)

[![Launch in Ireland](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png) Ireland eu-west-1](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/quickcreate?templateURL=https://ssm-label.s3-eu-west-1.amazonaws.com/cfn-template-ssm-label.yml)

[![Launch in Hong Kong](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png) Hong Kong ap-east-1](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/quickcreate?templateURL=https://ssm-label.s3-eu-west-1.amazonaws.com/cfn-template-ssm-label.yml)

[![Launch in Canada](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png) Canada ca-central-1](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/quickcreate?templateURL=https://ssm-label.s3-eu-west-1.amazonaws.com/cfn-template-ssm-label.yml)

<details><summary>
More regions
</summary>

To deploy in other regions, replace AWS_REGION with the region's code

```
https://AWS_REGION.console.aws.amazon.com/cloudformation/home?region=AWS_REGION#/stacks/quickcreate?templateURL=https://
ssm-label.s3-eu-west-1.amazonaws.com/cfn-template-ssm-label.yml
```

</details>

### Use in your application

On startup, use AWS SDK and fetch all parameters, filter by label according to a given environment variable which, for example `LABEL=latest`, save the results to a global object and use it across your application. See examples:

- NodeJS
- Python

## Limitations

1. It takes ~30 seconds for the label to be attached
1. There's a limit of 100 versions per parameter - [AWS hard limit](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-labels.html), see Upcoming Features below `ssm-cleanup`

## Upcoming Features

1. Lambda Function, `ssm-cleanup` runs once a day to clean up all parameters which have more than 30 versions, cleans up the first 20 versions, and ignores versions with labels
1. Lambda Function, `ssm-slack` sends a message to a Slack channel with the information about the change - actor, parameter name and version
