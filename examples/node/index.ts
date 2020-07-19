import { SSM } from 'aws-sdk';
const ssm = new SSM();

const getPaginatedResults = async (fn: Function) => {
    // Reference: https://advancedweb.hu/how-to-paginate-the-aws-js-sdk-using-async-generators/
    const EMPTY = Symbol('empty');
    const res = [];
    for await (const lf of (async function*() {
        let NextMarker = EMPTY;
        while (NextMarker || NextMarker === EMPTY) {
            const { marker, results } = await fn(NextMarker !== EMPTY ? NextMarker : undefined);

            yield* results;
            NextMarker = marker;
        }
    })()) {
        res.push(lf);
    }

    return res;
};

class Parameters {
    // Reference: https://refactoring.guru/design-patterns/Parameters/typescript/example
    private static instance: Parameters;
    private static parameters: any;
    private parameter_filters: any;

    private constructor() {}

    private static handleStringList(parameter_value: any) {
        let delimiter = ',';
        if (parameter_value.indexOf(delimiter) > -1) {
            parameter_value = parameter_value.split(delimiter);
            parameter_value = parameter_value.map((p: any, i: Number) => {
                return p.trim();
            });
        }
        return parameter_value;
    }

    public static async get(parameter_path?: any): Promise<Parameters> {
        if (!Parameters.instance) {
            Parameters.instance = new Parameters();
            let label_value = process.env.PARAMETERS_LABEL ? process.env.PARAMETERS_LABEL : 'latest';
            let parameter_filters = [
                {
                    Key: 'Label',
                    Option: 'Equals',
                    Values: [label_value],
                },
            ];
            let recursive = process.env.PARAMETERS_NON_RECURSIVE ? false : true;
            let with_decryption = process.env.PARAMETERS_NON_RECURSIVE ? false : true;
            let max_results = process.env.MAX_RESULTS ? parseInt(<string>process.env.MAX_RESULTS, 10) : 10;
            var params: any = {
                Path: parameter_path,
                MaxResults: max_results,
                ParameterFilters: parameter_filters,
                Recursive: recursive,
                WithDecryption: with_decryption,
            };

            // Reference: https://advancedweb.hu/how-to-paginate-the-aws-js-sdk-using-async-generators/
            var parameters = await getPaginatedResults(async (NextMarker: any) => {
                params['NextToken'] = NextMarker;
                var parameters = await ssm.getParametersByPath(params).promise();
                return {
                    marker: parameters.NextToken,
                    results: parameters.Parameters,
                };
            });
            parameters = parameters.map((parameter, i) => {
                return {
                    Name: parameter['Name'],
                    Value: Parameters.handleStringList(parameter['Value']),
                    Version: parameter['Version'],
                };
            });
            console.log(`>> [LOG] Used AWS SSM SDK and fetched ${parameters.length} parameters`);
            Parameters.parameters = parameters;
        }

        return Parameters.parameters;
    }
}

function otherFunction() {
    return Parameters.get();
}

async function main() {
    const parameters_path = process.env.PARAMETERS_PATH;
    if (!parameters_path) {
        console.log('>> [ERROR]: Must set PARAMETERS_PATH environment variable');
        process.exit(1);
    }

    var p1 = await Parameters.get(parameters_path); // fetching from AWS
    console.log(p1);
    var p2 = await otherFunction(); // already fetched from AWS
    console.log(p2);
}

main();
