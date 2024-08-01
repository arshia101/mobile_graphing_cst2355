import 'package:flutter/material.dart';
import 'database_helper.dart';

class FlightsListPage extends StatefulWidget {
  @override
  _FlightsListPageState createState() => _FlightsListPageState();
}

class _FlightsListPageState extends State<FlightsListPage> {
  List<Map<String, dynamic>> flights = [];

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    final data = await DatabaseHelper().flights();
    setState(() {
      flights = data;
    });
  }

  void _addFlight(Map<String, String> flight) async {
    await DatabaseHelper().insertFlight(flight);
    _loadFlights();
  }

  void _updateFlight(int id, Map<String, String> flight) async {
    await DatabaseHelper().updateFlight(id, flight);
    _loadFlights();
  }

  void _removeFlight(int id) async {
    await DatabaseHelper().deleteFlight(id);
    _loadFlights();
  }

  void _navigateToFlightDetail(Map<String, dynamic> flight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlightPage(
          flight: flight,
          onSaveFlight: (updatedFlight) {
            _updateFlight(flight['id'], updatedFlight);
          },
          onDeleteFlight: () {
            _removeFlight(flight['id']);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flights List Page'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFlightPage(onSaveFlight: _addFlight),
                ),
              );
            },
            child: Text('Add New Flight'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: flights.length,
              itemBuilder: (context, index) {
                final flight = flights[index];
                return ListTile(
                  title: Text('${flight['departureCity']} to ${flight['destinationCity']}'),
                  subtitle: Text(
                      'Departure: ${flight['departureTime']}, Arrival: ${flight['arrivalTime']}'),
                  onTap: () => _navigateToFlightDetail(flight),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddFlightPage extends StatefulWidget {
  final Function(Map<String, String>) onSaveFlight;
  final Function()? onDeleteFlight;
  final Map<String, dynamic>? flight;

  AddFlightPage({required this.onSaveFlight, this.onDeleteFlight, this.flight});

  @override
  _AddFlightPageState createState() => _AddFlightPageState();
}

class _AddFlightPageState extends State<AddFlightPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _departureCityController;
  late TextEditingController _destinationCityController;
  late TextEditingController _departureTimeController;
  late TextEditingController _arrivalTimeController;

  @override
  void initState() {
    super.initState();
    _departureCityController = TextEditingController(
        text: widget.flight?['departureCity'] ?? '');
    _destinationCityController = TextEditingController(
        text: widget.flight?['destinationCity'] ?? '');
    _departureTimeController = TextEditingController(
        text: widget.flight?['departureTime'] ?? '');
    _arrivalTimeController = TextEditingController(
        text: widget.flight?['arrivalTime'] ?? '');
  }

  void _submitFlight() {
    if (_formKey.currentState!.validate()) {
      final newFlight = {
        'departureCity': _departureCityController.text,
        'destinationCity': _destinationCityController.text,
        'departureTime': _departureTimeController.text,
        'arrivalTime': _arrivalTimeController.text,
      };
      widget.onSaveFlight(newFlight);
      Navigator.pop(context);
    }
  }

  void _deleteFlight() {
    if (widget.onDeleteFlight != null) {
      widget.onDeleteFlight!();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flight == null ? 'Add New Flight' : 'Edit Flight'),
        actions: widget.flight != null
            ? [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteFlight,
          ),
        ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _departureCityController,
                decoration: InputDecoration(labelText: 'Departure City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a departure city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _destinationCityController,
                decoration: InputDecoration(labelText: 'Destination City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a destination city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _departureTimeController,
                decoration: InputDecoration(labelText: 'Departure Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a departure time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _arrivalTimeController,
                decoration: InputDecoration(labelText: 'Arrival Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an arrival time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitFlight,
                child: Text(widget.flight == null ? 'Submit' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
