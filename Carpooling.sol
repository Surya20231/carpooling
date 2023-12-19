// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Carpooling {
    // Struct to represent a person
    struct Human {
        string name;
        uint8 age;
        bool gender;  // 0 for female, 1 for male
    }

    // Struct to represent a ride
    struct Ride {
        uint rideId;
        string origin;
        string destination;
        uint departuretime;
        uint fare;
        uint seats;
    }

    // Mapping to track ride owners
    mapping(uint => address) public rideOwner;

    // Mapping to track which seats are booked for each ride
    mapping(uint => mapping(uint => address)) public rideToRider;

    // Counter for the total number of rides
    uint8 public rideCount = 0;

    // Arrays to store ride and person details
    Ride[] public rides;
    Human[] public persons;

    // Mapping to store details of a person based on their address
    mapping(address => Human) public addressDetails;

    // Events to log important actions
    event RideCreated(
        uint rideId,
        string origin,
        string destination,
        uint departuretime,
        uint fare,
        uint seats        
    );

    event RideBooked(
        uint rideId,
        uint seats,
        address passenger
    );

    event RideCancelled(uint rideId);

    // Function to create a new user
    function newUser(string memory _name, uint8 _age, bool _gender) public {
        persons.push(Human(_name, _age, _gender));
        addressDetails[msg.sender].name = _name;
        addressDetails[msg.sender].age = _age;
        addressDetails[msg.sender].gender = _gender;
    }

    // Function to create a new ride
    function createRide(string memory _origin, string memory _destination, uint _departuretime, uint8 _fare, uint8 _seats) public {
        rides.push(Ride(rideCount, _origin, _destination, _departuretime, _fare, _seats));
        rideOwner[rideCount] = msg.sender;
        emit RideCreated(rideCount, _origin, _destination, _departuretime, _fare, _seats);
        rideCount++;
    }  

    // Function to book a ride
    function bookRide(uint rideId) public {
        rideToRider[rideId][rides[rideId].seats] = msg.sender;
        rides[rideId].seats -= 1;
        emit RideBooked(rideId, rides[rideId].seats, msg.sender);
    }

    // Function to get details of a specific ride
    function getRideDetails(uint rideId) external view returns (
        string memory origin,
        string memory destination,
        uint departuretime,
        uint fare,
        uint seats,
        address owner
    ) {
        require(rideId < rides.length, "Ride does not exist");
        Ride memory currentRide = rides[rideId];
        return (
            currentRide.origin,
            currentRide.destination,
            currentRide.departuretime,
            currentRide.fare,
            currentRide.seats,
            rideOwner[rideId]
        );
    }

    // Function to view available rides
    function viewAvailableRides() external view returns (Ride[] memory) {
        return rides;
    }

    // Function to cancel a ride (only the owner can cancel)
    function cancelRide(uint rideId) external {
        require(rideId < rides.length, "Ride does not exist");
        require(msg.sender == rideOwner[rideId], "You are not the ride owner");

        emit RideCancelled(rideId);

        // Refund booked seats to passengers
        for (uint i = 0; i < rides[rideId].seats; i++) {
            address passenger = rideToRider[rideId][i];
            if (passenger != address(0)) {
                // Refund logic: Transfer fare back to the passenger
                payable(passenger).transfer(rides[rideId].fare);
            }
        }
        // Remove the ride from the rides array
        delete rides[rideId];
    }
}
