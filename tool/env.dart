
main() {
  const bool isProduction = bool.fromEnvironment('dart.vm.product');

  print(isProduction);

  const testConfig = {
    'baseUrl': 'some-url.test',
    'credentials': '', //This should not be defined here!
  };

  const productionConfig = {
    'baseUrl': 'some-url.com',
    'credentials': '', //This should not be defined here!
  };

  const environment = isProduction ? productionConfig : testConfig;
}