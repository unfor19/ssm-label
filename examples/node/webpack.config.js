const path = require('path');
const nodeExternals = require('webpack-node-externals');
module.exports = {
    target: 'node',
    externals: [nodeExternals()],
    entry: './index.ts',
    node: {
        __filename: true,
        __dirname: true,
    },
    resolve: {
        extensions: ['.ts'],
        alias: {
            src: path.resolve('./'),
        },
    },
    // devtool: 'source-map',
    module: {
        rules: [
            {
                test: /\.(ts)$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                },
            },
        ],
    },
    output: {
        filename: 'index.js',
        path: path.resolve(__dirname, './'),
        libraryTarget: 'commonjs',
    },
};
