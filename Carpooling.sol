// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Carpooling {
    struct Human {
        string name;
        uint8 age;
        bool gender;  // 0 for female, 1 for male
    }

    struct Ride {
        uint rideId;
        string origin;
        string destination;
        uint departuretime;
        uint fare;
        uint seats;
    }

    mapping(uint => address) public rideOwner;
    mapping(uint => mapping(uint => address)) public rideToRider;

    uint8 public rideCount = 0;
    Ride[] public rides;
    mapping(address => Human) public addressDetails;

    event RideCreated(
        uint rideId,
        string origin,
        string destination,
        uint departuretime,
        uint fare,
        uint seats,
        address owner
    );

    event RideBooked(
        uint rideId,
        uint seats,
        address passenger
    );

    event RideCancelled(
        uint rideId,
        address owner
    );

    modifier rideExists(uint rideId) {
        require(rideId < rides.length, "Ride does not exist");
        _;
    }

    modifier onlyRideOwner(uint rideId) {
        require(msg.sender == rideOwner[rideId], "You are not the ride owner");
        _;
    }

    modifier seatsAvailable(uint rideId) {
        require(rides[rideId].seats > 0, "No available seats");
        _;
    }

    function newUser(string memory _name, uint8 _age, bool _gender) public {
        persons.push(Human(_name, _age, _gender));
        addressDetails[msg.sender] = Human(_name, _age, _gender);
    }

    function createRide(string memory _origin, string memory _destination, uint _departuretime, uint _fare, uint _seats) public {
        rides.push(Ride(rideCount, _origin, _destination, _departuretime, _fare, _seats));
        rideOwner[rideCount] = msg.sender;
        emit RideCreated(rideCount, _origin, _destination, _departuretime, _fare, _seats, msg.sender);
        rideCount++;
    }

    function bookRide(uint rideId) public rideExists(rideId) seatsAvailable(rideId) {
        rideToRider[rideId][rides[rideId].seats] = msg.sender;
        rides[rideId].seats -= 1;
        emit RideBooked(rideId, rides[rideId].seats, msg.sender);
    }

    function getRideDetails(uint rideId) external view rideExists(rideId) returns (
        string memory origin,
        string memory destination,
        uint departuretime,
        uint fare,
        uint seats,
        address owner
    ) {
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

    function viewAvailableRides() external view returns (Ride[] memory) {
        return rides;
    }

    function cancelRide(uint rideId) external rideExists(rideId) onlyRideOwner(rideId) {
        emit RideCancelled(rideId, msg.sender);

        for (uint i = 0; i < rides[rideId].seats; i++) {
            address passenger = rideToRider[rideId][i];
            if (passenger != address(0)) {
                // Withdraw funds using the withdrawal pattern
                withdrawFunds(passenger, rides[rideId].fare);
            }
        }
        delete rides[rideId];
    }

    // Withdraw funds using the withdrawal pattern
    function withdrawFunds(address payable recipient, uint amount) internal {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Withdrawal failed");
    }
}
