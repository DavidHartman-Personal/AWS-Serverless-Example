import json

# import requests


def lambda_handler(event, context):
    print(event)
    # bucket = event['Records'][0]['s3']['bucket']['name']
    # ey = event['Records'][0]['s3']['object']['key']
    print("Included FunctionName")
    return event

