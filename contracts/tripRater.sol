pragma solidity ^0.4.19;

// initilizes a new trip and rates quality
contract tripRater {

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

    // trip status, is false if not started or already stopped
    bool isDriving;

    // allows only the iot device of the truck to modify state
    modifier only_truck { require (msg.sender == truckDevice); _; }

    // constructor, sets trip owner and quality
    function tripRater (uint256 _light, uint256 _z) public {
        truckDevice = msg.sender;
        lightIllumilation = _light;
        zAcceleration = _z;
        startTrip();
    }

    // the truck is starting the trip
    function startTrip() internal {

        // initialize at 100.000%
        tripQuality = 100000;

        // start the truck
        isDriving = true;
    }

    // finalizes the trip once the truck arrives
    function finalizeTrip () public only_truck {

        // stop the truck
        isDriving = false;
    }

    // tracks changes in light events inside the trailer
    // {"sensorType": "LIGHT", "valueLength": 1, "values": 0.96, "timestamp": 1512052879014, "": ""}
    function trackLightEvent (uint256 _time, uint256 _light) public only_truck {
        if (msg.sender == truckDevice && isDriving) {

            // rating reduces by -10.000%
            tripQuality = tripQuality - 10000;

            // set light and time
            lightIllumilation = _light;
            latestEvent = _time;
        }
    }

    // tracks bumpy road events based z-acceleromator
    // {"sensorType": "ACCELEROMETER", "valueLength": 3, "values": [0.09375, 0.055419921875, -0.912109375], "timestamp": 1512052880297, "": ""}
    function trackBumpEvent (uint256 _time, uint256 _z) public only_truck {
        if (msg.sender == truckDevice && isDriving) {

            // rating reduces by -0.001%
            tripQuality = tripQuality - 1;

            // set bump intensity and time
            zAcceleration = _z;
            latestEvent = _time;
        }
    }

    // allow calling the truck status
    function isTruckDriving () constant public returns (bool) {
        return isDriving;
    }

    // allow calling the trip quality
    function getTripRating () constant public returns (uint256) {
        return tripQuality;
    }
}
