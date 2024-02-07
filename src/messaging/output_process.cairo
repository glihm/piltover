//! SPDX-License-Identifier: MIT
//!
//! StarknetOS output messages processing.
//! The output of StarknetOS can be found here:
//! <https://github.com/starkware-libs/cairo-lang/blob/caba294d82eeeccc3d86a158adb8ba209bf2d8fc/src/starkware/starknet/core/os/output.cairo#L41>
//!
//! Solidity code:
//! <https://github.com/starkware-libs/cairo-lang/blob/caba294d82eeeccc3d86a158adb8ba209bf2d8fc/src/starkware/starknet/solidity/Output.sol>.
//!
//! For Starknet to know which messages were processed on the Appchain
//! and to validate which message can be consumed, the output of StarknetOS
//! given during a state update must be parsed.
//!
//! The output contains the list of all the messages to process.
//!

// Messages count is right after the header.
const MESSAGE_SEGMENT_SIZE_OFFSET: u32 = 6;

// L1 is starknet in the current context.
const MESSAGE_TO_L1_FROM_ADDRESS_OFFSET: u32 = 0;
const MESSAGE_TO_L1_TO_ADDRESS_OFFSET: u32 = 1;
const MESSAGE_TO_L1_PAYLOAD_SIZE_OFFSET: u32 = 2;
const MESSAGE_TO_L1_PREFIX_SIZE: u32 = 3;

// L2 is the appchain in the current context.
const MESSAGE_TO_L2_FROM_ADDRESS_OFFSET: u32 = 0;
const MESSAGE_TO_L2_TO_ADDRESS_OFFSET: u32 = 1;
const MESSAGE_TO_L2_NONCE_OFFSET: u32 = 2;
const MESSAGE_TO_L2_SELECTOR_OFFSET: u32 = 3;
const MESSAGE_TO_L2_PAYLOAD_SIZE_OFFSET: u32 = 4;
const MESSAGE_TO_L2_PREFIX_SIZE: u32 = 5;


fn process_messages(is_l2_to_l1: bool, program_output: Span<felt252>) {
    assert(program_output.len() > MESSAGE_SEGMENT_SIZE_OFFSET, 'invalid program output');

    let message_segment_len = program_output.len() - MESSAGE_SEGMENT_SIZE_OFFSET;
    let message_segment_size = *program_output[MESSAGE_SEGMENT_SIZE_OFFSET];
    // TODO: Check pow.
    // require(messageSegmentSize < 2**30, "INVALID_MESSAGE_SEGMENT_SIZE");

    let mut offset = MESSAGE_SEGMENT_SIZE_OFFSET + 1;
    let message_segment_end = offset + message_segment_size;

    let payload_size_offset = match is_l2_to_l1 {
        core::bool::False => MESSAGE_TO_L2_PAYLOAD_SIZE_OFFSET,
        core::bool::True => MESSAGE_TO_L1_PAYLOAD_SIZE_OFFSET,
    };

    loop {
        if offset >= message_segment_end {
            break; 
        }

        let payload_len_offset = offset + payload_size_offset;
        assert(payload_len_offset < message_segment_end, 'MESSAGE_TOO_SHORT');

        let payload_len = program_output[payload_len_offset];
        // TODO: require(payloadLength < 2**30, "INVALID_PAYLOAD_LENGTH");

        let end_offset = payload_len_offset + 1 + payload_len;
        assert(end_offset <= message_segment_len, 'TRUNCATED_MESSAGE_PAYLOAD');

        

        offset = end_offset;
    };
}

//     ) internal returns (uint256) {
//         uint256 messageSegmentSize = programOutputSlice[0];
//         require(messageSegmentSize < 2**30, "INVALID_MESSAGE_SEGMENT_SIZE");

//         uint256 offset = 1;
//         uint256 messageSegmentEnd = offset + messageSegmentSize;

//         uint256 payloadSizeOffset = (
//             isL2ToL1 ? MESSAGE_TO_L1_PAYLOAD_SIZE_OFFSET : MESSAGE_TO_L2_PAYLOAD_SIZE_OFFSET
//         );

//         uint256 totalMsgFees = 0;
//         while (offset < messageSegmentEnd) {
//             uint256 payloadLengthOffset = offset + payloadSizeOffset;
//             require(payloadLengthOffset < programOutputSlice.length, "MESSAGE_TOO_SHORT");

//             uint256 payloadLength = programOutputSlice[payloadLengthOffset];
//             require(payloadLength < 2**30, "INVALID_PAYLOAD_LENGTH");

//             uint256 endOffset = payloadLengthOffset + 1 + payloadLength;
//             require(endOffset <= programOutputSlice.length, "TRUNCATED_MESSAGE_PAYLOAD");

//             if (isL2ToL1) {
//                 bytes32 messageHash = keccak256(
//                     abi.encodePacked(programOutputSlice[offset:endOffset])
//                 );

//                 emit LogMessageToL1(
//                     // from=
//                     programOutputSlice[offset + MESSAGE_TO_L1_FROM_ADDRESS_OFFSET],
//                     // to=
//                     address(programOutputSlice[offset + MESSAGE_TO_L1_TO_ADDRESS_OFFSET]),
//                     // payload=
//                     (uint256[])(programOutputSlice[offset + MESSAGE_TO_L1_PREFIX_SIZE:endOffset])
//                 );
//                 messages[messageHash] += 1;
//             } else {
//                 {
//                     bytes32 messageHash = keccak256(
//                         abi.encodePacked(programOutputSlice[offset:endOffset])
//                     );

//                     uint256 msgFeePlusOne = messages[messageHash];
//                     require(msgFeePlusOne > 0, "INVALID_MESSAGE_TO_CONSUME");
//                     totalMsgFees += msgFeePlusOne - 1;
//                     messages[messageHash] = 0;
//                 }

//                 uint256 nonce = programOutputSlice[offset + MESSAGE_TO_L2_NONCE_OFFSET];
//                 uint256[] memory messageSlice = (uint256[])(
//                     programOutputSlice[offset + MESSAGE_TO_L2_PREFIX_SIZE:endOffset]
//                 );
//                 emit ConsumedMessageToL2(
//                     // from=
//                     address(programOutputSlice[offset + MESSAGE_TO_L2_FROM_ADDRESS_OFFSET]),
//                     // to=
//                     programOutputSlice[offset + MESSAGE_TO_L2_TO_ADDRESS_OFFSET],
//                     // selector=
//                     programOutputSlice[offset + MESSAGE_TO_L2_SELECTOR_OFFSET],
//                     // payload=
//                     messageSlice,
//                     // nonce =
//                     nonce
//                 );
//             }

//             offset = endOffset;
//         }
//         require(offset == messageSegmentEnd, "INVALID_MESSAGE_SEGMENT_SIZE");

//         if (totalMsgFees > 0) {
//             // NOLINTNEXTLINE: low-level-calls.
//             (bool success, ) = msg.sender.call{value: totalMsgFees}("");
//             require(success, "ETH_TRANSFER_FAILED");
//         }

//         return offset;
//     }
// }

