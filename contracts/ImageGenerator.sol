pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import { Base64 } from "../libraries/Base64.sol";
// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract ImageGenerator is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint public constant MAX_SUPPLY = 1000;


  string[] public palette = ["#F94144", "#F3722C", "#F9C74F", "#90BE6D", "#90BE6D", "#577590", "#C5C35E", "#6682ff"];
  event NewCryptoShapeMinted(address sender, uint256 tokenId);

  
  // So, we make a baseSvg variable here that all our NFTs can use.
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style>";
  string noiseFilter = "<filter id='noiseFilter'><feGaussianBlur stdDeviation='50' result='blur'/><feTurbulence type='fractalNoise' baseFrequency='10.5' numOctaves='8' /><feColorMatrix type='saturate' values='0' result='grain'/><feComposite operator='in' in='blur' in2='grain' /></filter><filter id='blur'><feGaussianBlur stdDeviation='0.3' result='blur' /></filter>";

  uint256 size = 350;
  uint initialNumber;
  constructor() ERC721 ("CryptoShapesNFT", "CRYSHP") {
    console.log("This is my NFT contract. Woah!");
  }






  function drawRandomPattern(uint256 id) public view returns (string memory) {
    uint256 rotation = random(string(abi.encodePacked(block.timestamp, Strings.toString(id))))%360;
        uint256 shapeRand = random(string(abi.encodePacked(block.timestamp, block.difficulty, Strings.toString(id))))%99;

    uint256 fillOrNot = random(string(abi.encodePacked(block.timestamp, Strings.toString(id+rotation))))%100;
    uint256 randomColor = random(string(abi.encodePacked(block.timestamp, Strings.toString(id))))%palette.length;
    uint256 tiling = 1 + random(string(abi.encodePacked(block.timestamp, Strings.toString(id))))%12;
    string memory tilingS = Strings.toString(tiling);
    string memory style = string(abi.encodePacked(" style='fill: none; stroke-width:0.35px; stroke:", palette[randomColor], "'"));
   
    if(fillOrNot<50){
      style=string(abi.encodePacked(" style='fill: ", palette[randomColor], "'"));
    }

    string memory pattern = string(abi.encodePacked('<defs><pattern id="star" viewBox="0,0,10,10" width="', tilingS, '%" height="', tilingS, '%"> <rect transform="('));

    // Make rect
    string memory rectStart = string(abi.encodePacked(Strings.toString(rotation), ' 5 5)"  x="2.5px" y="2.5px" width="5px" height="5px"'));


    string memory patternEnd = '/></pattern></defs>';

    // Drawing rects
    string memory layer1 = '<rect x="0"  y="0" width="350" height="350" fill="#000"/><rect x="0"  y="0" width="350" height="350" fill="#fff" opacity="0.25" filter="url(#noiseFilter)"/>';
    string memory layer2 = '<rect x="0"  y="0" width="350" height="350" fill="url(#star)" filter="url(#blur)"/>';



    if(shapeRand <= 33) {
      layer2 = '<circle cx="175" cy="175" r="175"  fill="url(#star)" filter="url(#blur)" />';
    } else if(shapeRand >=66){
      layer2 = '<polygon points="170 10, 350 350, 0 350"  fill="url(#star)" filter="url(#blur)" />';
    }
    // pattern + rectartart + style + patternEnd
    string memory returnString = string(abi.encodePacked(pattern, rectStart, style, patternEnd, layer1, layer2));

    return returnString;

    

  } 

  

  function random(string memory input) internal view returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input, Strings.toString(initialNumber))));
  }

  function generateNewImage() public {
    uint256 newItemId = _tokenIds.current();


    string memory shapeGroup = drawRandomPattern(newItemId);
    // I concatenate it all together, and then close the <text> and <svg> tags.
    string memory finalSvg = string(abi.encodePacked(baseSvg, noiseFilter, shapeGroup,  "</svg>"));

    console.log("\n--------------------");
    console.log(finalSvg);
    console.log("--------------------\n");

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "CryptoShapes - # ',
                    // We set the title of our NFT as the generated word.
                    Strings.toString(newItemId),
                    '", "description": "A highly acclaimed collection of shapes generated on chain.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    emit NewCryptoShapeMinted(msg.sender, newItemId);
  }
}