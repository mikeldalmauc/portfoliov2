const path = require('path');

module.exports = {
    entry: './src/js/canvas.js',
    mode: 'production',
    output: {
        filename: 'canvas.js',
        path: path.resolve(__dirname, 'build'),
    },
    module: {
        rules: [
            {   
                test: /\.(png|svg|jpg|jpeg|gif)$/i,
                type: 'asset/resource',
                // use: [
                //     {
                //       loader: 'file-loader',
                //       options: {
                //         outputPath: 'assets/scene',
                //       },
                //     },
                // ],
            },  
        ],
    },
};