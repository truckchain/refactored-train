var web3 = require('web3');
var web3 = new web3(new web3.providers.HttpProvider("http://localhost:8545"));

var abiArray = [{"constant":true,"inputs":[],"name":"getTripNumber","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_id","type":"uint256"},{"name":"_time","type":"uint256"},{"name":"_z","type":"uint256"}],"name":"trackBumpEvent","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"destroy","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_id","type":"uint256"},{"name":"_time","type":"uint256"},{"name":"_light","type":"uint256"}],"name":"trackLightEvent","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_id","type":"uint256"}],"name":"isTripFinalized","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_id","type":"uint256"}],"name":"finalizeTrip","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getCarrierQuality","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_light","type":"uint256"},{"name":"_z","type":"uint256"}],"name":"newTrip","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_id","type":"uint256"}],"name":"getTripRating","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getCarrierName","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_name","type":"bytes32"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"}];

var MyContract = web3.eth.contract(abiArray);

function get_number_of_trips(carrier_id) {
    var contract_address = get_contact_address_for_carrier(carrier_id);
    var instance = MyContract.at(contract_address);

    return instance.getTripNumber.call().toString();
}

function get_trip_data(contract_address, trip_id) {

    var instance = MyContract.at(contract_address);

    var isFinalized = instance.isTripFinalized.call(trip_id);
    
    if (!isFinalized) {
        return {};
    }

    var c = instance.getTripRating.call(trip_id).c;

    if (!c) {
        return {};
    }

    var rating = c[0] / 1000;

    var result = {
        "carrier_id":1,
        "trip_id":trip_id,
        "rating":rating,
    }

console.log(result);
    return result;
}

function get_contact_address_for_carrier(carrier_id) {
    switch (carrier_id) {
        case 1:
            return '0xC88B6650665cE79BbC30383417CDd1ac6A47CA78';
        default:
            return;
    }
}

function get_carrier_trip_data(carrier_id, trip_id) {
    var address = get_contact_address_for_carrier(carrier_id);
    if (!address) {
        return {};
    }
    return get_trip_data(address, trip_id);
}

/*
{
    "carrier_id": 1,
    "carrier_name": "African Trucking",
    "rating": 3.08,
    "number_of_events": 3
}
*/
function update_carrier_rating(current, new_event) {
    if (new_event.carrier_id != current.carrier_id) { //also handles blank new_event
        return current;
    }
    
    var old_total = current.rating * current.number_of_events;
    var new_total = old_total + new_event.rating;
    var new_number_of_events = current.number_of_events + 1;
    var new_rating = new_total / new_number_of_events;
    
    return {
        "carrier_id": current.carrier_id,
        "carrier_name": current.carrier_name,
        "rating": new_rating,
        "number_of_events": new_number_of_events
    }
}

/*
{
    "trip_id": 1,
    "trip_name": "Cape Town to Johannesburg",
    "rating": 2.6875,
    "number_of_events": 4
}
*/
function update_trip_rating(current, new_event) {
    if (new_event.trip_id != current.trip_id) { //also handles blank new_event
        return current;
    }
        
    var old_total = current.rating * current.number_of_events;
    var new_total = old_total + new_event.rating;
    var new_number_of_events = current.number_of_events + 1;
    var new_rating = new_total / new_number_of_events;
    
    return {
        "trip_id": current.trip_id,
        "trip_name": current.trip_name,
        "rating": new_rating,
        "number_of_events": new_number_of_events
    }
}

function update_carriers_from_event(current_carriers, new_event) {
    return current_carriers.map(function(carrier) {
        return update_carrier_rating(carrier, new_event);
    });
}

function update_trips_from_event(current_trips, new_event) {
    return current_trips.map(function(trip) {
        return update_trip_rating(trip, new_event);
    });
}

function trip_already_captured(completed_trips, carrier_id, trip_id) {
    var carrier_data = completed_trips[carrier_id];
    if (!carrier_data) return false;

    return carrier_data[trip_id];
}


function set_completed_trips(completed_trips, new_event) {
    c = completed_trips;
    if (!new_event.trip_id) { //also handles blank new_event
        return c;
    }

    if (!c[new_event.carrier_id]) {
      c[new_event.carrier_id] = {};
    }
    c[new_event.carrier_id][new_event.trip_id] = true;
    return c;
}

function read_json(filename) {
  var fs = require('fs');
  try {
    return JSON.parse(fs.readFileSync(filename, 'utf8'));
  } catch (err) { }

  return {};
}

function write_json(filename, obj) {
  var fs = require('fs');
  fs.writeFile(filename, JSON.stringify(obj), function(err) {
    if(err) {
        return console.log(err);
    }

  }); 
}

function update_all() {
    var completed_trips = read_json('completed_trips.json');
    var all_carriers = read_json('carriers.json');
    var all_trips = read_json('trips.json');

    var number_of_trips = get_number_of_trips(1);

    var carrier_id = 1;
    for (var i=1; i<=number_of_trips;i++) {
        if (trip_already_captured(completed_trips, carrier_id, i)) {
            continue;
        }
        var result = get_carrier_trip_data(carrier_id, i);

        all_carriers = update_carriers_from_event(all_carriers, result);
        all_trips = update_trips_from_event(all_trips, result);
        completed_trips = set_completed_trips(completed_trips, result);
    }

    write_json('completed_trips.json', completed_trips);
    write_json('carriers.json', all_carriers);
    write_json('trips.json', all_trips);
}

update_all();
