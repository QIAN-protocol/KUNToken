var { deployProxy, admin } = require("@openzeppelin/truffle-upgrades");

var KUN = artifacts.require("KUN");
var Msign = artifacts.require("Msign");

var path = require("path");
var fs = require("fs-extra");

module.exports = async function (deployer, network) {
    network = /([a-z]+)(-fork)?/.exec(network)[1];

    var deployenv = require(path.join(
        path.dirname(__dirname),
        "deployenv-" + network + ".json"
    ));

    await deployer.deploy(
        Msign,
        deployenv.msign.threshold,
        deployenv.msign.signers
    );

    var token = await deployProxy(KUN, [deployenv.deployer], {
        deployer: deployer,
        unsafeAllowCustomTypes: true,
    });

    await token.addAdmin(Msign.address);
    await admin.transferProxyAdminOwnership(Msign.address);

    fs.outputFileSync(
        path.join(
            path.dirname(__dirname),
            "output",
            "addresses." + network + ".json"
        ),
        JSON.stringify({ Msign: Msign.address, KUNProxy: KUN.address }, null, 4)
    );
};
