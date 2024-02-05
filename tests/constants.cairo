//! Test constants.
//!
use starknet::ContractAddress;

fn ZERO_ADDR() -> ContractAddress {
    starknet::contract_address_const::<0>()
}

fn CONTRACT_A() -> ContractAddress {
    starknet::contract_address_const::<'CONTRACT_A'>()
}

fn CONTRACT_B() -> ContractAddress {
    starknet::contract_address_const::<'CONTRACT_B'>()
}

fn OWNER() -> ContractAddress {
    starknet::contract_address_const::<'OWNER'>()
}

fn BOB() -> ContractAddress {
    starknet::contract_address_const::<'BOB'>()
}

fn ALICE() -> ContractAddress {
    starknet::contract_address_const::<'ALICE'>()
}
