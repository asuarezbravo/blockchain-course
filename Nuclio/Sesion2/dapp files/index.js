import Web3 from "web3";
import metaCoinArtifact from "../../build/contracts/MetaCoin.json";

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async function () {
    const { web3 } = this;

    try {
      // get contract instance

      // get accounts

      // refresh balance

    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  refreshBalance: async function () {
  },

  sendCoin: async function () {
    // get amount and receiver

    // change status
    this.setStatus("Initiating transaction... (please wait)");

    // sendcoin

    // change status
    this.setStatus("Transaction complete!");

    // refresh balance
  },

  setStatus: function (message) {
    const status = document.getElementById("status");
    status.innerHTML = message;
  },
};

window.App = App;

window.addEventListener("load", function () {


  // set ethereum provider

  App.start();
});
