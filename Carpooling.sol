// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Carpooling Smart Contract
 * @dev A smart contract for managing carpooling rides and users.
 */
contract Carpooling {
    // ... (existing structs and events)

    /// @dev Mapping to track ride owners
    mapping(uint => address) public rideOwner;

    /// @dev Mapping to track which seats are booked for each ride
    mapping(uint => mapping(uint => address)) public rideToRider;

    /// @dev Counter for the total number of rides
    uint8 public rideCount = 0;

    /// @dev Arrays to store ride and person details
    Ride[] public rides;
    Human[] public persons;

    /// @dev Mapping to store details of a person based on their address
    mapping(address => Human) public addressDetails;

    /**
     * @dev Event emitted when a new ride is created.
     */
    event RideCreated(
        uint rideId,
        string origin,
        string destination,
        uint departuretime,
        uint fare,
        uint seats
    );

    /**
     * @dev Event emitted when a ride is booked.
     */
    event RideBooked(
        uint rideId,
        uint seats,
        address passenger
    );

    /**
     * @dev Event emitted when a ride is cancelled.
     */
    event RideCancelled(uint rideId);

    /**
     * @dev Function to create a new user.
     * @param _name The name of the user.
     * @param _age The age of the user.
     * @param _gender The gender of the user (false for female, true for male).
     */
    function newUser(string memory _name, uint8 _age, bool _gender) public {
        // Input validation
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_age > 0, "Age must be greater than 0");

        persons.push(Human(_name, _age, _gender));
        addressDetails[msg.sender] = Human(_name, _age, _gender);
    }

    /**
     * @dev Function to create a new ride.
     * @param _origin The origin of the ride.
     * @param _destination The destination of the ride.
     * @param _departuretime The departure time of the ride.
     * @param _fare The fare for the ride.
     * @param _seats The number of available seats in the ride.
     */
    function createRide(string memory _origin, string memory _destination, uint _departuretime, uint _fare, uint _seats) public {
        // Input validation
        require(bytes(_origin).length > 0 && bytes(_destination).length > 0, "Origin and destination cannot be empty");
        require(_departuretime > block.timestamp, "Departure time must be in the future");
        require(_fare > 0, "Fare must be greater than 0");
        require(_seats > 0, "Number of seats must be greater than 0");

        rides.push(Ride(rideCount, _origin, _destination, _departuretime, _fare, _seats));
        rideOwner[rideCount] = msg.sender;
        emit RideCreated(rideCount, _origin, _destination, _departuretime, _fare, _seats);
        rideCount++;
    }

    // ... (rest of the functions with improvements)

    /**
     * @dev Function to cancel a ride (only the owner can cancel).
     * @param rideId The ID of the ride to be cancelled.
     */
    function cancelRide(uint rideId) external {
        // ... (existing code)

        // Refund booked seats to passengers using a withdrawal pattern
        for (uint i = 0; i < rides[rideId].seats; i++) {
            address payable passenger = payable(rideToRider[rideId][i]);
            if (passenger != address(0)) {
                // Refund logic: Transfer fare back to the passenger
                require(passenger.send(rides[rideId].fare), "Failed to refund fare");
            }
        }

        // Remove the ride from the rides array
        delete rides[rideId];
    }
}
