import 'package:flutter/material.dart';

void main() => runApp(HealHiveApp());

class HealHiveApp extends StatefulWidget {
  @override
  _HealHiveAppState createState() => _HealHiveAppState();
}

class _HealHiveAppState extends State<HealHiveApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool dark) {
    setState(() => _themeMode = dark ? ThemeMode.dark : ThemeMode.light);
  }

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
   Model and sample data
   --------------------------- */
class Doctor {
  final String id;
  final String name;
  final String speciality;
  final double rating;
  final String location;

  Doctor({
    required this.id,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.location,
  });
}

final List<Doctor> sampleDoctors = [
  Doctor(id: 'd1', name: 'Dr. Asha Verma', speciality: 'General Physician', rating: 4.7, location: 'Hyderabad'),
  Doctor(id: 'd2', name: 'Dr. Vikram Rao', speciality: 'Cardiologist', rating: 4.9, location: 'Bengaluru'),
  Doctor(id: 'd3', name: 'Dr. Meena Iyer', speciality: 'Dermatologist', rating: 4.5, location: 'Chennai'),
  Doctor(id: 'd4', name: 'Dr. Rohit Gupta', speciality: 'Pediatrics', rating: 4.6, location: 'Mumbai'),
];

/* ---------------------------
   Home Navigation
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

  void _onNavTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Doctors'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onThemeToggle(!widget.isDark),
        child: Icon(widget.isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined),
      ),
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
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Heal Hive'),
              background: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                child: const Text(
                  'Your Health Companion',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search tapped')));
                },
              )
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickCard(context),
                const SizedBox(height: 12),
                _buildDoctorsPreview(context),
                const SizedBox(height: 12),
                _buildTips(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(BuildContext context) => GestureDetector(
        onTap: onBook,
        child: Hero(
          tag: 'bookHero',
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 36, backgroundColor: Colors.white24, child: Icon(Icons.health_and_safety, color: Colors.white)),
                const SizedBox(width: 16),
                const Expanded(child: Text('Book a quick checkup with top doctors nearby', style: TextStyle(color: Colors.white, fontSize: 16))),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: onBook, child: const Text('Book')),
              ],
            ),
          ),
        ),
      );

  Widget _buildDoctorsPreview(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Doctors', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sampleDoctors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final d = sampleDoctors[i];
                return GestureDetector(
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => DoctorDetailPage(doctor: d))),
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 30, child: Text(d.name.split(' ')[1][0])),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(d.speciality),
                              const SizedBox(height: 6),
                              Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text(d.rating.toString())]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );

  Widget _buildTips(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wellness Tips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _tipChip(context, 'Hydrate', '8 glasses/day'),
              _tipChip(context, 'Sleep', '7-8 hrs'),
              _tipChip(context, 'Walk', '30 mins'),
              _tipChip(context, 'Mindfulness', '5 mins'),
            ],
          ),
        ],
      );

  Widget _tipChip(BuildContext context, String title, String sub) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      );
}

/* ---------------------------
   Doctors Page
   --------------------------- */
class DoctorsPage extends StatelessWidget {
  final void Function(Doctor) onBook;
  DoctorsPage({required this.onBook});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sampleDoctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final d = sampleDoctors[i];
            return ListTile(
              contentPadding: const EdgeInsets.all(12),
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: Hero(tag: d.id, child: CircleAvatar(child: Text(d.name.split(' ')[1][0]))),
              title: Text(d.name),
              subtitle: Text('${d.speciality} • ${d.location}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ElevatedButton(onPressed: () => onBook(d), child: const Text('Book', style: TextStyle(fontSize: 12))),
                ],
              ),
              onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => DoctorDetailPage(doctor: d))),
            );
          },
        ),
      );
}

/* ---------------------------
   Doctor Detail Page
   --------------------------- */
class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;
  DoctorDetailPage({required this.doctor});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(doctor.name)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Hero(tag: doctor.id, child: CircleAvatar(radius: 48, child: Text(doctor.name.split(' ')[1][0], style: const TextStyle(fontSize: 30)))),
              const SizedBox(height: 12),
              Text(doctor.speciality, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Location: ${doctor.location}'),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 6),
                Text(doctor.rating.toString())
              ]),
              const SizedBox(height: 20),
              const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Experienced ${doctor.speciality.toLowerCase()} with a patient-first approach. Accepts consultations and telemedicine.'),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFormPage(doctor: doctor))),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Book Appointment'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              ),
            ],
          ),
        ),
      );
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
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _selectedTime);
    if (t != null) setState(() => _selectedTime = t);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final appt = '${_selectedDate.toLocal().toString().split(' ')[0]} @ ${_selectedTime.format(context)}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Appointment Confirmed'),
        content: Text('$_name\nwith ${widget.doctor.name}\n$appt'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Book: ${widget.doctor.name}')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                  onSaved: (v) => _name = v!.trim(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text('${_selectedDate.toLocal().toString().split(' ')[0]}'),
                        onPressed: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime.format(context)),
                        onPressed: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Confirm Appointment'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 46)),
                ),
              ],
            ),
          ),
        ),
      );
}

/* ---------------------------
   Appointments Page
   --------------------------- */
class AppointmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Your Appointments', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: const [
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

/* ---------------------------
   Profile Page
   --------------------------- */
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
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
              Spacer(),
              Text('Heal Hive • Demo App', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
}
