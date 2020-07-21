# ssm-label

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

Attach the label `latest` when AWS SSM Parameter is created or updated. Especially useful for applications which load AWS SSM Parameters on startup.

## Getting Started

### Deploy

**IMPORTANT** `ssm-label` works per region, so deploy it in each reason that you need to use it

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

On startup, use AWS SDK and fetch all parameters, filter by label `latest`, save the results to a global variable (or a Singleton) and use it across your application.

Need to rollback to a previous Parameter version?

1. Go to your AWS Console
1. Systems Manager > Parameter Store > Click on relevant Parameter
1. History tab > Click on relevant version > Click Attach labels button
1. Add another label > Type latest > A **good** warning - Moving from version # > Confirm

### Examples

- Requires `ssm-label` to be deployed in your AWS account
- Assuming that `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables are set, or that you're using some other [credentials provider](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html#configuring-credentials), for example, `aws configure`
- Both examples rely on the following environment variables

  ```bash
  VARNAME=DEFAULT_VALUE
  PARAMETERS_PATH=(Required)
  PARAMETERS_NON_RECURSIVE=''
  PARAMETERS_NO_DECRYPTION=''
  PARAMETERS_MAX_RESULTS=10 # used in pagination, keep it as 10
  ```

#### Python

- Requires Python 3.6+ and [boto3](https://pypi.org/project/boto3/) `pip install boto3`
- Execute
  ```bash
  $ bash examples/python_example.sh
  ```

#### NodeJS

- Requires [NodeJS 12.x](https://nodejs.org/en/download/package-manager/), [yarn](https://classic.yarnpkg.com/en/docs/install/) and [aws-sdk](https://www.npmjs.com/package/aws-sdk)
- Execute
  ```bash
  $ bash examples/node_example.sh
  ```

## Limitations

1. It takes up to 30 seconds for the label `latest` to be attached - the Lambda Function which attaches the label runs for about ~1sec, but it takes time for it to be triggered by the CloudWatch Event
1. There's a limit of 100 versions per parameter - [AWS hard limit](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-labels.html), see Upcoming Features below `ssm-cleanup`

## Upcoming Features

1. Lambda Function, `ssm-cleanup` runs once a day to clean up all parameters which have more than 30 versions, cleans up the first 20 versions, and ignores versions with labels
1. Lambda Function, `ssm-slack` sends a message to a Slack channel with the information about the change - actor, parameter name and version

## Contributing

Report issues/questions/feature requests on the [Issues](https://github.com/unfor19/ssm-label/issues) section.

Pull requests are welcome! Ideally, create a feature branch and issue for every single change you make. These are the steps:

1. Fork this repo
1. Create your feature branch from master (`git checkout -b my-new-feature`)
1. Add the code of your new feature
1. Commit your remarkable changes (`git commit -am 'Added new feature'`)
1. Push to the branch (`git push --set-up-stream origin my-new-feature`)
1. Create a new Pull Request and tell us about your changes

## Authors

Created and maintained by [Meir Gabay](https://github.com/unfor19)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/unfor19/ssm-label/blob/master/LICENSE) file for details
