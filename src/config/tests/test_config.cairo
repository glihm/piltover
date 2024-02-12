use openzeppelin::tests::utils::constants as c;
use piltover::config::{
    config_cpt, config_cpt::InternalTrait as ConfigInternal, IConfig, IConfigDispatcherTrait,
    IConfigDispatcher, config_mock
};
use snforge_std as snf;
use snforge_std::{CheatTarget, ContractClassTrait};
use starknet::ContractAddress;

fn deploy_mock() -> IConfigDispatcher {
    let contract = snf::declare('config_mock');
    let calldata = array![c::OWNER().into()];
    let contract_address = contract.deploy(@calldata).unwrap();
    IConfigDispatcher { contract_address }
}

#[test]
fn config_set_operator_ok() {
    let mock = deploy_mock();
    assert(mock.get_operator() == c::ZERO(), 'expect 0 addr');

    snf::start_prank(CheatTarget::One(mock.contract_address), c::OWNER());

    mock.set_operator(c::OPERATOR());
    assert(mock.get_operator() == c::OPERATOR(), 'expect operator');
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn config_set_operator_unauthorized() {
    let mock = deploy_mock();
    assert(mock.get_operator() == c::ZERO(), 'expect 0 addr');

    mock.set_operator(c::OPERATOR());
    assert(mock.get_operator() == c::OPERATOR(), 'expect operator');
}

#[test]
fn config_set_program_info_ok() {
    let mock = deploy_mock();

    snf::start_prank(CheatTarget::One(mock.contract_address), c::OWNER());

    // Owner sets the info.
    mock.set_program_info(0x1, 0x2);
    assert(mock.get_program_info() == (0x1, 0x2), 'expect correct hashes');

    mock.set_operator(c::OPERATOR());

    // Operator can also set the program info.
    snf::start_prank(CheatTarget::One(mock.contract_address), c::OPERATOR());
    mock.set_program_info(0x11, 0x22);

    assert(mock.get_program_info() == (0x11, 0x22), 'expect operator hashes');
}

#[test]
#[should_panic(expected: ('Config: not owner or operator',))]
fn config_set_program_info_unauthorized() {
    let mock = deploy_mock();

    snf::start_prank(CheatTarget::One(mock.contract_address), c::OPERATOR());
    mock.set_program_info(0x11, 0x22);
}

#[test]
fn config_set_facts_registry_ok() {
    let mock = deploy_mock();

    snf::start_prank(CheatTarget::One(mock.contract_address), c::OWNER());

    let facts_registry_address = starknet::contract_address_const::<0x123>();

    // Owner sets the address.
    mock.set_facts_registry(facts_registry_address);
    assert(mock.get_facts_registry() == facts_registry_address, 'expect valid address');

    mock.set_operator(c::OPERATOR());

    // Operator can also set the program info.
    snf::start_prank(CheatTarget::One(mock.contract_address), c::OPERATOR());
    mock.set_facts_registry(c::OTHER());

    assert(mock.get_facts_registry() == c::OTHER(), 'expect other address');
}

#[test]
#[should_panic(expected: ('Config: not owner or operator',))]
fn config_set_facts_registry_unauthorized() {
    let mock = deploy_mock();

    let facts_registry_address = starknet::contract_address_const::<0x123>();

    // Other is not an operator.
    snf::start_prank(CheatTarget::One(mock.contract_address), c::OTHER());
    mock.set_facts_registry(facts_registry_address);
}
