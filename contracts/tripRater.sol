pragma solidity ^0.4.17;

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
        tripQuality = 100000;
        isDriving = true;
    }

    // finalizes the trip once the truck arrives
    function finalizeTrip () public only_truck {
        isDriving = false;
    }

    // tracks changes in light events inside the trailer
    // {"sensorType": "LIGHT", "valueLength": 1, "values": 0.96, "timestamp": 1512052879014, "": ""}
    function trackLightEvent (uint256 _time, uint256 _light) public only_truck {
        if (msg.sender == truckDevice && isDriving) {
            tripQuality = tripQuality - 10000;
            lightIllumilation = _light;
            latestEvent = _time;
        }
    }

    // tracks bumpy road events based z-acceleromator
    // {"sensorType": "ACCELEROMETER", "valueLength": 3, "values": [0.09375, 0.055419921875, -0.912109375], "timestamp": 1512052880297, "": ""}
    function trackBumpEvent (uint256 _time, uint256 _z) public only_truck {
        if (msg.sender == truckDevice && isDriving) {
            tripQuality = tripQuality - 1;
            zAcceleration = _z;
            latestEvent = _time;
        }
    }
}
