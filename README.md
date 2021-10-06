# usaid_bia_v2

Resources container in this repository:

| Resource            | Type                    | Description                                                                         |
|:--------------------|:------------------------|:------------------------------------------------------------------------------------|
| file_posting_broker | Folder                  | contains main Lambda functioncode                                                   |
| tests               | Folder                  | Contains unit/etc. test code and data                                               |
| setup.sh            | Shell Script            | Shell script that contains variable settings, functions, etc. used in other scripts |
| execute_lambda.sh   | Shell Script            | Shell script to execute Lambda Function                                             |
| get_logs.sh         | Shell Script            | Script to grab CloudWatch logs for a Lambda exuection                               |
| README.md           | Readme file             | This readme document                                                                |
| samconfig.toml      | SAM Config File         | Used to run sam commands without prompts                                            |
| template.yaml       | CloudFormation Template | cfn Tempalte file to create Serverless resources                                        |

## Deploy the sample application

To build and deploy your application for the first time, run the following in your shell:

```bash
# Run setup.sh script to set AWS_PROFILE,etc.
source ./setup.sh 
```

Run the following commands to build and deploy serverless function.
```bash

# Remove the .aws_sam folder for clean build.  This avoids the permissions error sometimes seen with sam build commands
# Note that the remove sometimes is needed multiple times due to odd permissions errors.
rm -Rf .aws-sam/
sam build --use-container
sam deploy --guided
```

After the first run, the --guided option is not needed as the samconfig.toml file has the defaults.

The first command will build the source of your application. The second command will package and deploy your application to AWS, with a series of prompts:

* **Stack Name**: The name of the stack to deploy to CloudFormation. This should be unique to your account and region, and a good starting point would be something matching your project name.
* **AWS Region**: The AWS region you want to deploy your app to.
* **Confirm changes before deploy**: If set to yes, any change sets will be shown to you before execution for manual review. If set to no, the AWS SAM CLI will automatically deploy application changes.
* **Allow SAM CLI IAM role creation**: Many AWS SAM templates, including this example, create AWS IAM roles required for the AWS Lambda function(s) included to access AWS services. By default, these are scoped down to minimum required permissions. To deploy an AWS CloudFormation stack which creates or modifies IAM roles, the `CAPABILITY_IAM` value for `capabilities` must be provided. If permission isn't provided through this prompt, to deploy this example you must explicitly pass `--capabilities CAPABILITY_IAM` to the `sam deploy` command.
* **Save arguments to samconfig.toml**: If set to yes, your choices will be saved to a configuration file inside the project, so that in the future you can just re-run `sam deploy` without parameters to deploy changes to your application.

## Use the SAM CLI to build and test locally

Build your application with the `sam build --use-container` command.

```bash
usaid_bia_v2$ sam build --use-container
```

The SAM CLI installs dependencies defined in `hello_world/requirements.txt`, creates a deployment package, and saves it in the `.aws-sam/build` folder.

Test a single function by invoking it directly with a test event. An event is a JSON document that represents the input that the function receives from the event source. Test events are included in the `events` folder in this project.

Run functions locally and invoke them with the `sam local invoke` command.

```bash
usaid_bia_v2$ sam local invoke HelloWorldFunction --event events/event.json
```

The SAM CLI can also emulate your application's API. Use the `sam local start-api` to run the API locally on port 3000.

```bash
usaid_bia_v2$ sam local start-api
usaid_bia_v2$ curl http://localhost:3000/
```

The SAM CLI reads the application template to determine the API's routes and the functions that they invoke. The `Events` property on each function's definition includes the route and method for each path.

```yaml
      Events:
        HelloWorld:
          Type: Api
          Properties:
            Path: /hello
            Method: get
```

## Add a resource to your application
The application template uses AWS Serverless Application Model (AWS SAM) to define application resources. AWS SAM is an extension of AWS CloudFormation with a simpler syntax for configuring common serverless application resources such as functions, triggers, and APIs. For resources not included in [the SAM specification](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md), you can use standard [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html) resource types.

## Fetch, tail, and filter Lambda function logs

To simplify troubleshooting, SAM CLI has a command called `sam logs`. `sam logs` lets you fetch logs generated by your deployed Lambda function from the command line. In addition to printing the logs on the terminal, this command has several nifty features to help you quickly find the bug.

`NOTE`: This command works for all AWS Lambda functions; not just the ones you deploy using SAM.

```bash
usaid_bia_v2$ sam logs -n HelloWorldFunction --stack-name usaid_bia_v2 --tail
```

You can find more information and examples about filtering Lambda function logs in the [SAM CLI Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-logging.html).

## Unit tests

Tests are defined in the `tests` folder in this project. Use PIP to install the [pytest](https://docs.pytest.org/en/latest/) and run unit tests.

```bash
usaid_bia_v2$ pip install pytest pytest-mock --user
usaid_bia_v2$ python -m pytest tests/ -v
```

## Cleanup

To delete the sample application that you created, use the AWS CLI. Assuming you used your project name for the stack name, you can run the following:

```bash
aws cloudformation delete-stack --stack-name usaid_bia_v2
```

## Resources

See the [AWS SAM developer guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) for an introduction to SAM specification, the SAM CLI, and serverless application concepts.

Next, you can use AWS Serverless Application Repository to deploy ready to use Apps that go beyond hello world samples and learn how authors developed their applications: [AWS Serverless Application Repository main page](https://aws.amazon.com/serverless/serverlessrepo/)
