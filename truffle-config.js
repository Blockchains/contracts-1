module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      network_id: "*"
    }
  },
  compilers: {
    solc: {
      version: "0.6.2",
    },
  },
  plugins: [
    'truffle-contract-size'
  ]
};