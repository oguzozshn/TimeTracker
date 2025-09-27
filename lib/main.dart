import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const TimeTrackerApp());
}

// ---------------- Global Track Model ----------------
class Track {
  String title;
  DateTime start;
  DateTime end;

  Track({required this.title, required this.start, required this.end});
}

List<Track> allTracks = [];
List<String> allTitles = [];

// ---------------- Time Tracker App ----------------
class TimeTrackerApp extends StatelessWidget {
  const TimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

// ---------------- Main Screen ----------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const TrackPage(),
    const HistoryPage(),
    const SummaryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Track"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Summary"),
        ],
      ),
    );
  }
}

// ---------------- Track Page ----------------
class TrackPage extends StatefulWidget {
  const TrackPage({super.key});
  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final TextEditingController _titleController = TextEditingController();
  String? _selectedTitle;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  String get _elapsedTime {
    final duration = _stopwatch.elapsed;
    return "${duration.inHours.toString().padLeft(2,'0')}:"
        "${(duration.inMinutes % 60).toString().padLeft(2,'0')}:"
        "${(duration.inSeconds % 60).toString().padLeft(2,'0')}";
  }

  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    } else {
      _stopwatch.stop();
      _timer?.cancel();
      String title = _selectedTitle ?? _titleController.text;
      if (title.isEmpty) title = "Untitled";

      allTracks.add(Track(
        title: title,
        start: DateTime.now().subtract(_stopwatch.elapsed),
        end: DateTime.now(),
      ));

      // Başlığı dropdown’da en üstte tut
      allTitles.remove(title);
      allTitles.insert(0, title);

      _stopwatch.reset();
      _titleController.clear();
      _selectedTitle = null;
      setState(() {});
    }
  }

  void _removeTitleFromDropdown(String title) {
    setState(() {
      allTitles.remove(title);
      allTracks.removeWhere((t) => t.title == title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center, // ortalama
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 60, // dropdown'u biraz büyüt
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Select previous title"),
                value: _selectedTitle,
                items: allTitles
                    .map((e) => DropdownMenuItem(
                          child: Text(e, style: const TextStyle(fontSize: 18)),
                          value: e,
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedTitle = val),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedTitle == null
                ? null
                : () => _removeTitleFromDropdown(_selectedTitle!),
          )
        ],
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _titleController,
        decoration: const InputDecoration(labelText: "Or enter a new title"),
      ),
      const SizedBox(height: 20),
      Text(_elapsedTime, style: const TextStyle(fontSize: 32)),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _startStopwatch,
        child: Text(_stopwatch.isRunning ? "Stop" : "Start"),
      )
    ],
  ),
);

  }
}

// ---------------- History Page ----------------
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} "
        "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}:${dt.second.toString().padLeft(2,'0')}";
  }

  void _editTrack(Track track) {
    final titleController = TextEditingController(text: track.title);
    final startController = TextEditingController(
        text:
            "${track.start.year}-${track.start.month.toString().padLeft(2,'0')}-${track.start.day.toString().padLeft(2,'0')} "
            "${track.start.hour.toString().padLeft(2,'0')}:${track.start.minute.toString().padLeft(2,'0')}:${track.start.second.toString().padLeft(2,'0')}");
    final endController = TextEditingController(
        text:
            "${track.end.year}-${track.end.month.toString().padLeft(2,'0')}-${track.end.day.toString().padLeft(2,'0')} "
            "${track.end.hour.toString().padLeft(2,'0')}:${track.end.minute.toString().padLeft(2,'0')}:${track.end.second.toString().padLeft(2,'0')}");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Track"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: startController, decoration: const InputDecoration(labelText: "Start (yyyy-mm-dd HH:mm:ss)")),
            TextField(controller: endController, decoration: const InputDecoration(labelText: "End (yyyy-mm-dd HH:mm:ss)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                track.title = titleController.text;
                track.start = DateTime.parse(startController.text);
                track.end = DateTime.parse(endController.text);
                allTitles.remove(track.title);
                allTitles.insert(0, track.title);
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _deleteTrack(Track track) {
    setState(() {
      allTracks.remove(track);
      if (!allTracks.any((t) => t.title == track.title)) allTitles.remove(track.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allTracks.length,
      itemBuilder: (context, index) {
        final track = allTracks[index];
        final duration = track.end.difference(track.start);
        return ListTile(
          title: Text(track.title),
          subtitle: Text("${_formatDateTime(track.start)} - ${_formatDateTime(track.end)}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s"),
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _editTrack(track)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTrack(track)),
            ],
          ),
        );
      },
    );
  }
}

// ---------------- Summary Page ----------------
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});
  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String _sortType = "Alphabetical";

  List<Map<String, dynamic>> getSummary() {
    Map<String, int> totals = {};
    for (var t in allTracks) {
      totals[t.title] = (totals[t.title] ?? 0) + t.end.difference(t.start).inSeconds;
    }
    List<Map<String, dynamic>> summary = totals.entries
        .map((e) => {"title": e.key, "totalSeconds": e.value})
        .toList();

    if (_sortType == "Alphabetical") summary.sort((a, b) => a["title"].compareTo(b["title"]));
    if (_sortType == "Duration Asc") summary.sort((a, b) => a["totalSeconds"].compareTo(b["totalSeconds"]));
    if (_sortType == "Duration Desc") summary.sort((a, b) => b["totalSeconds"].compareTo(a["totalSeconds"]));

    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final summary = getSummary();
    return Column(
      children: [
        DropdownButton<String>(
          value: _sortType,
          items: const ["Alphabetical", "Duration Asc", "Duration Desc"]
              .map((e) => DropdownMenuItem(child: Text(e), value: e))
              .toList(),
          onChanged: (val) => setState(() => _sortType = val!),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: summary.length,
            itemBuilder: (context, index) {
              final item = summary[index];
              final hours = item["totalSeconds"] ~/ 3600;
              final minutes = (item["totalSeconds"] % 3600) ~/ 60;
              final seconds = item["totalSeconds"] % 60;
              return ListTile(
                title: Text(item["title"]),
                trailing: Text("${hours}h ${minutes}m ${seconds}s"),
              );
            },
          ),
        )
      ],
    );
  }
}
