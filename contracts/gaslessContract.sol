// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract ERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Transfer(address indexed from, address indexed to, uint256 amount);

    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    uint256 public INITIAL_CHAIN_ID;
    bytes32 public INITIAL_DOMAIN_SPARATOR;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SPARATOR = computeDomainSparator();
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][to];
        require(allowed >= amount, "your amount large then allowed");
        if (allowed != type(uint256).max) {
            allowance[from][to] = allowed - amount;
        }

        balanceOf[from] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 s,
        bytes32 r
    ) public virtual {
        require(block.timestamp > deadline, "deadline expired");

        unchecked {
            address recoverAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner, address spender, uint256 value, uint256 nonce, uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(
                recoverAddress != address(0) && recoverAddress == owner,
                "Invalid signer"
            );
            allowance[recoverAddress][spender] = value;
            emit Approval(owner, spender, value);
        }
    }

    function DOMAIN_SPARATOR() public view virtual returns (bytes32) {
        return
            INITIAL_CHAIN_ID == block.chainid
                ? INITIAL_DOMAIN_SPARATOR
                : computeDomainSparator();
    }

    function computeDomainSparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP721Domain(string name, string version, uint256 chainId, address veryfingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual{
        totalSupply -= amount;
        unchecked {
            balanceOf[from] -= amount;
        }
        emit Transfer(from, address(0), amount);
    }
}

contract ERC20Permit is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}
