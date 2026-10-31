import 'package:flutter/material.dart';

void main() {
  runApp(const KlaedApp());
}

class KlaedApp extends StatelessWidget {
  const KlaedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KLAED',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: KlaedHome(),
      ),
    );
  }
}

class KlaedHome extends StatefulWidget {
  const KlaedHome({super.key});

  @override
  State<KlaedHome> createState() => _KlaedHomeState();
}

class _KlaedHomeState extends State<KlaedHome> {
  int index = 0;

  final pages = const [
    FeedPage(),
    SimplePage(title: 'فيديوهات KLAED', icon: Icons.play_circle),
    SimplePage(title: 'إنشاء منشور', icon: Icons.add_a_photo),
    SimplePage(title: 'الرسائل', icon: Icons.chat),
    SimplePage(title: 'ملفي الشخصي', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KLAED',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        backgroundColor: const Color(0xFF080808),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 20),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF151515),
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() => index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            label: 'الفيديو',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'نشر',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'الرسائل',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'مرحباً بك في KLAED',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text('القصص', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        SizedBox(
          height: 85,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(8, (i) {
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(height: 5),
                    Text('مستخدم ${i + 1}'),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'أحدث المنشورات',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (i) {
          return Card(
            color: const Color(0xFF191919),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.person),
                      ),
                      SizedBox(width: 10),
                      Text('KLAED User'),
                      Spacer(),
                      Icon(Icons.more_horiz),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF29213B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 65,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.favorite_border),
                      SizedBox(width: 20),
                      Icon(Icons.comment_outlined),
                      SizedBox(width: 20),
                      Icon(Icons.share_outlined),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('منشور تجريبي رقم ${i + 1}'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;

  const SimplePage({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 75, color: Colors.deepPurple),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          const Text('مرحباً بك في KLAED'),
        ],
      ),
    );
  }
}
