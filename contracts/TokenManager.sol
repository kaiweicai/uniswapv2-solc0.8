//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/ITokenManager.sol";

contract TokenManager is OwnableUpgradeable,ITokenManager {
    // class A mapping
    mapping(address => bool) public classAMapping;
    // type A associate B
    mapping(address => address) public associateA2BMapping;

    //class B mapping
    mapping(address => bool) public classBMapping;

    //class USDT Mapping
    mapping(address => bool) public usdtMapping;

    mapping(address => bool) private isManager;

    modifier onlyManager() {
        require(isManager[_msgSender()], "Not manager");
        _;
    }

    function initialize(address _tokenB,address _usdt) public initializer {
        __Ownable_init();
        classBMapping[_tokenB] = true;
        usdtMapping[_usdt] = true;
    }

    enum TokenType{TOKENA,TOKENB,USDT}

    event AddToken(
        address indexed sender,
        TokenType tokenType,
        bool add
    );

    //如果opt为true，关联tokenA和tokenB。如果opt为false
    function associateA2B(address tokenA,address tokenB,bool opt) public onlyManager{
        if(opt){
            associateA2BMapping[tokenA] = tokenB;
        }else{
            delete associateA2BMapping[tokenA];
        }
        
    }
    
    function addTokenAList(address tokenAAddress,bool add)public onlyManager{
        if (add) {
            classAMapping[tokenAAddress] = true;
        }else{
            delete classAMapping[tokenAAddress];
        }
        emit AddToken(tokenAAddress,TokenType.TOKENA,add);
    }

    function addTokenBList(address tokenBAddress,bool add)public onlyManager{
        if (add) {
            classBMapping[tokenBAddress] = true;
        }else{
            delete classAMapping[tokenBAddress];
        }
        emit AddToken(tokenBAddress,TokenType.TOKENB,add);
    }

    function addUsdtList(address usdtAddress,bool add)public onlyManager{
        if (add) {
            usdtMapping[usdtAddress] = true;
        }else{
            delete usdtMapping[usdtAddress];
        }
        emit AddToken(usdtAddress,TokenType.USDT,add);
    }

    function isTokenA(address tokenAddress) public view returns (bool) {
        return classAMapping[tokenAddress];
    }

    function isTokenB(address tokenAddress) public view returns (bool) {
        return classBMapping[tokenAddress];
    }

    function isUsdt(address tokenAddress) public view returns (bool) {
        return usdtMapping[tokenAddress];
    }

    function setManager(address _manager, bool _flag) public onlyOwner {
        isManager[_manager] = _flag;
    }

    ///根据传入的交易路径，当前交易是否是TokenA/USDT的交易对儿，并交易方向是买还是卖。如果token0是tokenA并且token1
    ///是USDT或者token0是USDT，并且token1是tokenA类别，则是TokenA/USDT的交易对儿。
    ///如果token0是tokenA类别，token1是USDT类别则是属于卖出。
    ///当token0是USDT，token1是tokenA类别，则是买入。
    ///trade[0]，是否是tokenA和usdt的交易，trade[1]是否是买交易，trade[2]是否管理B币。
    function isTokenAUsdt(address[] memory path)public override view returns(bool[] memory trade){
        require(path.length == 2,"path is too long!");
        address token0 = path[0];
        address token1 = path[1];
        trade = new bool[](2);
        if(classAMapping[token0]&&usdtMapping[token1]){
            trade[0] = true;
            trade[1] = false;
        }else if(usdtMapping[token0]&&classAMapping[token1]){
            trade[0] = true;
            trade[1] = true;
        }
        return trade;
    }
    
}
