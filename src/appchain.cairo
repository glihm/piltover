//! SPDX-License-Identifier: MIT
//!
//!

mod errors {
    const INVALID_ADDRESS: felt252 = 'Config: invalid address';
    const SNOS_INVALID_PROGRAM_OUTPUT_SIZE: felt252 = 'snos: invalid output size';
    const SNOS_INVALID_MESSAGE_SEGMENT_STARKNET: felt252 = 'snos: invalid starknet msg seg';
    const SNOS_INVALID_MESSAGE_SEGMENT_APPCHAIN: felt252 = 'snos: invalid appchain msg seg';
}

/// Appchain settlement contract on starknet.
#[starknet::contract]
mod appchain {
    use openzeppelin::access::ownable::{OwnableComponent as ownable_cpt, interface::IOwnable};
    use piltover::config::{config_cpt, config_cpt::InternalTrait as ConfigInternal, IConfig};
    use piltover::messaging::{
        messaging_cpt, messaging_cpt::InternalTrait as MessagingInternal, IMessaging,
        output_process::{MessageToStarknet, MessageToAppchain},
    };
    use starknet::ContractAddress;
    use super::errors;

    const SNOS_OUTPUT_HEADER_SIZE: usize = 5;

    component!(path: ownable_cpt, storage: ownable, event: OwnableEvent);
    component!(path: config_cpt, storage: config, event: ConfigEvent);
    component!(path: messaging_cpt, storage: messaging, event: MessagingEvent);

    #[abi(embed_v0)]
    impl ConfigImpl = config_cpt::ConfigImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: ownable_cpt::Storage,
        #[substorage(v0)]
        config: config_cpt::Storage,
        #[substorage(v0)]
        messaging: messaging_cpt::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: ownable_cpt::Event,
        #[flat]
        ConfigEvent: config_cpt::Event,
        #[flat]
        MessagingEvent: messaging_cpt::Event,
    }

    /// Initializes the contract.
    ///
    /// # Arguments
    ///
    /// * `address` - The contract address of the owner.
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.transfer_ownership(owner);

        let cancellation_delay_secs = 432000;
        self.messaging.initialize(cancellation_delay_secs);
    }

    /// Updates the states of the Appchain on Starknet,
    /// based on a proof of the StarknetOS that the state transition
    /// is valid.
    ///
    /// # Arguments
    ///
    /// * `program_output` - The StarknetOS state update output.
    /// TODO: DA + facts.
    fn update_state(ref self: ContractState, program_output: Span<felt252>) {
        self.config.is_owner_or_operator(starknet::get_caller_address());

        // TODO: reentrancy guard.
        // TODO: facts verification.
        // TODO: update the current state (component needed).

        // Header size + 2 messages segments len.
        assert(
            program_output.len() > SNOS_OUTPUT_HEADER_SIZE + 2,
            errors::SNOS_INVALID_PROGRAM_OUTPUT_SIZE
        );

        let mut offset = SNOS_OUTPUT_HEADER_SIZE;

        // TODO: We should update SNOS output to have the messages count
        // instead of the messages segment len.

        // Messages to starknet.
        let mut segment = program_output.slice(offset, program_output.len() - offset);
        let message_to_starknet_segment_len: usize = (*segment[0])
            .try_into()
            .expect(errors::SNOS_INVALID_MESSAGE_SEGMENT_STARKNET);

        let messages: Span<MessageToStarknet> = Serde::deserialize(ref segment)
            .expect(errors::SNOS_INVALID_MESSAGE_SEGMENT_STARKNET);
        self.messaging.process_messages_to_starknet(messages);

        offset += message_to_starknet_segment_len;

        // Messages to appchain.
        let mut segment = program_output.slice(offset, program_output.len() - offset);

        let messages: Span<MessageToAppchain> = Serde::deserialize(ref segment)
            .expect(errors::SNOS_INVALID_MESSAGE_SEGMENT_APPCHAIN);
        self.messaging.process_messages_to_appchain(messages);
    }
}
