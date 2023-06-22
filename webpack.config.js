const path = require('path');

module.exports = {
  entry: './src/js/canvas.js',
  mode: 'production',
  output: {
    filename: 'canvas.js',
    path: path.resolve(__dirname, 'build'),
  },
};