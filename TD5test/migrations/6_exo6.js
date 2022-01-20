const Str = require('@supercharge/strings')

var token = artifacts.require("ourERC721.sol");
var evaluatorContract = artifacts.require("Evaluator.sol");

module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        await createToken(deployer,network,accounts);
        await exo1(deployer, network, accounts); 
    });
};


async function createToken(deployer, network, accounts) {
    ourToken = await token.new();
}


async function exo1(deployer, network, accounts) {
    evaluator = await evaluatorContract.at('0xa0b9f62A0dC5cCc21cfB71BA70070C3E1C66510E');

    await evaluator.submitExercice(ourToken.address);

    await Evaluator.ex6a_auctionAnimal_offer();

    await ourToken.declareAnimal(0, 100000, 1, "bete");
	const num = await MyERC721.lastMintedToken();
	await ourToken.offerForSale(num, 1000000000000000)

	await Evaluator.ex6b_auctionAnimal_buy(num);
}


