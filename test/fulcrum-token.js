const Token = artifacts.require('./FulcrumToken.sol');
const BigNumber = require('bignumber.js');
const EVMRevert = require('./helpers/EVMRevert').EVMRevert;
const ether = require('./helpers/ether').ether;
const latestTime  = require('./helpers/latestTime').latestTime;
const increaseTime = require('./helpers/increaseTime');
const increaseTimeTo = increaseTime.increaseTimeTo;
const duration = increaseTime.duration;
const million = 1000000;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('FulcrumToken', function(accounts) {
  describe('Token Creation Ruleset', () => {
    it('must correctly deploy with correct parameters and state variables.', async () => {
      let token = await Token.new();
      let owner = accounts[0];
      let expectedMaxSupply = 200 * million;
      let expectedInitialSupply = 100 * million;

      assert.equal(await token.owner(), owner);
      assert.equal(await token.released(), false);
      assert.equal((await token.decimals()).toNumber(), 18);
      assert.equal(await token.name(), 'Fulcrum Token');
      assert.equal(await token.symbol(), 'FULC');

      (await token.MAX_SUPPLY()).should.bignumber.equal(ether(expectedMaxSupply));
      (await token.totalSupply()).should.bignumber.equal(ether(expectedInitialSupply));
      (await token.balanceOf(owner)).should.bignumber.equal(ether(expectedInitialSupply));

      assert.equal((await token.icoEndDate()).toNumber(), 0);
    });
  });

  describe('ICO End Ruleset', () => {
    let token;

    beforeEach(async () => {
      token = await Token.new();
    });

    it('must properly set the ICO end date.', async () => {
      let currentTime = await latestTime();
      const icoEndDate = currentTime + duration.weeks(1);

      await token.setICOEndDate(icoEndDate);
      assert.equal((await token.icoEndDate()).toNumber(), icoEndDate);
    });

    it('must not allow non admins to set the ICO end date.', async () => {
      let currentTime = await latestTime();
      const icoEndDate = currentTime + duration.weeks(1);

      await token.setICOEndDate(icoEndDate, { from: accounts[1] }).should.be.rejectedWith(EVMRevert);
    });

    it('must not allow ICO end date to be set more than once.', async () => {
      let currentTime = await latestTime();
      const icoEndDate = currentTime + duration.weeks(1);

      await token.setICOEndDate(icoEndDate);
      await token.setICOEndDate(icoEndDate).should.be.rejectedWith(EVMRevert)
    });

    it('must ensure that ICO end date is a future date.', async () => {
      let currentTime = await latestTime();
      await token.setICOEndDate(currentTime).should.be.rejectedWith(EVMRevert)
    });
  });
});
