//! SPDX-License-Identifier: MIT
//!
//! Helpers functions to process messages from
//! state update buffer.
//!
//! The output of StarknetOS can be found here:
//! <https://github.com/starkware-libs/cairo-lang/blob/caba294d82eeeccc3d86a158adb8ba209bf2d8fc/src/starkware/starknet/core/os/output.cairo#L41>
//!
//! Solidity code related to message processing:
//! <https://github.com/starkware-libs/cairo-lang/blob/caba294d82eeeccc3d86a158adb8ba209bf2d8fc/src/starkware/starknet/solidity/Output.sol>.
//!
use starknet::ContractAddress;

/// Message to Starknet.
#[derive(Drop, Serde)]
struct MessageToStarknet {
    /// Appchain contract address sending the message.
    from_address: ContractAddress,
    /// Starknet contract address receiving the message.
    to_address: ContractAddress,
    /// Payload of the message.
    payload: Span<felt252>,
}

/// Message to Appchain.
#[derive(Drop, Serde)]
struct MessageToAppchain {
    /// Starknet address sending the message.
    from_address: ContractAddress,
    /// Appchain address receiving the message.
    to_address: ContractAddress,
    /// Nonce.
    nonce: felt252,
    /// Function selector (with #[l1 handler] attribute).
    selector: felt252,
    /// Payload size.
    payload: Span<felt252>,
}
