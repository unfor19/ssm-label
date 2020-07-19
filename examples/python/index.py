import sys
import os
import boto3  # noqa: F401
from singleton import Singleton


class Parameters(metaclass=Singleton):
    """The __init__ function is called only once, even you create many instances."""  # noqa: 504

    def get(self):
        return self.parameters

    def __init__(self, parameter_path=""):
        self.parameters_path = parameter_path
        self.parameters = [
            {
                "Name": parameter['Name'],
                "Value": self.handle_stringlist(parameter['Value']),
                "Version": parameter['Version']
            } for parameter in self.get_parameters_by_latest_label(self.parameters_path)  # noqa: 504
        ]

        print(
            f">> [LOG] Used AWS SSM SDK and fetched {len(self.parameters)} parameters")  # noqa: 504

    @staticmethod
    def handle_stringlist(parameter_value):
        delimiter = ","
        if delimiter in parameter_value:
            parameter_value = parameter_value.split(delimiter)
            parameter_value = [val.strip() for val in parameter_value]
        return parameter_value

    def get_parameters_by_latest_label(self, parameters_path):
        recursive = True
        decryption = True
        max_results = 10
        if os.environ.get('PARAMETERS_NON_RECURSIVE'):
            recursive = False
        if os.environ.get('PARAMETERS_NO_DECRYPTION'):
            decryption = False
        if os.environ.get('PARAMETERS_MAX_RESULTS'):
            max_results = int(os.environ.get('PARAMETERS_MAX_RESULTS'))
        if not parameters_path:
            raise Exception("Must provide SSM Parameters path")
        client = boto3.client('ssm')
        parameters = []
        next_tokens = [""]
        parameter_filters = [
            {
                'Key': 'Label',
                'Option': 'Equals',
                'Values': [
                    'latest',
                ]
            },
        ]
        params = {
            "Path": parameters_path,
            "Recursive": recursive,
            "ParameterFilters": parameter_filters,
            "WithDecryption": decryption,
            "MaxResults": max_results,
        }
        for next_token in next_tokens:
            if next_token:
                params['NextToken'] = next_token
            response = client.get_parameters_by_path(**params)
            parameters += response['Parameters']
            if 'NextToken' in response:
                next_tokens.append(response['NextToken'])
            else:
                break

        return parameters


def other_function():
    p2 = Parameters().get()
    return p2


if __name__ == "__main__":
    if len(sys.argv) == 2:
        parameter_path = sys.argv[1]
    elif os.environ.get('PARAMETERS_PATH'):
        parameter_path = os.environ.get('PARAMETERS_PATH')
    else:
        raise Exception(
            ">> [ERROR]: Must set PARAMETERS_PATH environment variable")

    p1 = Parameters(parameter_path).get()  # // fetching from AWS
    print(f"\np1\n{p1}\n")
    p2 = other_function()  # already fetched from AWS
    print(f"p2\n{p2}\n")
