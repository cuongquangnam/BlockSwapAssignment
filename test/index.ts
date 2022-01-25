import {expect} from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

describe("Testing the pool ", function () {
  let owners: any;
  let hardhatPool: any;
  let hardhatToken: any;

  before(async function (){
    owners = await ethers.getSigners();
    const Pool = await ethers.getContractFactory("Pool");
    const Token = await ethers.getContractFactory("DETH");
    hardhatPool = await Pool.deploy("TestPool","TP");
    hardhatToken = Token.attach(await hardhatPool.getDETH());
    // console.log(await hardhatPool.getDETH());

    // mint tokens and send it to the pool
    await hardhatToken.mint(hardhatPool.address, ethers.utils.parseEther("15"));
    const poolBalance = await hardhatToken.balanceOf(hardhatPool.address);
    await expect(poolBalance).to.equal(ethers.utils.parseEther("15"));
  });
  
  it("Test burnVoucher()", async function () {
    // mint a voucher with a duration of 3 months
    await hardhatPool.mintVoucher(owners[0].address, 0, {value: ethers.utils.parseEther("1")});
    const voucher = await hardhatPool.getVoucher(0);
    expect(voucher[1]).to.equal(BigNumber.from("10").pow(18).mul(1));

    // increase the time by 91 days so as to be able to burn the voucher
    await ethers.provider.send("evm_increaseTime", [91 * 24 * 60 * 60]);
    await hardhatPool.burnVoucher(0);
    const firstAddressBalance = await hardhatToken.balanceOf(owners[0].address);
    const poolBalance = await hardhatToken.balanceOf(hardhatPool.address);

    await expect(firstAddressBalance).to.equal(ethers.utils.parseEther("1.1"));
    await expect(poolBalance).to.equal(ethers.utils.parseEther("13.9"));
  });



  it("Test burnVoucherTo()", async function() {
      // mint a voucher with a duration of 12 months
      await hardhatPool.mintVoucher(owners[0].address, 1, {value: ethers.utils.parseEther("1")});
      const voucher = await hardhatPool.getVoucher(1);
      await expect(voucher[1]).to.equal(BigNumber.from("10").pow(18).mul(1));
  
      // increase the time by 361 days so as to be able to burn the voucher
      await ethers.provider.send("evm_increaseTime", [361 * 24 * 60 * 60]);
      await hardhatPool.burnVoucherTo(owners[1].address,1);
      const secondAddressBalance = await hardhatToken.balanceOf(owners[1].address);
      const poolBalance = await hardhatToken.balanceOf(hardhatPool.address);
  
      await expect(secondAddressBalance).to.equal(ethers.utils.parseEther("1.15"));
      await expect(poolBalance).to.equal(ethers.utils.parseEther("12.75"));
  });
})
