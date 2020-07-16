import boto3  # noqa: F401
import os


def get_previous_version(parameter_history, label_latest):
    for parameter in parameter_history['Parameters']:
        if label_latest in parameter['Labels']:
            return parameter['Version']
    return False


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
    LABEL_PREVIOUS = os.environ.get('LABEL_PREVIOUS')
    LABEL_PREVIOUS = LABEL_PREVIOUS if LABEL_PREVIOUS else 'previous'

    # Set label - previous
    parameter_history = client.get_parameter_history(
        Name=event['detail']['name'], WithDecryption=False
    )

    previous_parameter_version = get_previous_version(
        parameter_history, LABEL_LATEST
    )

    if previous_parameter_version:
        client.label_parameter_version(
            Name=event['detail']['name'],
            ParameterVersion=previous_parameter_version,
            Labels=[LABEL_PREVIOUS]
        )

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
