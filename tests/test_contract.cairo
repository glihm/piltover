use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use piltover::IHelloStarknetSafeDispatcher;
use piltover::IHelloStarknetSafeDispatcherTrait;
use piltover::IHelloStarknetDispatcher;
use piltover::IHelloStarknetDispatcherTrait;

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}

#[test]
fn test_increase_balance() {
    let contract_address = deploy_contract('HelloStarknet');

    let dispatcher = IHelloStarknetDispatcher { contract_address };

    let balance_before = dispatcher.get_balance();
    assert(balance_before == 0, 'Invalid balance');

    dispatcher.increase_balance(42);

    let balance_after = dispatcher.get_balance();
    assert(balance_after == 42, 'Invalid balance');
}

#[test]
fn test_cannot_increase_balance_with_zero_value() {
    let contract_address = deploy_contract('HelloStarknet');

    let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

    #[feature("safe_dispatcher")]
    let balance_before = safe_dispatcher.get_balance().unwrap();
    assert(balance_before == 0, 'Invalid balance');

    #[feature("safe_dispatcher")]
    match safe_dispatcher.increase_balance(0) {
        Result::Ok(_) => panic_with_felt252('Should have panicked'),
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
        }
    };
}
