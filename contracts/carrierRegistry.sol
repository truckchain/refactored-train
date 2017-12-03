//! Carrier Registry contract. Allows carriers to register their truck's IoT
//! devices, record trips, and rate trip quality based on sensor data.
//!
//! Copyright (c) 2017 Afri Schoedon
//!
//! Permission is hereby granted, free of charge, to any person obtaining a copy
//! of this software and associated documentation files (the "Software"), to deal
//! in the Software without restriction, including without limitation the rights
//! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//! copies of the Software, and to permit persons to whom the Software is
//! furnished to do so, subject to the following conditions:
//!
//! The above copyright notice and this permission notice shall be included in all
//! copies or substantial portions of the Software.
//!
//! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//! SOFTWARE.

pragma solidity ^0.4.19;

// carrier registry containing trailer trips
contract CarrierRegistry {

    // stores the name of the carrier
    bytes32 carrierName;

    // stores the carrier quality
    uint256 carrierQualityAbsolute;

    // stores the carrier registry owner
    address registryOwner;

    // stores each trip's attributes
    struct Trip {

        // account of the truck iot device tracking the trip (owner)
        address truckDevice;

        // quality of the trip. 100000 is perfect. 0 is bad, probably failed.
        uint256 tripQuality;

        // tracks the state of the light sensor
        uint256 lightIllumilation;

        // tracks the sate of the z-axis accelerometer
        uint256 zAcceleration;

        // keeps track of the latest logged event
        uint256 latestEvent;

        // intrusion status, is false if trailer was never opened
        bool intrusionDetected;

        // trip status, is false not at destination yet
        bool isFinalized;
    }

    // stores all trips of the carrier
    mapping (uint => Trip) allTrips;

    // stores the number of initialized trips
    uint256 numTrips;

    // stores the number of finalized trips
    uint256 numFinalizedTrips;

    // fires an event when new trips are registered
    event TripRegistered (uint256 tripID);

    // fires an event when a trip is finalized
    event TripFinalized (uint256 tripID, uint256 tripQuality);

    // fires an event when a road bump is tracked
    event BumpTracked (uint256 tripID, uint256 time, uint256 zAcceleration);

    // fires an event when a light event is tracked
    event LightTracked (uint256 tripID, uint256 time, uint256 lightIllumilation);

    // allows only the registry owner to execute
    modifier onlyOwner { require (msg.sender == registryOwner); _; }


    // constructor, sets carrier name and initializes trips to 0
    function CarrierRegistry (bytes32 _name) public {
        registryOwner = msg.sender;
        carrierName = _name;
        carrierQualityAbsolute = 0;
        numTrips = 0;
        numFinalizedTrips = 0;
    }

    // the truck is starting a trip for the carrier
    function newTrip (uint256 _light, uint256 _z) public {
        uint256 tripID = numTrips + 1;
        assert(tripID >= numTrips);
        allTrips[tripID] = Trip(msg.sender, 100000, _light, _z, 0, false, false);
        numTrips = numTrips + 1;
        TripRegistered(tripID);
    }

    // finalizes the trip once the truck arrives, updates carrier rating
    function finalizeTrip (uint256 _id) public {
        if (msg.sender == allTrips[_id].truckDevice && !allTrips[_id].isFinalized) {

            // stop the truck
            allTrips[_id].isFinalized = true;
            carrierQualityAbsolute = carrierQualityAbsolute + allTrips[_id].tripQuality;
            assert(carrierQualityAbsolute >= carrierQualityAbsolute);

            // finalize the trip
            numFinalizedTrips = numFinalizedTrips + 1;
            TripFinalized(_id, allTrips[_id].tripQuality);
        }
    }

    // tracks changes in light events inside the trailer
    function trackLightEvent (uint256 _id, uint256 _time, uint256 _light) public {
        if (msg.sender == allTrips[_id].truckDevice && !allTrips[_id].isFinalized) {

            // intrusion detected
            allTrips[_id].intrusionDetected = true;

            // rating reduces by -10.000%
            uint256 penalty = 10000;
            assert(penalty <= allTrips[_id].tripQuality);
            int256 quality = int256(allTrips[_id].tripQuality - penalty);
            if (quality > 0) {
                allTrips[_id].tripQuality = uint256(quality);
            } else {
                allTrips[_id].tripQuality = 0;
            }

            // set light and time
            allTrips[_id].lightIllumilation = _light;
            allTrips[_id].latestEvent = _time;
            LightTracked(_id, _time, _light);
        }
    }

    // tracks bumpy road events based z-acceleromator
    function trackBumpEvent (uint _id, uint256 _time, uint256 _z) public {
        if (msg.sender == allTrips[_id].truckDevice && !allTrips[_id].isFinalized) {

            // rating reduces by -0.1%
            uint256 penalty = 100;
            assert(penalty <= allTrips[_id].tripQuality);
            int256 quality = int256(allTrips[_id].tripQuality - penalty);
            if (quality > 0) {
                allTrips[_id].tripQuality = uint256(quality);
            } else {
                allTrips[_id].tripQuality = 0;
            }

            // set bump intensity and time
            allTrips[_id].zAcceleration = _z;
            allTrips[_id].latestEvent = _time;
            BumpTracked(_id, _time, _z);
        }
    }

    // self-destructs the registry
    function destroy () public onlyOwner {
        selfdestruct(registryOwner);
    }

    // allow calling the truck status
    function isTripFinalized (uint256 _id) constant public returns (bool) {
        return allTrips[_id].isFinalized;
    }

    // allow calling the trip quality
    function getTripRating (uint256 _id) constant public returns (uint256) {
        return allTrips[_id].tripQuality;
    }

    // allow calling the number of trips per carrier
    function getTripNumber () constant public returns (uint256) {
        return numTrips;
    }

    // allow calling the carrier name of this instance
    function getCarrierName () constant public returns (bytes32) {
        return carrierName;
    }

    // allow getting the carrier quality rating
    function getCarrierQuality () constant public returns (uint256) {
        uint256 qualityRelative = carrierQualityAbsolute / numFinalizedTrips;
        return qualityRelative;
    }
}
