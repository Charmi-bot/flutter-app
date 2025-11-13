import 'package:flutter/material.dart';

void main() => runApp(HealHiveApp());

class HealHiveApp extends StatefulWidget {
  @override
  _HealHiveAppState createState() => _HealHiveAppState();
}

class _HealHiveAppState extends State<HealHiveApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool dark) => setState(() => _themeMode = dark ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heal Hive',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xFFF6F9F8),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xFF0F1113),
      ),
      home: HomeScreen(onThemeToggle: toggleTheme, isDark: _themeMode == ThemeMode.dark),
    );
  }
}

/* ---------------------------
   Sample models & data
   --------------------------- */
class Doctor {
  final String id;
  final String name;
  final String speciality;
  final double rating;
  final String location;

  Doctor({required this.id, required this.name, required this.speciality, required this.rating, required this.location});
}

final List<Doctor> sampleDoctors = [
  Doctor(id: 'd1', name: 'Dr. Asha Verma', speciality: 'General Physician', rating: 4.7, location: 'Hyderabad'),
  Doctor(id: 'd2', name: 'Dr. Vikram Rao', speciality: 'Cardiologist', rating: 4.9, location: 'Bengaluru'),
  Doctor(id: 'd3', name: 'Dr. Meena Iyer', speciality: 'Dermatologist', rating: 4.5, location: 'Chennai'),
  Doctor(id: 'd4', name: 'Dr. Rohit Gupta', speciality: 'Pediatrics', rating: 4.6, location: 'Mumbai'),
];

/* ---------------------------
   Home Screen with Navigation
   --------------------------- */
class HomeScreen extends StatefulWidget {
  final void Function(bool) onThemeToggle;
  final bool isDark;
  HomeScreen({required this.onThemeToggle, required this.isDark});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(onBook: _openBookingFromHome),
      DoctorsPage(onBook: _openBooking),
      AppointmentsPage(),
      ProfilePage(),
    ];
  }

  void _openBookingFromHome() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFormPage(doctor: sampleDoctors[0])));
  }

  void _openBooking(Doctor doctor) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFormPage(doctor: doctor)));
  }

  void _onNavTap(int idx) {
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    // bottom padding to avoid bottom nav overlap for pages that use SingleChildScrollView
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        onTap: _onNavTap,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Doctors'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'themeBtn',
        onPressed: () => widget.onThemeToggle(!widget.isDark),
        child: Icon(widget.isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined),
        tooltip: 'Toggle Theme',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

/* ---------------------------
   Dashboard Page
   --------------------------- */
class DashboardPage extends StatelessWidget {
  final VoidCallback onBook;
  DashboardPage({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: true, // center the appbar title
            expandedHeight: 150,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Heal Hive'),
              // no background subtitle here to avoid overlap
              background: Container(color: Theme.of(context).primaryColor),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search tapped'))),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // move the small subtitle under the appbar so it won't overlap the title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text('Your Health Companion', style: TextStyle(color: Colors.grey[700])),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 12),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _buildQuickCard(context),
              SizedBox(height: 12),
              _buildDoctorsPreview(context),
              SizedBox(height: 12),
              _buildTips(context),
            ])),
          )
        ],
      ),
    );
  }

  Widget _buildQuickCard(BuildContext context) {
    return GestureDetector(
      onTap: onBook,
      child: Hero(
        tag: 'bookHero',
        child: Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0,3))],
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 36, backgroundColor: Colors.white24, child: Icon(Icons.health_and_safety, size: 36, color: Colors.white)),
              SizedBox(width: 16),
              Expanded(child: Text('Book a quick checkup with top doctors nearby', style: TextStyle(color: Colors.white, fontSize: 16))),
              SizedBox(width: 8),
              ElevatedButton(onPressed: onBook, child: Text('Book')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Doctors', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sampleDoctors.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final d = sampleDoctors[i];
              return GestureDetector(
                onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => DoctorDetailPage(doctor: d))),
                child: Container(
                  width: 220,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 30, child: Text(d.name.split(' ')[1][0])),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(d.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(d.speciality),
                            SizedBox(height: 6),
                            Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), SizedBox(width: 4), Text(d.rating.toString())]),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildTips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wellness Tips', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _tipChip(context, 'Hydrate', '8 glasses/day'),
            _tipChip(context, 'Sleep', '7-8 hrs'),
            _tipChip(context, 'Walk', '30 mins'),
            _tipChip(context, 'Mindfulness', '5 mins'),
          ],
        )
      ],
    );
  }

  Widget _tipChip(BuildContext context, String title, String sub) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    );
  }
}

/* ---------------------------
   Doctors Page
   --------------------------- */
class DoctorsPage extends StatelessWidget {
  final void Function(Doctor) onBook;
  DoctorsPage({required this.onBook});

