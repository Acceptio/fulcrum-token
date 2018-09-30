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
      let expectedMaxSupply = 400 * million;
      let expectedInitialSupply = 150 * million;

      assert(await token.owner() === owner);
      assert(await token.released() === false);
      assert((await token.decimals()).toNumber() === 18);
      assert(await token.name() === 'Fulcrum Token');
      assert(await token.symbol() === 'FULC');
      assert(await token.admins(owner));
      assert((await token.numberOfAdmins()).toNumber() === 1);

      (await token.MAX_SUPPLY()).should.bignumber.equal(ether(expectedMaxSupply));
      (await token.totalSupply()).should.bignumber.equal(ether(expectedInitialSupply));
      (await token.balanceOf(owner)).should.bignumber.equal(ether(expectedInitialSupply));

      assert((await token.ICOEndDate()).toNumber() === 0);
    });
  });

  describe('ICO End Ruleset', () => {
    let token;

    beforeEach(async () => {
      token = await Token.new();
    });

    it('must properly set the ICO end date.', async () => {
      let currentTime = await latestTime();
      const ICOEndDate = currentTime + duration.weeks(1);

      await token.setICOEndDate(ICOEndDate);
      assert((await token.ICOEndDate()).toNumber() === ICOEndDate);
    });

    it('must not allow non admins to set the ICO end date.', async () => {
      let currentTime = await latestTime();
      const ICOEndDate = currentTime + duration.weeks(1);

      await token.setICOEndDate(ICOEndDate, { from: accounts[1] }).should.be.rejectedWith(EVMRevert);
    });

    it('must not allow ICO end date to be set more than once.', async () => {
      let currentTime = await latestTime();
      const ICOEndDate = currentTime + duration.weeks(1);

      await token.setICOEndDate(ICOEndDate);
      await token.setICOEndDate(ICOEndDate).should.be.rejectedWith(EVMRevert)
    });

    it('must ensure that ICO end date is a future date.', async () => {
      let currentTime = await latestTime();
      await token.setICOEndDate(currentTime).should.be.rejectedWith(EVMRevert)
    });
  });
});
