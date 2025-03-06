import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges; // Alias the badges package
import 'maps.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _notificationCount = 3; // Example of unread notifications

  // Example upcoming trips data
  List<String> _upcomingTrips = [
    'Trip to Paris - 20th Feb',
    'Trip to Tokyo - 15th Mar',
    'Trip to New York - 1st Apr',
  ];

  // Example ongoing trips data
  List<String> _ongoingTrips = [
    'Trip to London - 10th Feb',
  ];

  // Function to show notification
  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // Customize duration
      ),
    );
  }

  void _onItemTapped(int index) {
  if (index == 4) { // If "Maps" tab is clicked
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlacesSearchScreen()), // Navigate to maps.dart
    );
  } else {
    setState(() {
      _selectedIndex = index;
    });
    _showNotification('Selected tab: ${index + 1}');
  }
}


  // Show a dialog or screen with trips information
  void _showTripsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upcoming and Ongoing Trips'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Check if there are any upcoming trips
              if (_upcomingTrips.isNotEmpty) Text('Upcoming Trips:'),
              for (var trip in _upcomingTrips) Text(trip),
              if (_upcomingTrips.isEmpty) Text('No upcoming trips.'),
              SizedBox(height: 10),
              // Check if there are any ongoing trips
              if (_ongoingTrips.isNotEmpty) Text('Ongoing Trips:'),
              for (var trip in _ongoingTrips) Text(trip),
              if (_ongoingTrips.isEmpty) Text('No ongoing trips.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.menu, color: Colors.purple),
            Text(
              "Home",
              style: TextStyle(
                color: Colors.purple,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Notification Icon with Badge
            badges.Badge(
              badgeContent: Text(
                '$_notificationCount',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              badgeColor: Colors.red,
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              child: IconButton(
                icon: Icon(Icons.notifications, color: Colors.purple),
                onPressed: () {
                  // Show upcoming and ongoing trips when notification is clicked
                  _showTripsDialog();
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Quote Section (Replacing Search Bar)
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.public,
                      color: Colors.purple, size: 30), // Globe Icon
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "A map shows you where to go your journal tells you where you’ve been.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 🔹 Trending Heading
              Text(
                "Trending",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // 🔹 Enlarged Trending Places Section
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Show notification when a place is tapped
                        _showNotification('You tapped on Place ${index + 1}');
                      },
                      child: Container(
                        width: 180,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.orange, size: 50),
                            SizedBox(height: 5),
                            Text(
                              "Place ${index + 1}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text("Details go here"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              // 🔹 Saved Trips Heading
              Text(
                "Saved Trips",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // 🔹 Enlarged Saved Trips Section
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Show notification when a trip is tapped
                        _showNotification('You tapped on Trip ${index + 1}');
                      },
                      child: Container(
                        width: 180,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flight_takeoff,
                                color: Colors.blue, size: 50),
                            SizedBox(height: 5),
                            Text(
                              "Trip ${index + 1}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text("Details go here"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Your Trips"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: "Plan a Trip"),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit), label: "Document a Trip"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Maps"),
        ],
      ),
    );
  }
}
