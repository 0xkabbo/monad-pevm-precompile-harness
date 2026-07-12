// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PrecompileTelemetry
 * @dev On-chain storage grid recording historical gas performance metrics for custom precompiles.
 */
contract PrecompileTelemetry is Ownable {

    struct TelemetryData {
        uint256 averageGasUsed;
        uint256 totalInvocations;
        bool isMonitored;
    }

    mapping(address => TelemetryData) public precompileMetricsRegistry;
    address public telemetryOperator;

    event TelemetryUpdated(address indexed precompileTarget, uint256 averageGasUsed);

    constructor() Ownable(msg.sender) {
        telemetryOperator = msg.sender;
    }

    /**
     * @notice Registers verified performance benchmarks for down-stream optimization routines.
     */
    function recordMetrics(address precompileTarget, uint256 gasUsed) external {
        require(msg.sender == telemetryOperator, "AuthError: Caller identity matches no whitelisted node profiles");
        
        TelemetryData storage data = precompileMetricsRegistry[precompileTarget];
        data.totalInvocations += 1;
        data.averageGasUsed = ((data.averageGasUsed * (data.totalInvocations - 1)) + gasUsed) / data.totalInvocations;
        data.isMonitored = true;

        emit TelemetryUpdated(precompileTarget, gasUsed);
    }
}
