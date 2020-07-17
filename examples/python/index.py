import sys
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
            f"Used AWS SSM SDK and fetched {len(self.parameters)} parameters")  # noqa: 504

    @staticmethod
    def handle_stringlist(parameter_value):
        delimiter = ","
        if delimiter in parameter_value:
            parameter_value = parameter_value.split(delimiter)
            parameter_value = [val.strip() for val in parameter_value]
        return parameter_value

    def get_parameters_by_latest_label(self, parameters_path):
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
        for next_token in next_tokens:
            if not next_token:
                response = client.get_parameters_by_path(
                    Path=parameters_path,
                    Recursive=True,
                    ParameterFilters=parameter_filters,
                    WithDecryption=True,
                    MaxResults=10,
                )
            else:
                response = client.get_parameters_by_path(
                    Path=parameters_path,
                    Recursive=True,
                    ParameterFilters=parameter_filters,
                    WithDecryption=True,
                    MaxResults=10,
                    NextToken=next_token
                )

            parameters += response['Parameters']
            if 'NextToken' in response:
                next_tokens.append(response['NextToken'])
            else:
                break

        return parameters


def other_function():
    p2 = Parameters().get()  # doesn't use AWS API
    return p2


if __name__ == "__main__":
    if len(sys.argv) <= 1:
        raise Exception("Must provide SSM Parameters path")
    parameter_path = sys.argv[1]
    p1 = Parameters(parameter_path).get()  # first time, uses AWS API
    print(f"\np1\n{p1}\n")
    p2 = other_function()
    print(f"p2\n{p2}\n")
