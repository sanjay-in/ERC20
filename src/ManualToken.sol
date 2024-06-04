// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract ManualToken {
    string public name;
    string public symbol;
    uint8 public constant DECIMALS = 18;
    uint256 public totalSupply;

    // Mapping variables
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Burn(address indexed from, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initailSupply
    ) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initailSupply * 10 ** uint256(DECIMALS);
        balanceOf[msg.sender] = totalSupply;
    }

    /**
     * Transfer tokens called by internal functions
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _amount the amount to send
     */
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_from != address(0), "Cannot transfer from zero address");
        require(_to != address(0), "Cannot transfer to zero address");
        require(
            balanceOf[_to] + _amount >= balanceOf[_to],
            "Existing balance of to account less after transfer"
        );

        uint256 previousBalance = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalance);
    }

    /**
     * Transfers from sender to particular address
     * @param _to The address of the recipient
     * @param _amount the amount to send
     * @return boolean
     */
    function transfer(address _to, uint256 _amount) public returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
     * Transfers from an address to another address
     * @param _from The address from which token needs to be transfered
     * @param _to The address of the recipient
     * @param _value the amount to send
     * @return boolean
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(
            _value <= allowances[_from][msg.sender],
            "Address not authorized to transfer these many tokens"
        );
        allowances[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Approve an address to spend specified amount of token
     * @param _spender The address of the spender
     * @param _value the amount allowed to spend
     * @return boolean
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Burns some amount of token from the total supply and the balance of the sender
     * @param _value the amount of tokens to burn
     * @return boolean
     */
    function burn(uint256 _value) public returns (bool) {
        require(
            balanceOf[msg.sender] >= _value,
            "Cannot burn more tokens than available tokens"
        );
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Burns the token from an address and the total supply
     * @param _from The address of the sender
     * @param _value the amount to send
     * @return boolean
     */
    function burnFrom(address _from, uint256 _value) public returns (bool) {
        require(
            balanceOf[_from] >= _value,
            "Cannot burn more tokens than available tokens"
        );
        require(
            allowances[_from][msg.sender] >= _value,
            "Address not authorized to transfer these many tokens"
        );
        balanceOf[_from] -= _value;
        allowances[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}
