# Carpooling Smart Contract

## Overview

The Carpooling Smart Contract is a decentralized application (DApp) built on the Ethereum blockchain. It facilitates a transparent and secure carpooling system where users can create rides, book seats, and cancel rides. The contract provides basic refund functionality for canceled rides.

## Features

- **User Registration:** Users can register by providing their name, age, and gender.
- **Ride Creation:** Users can create rides with specific details, including origin, destination, departure time, fare, and available seats.
- **Ride Booking:** Other users can view available rides and book seats, reducing the available seat count.
- **Ride Cancellation:** Ride owners can cancel rides, triggering refunds for booked seats.

## Smart Contract Details

### Structs

- `Human`: Represents user details, including name, age, and gender.
- `Ride`: Represents ride details, including a unique identifier (`rideId`), origin, destination, departure time, fare, and available seats.

### Functions

- `newUser`: Registers a new user.
- `createRide`: Allows users to create new rides.
- `bookRide`: Permits users to book available seats in rides.
- `getRideDetails`: Retrieves details of a specific ride.
- `viewAvailableRides`: Provides a list of available rides.
- `cancelRide`: Allows ride owners to cancel rides, triggering refunds.

### Events

- `RideCreated`: Logs the creation of a new ride.
- `RideBooked`: Logs the booking of a seat in a ride.
- `RideCancelled`: Logs the cancellation of a ride.

## Usage

1. Deploy the smart contract on the Ethereum blockchain.
2. Users can register, create rides, view available rides, and book seats.
3. Ride owners can cancel rides, triggering refunds for booked seats.


