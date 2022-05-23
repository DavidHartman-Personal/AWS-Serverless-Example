# AWS Serverless Reference and Examples

Prototype options and related tags

Tag - BASE_AWS_SERVERLESS_FUNCTION: A functional base sam template, code and resources to create a lambda function

- [x] Create base lambda serverless function. Tag: BASE_AWS_SERVERLESS_FUNCTION
- [ ] Create Application Layer with resuable function

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


## Lambda Function CloudFormation/SAM [Lambda Function CloudFormation/SAM Definition]

```yaml
  FilePostingBroker:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: file_posting_broker
      Handler: lambda_function.lambda_handler
      Runtime: python3.6
      FunctionName: "file_posting_broker"
      Environment:
        Variables:
          ENDPOINT: "rds-postgres-usaid-metadata-read-only.endpoint.proxy-cfydm4e1awn9.us-east-1.rds.amazonaws.com"
          PORT: 5432
          DATABASE: "rds-postgres-usaid-metadata"
          DBUSER: "masteruser"
          DBPASSWORD: "JUz0!'ezTC"
          REGION: "us-east-1"
      VpcConfig:
        SubnetIds:
          - subnet-0cd583612820eeffb
          - subnet-03a5f6308809f73c6
        SecurityGroupIds:
          - sg-01a6866a311ed79a0
      Layers:
        - !Ref UtilitiesLayer

```

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

## Execute Lambda Function

The [execute_lambda.sh](execute_lambda.sh) script will invokde the lambda function and print the results.

## Add Helper Layer and Functions

Steps for creating utilities reusable layer using the SAM cli.

1. Create folder for utilities_layer/
2. Create python/ folder (See Python requirements for Lambda Layers)
3. Create python file(s) (e.g.utility_test.py) source code to utilities_layer/python/ directory
4. Add LayerVerion definition to SAM template.yaml.  Note that the ContentUri is noted as the base folder for the layer definition, with the source code in the python directory below the main folder.
    ```yaml
    UtilitiesLayer:
    Type: AWS::Serverless::LayerVersion
    Properties:
      LayerName: utilities_layer
      ContentUri: utilities_layer/
      CompatibleRuntimes:
        - python3.6
      RetentionPolicy: Retain
    ```
5. Add Layer reference to the SAM template function definition that is using the newly created layer.
   ```yaml
   Layers:
        - !Ref UtilitiesLayer
   ```
6. Run `sam build --use-container` command.
7. Run `sam deploy` command to deploy layer and updated function.
8. In PyCharm, to avoid source code errors, include layer code as a Source in the settings.

To reference the layers functions, an import is needed.  If the source code from the layer is stored in python/utilities_layer.py and
there is a function named test_utilities(), an import as below would be needed.

`import utilities_layer as ul`

To call the function, the souce code would be the following:'
`ul.test_utilities()`

custom_func.py - contains cust_func() function.

import custom_func as cf

Steps for creating utilities reusable layer "manually".

1. Create folder for utilities_layer/
2. Create python/ folder (See Python requirements for Lambda Layers)
3. Add utility_test.py Python source code file to utilities_layer/python/
4. Create zip archive for upload
5. Add LayerVerion definition to SAM template.yaml
    ```yaml
    UtilitiesLayer:
    Type: AWS::Serverless::LayerVersion
    Properties:
      LayerName: helper-layer
      ContentUri: ./helper-layer/python.zip
      CompatibleRuntimes:
        - python3.6
      RetentionPolicy: Retain
    ```
6. Add import statement `from my_common_function import say_hello ` into lambda handler function.

For shared depencencies/libraries:

### For shared libraries

If you want to create a Layer that also embeds dependencies, the AWS SAM template will look like this

```yaml
MyLibLayer:
  Type: AWS::Serverless::LayerVersion
  Properties:
    ContentUri: utilities_layer
    CompatibleRuntimes:
      - python3.6
  Metadata:
    BuildMethod: python3.6
```
The only differences are the Metadata and BuildMethod fields, telling AWS SAM that we want to build our Layer using python 3.8 interpreter

So during the execution of sam build SAM will execute a pip install -r my_lib_layer/requirements.txt -t .aws-sam/build/MyLibLayer downloading our dependencies

This time we can get rid of the python folder but we need to add the requirements.txt

So we would have:
utilities_layer/
  requirements.txt

For PyCharm import error, mark utilities_layer/python directory as source root like we

NOTE: To create layer zip manually, run `python -m pip install -r requirements.txt`

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

[Lambda Function CloudFormation/SAM Definition]: #lambda-function-cloudformationsam-definition

