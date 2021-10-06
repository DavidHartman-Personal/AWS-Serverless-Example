import json

# import requests


def lambda_handler(event, context):
    print(event)
    # bucket = event['Records'][0]['s3']['bucket']['name']
    # ey = event['Records'][0]['s3']['object']['key']
    print("Base Lambda Function managed in git repo")
    return event

