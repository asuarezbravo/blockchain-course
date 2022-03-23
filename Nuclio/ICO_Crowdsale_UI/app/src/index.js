import Web3 from "web3";
import crodwsaleArtifact from "../../build/contracts/Crowdsale.json";

const App = {
  web3: null,
  account: null,
  crodwsale: null,

  start: async function() {
    const { web3 } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = crodwsaleArtifact.networks[networkId];
      this.crodwsale = new web3.eth.Contract(
        crodwsaleArtifact.abi,
        deployedNetwork.address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];

      this.refreshFields();
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

  refreshFields: async function() {
    const { tokensSold, etherRaised, icoEndTime, token } = this.crodwsale.methods;
    const tokens = await tokensSold().call();
    const ether = await etherRaised().call();
    const endtime = await icoEndTime().call();
    const tokenContract = await token().call();

    const tokensElement = document.getElementsByClassName("tokens")[0];
    balanceElement.innerHTML = tokens;
    const etherElement = document.getElementsByClassName("ether")[0];
    etherElement.innerHTML = ether;
    // const supplyElement = document.getElementsByClassName("supply")[0];
    // supplyElement.innerHTML = supply;
    const endtimeElement = document.getElementsByClassName("endtime")[0];
    endtimeElement.innerHTML = endtime;
    const tokensPercentageElement = document.getElementsByClassName("tokensPercentage")[0];
    tokensPercentageElement.innerHTML = tokensElement;
  },

  sendCoin: async function() {
    const amount = parseInt(document.getElementById("amount").value);
    const receiver = document.getElementById("receiver").value;

    this.setStatus("Initiating transaction... (please wait)");

    const { sendCoin } = this.meta.methods;
    await sendCoin(receiver, amount).send({ from: this.account });

    this.setStatus("Transaction complete!");
    this.refreshBalance();
  },
};

window.App = App;

window.addEventListener("load", function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live",
    );
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
    );
  }

  App.start();
});