  @override
  Widget build(BuildContext context) {
    // Add bottom padding so last list tile doesn't hide under bottom nav/fab
    final bottomInset = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    return SafeArea(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 12),
        itemCount: sampleDoctors.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final d = sampleDoctors[i];
          return ListTile(
            contentPadding: EdgeInsets.all(12),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Hero(tag: d.id, child: CircleAvatar(child: Text(d.name.split(' ')[1][0]))),
            title: Text(d.name),
            subtitle: Text('${d.speciality} • ${d.location}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(d.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                ElevatedButton(onPressed: () => onBook(d), child: Text('Book', style: TextStyle(fontSize: 12))),
              ],
            ),
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => DoctorDetailPage(doctor: d))),
          );
        },
      ),
    );
  }
}

/* ---------------------------
   Doctor Detail Page
   --------------------------- */
class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;
  DoctorDetailPage({required this.doctor});

  @override
  Widget build(BuildContext context) {
    // Make page scrollable and add bottom padding equal to bottom nav height
    final bottomInset = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(doctor.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
        child: Column(
          children: [
            Hero(tag: doctor.id, child: CircleAvatar(radius: 48, child: Text(doctor.name.split(' ')[1][0], style: TextStyle(fontSize: 30)))),
            SizedBox(height: 12),
            Text(doctor.speciality, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Location: ${doctor.location}'),
            SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 6),
              Text(doctor.rating.toString())
            ]),
            SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text('About', style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            Text('Experienced ${doctor.speciality.toLowerCase()} with a patient-first approach. Accepts consultations and telemedicine.'),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFormPage(doctor: doctor))),
              icon: Icon(Icons.calendar_today),
              label: Text('Book Appointment'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
            )
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   Booking Form Page
   --------------------------- */
class BookingFormPage extends StatefulWidget {
  final Doctor doctor;
  BookingFormPage({required this.doctor});

  @override
  _BookingFormPageState createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay(hour: 10, minute: 0);
  final int rows = 5;
  final int cols = 6;
  late List<bool> _selectedSeats; // length rows*cols

  @override
  void initState() {
    super.initState();
    _selectedSeats = List<bool>.filled(rows * cols, false);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 60)));
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _selectedTime);
    if (t != null) setState(() => _selectedTime = t);
  }

  void _toggleSeat(int idx) => setState(() => _selectedSeats[idx] = !_selectedSeats[idx]);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final appt = '${_selectedDate.toLocal().toString().split(' ')[0]} @ ${_selectedTime.format(context)}';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Appointment Confirmed'),
      content: Text('$_name\nwith ${widget.doctor.name}\n$appt'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK'))],
    ));
    setState(() => _selectedSeats = List<bool>.filled(rows * cols, false));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    final seatCount = rows * cols;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Book: ${widget.doctor.name}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                    validator: (v) => (v==null || v.trim().length<2) ? 'Enter your name' : null,
                    onSaved: (v) => _name = v!.trim(),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text('${_selectedDate.toLocal().toString().split(' ')[0]}'),
                          onPressed: _pickDate,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.access_time),
                          label: Text(_selectedTime.format(context)),
                          onPressed: _pickTime,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: Text('Select Seats', style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Text('Screen', style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 8),
                  SizedBox(
                    // make grid adapt to screen height but not overflow entire screen
                    height: MediaQuery.of(context).size.height * 0.32,
                    child: GridView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: seatCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        childAspectRatio: 1.3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (ctx, i) {
                        final selected = _selectedSeats[i];
                        return GestureDetector(
                          onTap: () => _toggleSeat(i),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? Colors.green : Theme.of(context).canvasColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text((i + 1).toString()),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      LegendDot(text: 'Available', color: Theme.of(context).canvasColor, borderColor: Colors.grey),
                      SizedBox(width: 8),
                      LegendDot(text: 'Selected', color: Colors.green, borderColor: Colors.green),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Confirm Appointment'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 46)),
            )
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   Appointments Page (Simple placeholder)
   --------------------------- */
class AppointmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 12),
        child: Column(
          children: [
            Text('Your Appointments', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('A')),
                      title: Text('Telemedicine with Dr. Asha'),
                      subtitle: Text('2025-11-15 • 10:00 AM'),
                      trailing: Text('Upcoming'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('V')),
                      title: Text('In-person with Dr. Vikram'),
                      subtitle: Text('2025-12-05 • 02:30 PM'),
                      trailing: Text('Booked'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   Profile Page
   --------------------------- */
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 12),
        child: Column(
          children: [
            CircleAvatar(radius: 48, child: Text('C', style: TextStyle(fontSize: 36))),
            SizedBox(height: 12),
            Text('Dunna Sai Charmi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('Member since 2025'),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.health_and_safety),
                title: Text('Health Summary'),
                subtitle: Text('Last checkup: 2025-10-01\nBlood Pressure: Normal'),
              ),
            ),
            SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                subtitle: Text('Manage account and preferences'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            SizedBox(height: 20),
            Text('Heal Hive • Demo App', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   Helper
   --------------------------- */
class LegendDot extends StatelessWidget {
  final String text;
  final Color color;
  final Color borderColor;
  const LegendDot({required this.text, required this.color, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 18, height: 18, decoration: BoxDecoration(color: color, border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(4))),
      SizedBox(width: 6),
      Text(text),
    ]);
  }
}
