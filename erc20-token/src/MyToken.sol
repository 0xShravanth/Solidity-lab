// SPDX-Licencse-Identifier:MIT
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

    /// @notice sets name, symbol, and decimals at deployment
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 initialSupply){
        name = _name;
        decimals = _decimals;
        symbol = _symbol;
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals)));
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
    function transfer(address recipient, uint256 amount) external returns (bool){
        require(recipient != address(0), "invalid recipient address");
        require(_balances[msg.sender] >= amount, "Not enough balance" );
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /// @notice Approves a spender to spend/transfer tokens
    function Approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Returns how much spender can use from owner’s account
    function allowance(address owner, address spender) external view returns (uint256){
        return _allowances[owner][spender];
    }

    /// @notice Transfer from one account to another (using allowance)
    function transferFrom(address from, address to, uint256 amount)external returns(bool){
        require(_allowances[from][msg.sender] >= amount, "Not enough allowance");
        require(_balances[from] >= amount,"Not enough balance");
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /// @dev Internal mint function
    function _mint(address to, uint256 amount) internal {
        require(to != address(0),"Invalid address");
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