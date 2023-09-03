const config = {
  comments: false,
  presets: [
    '@babel/preset-typescript',
    [
      '@babel/preset-env',
      {
        targets: {
          node: '18'
        }
      }
    ]
  ],
  plugins: [],
  ignore: [/node_modules/]
};

module.exports = config;
