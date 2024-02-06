use starknet::ContractAddress;

use snforge_std::{declare, start_prank, stop_prank, CheatTarget, ContractClassTrait};

use piltover::config::{
    config_cpt, config_cpt::InternalTrait as ConfigInternal, IConfig, IConfigDispatcherTrait,
    IConfigDispatcher, config_mock
};

use super::constants::{OWNER, ZERO_ADDR, BOB, ALICE, CONTRACT_A, CONTRACT_B};

fn deploy_mock() -> IConfigDispatcher {
    let contract = declare('config_mock');
    let calldata = array![OWNER().into()];
    let contract_address = contract.deploy(@calldata).unwrap();
    IConfigDispatcher { contract_address }
}

#[test]
fn config_set_operator_ok() {
    let mock = deploy_mock();
    assert(mock.get_operator() == ZERO_ADDR(), 'expect 0 addr');

    start_prank(CheatTarget::One(mock.contract_address), OWNER());

    mock.set_operator(BOB());
    assert(mock.get_operator() == BOB(), 'expect bob');
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn config_set_operator_unauthorized() {
    let mock = deploy_mock();
    assert(mock.get_operator() == ZERO_ADDR(), 'expect 0 addr');

    mock.set_operator(BOB());
    assert(mock.get_operator() == BOB(), 'expect bob');
}

#[test]
fn config_set_program_info_ok() {
    let mock = deploy_mock();

    start_prank(CheatTarget::One(mock.contract_address), OWNER());

    // Owner sets the info.
    mock.set_program_info(0x1, 0x2);
    assert(mock.get_program_info() == (0x1, 0x2), 'expect correct hashes');

    mock.set_operator(BOB());

    // Bob as operator can also set the program info.
    start_prank(CheatTarget::One(mock.contract_address), BOB());
    mock.set_program_info(0x11, 0x22);

    assert(mock.get_program_info() == (0x11, 0x22), 'expect operator hashes');
}

#[test]
#[should_panic(expected: ('Config: not owner or operator',))]
fn config_set_program_info_unauthorized() {
    let mock = deploy_mock();

    // Bob is not an operator.
    start_prank(CheatTarget::One(mock.contract_address), BOB());
    mock.set_program_info(0x11, 0x22);
}

#[test]
fn config_set_facts_registry_ok() {
    let mock = deploy_mock();

    start_prank(CheatTarget::One(mock.contract_address), OWNER());

    // Owner sets the address.
    mock.set_facts_registry(CONTRACT_A());
    assert(mock.get_facts_registry() == CONTRACT_A(), 'expect valid address');

    mock.set_operator(BOB());

    // Bob as operator can also set the program info.
    start_prank(CheatTarget::One(mock.contract_address), BOB());
    mock.set_facts_registry(CONTRACT_B());

    assert(mock.get_facts_registry() == CONTRACT_B(), 'expect operator address');
}

#[test]
#[should_panic(expected: ('Config: not owner or operator',))]
fn config_set_facts_registry_unauthorized() {
    let mock = deploy_mock();

    // Bob is not an operator.
    start_prank(CheatTarget::One(mock.contract_address), BOB());
    mock.set_facts_registry(CONTRACT_A());
}
