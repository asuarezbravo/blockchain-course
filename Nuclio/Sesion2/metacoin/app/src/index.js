import Web3 from "web3";
import metaCoinArtifact from "../../build/contracts/MetaCoin.json";

const App = {
    web3: null,
    account: null,
    meta: null,

    start: async function () {
        const {
            web3
        } = this;

        try {
            // get contract instance
            const networkId = await web3.eth.net.getId();
            const deployedNetwork = metaCoinArtifact.networks[networkId];
            this.meta = new web3.eth.Contract(
                metaCoinArtifact.abi,
                deployedNetwork.address,
            );

            // get accounts
            const accounts = await web3.eth.getAccounts();
            this.account = accounts[0];

            // refresh balance
            this.refreshBalance();
        } catch (error) {
            console.error("Could not connect to contract or chain.");
        }
    },

    refreshBalance: async function () {
        const {
            getBalance
        } = this.meta.methods;
        const balance = await getBalance(this.account).call();

        const balanceElement = document.getElementsByClassName("balance")[0];
        balanceElement.innerHTML = balance;
    },

    sendCoin: async function () {
        // get amount and receiver
        const amount = parseInt(document.getElementById("amount").value);
        const receiver = document.getElementById("receiver").value;

        // change status
        this.setStatus("Initiating transaction... (please wait)");

        // sendcoin
        const {
            sendCoin
        } = this.meta.methods;
        await sendCoin(receiver, amount).send({
            from: this.account
        });

        // change status
        this.setStatus("Transaction complete!");

        // refresh balance
        this.refreshBalance();
    },

    setStatus: function (message) {
        const status = document.getElementById("status");
        status.innerHTML = message;
    },
};

window.App = App;

window.addEventListener("load", function () {


    // set ethereum provider
    if (window.ethereum) {
        App.web3 = new Web3(window.ethereum);
        window.ethereum.enable();
    } else {
        App.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));
    }

    App.start();
});