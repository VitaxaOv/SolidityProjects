// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external pure returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external;

    function transferFrom(address sender, address recipient, uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed to, uint256 amount);
}

contract ERC20 is IERC20 {
    uint256 totalTokens;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    string public name = "Vitaxa";
    string public symbol = "VTX";

    constructor(uint initialSupply)
    {
        mint(initialSupply);
    }

    modifier enoughTokens(address _from, uint amount)
    {
        require(balances[_from] >= amount,"Not enough");
        _;
    }

    function decimals() override external pure returns (uint256) {
        return 0; // 18
    }

    function totalSupply() override public view returns (uint256) {
        // возвращает сколько токенов в обороте
        return totalTokens;
    }

    function balanceOf(address account) override public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount)override external  enoughTokens(msg.sender, amount) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(address owner, address spender)
        override
        external
        view
        returns (uint256)
    {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) override external {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount)  override external  enoughTokens(sender, amount) {
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function mint(uint256 amount) public {
        balances[msg.sender] += amount;
        totalTokens += amount;

        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint256 amount) public  enoughTokens(msg.sender, amount){
        balances[msg.sender] -= amount;
        totalTokens -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    fallback() external payable {}

    receive() external payable {}
}

contract TokenSeller{
    IERC20 public token;

    address owner;

    address thisAddress;

    event Bought(address indexed buyer,uint amount);
    event Sell(address indexed seller,uint amount);

    constructor(IERC20 _token)
    {
        token = _token;
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner!");
        _;
    }

    function balance() public view returns(uint)
    {
        return thisAddress.balance;
    }

    function buy() public payable{
        require(msg.value >= _rate(),"Incorrect sum");

        uint tokensAvailable = token.balanceOf(thisAddress);
        uint tokensToBuy = msg.value / _rate();
        require(tokensToBuy <= tokensAvailable, "Not enough tokens");
        token.transfer(msg.sender, tokensToBuy);
        emit Bought(msg.sender, tokensToBuy);
    }

    function sell(uint amount) public {
        require(amount > 0, "Amount must be greater then 0");
        uint allowance = token.allowance(msg.sender, thisAddress);
        require(allowance >= amount, "notw allowance");

        token.transferFrom(msg.sender, thisAddress, amount);
        payable(msg.sender).transfer(amount * _rate());
        emit Sell(msg.sender,amount);
    }

    function withdrow(uint amount) public onlyOwner
    {
        require(amount<= balance(),"Not enough funds");

        payable(msg.sender).transfer(amount);
    }

    function _rate() private pure returns(uint){
        return 5 ether;
    }
}
