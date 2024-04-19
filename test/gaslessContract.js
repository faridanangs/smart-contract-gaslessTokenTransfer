const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect, assert } = require("chai");
const { boolean } = require("hardhat/internal/core/params/argumentTypes");

describe("Gassles", function () {

  async function deployGasslesToken() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();
    const ownerAddr = owner.address;
    const otherAddr = otherAccount.address;
    const name = "Bitek"
    const symbol = "BTK"
    const decimals = 18

    const Lock = await ethers.getContractFactory("ERC20Permit");
    const lock = await Lock.deploy(name, symbol, decimals);

    return { lock, ownerAddr, otherAddr, name, symbol, decimals };
  }

  it("Check name, symbol and decimal", async () => {
    const { lock, name, symbol, decimals } = await loadFixture(deployGasslesToken);
    expect(await lock.name()).to.equal(name);
    expect(await lock.symbol()).to.equal(symbol);
    expect(await lock.decimals()).to.equal(decimals);

    assert.notEqual(await lock.decimals(), 11);
  })
  it("Check mint and balance of address", async () => {
    const { lock, ownerAddr, otherAddr, name, symbol, decimals } = await loadFixture(deployGasslesToken);
    await lock.mint(ownerAddr, 100);
    assert.equal(await lock.balanceOf(ownerAddr), 100);
  })
  it("Check burn and balance of address", async () => {
    const { lock, ownerAddr, otherAddr, name, symbol, decimals } = await loadFixture(deployGasslesToken);
    await lock.mint(ownerAddr, 100);

    await lock.burn(ownerAddr, 60);
    assert.equal(await lock.balanceOf(ownerAddr), 40);
  })
  it("Check transfer token", async () => {
    const { lock, ownerAddr, otherAddr, name, symbol, decimals } = await loadFixture(deployGasslesToken);
    await lock.mint(ownerAddr, 100);
    await lock.mint(otherAddr, 10);

    await lock.transfer(otherAddr, 10);
    assert.equal(await lock.balanceOf(otherAddr), 20);
    assert.equal(await lock.balanceOf(ownerAddr), 90);
  })
  it("Check approval and transferFrom token", async () => {
    const { lock, ownerAddr, otherAddr, name, symbol, decimals } = await loadFixture(deployGasslesToken);
    await lock.mint(ownerAddr, 100);
    await lock.mint(otherAddr, 50);

    await lock.approve(otherAddr, 50);
    await expect(lock.transferFrom(ownerAddr, otherAddr, 60)).to.be.revertedWith("your amount large then allowed")
    await lock.transferFrom(ownerAddr, otherAddr, 30);

    assert.equal(await lock.allowance(ownerAddr, otherAddr), 20);
    assert.equal(await lock.balanceOf(ownerAddr), 70);
  })
});
