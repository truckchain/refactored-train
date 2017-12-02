pragma solidity ^0.4.19;

// initilizes a new trip and rates quality
contract tripRater {

    struct Trip {
        // account of the truck iot device tracking the trip (owner)
        address truckDevice;

        // quality of the trip. 100000 is perfect. 0 is bad, probably failed.
        int256 tripQuality;

        // tracks the state of the light sensor
        uint256 lightIllumilation;

        // tracks the sate of the z-axis accelerometer
        uint256 zAcceleration;

        // keeps track of the latest logged event
        uint256 latestEvent;

        // trip status, is false not at destination yet
        bool isFinalized;
    }

    mapping (uint => Trip) allTrips;

    uint256 numTrips;

    // constructor, sets trip owner and quality
    function tripRater () public {
        numTrips = 0;
    }

    // the truck is starting the trip
    function newTrip (uint256 _light, uint256 _z) public returns (uint256) {
        uint256 tripID = numTrips + 1;
        allTrips[tripID] = Trip(msg.sender, 100000, _light, _z, 0, false);
        return tripID;
    }

    // finalizes the trip once the truck arrives
    function finalizeTrip (uint256 _id) public {
        if (msg.sender == allTrips[_id].truckDevice) {
            // stop the truck
            allTrips[_id].isFinalized = true;
        }
    }

    // tracks changes in light events inside the trailer
    function trackLightEvent (uint256 _id, uint256 _time, uint256 _light) public {
        if (msg.sender == allTrips[_id].truckDevice && !allTrips[_id].isFinalized) {

            // rating reduces by -10.000%
            int256 quality = allTrips[_id].tripQuality -10000;
            if (quality > 0) {
                allTrips[_id].tripQuality = quality;
            } else {
                allTrips[_id].tripQuality = 0;
            }

            // set light and time
            allTrips[_id].lightIllumilation = _light;
            allTrips[_id].latestEvent = _time;
        }
    }

    // tracks bumpy road events based z-acceleromator
    function trackBumpEvent (uint _id, uint256 _time, uint256 _z) public {
        if (msg.sender == allTrips[_id].truckDevice && !allTrips[_id].isFinalized) {

            // rating reduces by -0.1%
            int256 quality = allTrips[_id].tripQuality -100;
            if (quality > 0) {
                allTrips[_id].tripQuality = quality;
            } else {
                allTrips[_id].tripQuality = 0;
            }

            // set bump intensity and time
            allTrips[_id].zAcceleration = _z;
            allTrips[_id].latestEvent = _time;
        }
    }

    // allow calling the truck status
    function isTripFinalized (uint256 _id) constant public returns (bool) {
        return allTrips[_id].isFinalized;
    }

    // allow calling the trip quality
    function getTripRating (uint256 _id) constant public returns (int256) {
        return allTrips[_id].tripQuality;
    }
}
