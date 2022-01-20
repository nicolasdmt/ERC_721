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

    await evaluator.ex2a_getAnimalToCreateAttributes();

    const sex = await evaluator.readSex(accounts[0]);
	const legs = await evaluator.readLegs(accounts[0]);
	const wings = await evaluator.readWings(accounts[0]);
	const name = await evaluator.readName(accounts[0]);

    await ourToken.declareAnimal(sex, legs, wings, name);
    const num = await MyERC721.lastMintedToken();
	await ourToken.transferFrom(accounts[0], Evaluator.address, num);
	await Evaluator.ex2b_testDeclaredAnimal(num);
}