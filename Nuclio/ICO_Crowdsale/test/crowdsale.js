const Crowdsale = artifacts.require("Crowdsale");
const ICOToken = artifacts.require("ICOToken");

contract('Crowdsale', (accounts) => {

  it('should create Crowdsale and ICO Token contracts', async () => {
    const crowdsaleInstance = await Crowdsale.deployed();
    const ICOTokenContractAddress = await crowdsaleInstance.token.call();
    const ICOTokenInstance = await ICOToken.at(ICOTokenContractAddress);

    const balance = await ICOTokenInstance.balanceOf.call(crowdsaleInstance.address);

    assert.equal(balance.toNumber(), 100, "100 wasn't in the crowdsale contract");
  });

  it('account 2 buy 10 tokens', async () => {
    const crowdsaleInstance = await Crowdsale.deployed();
    const ICOTokenContractAddress = await crowdsaleInstance.token.call();
    const ICOTokenInstance = await ICOToken.at(ICOTokenContractAddress);

    await crowdsaleInstance.buy({ from: accounts[1], value: 10 ** 18 })
    const balance = await ICOTokenInstance.balanceOf.call(crowdsaleInstance.address);
    assert.equal(balance.toNumber(), 90, "90 wasn't in the crowdsale contract");
    const balance2 = await ICOTokenInstance.balanceOf.call(accounts[1]);
    assert.equal(balance2.toNumber(), 10, "10 wasn't in the account 1");
  });

  it('account 3 buy 90 tokens and end distribution', async () => {
    const crowdsaleInstance = await Crowdsale.deployed();
    const ICOTokenContractAddress = await crowdsaleInstance.token.call();
    const ICOTokenInstance = await ICOToken.at(ICOTokenContractAddress);

    await crowdsaleInstance.buy({ from: accounts[2], value: 9 * 10 ** 18 });
    const balance = await ICOTokenInstance.balanceOf.call(crowdsaleInstance.address);
    assert.equal(balance.toNumber(), 0, "0 wasn't in the crowdsale contract");
    const balance2 = await ICOTokenInstance.balanceOf.call(accounts[2]);
    assert.equal(balance2.toNumber(), 90, "90 wasn't in the account 2");
    const ICOEnded = await crowdsaleInstance.isCompleted.call();
    assert.equal(ICOEnded, true, "ICO has not ended");
  });
  // it('should call a function that depends on a linked library', async () => {
  //   const metaCoinInstance = await MetaCoin.deployed();
  //   const metaCoinBalance = (await metaCoinInstance.getBalance.call(accounts[0])).toNumber();
  //   const metaCoinEthBalance = (await metaCoinInstance.getBalanceInEth.call(accounts[0])).toNumber();

  //   assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, 'Library function returned unexpected function, linkage may be broken');
  // });
  // it('should send coin correctly', async () => {
  //   const metaCoinInstance = await MetaCoin.deployed();

  //   // Setup 2 accounts.
  //   const accountOne = accounts[0];
  //   const accountTwo = accounts[1];

  //   // Get initial balances of first and second account.
  //   const accountOneStartingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
  //   const accountTwoStartingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();

  //   // Make transaction from first account to second.
  //   const amount = 10;
  //   await metaCoinInstance.sendCoin(accountTwo, amount, { from: accountOne });

  //   // Get balances of first and second account after the transactions.
  //   const accountOneEndingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
  //   const accountTwoEndingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();


  //   assert.equal(accountOneEndingBalance, accountOneStartingBalance - amount, "Amount wasn't correctly taken from the sender");
  //   assert.equal(accountTwoEndingBalance, accountTwoStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
  // });
});
