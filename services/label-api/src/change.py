import boto3  # noqa: F401
import os


def handler(event, context):
    DEBUG = os.environ.get('DEBUG')
    if DEBUG:
        print(event)
    if event['detail']['operation'] == 'LabelParameterVersion':
        print("Ignoring LabelParameterVersion to avoid recursion")
        return False

    client = boto3.client('ssm')

    LABEL_LATEST = os.environ.get('LABEL_LATEST')
    LABEL_LATEST = LABEL_LATEST if LABEL_LATEST else 'latest'

    # Set label - latest
    changed_parameter = client.get_parameter(
        Name=event['detail']['name'], WithDecryption=False
    )
    client.label_parameter_version(
        Name=event['detail']['name'],
        ParameterVersion=changed_parameter['Parameter']['Version'],
        Labels=[LABEL_LATEST]
    )

    return True
