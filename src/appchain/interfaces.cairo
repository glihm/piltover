//! SPDX-License-Identifier: MIT
//!
//! Interfaces for appchain contracts.

#[starknet::interface]
trait IAppchainCore<T> {
    /// Sets the program hash in the storage.
    ///
    /// # Arguments
    ///
    /// * `hash` - The program hash.
    fn set_program_hash(ref self: T, hash: felt252);

    /// Gets the program hash from the storage.
    ///
    /// # Returns
    ///
    /// The program hash.
    fn get_program_hash(self: @T) -> felt252;

    /// Sets the address of the verifier contract.
    ///
    /// # Arguments
    ///
    /// * `address` - The verifier contract address.
    fn set_verifier_address(ref self: T, address: ContractAddress);

    /// Gets the address of the verifier contract.
    ///
    /// # Returns
    ///
    /// The verifier contract address.
    fn get_verifier_address(self: @T) -> ContractAddress;

    /// Sets the address of the fact registry contract.
    ///
    /// # Arguments
    ///
    /// * `address` - The fact registry contract address.
    fn set_fact_registry_address(ref self: T, address: ContractAddress);

    /// Gets the address of the fact registry contract.
    ///
    /// # Returns
    ///
    /// The fact registry contract address.
    fn get_fact_registry_address(self: @T) -> ContractAddress;
}
