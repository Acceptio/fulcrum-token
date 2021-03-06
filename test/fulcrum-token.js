const Token = artifacts.require('./FulcrumToken.sol');
const BigNumber = require('bignumber.js');
const EVMRevert = require('./helpers/EVMRevert').EVMRevert;
const ether = require('./helpers/ether').ether;
const latestTime = require('./helpers/latestTime').latestTime;
const increaseTime = require('./helpers/increaseTime');
const increaseTimeTo = increaseTime.increaseTimeTo;
const duration = increaseTime.duration;
const million = 1000000;
const icoEndsOn = duration.days(90) + Math.floor((new Date()).getTime() / 1000);

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('FulcrumToken', function (accounts) {
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

      await token.setICOEndDate(icoEndDate, {
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);
    });

    it('must not allow ICO end date to be set more than once.', async () => {
      let currentTime = await latestTime();
      const icoEndDate = currentTime + duration.weeks(1);

      await token.setICOEndDate(icoEndDate);
      await token.setICOEndDate(icoEndDate).should.be.rejectedWith(EVMRevert)
    });
  });

  describe('Non locked minting feature ruleset', async () => {
    let token;

    beforeEach(async () => {
      token = await Token.new();
    });

    it('must correctly mint community rewards tokens only once and only if the ICO is successful.', async () => {
      const totalSupply = await token.totalSupply();
      const communityRewardsTokenCount = ether(15 * million);

      /*-------------------------------------------------------------
       SHOULD NOT ALLOW MINTING BEFORE THE ICO STATE IS SET AS "SUCCESSFUL"
      -------------------------------------------------------------*/
      await token.addAdmin(accounts[1]);

      await token.mintCommunityRewardTokens({
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);

      /*-------------------------------------------------------------
       SHOULD ALLOW MINTING ONLY WHEN THE ICO STATE IS SET AS SUCCESSFUL
      -------------------------------------------------------------*/
      await token.setSuccess({
        from: accounts[1]
      });
      await token.mintCommunityRewardTokens({
        from: accounts[1]
      });

      const balance = await token.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(communityRewardsTokenCount);

      (await token.totalSupply()).should.be.bignumber.equal(totalSupply.add(communityRewardsTokenCount));

      /*-------------------------------------------------------------
       ADDITIONAL CORRECTNESS RULE(S) 
      -------------------------------------------------------------*/

      //additional minting attempts of community reward tokens should be declined.
      await token.mintCommunityRewardTokens({
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);
    });

    it('must correctly mint initial strategic partnership tokens only once and only if the ICO is successful.', async () => {
      const totalSupply = await token.totalSupply();
      const initialStrategicPartnershipTokenCount = ether(10 * million);

      /*-------------------------------------------------------------
       SHOULD NOT ALLOW MINTING BEFORE THE ICO STATE IS SET AS "SUCCESSFUL"
      -------------------------------------------------------------*/
      await token.addAdmin(accounts[1]);

      await token.mintTokensForInitialStrategicPartnerships({
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);

      /*-------------------------------------------------------------
       SHOULD ALLOW MINTING ONLY WHEN THE ICO STATE IS SET AS SUCCESSFUL
      -------------------------------------------------------------*/
      await token.setSuccess({
        from: accounts[1]
      });
      await token.mintTokensForInitialStrategicPartnerships({
        from: accounts[1]
      });

      const balance = await token.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(initialStrategicPartnershipTokenCount);

      (await token.totalSupply()).should.be.bignumber.equal(totalSupply.add(initialStrategicPartnershipTokenCount));

      /*-------------------------------------------------------------
       ADDITIONAL CORRECTNESS RULE(S) 
      -------------------------------------------------------------*/

      //additional minting attempts of community reward tokens should be declined.
      await token.mintTokensForInitialStrategicPartnerships({
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);
    });
  });

  describe('Locked minting feature ruleset', async () => {
    let token;

    beforeEach(async () => {
      token = await Token.new();
    });

    it('must not allow minting of advisory tokens before the specified date.', async () => {
      await token.addAdmin(accounts[1]);
      await token.setSuccess();

      await token.mintTokensForAdvisors({
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);
    });

    it('must allow minting of advisory tokens only once after 18 months from the ICO end date.', async () => {
      const totalSupply = await token.totalSupply();
      var balance = 0;

      const advisoryTokenCount = ether(8 * million);

      await token.addAdmin(accounts[1]);

      await token.setICOEndDate(icoEndsOn);
      await token.setSuccess();

      const endDate = (await token.icoEndDate()).toNumber();
      assert.equal(icoEndsOn, endDate);

      //Need to increase the EVM time after the lockup period.
      await increaseTimeTo(endDate + duration.days(365) + duration.seconds(1));

      /*-------------------------------------------------------------
       ADVISORY TOKEN MINTING
      -------------------------------------------------------------*/

      await token.mintTokensForAdvisors({
        from: accounts[1]
      });

      balance = await token.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(advisoryTokenCount);

      (await token.totalSupply()).should.be.bignumber.equal(totalSupply.add(advisoryTokenCount));

      /*-------------------------------------------------------------
       ADDITIONAL CORRECTNESS RULES
      -------------------------------------------------------------*/

      await token.mintTokensForAdvisors().should.be.rejectedWith(EVMRevert);
    });

    it('must not allow minting of reserve tokens before the specified date.', async () => {
      await token.addAdmin(accounts[1]);
      await token.setSuccess();

      await token.mintReserveTokens({
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);
    });

    it('must allow minting of reserve tokens only once after 18 months from the ICO end date.', async () => {
      const totalSupply = await token.totalSupply();
      var balance = 0;

      const reserveTokenCount = ether(17 * million);

      await token.addAdmin(accounts[1]);

      await token.setICOEndDate(icoEndsOn);
      await token.setSuccess();

      const endDate = (await token.icoEndDate()).toNumber();
      assert.equal(icoEndsOn, endDate);

      //Need to increase the EVM time after the lockup period.
      await increaseTimeTo(endDate + duration.days(548) + duration.seconds(1));

      /*-------------------------------------------------------------
       RESERVE TOKEN MINTING
      -------------------------------------------------------------*/

      await token.mintReserveTokens({
        from: accounts[1]
      });

      balance = await token.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(reserveTokenCount);

      (await token.totalSupply()).should.be.bignumber.equal(totalSupply.add(reserveTokenCount));

      /*-------------------------------------------------------------
       ADDITIONAL CORRECTNESS RULES
      -------------------------------------------------------------*/

      await token.mintReserveTokens().should.be.rejectedWith(EVMRevert);
    });

    it('must not allow minting of team tokens before the specified date.', async () => {
      await token.addAdmin(accounts[1]);
      await token.setSuccess();

      await token.mintTokensForTeam({
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);
    });

    it('must allow minting of team tokens only once after 2 years from the ICO end date.', async () => {
      const totalSupply = await token.totalSupply();
      var balance = 0;

      const teamTokenCount = ether(40 * million);

      await token.addAdmin(accounts[1]);
      await token.setICOEndDate(icoEndsOn);
      await token.setSuccess();

      const endDate = (await token.icoEndDate()).toNumber();

      //Need to increase the EVM time after the lockup period.
      await increaseTimeTo(endDate + duration.days(730) + duration.seconds(1));

      /*-------------------------------------------------------------
       TEAM TOKEN MINTING
      -------------------------------------------------------------*/

      await token.mintTokensForTeam({
        from: accounts[1]
      });

      balance = await token.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(teamTokenCount);

      (await token.totalSupply()).should.be.bignumber.equal(totalSupply.add(teamTokenCount));

      /*-------------------------------------------------------------
       ADDITIONAL CORRECTNESS RULES
      -------------------------------------------------------------*/

      await token.mintTokensForTeam().should.be.rejectedWith(EVMRevert);
    });

    it('must not allow minting of strategic partnership tokens before the specified date.', async () => {
      await token.addAdmin(accounts[1]);
      await token.setSuccess();

      await token.mintTokensForStrategicPartnerships({
        from: accounts[1]
      }).should.be.rejectedWith(EVMRevert);
    });

    it('must allow minting of strategic partnership tokens only once after 2 years from the ICO end date.', async () => {
      const totalSupply = await token.totalSupply();
      var balance = 0;

      const strategicPartnershipTokenCount = ether(10 * million);

      await token.addAdmin(accounts[1]);
      await token.setICOEndDate(icoEndsOn);
      await token.setSuccess();

      const endDate = (await token.icoEndDate()).toNumber();

      //Need to increase the EVM time after the lockup period.
      await increaseTimeTo(endDate + duration.days(730) + duration.minutes(2));

      /*-------------------------------------------------------------
       STRATEGIC PARTNERSHIP TOKEN MINTING
      -------------------------------------------------------------*/

      await token.mintTokensForStrategicPartnerships({
        from: accounts[1]
      });

      balance = await token.balanceOf(accounts[1]);
      balance.should.be.bignumber.equal(strategicPartnershipTokenCount);

      (await token.totalSupply()).should.be.bignumber.equal(totalSupply.add(strategicPartnershipTokenCount));

      /*-------------------------------------------------------------
       ADDITIONAL CORRECTNESS RULES
      -------------------------------------------------------------*/

      await token.mintTokensForStrategicPartnerships().should.be.rejectedWith(EVMRevert);
    });

    it('must exactly match the set maximum supply after all minting is performed.', async () => {
      const MAX_SUPPLY = await token.MAX_SUPPLY();

      await token.setICOEndDate(icoEndsOn);
      await token.setSuccess();

      //The EVM time is already increased to a date after the lockup period.
      // const endDate = (await token.icoEndDate()).toNumber();
      // await increaseTimeTo(endDate + duration.days(365) + duration.seconds(2));

      await token.mintCommunityRewardTokens({
        from: accounts[0]
      });
      await token.mintReserveTokens({
        from: accounts[0]
      });
      await token.mintTokensForTeam({
        from: accounts[0]
      });
      await token.mintTokensForAdvisors({
        from: accounts[0]
      });
      await token.mintTokensForInitialStrategicPartnerships({
        from: accounts[0]
      });

      let totalSupply = await token.totalSupply();
      totalSupply.should.not.be.bignumber.equal(MAX_SUPPLY);

      (await token.balanceOf(accounts[0])).should.not.be.bignumber.equal(MAX_SUPPLY);

      /*-------------------------------------------------------------
       STRATEGIC PARTNERSHIP TOKEN MINTING ISN'T MINTED YET
      -------------------------------------------------------------*/

      await token.mintTokensForStrategicPartnerships({
        from: accounts[0]
      });

      totalSupply = await token.totalSupply();
      totalSupply.should.be.bignumber.equal(MAX_SUPPLY);

      (await token.balanceOf(accounts[0])).should.be.bignumber.equal(MAX_SUPPLY);
    });
  });
});
