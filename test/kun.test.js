var KUN = artifacts.require("KUN");

contract("kun test", async function (accounts, network) {
    before(async function () {
        this.account0 = accounts[0];
        this.account1 = accounts[1];
        this.account2 = accounts[2];
        this.account3 = accounts[3];

        console.log("account0: ", this.account0);
        console.log("account1: ", this.account1);
        console.log("account2: ", this.account2);
        console.log("account3: ", this.account3);

        this.kun = await KUN.deployed();
        
        this.kun.addMinter(this.account1, web3.utils.toWei("10000"), {from: this.account0 });
        this.kun.addMinter(this.account2, web3.utils.toWei("20000"), {from: this.account0 });

        var mintAllowances1 = await this.kun.mintAllowances(this.account1);
        var mintAllowances2 = await this.kun.mintAllowances(this.account2);

        assert.equal(mintAllowances1, web3.utils.toWei("10000"));
        assert.equal(mintAllowances2, web3.utils.toWei("20000"));
    });

    afterEach(async function () {
    });

    beforeEach(async function () {
    });

    it("KUN.mint", async function () {
        await this.kun.mint(this.account3, web3.utils.toWei("5000"), {from: this.account1 });
        await this.kun.mint(this.account3, web3.utils.toWei("5000"), {from: this.account1 });
        
        var mintAllowances1 = await this.kun.mintAllowances(this.account1);
        assert.equal(mintAllowances1, web3.utils.toWei("0"));

        var balanceOf3 = await this.kun.balanceOf(this.account3);
        assert.equal(balanceOf3, web3.utils.toWei("10000"));

        // await this.kun.mint(this.account3, web3.utils.toWei("5000"), {from: this.account1 });
    });

    it("KUN.increaseMintAllowance/.decreaseMintAllowance", async function () {
        await this.kun.increaseMintAllowance(this.account1, web3.utils.toWei("5000"));

        var mintAllowances1 = await this.kun.mintAllowances(this.account1);
        assert.equal(mintAllowances1, web3.utils.toWei("5000"));

        await this.kun.decreaseMintAllowance(this.account1, web3.utils.toWei("5000"));

        var mintAllowances1 = await this.kun.mintAllowances(this.account1);
        assert.equal(mintAllowances1, web3.utils.toWei("0"));
    });


    it("KUN.removeMinter", async function () {
        await this.kun.increaseMintAllowance(this.account1, web3.utils.toWei("5000"));
        
        var isMinter = await this.kun.isMinter(this.account1);
        assert.equal(isMinter, true);

        var mintAllowances1 = await this.kun.mintAllowances(this.account1);
        assert.equal(mintAllowances1, web3.utils.toWei("5000"));

        await this.kun.removeMinter(this.account1);

        var mintAllowances1 = await this.kun.mintAllowances(this.account1);
        assert.equal(mintAllowances1, web3.utils.toWei("0"));

        var isMinter = await this.kun.isMinter(this.account1);
        assert.equal(isMinter, false);
    });

});
