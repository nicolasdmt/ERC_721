pragma solidity >=0.6.0;
import "./IExerciceSolution.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract MyERC721 is ERC721
{

	struct Animal {
		uint256 id;
		string name;
		bool wings;
		uint legs; 
		uint sex;
		bool isForSale;
		uint256 price;
		uint256 parent1;
		uint256 parent2;
		bool canReproduce;
		uint256 reproductionPrice;
		address payable authorizedUser;
	}

	uint256 private _tokenNumber;
	uint256 private _priceToBecomeBreeder;
	address private _owner;
	mapping(uint256 => Animal) public _tokens;
	mapping(address => bool) public _breeders;

	modifier onlyBreeder() 
	{
	    require(_breeders[msg.sender], "Only a breeder can call this function.");
	    _;
	}

	modifier onlyOwner() 
	{
	    require(_owner == msg.sender, "Only the contract owner can call this function.");
	    _;
	}

	modifier onlyAnimalOwner(uint256 tokenId) 
	{
	    require(ownerOf(tokenId) == msg.sender, "Only the animal owner can call this function.");
	    _;
	}

	constructor() public ERC721("HEATLES", "HEAT"){
		_tokenNumber = 0;
		_priceToBecomeBreeder = 0.1 ether;
		_owner = msg.sender;
		_breeders[_owner] = true;
	}

	// Breeding function

	function isBreeder(address account) external view returns (bool){
		return _breeders[account];
	}

	function registrationPrice() 
	external 
	view 
	returns (uint256)
	{
		return _priceToBecomeBreeder;
	}

	function registerMeAsBreeder() 
	external
	payable
	{
		require(msg.value == _priceToBecomeBreeder, "Wrong amount to become breeder");
		_breeders[msg.sender] = true;
	}

	function registerExtraBreeder(address breeder)
	external
	onlyOwner
	{
		_breeders[breeder] = true;
	}

	function declareAnimal(uint sex, uint legs, bool wings, string calldata name) 
	external 
	onlyBreeder
	returns (uint256)
	{
		_tokenNumber++;
		_mint(msg.sender, _tokenNumber);
		Animal memory newAnimal = Animal(_tokenNumber, name, wings, legs, sex, false, 0, 0, 0, false, 0, address(0));
		_tokens[_tokenNumber] = newAnimal;
		return _tokenNumber;
	}

	function getAnimalCharacteristics(uint animalNumber) 
	external 
	view 
	returns (string memory _name, bool _wings, uint _legs, uint _sex)
	{
		require(animalNumber <= _tokenNumber, "Id not found");
		require(animalNumber > 0, "Id not found");
		Animal memory animal = _tokens[animalNumber];
		return (animal.name, animal.wings, animal.legs, animal.sex);
	}

	function declareDeadAnimal(uint animalNumber) 
	external
	onlyAnimalOwner(animalNumber)
	{
		_burn(animalNumber);
		delete _tokens[animalNumber];
	}


	// Selling functions

	function isAnimalForSale(uint animalNumber) 
	external 
	view 
	returns (bool)
	{
		return _tokens[animalNumber].isForSale;
	}

	function animalPrice(uint animalNumber) 
	external 
	view 
	returns (uint256)
	{
		return _tokens[animalNumber].price;
	}

	function buyAnimal(uint animalNumber) 
	external
	payable
	{
		Animal memory animal = _tokens[animalNumber];

		require(animal.isForSale, "Animal is not for sale");
		require(msg.value == animal.price);

		address animalOwner = ownerOf(animalNumber);

		//give eth to current owner
		(bool sent, bytes memory data) = animalOwner.call{value: msg.value}("");
		require(sent, "Failed to transfer Ether");

		//transfer token to new owner
		_transfer(animalOwner, msg.sender, animalNumber);

		//reset sale
		_tokens[animalNumber].isForSale = false;
		_tokens[animalNumber].price = 0;
	}

	function offerForSale(uint animalNumber, uint price) 
	external
	onlyAnimalOwner(animalNumber)
	{
		_tokens[animalNumber].isForSale = true;
		_tokens[animalNumber].price = price;
	}

	function lastMintedToken()
	external
	view
	returns (uint256)
	{
		return _tokenNumber;
	}
}