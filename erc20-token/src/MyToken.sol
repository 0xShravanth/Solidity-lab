// SPDX-Licencse-Identifier: MIT
pragma solidity ^0.8.20;

///@title MyToken -ERC-20 Token Implementation

contract MyToken {
    // Mapping from address to balance
    mapping(address => uint256) private _balances;

    // Mapping from owner -> spender -> allowance
    mapping (address => mapping (address => uint)) private _allowances;

    uint256 private _totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    address public immutable owner;
    bool public paused;
    uint256 public immutable cap;

    /// @notice Modifier to restrict access to the contract owner
    /// @dev This modifier checks if the caller is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;  
    }
    /// @notice Modifier to check if the contract is not paused
    /// @dev This modifier prevents any function from being executed when the contract is paused
    modifier whenNotPaused(){
        require(!paused, "Token is paused");
        _;
    } 
    

    /// @notice sets name, symbol, and decimals at deployment
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 initialSupply , uint256 _cap) {
        require(initialSupply <= _cap, "Initial supply exceeds cap");
        name = _name;
        decimals = _decimals;
        symbol = _symbol;
        owner = msg.sender; // Set the contract deployer as the owner
        cap = _cap;
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals)));
    }
    /// @notice Pauses the contract, preventing transfers and minting
    function pause() external onlyOwner {
        paused = true;
    }
    /// @notice Unpauses the contract, allowing transfers and minting
    function unpause() external onlyOwner {
        paused = false;
    }


    /// @notice Returns total token created
    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

    /// @notice Returns tokrn balance of an account
    function balance(address account) external view returns (uint256) {
        return _balances[account];
    }

    /// @notice Transfers tokens from sender to recipient account
    function transfer(address recipient, uint256 amount) external whenNotPaused  returns (bool){
        require(recipient != address(0), "invalid recipient address");
        require(_balances[msg.sender] >= amount, "Not enough balance" );
        _beforeTokenTransfer(msg.sender, recipient, amount);
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        _afterTokenTransfer(msg.sender, recipient, amount);
        return true;
    }

    /// @notice Approves a spender to spend/transfer tokens
    function Approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Returns how much spender can use from owner’s account
    function allowance(address _owner, address spender) external view returns (uint256){
        return _allowances[_owner][spender];
    }

    /// @notice Transfer from one account to another (using allowance)
    function transferFrom(address from, address to, uint256 amount)external whenNotPaused  returns(bool){
        require(_allowances[from][msg.sender] >= amount, "Not enough allowance");
        require(_balances[from] >= amount,"Not enough balance");
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
    /// @notice Owner only mintig function
    function mint(address to, uint256 amount)external whenNotPaused  onlyOwner{
        _mint(to, amount);
    }
    /// @notice allow anyone to burn their own tokens
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    /// @notice Allow burning from another user with approval
    function burnFrom(address from, uint256 amount) external {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "Burn amount exceeds allowance");
        _allowances[from][msg.sender] -= amount;
        _burn(from, amount);
    }

    /// @dev Transfer function to allow internal transfers(transfer hook)
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual{}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual{}

    /// @dev Internal mint function
    function _mint(address to, uint256 amount) internal {
        require(to != address(0),"Invalid address");
        require(_totalSupply + amount <= cap, "Cap exceeded");
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    /// @dev Internal burn function
    function _burn(address from, uint256 amount) internal {
        require(_balances[from] >=amount, "Not enough to burn");
        _balances[from] -= amount;
        _totalSupply -= amount;
        emit Transfer(from, address(0), amount);

    }

    /// ERC-20 Events
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount); 
}