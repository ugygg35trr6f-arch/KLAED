import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KLAEDApp());
}
const Color purple = Color(0xFF9B5CFF);
const Color background = Color(0xFF09090F);
const Color surface = Color(0xFF171520);

class KLAEDApp extends StatelessWidget {
  const KLAEDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KLAED',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: purple),
              ),
            );
          }
          if (snapshot.hasData) return const HomePage();
          return const LoginPage();
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLogin = true;
  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل البريد وكلمة المرور')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      const messages = {
        'email-already-in-use': 'هذا البريد مسجل بالفعل',
        'invalid-email': 'البريد الإلكتروني غير صحيح',
        'weak-password': 'كلمة المرور ضعيفة، استخدم 6 أحرف على الأقل',
        'user-not-found': 'لا يوجد حساب بهذا البريد',
        'wrong-password': 'كلمة المرور غير صحيحة',
        'invalid-credential': 'البريد أو كلمة المرور غير صحيحة',
        'network-request-failed': 'تحقق من اتصال الإنترنت',
      };
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messages[e.code] ?? 'حدث خطأ: ${e.code}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إكمال العملية')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.people_alt_rounded, color: purple, size: 75),
                const SizedBox(height: 15),
                const Text(
                  'KLAED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: purple,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isLogin ? 'مرحباً بعودتك' : 'أنشئ حسابك الجديد',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email, color: purple),
                    filled: true,
                    fillColor: surface,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: password,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock, color: purple),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                      icon: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off,
                        color: purple,
                      ),
                    ),
                    filled: true,
                    fillColor: surface,
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: loading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isLogin ? 'تسجيل الدخول' : 'إنشاء حساب'),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? 'ليس لديك حساب؟ أنشئ حساباً'
                        : 'لديك حساب؟ سجل الدخول',
                    style: const TextStyle(color: purple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;
  final Set<int> likedPosts = {};

  final List<Map<String, String>> stories = [
    {'name': 'قصتك', 'initial': '+'},
    {'name': 'أحمد', 'initial': 'أ'},
    {'name': 'سارة', 'initial': 'س'},
    {'name': 'محمد', 'initial': 'م'},
    {'name': 'نور', 'initial': 'ن'},
    {'name': 'ليان', 'initial': 'ل'},
  ];

  final List<Map<String, String>> posts = [
    {
      'name': 'أحمد محمد',
      'username': '@ahmed',
      'caption': 'مرحباً بكم في KLAED! عالم جديد يجمعنا ❤️',
      'likes': '1.2 ألف',
      'comments': '85',
      'initial': 'أ',
      'tag': 'لحظات جميلة',
    },
    {
      'name': 'سارة علي',
      'username': '@sara',
      'caption': 'اصنع يومك بنفسك، فالحياة أجمل بالتفاؤل ✨',
      'likes': '856',
      'comments': '42',
      'initial': 'س',
      'tag': 'يوميات',
    },
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openCreateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      showDragHandle: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'إنشاء منشور جديد',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                createOption(Icons.image, 'نشر صورة'),
                createOption(Icons.video_library, 'نشر فيديو'),
                createOption(Icons.edit, 'كتابة منشور'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget createOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: purple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        showMessage('سنضيف هذه الميزة في المرحلة القادمة');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            buildHome(),
            buildPlaceholder('الفيديوهات', Icons.play_circle_outline),
            buildPlaceholder('استكشف', Icons.explore_outlined),
            buildPlaceholder('إنشاء منشور', Icons.add_box_outlined),
            buildPlaceholder('حسابي', Icons.person_outline),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111019),
        indicatorColor: purple.withValues(alpha: 0.2),
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          if (index == 3) {
            openCreateSheet();
            return;
          }
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: purple),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle, color: purple),
            label: 'فيديو',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: purple),
            label: 'استكشف',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            label: 'إضافة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: purple),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: buildHeader()),
        SliverToBoxAdapter(child: buildStories()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
            child: Row(
              children: [
                const Text(
                  'آخر المنشورات',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => showMessage('أنت تشاهد أحدث المنشورات'),
                  child: const Text(
                    'الأحدث',
                    style: TextStyle(color: purple),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildPost(index),
            childCount: posts.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 30),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [purple, Color(0xFF5425A8)],
              ),
            ),
            child: const Icon(
              Icons.bolt,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'KLAED',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => showMessage('الإشعارات قريباً'),
            icon: const Icon(Icons.notifications_none, size: 27),
          ),
          IconButton(
            onPressed: () => showMessage('الرسائل قريباً'),
            icon: const Icon(Icons.send_outlined, size: 25),
          ),
        ],
      ),
    );
  }

  Widget buildStories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            'القصص',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return GestureDetector(
                onTap: () => showMessage(
                  index == 0 ? 'إضافة قصتك قريباً' : 'قصة ${story['name']}',
                ),
                child: SizedBox(
                  width: 75,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: purple, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: surface,
                          child: Text(
                            story['initial']!,
                            style: const TextStyle(
                              color: purple,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        story['name']!,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 12),
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
  }

  Widget buildPost(int index) {
    final post = posts[index];
    final liked = likedPosts.contains(index);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: purple.withValues(alpha: 0.2),
                  child: Text(
                    post['initial']!,
                    style: const TextStyle(
                      color: purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      post['username']!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => showMessage('خيارات المنشور'),
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: Text(post['caption']!),
          ),
          const SizedBox(height: 12),
          Container(
            height: 245,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: index == 0
                    ? const [Color(0xFF51218B), Color(0xFF171020)]
                    : const [Color(0xFF30205E), Color(0xFF101018)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 85,
                  color: Colors.white24,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Text(
                    post['tag']!,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (liked) {
                        likedPosts.remove(index);
                      } else {
                        likedPosts.add(index);
                      }
                    });
                  },
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.pinkAccent : Colors.white,
                  ),
                ),
                Text(post['likes']!),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => showMessage('التعليقات ستتوفر قريباً'),
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
                Text(post['comments']!),
                const Spacer(),
                IconButton(
                  onPressed: () => showMessage('المشاركة قريباً'),
                  icon: const Icon(Icons.share_outlined),
                ),
                IconButton(
                  onPressed: () => showMessage('تم حفظ المنشور تجريبياً'),
                  icon: const Icon(Icons.bookmark_border),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: purple, size: 65),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'نعمل على تجهيز هذه الصفحة',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

