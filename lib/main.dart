import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/creator/creator_page.dart';

const Color purple = Color(0xFF9B5CFF);
const Color background = Color(0xFF09090F);
const Color surface = Color(0xFF171520);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KLAEDApp());
}

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
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLogin = true;
  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!isLogin && username.text.trim().isEmpty) {
      showError('أدخل اسم المستخدم');
      return;
    }

    if (email.text.trim().isEmpty || password.text.isEmpty) {
      showError('أدخل البريد وكلمة المرور');
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
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );

        final user = credential.user;
        if (user == null) throw Exception('تعذر إنشاء الحساب');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'username': username.text.trim(),
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      const messages = {
        'email-already-in-use': 'هذا البريد مسجل بالفعل',
        'invalid-email': 'البريد الإلكتروني غير صحيح',
        'weak-password': 'كلمة المرور ضعيفة',
        'user-not-found': 'لا يوجد حساب بهذا البريد',
        'wrong-password': 'كلمة المرور غير صحيحة',
        'invalid-credential': 'البريد أو كلمة المرور غير صحيحة',
        'network-request-failed': 'تحقق من اتصال الإنترنت',
      };
      showError(messages[e.code] ?? 'حدث خطأ: ${e.code}');
    } catch (_) {
      showError('تعذر إكمال العملية');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.people_alt_rounded,
                    color: purple, size: 75),
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
                if (!isLogin) ...[
                  TextField(
                    controller: username,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(Icons.person, color: purple),
                      filled: true,
                      fillColor: surface,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
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
                        hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
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

  final postsRef = FirebaseFirestore.instance
      .collection('posts');

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> createPost() async {
    final controller = TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: surface,
            title: const Text('إنشاء منشور'),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLines: 5,
              maxLength: 5000,
              decoration: const InputDecoration(
                hintText: 'بماذا تفكر؟ اكتب منشورك هنا...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext, controller.text.trim());
                },
                child: const Text('نشر'),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();

    if (text == null || text.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final username =
          userDoc.data()?['username']?.toString() ??
          user.email?.split('@').first ??
          'مستخدم KLAED';

      await postsRef.add({
        'authorId': user.uid,
        'authorName': username,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) showMessage('تم نشر منشورك بنجاح');
    } catch (e) {
      if (mounted) {
        showMessage('تعذر نشر المنشور. تحقق من الإنترنت والصلاحيات.');
      }
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postsRef.doc(postId).delete();
      if (mounted) showMessage('تم حذف المنشور');
    } catch (_) {
      if (mounted) showMessage('تعذر حذف المنشور');
    }
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
            buildPlaceholder('إضافة منشور', Icons.add_box_outlined),
            buildProfile(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111019),
        indicatorColor: purple.withValues(alpha: 0.2),
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          if (index == 3) {
            createPost();
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
    return Column(
      children: [
        buildHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              const Text(
                'آخر المنشورات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: createPost,
                icon: const Icon(Icons.add_circle, color: purple),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: postsRef
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: purple),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('تعذر تحميل المنشورات'),
                );
              }

              final documents = snapshot.data?.docs ?? [];

              if (documents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.post_add,
                        color: purple,
                        size: 65,
                      ),
                      const SizedBox(height: 12),
                      const Text('لا توجد منشورات حتى الآن'),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: createPost,
                        icon: const Icon(Icons.add),
                        label: const Text('اكتب أول منشور'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return buildPost(doc.id, doc.data());
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
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
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () => showMessage('الرسائل قريباً'),
            icon: const Icon(Icons.send_outlined),
          ),
        ],
      ),
    );
  }


  Future<void> toggleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final likeRef = postsRef.doc(postId).collection('likes').doc(user.uid);

    try {
      final like = await likeRef.get();
      if (like.exists) {
        await likeRef.delete();
      } else {
        await likeRef.set({
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      if (mounted) showMessage('تعذر تسجيل الإعجاب');
    }
  }

  Future<void> showComments(String postId) async {
    final controller = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final commentsRef =
        postsRef.doc(postId).collection('comments');

    Future<void> sendComment() async {
      final text = controller.text.trim();
      if (text.isEmpty) return;

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final username =
            userDoc.data()?['username']?.toString() ??
            user.email?.split('@').first ??
            'مستخدم KLAED';

        await commentsRef.add({
          'authorId': user.uid,
          'authorName': username,
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        controller.clear();
      } catch (_) {
        if (mounted) showMessage('تعذر إضافة التعليق');
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: surface,
            title: const Text('التعليقات'),
            content: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: commentsRef
                          .orderBy('createdAt')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('تعذر تحميل التعليقات'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: purple,
                            ),
                          );
                        }

                        final comments = snapshot.data?.docs ?? [];
                        if (comments.isEmpty) {
                          return const Center(
                            child: Text('لا توجد تعليقات بعد'),
                          );
                        }

                        return ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final data = comment.data();
                            final isOwner =
                                data['authorId'] == user.uid;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFF30205E),
                                child: Icon(
                                  Icons.person,
                                  color: purple,
                                ),
                              ),
                              title: Text(
                                data['authorName']?.toString() ??
                                    'مستخدم KLAED',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                data['text']?.toString() ?? '',
                              ),
                              trailing: isOwner
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        try {
                                          await comment.reference.delete();
                                        } catch (_) {
                                          if (mounted) {
                                            showMessage(
                                              'تعذر حذف التعليق',
                                            );
                                          }
                                        }
                                      },
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          maxLength: 1000,
                          decoration: const InputDecoration(
                            hintText: 'اكتب تعليقك...',
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: sendComment,
                        icon: const Icon(
                          Icons.send,
                          color: purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }

  Widget buildPost(String postId, Map<String, dynamic> post) {
    final user = FirebaseAuth.instance.currentUser;
    final authorId = post['authorId']?.toString() ?? '';
    final authorName =
        post['authorName']?.toString() ?? 'مستخدم KLAED';
    final text = post['text']?.toString() ?? '';
    final isOwner = user?.uid == authorId;

    final timestamp = post['createdAt'] as Timestamp?;
    final date = timestamp?.toDate();

    final likesRef = postsRef.doc(postId).collection('likes');
    final commentsRef = postsRef.doc(postId).collection('comments');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: likesRef.snapshots(),
      builder: (context, likesSnapshot) {
        final likes = likesSnapshot.data?.docs ?? [];
        final isLiked = user != null &&
            likes.any((like) => like.id == user.uid);

        return Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF30205E),
                    child: Icon(Icons.person, color: purple),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          date == null
                              ? 'الآن'
                              : '${date.day}/${date.month}/${date.year} '
                                  '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    IconButton(
                      onPressed: () => deletePost(postId),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              SelectableText(
                text,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              Row(
                children: [
                  IconButton(
                    onPressed: () => toggleLike(postId),
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.redAccent : Colors.white70,
                    ),
                  ),
                  Text('${likes.length} إعجاب'),
                  const SizedBox(width: 18),
                  StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: commentsRef.snapshots(),
                    builder: (context, commentsSnapshot) {
                      final count =
                          commentsSnapshot.data?.docs.length ?? 0;
                      return TextButton.icon(
                        onPressed: () => showComments(postId),
                        icon: const Icon(
                          Icons.mode_comment_outlined,
                          color: purple,
                        ),
                        label: Text('$count تعليق'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget buildProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('يجب تسجيل الدخول أولاً'));
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    Future<void> editProfile(Map<String, dynamic> data) async {
      final nameController = TextEditingController(
        text: data['username']?.toString() ?? '',
      );
      final bioController = TextEditingController(
        text: data['bio']?.toString() ?? '',
      );

      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: surface,
            title: const Text('تعديل الملف الشخصي'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(Icons.person, color: purple),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bioController,
                    maxLength: 250,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'نبذة عنك',
                      hintText: 'اكتب نبذة تعريفية عن نفسك...',
                      prefixIcon: Icon(Icons.info_outline, color: purple),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      );

      if (result == true) {
        final name = nameController.text.trim();
        final bio = bioController.text.trim();

        if (name.isEmpty) {
          if (mounted) showMessage('يرجى إدخال اسم المستخدم');
        } else {
          try {
            await userRef.update({
              'username': name,
              'bio': bio,
              'updatedAt': FieldValue.serverTimestamp(),
              'uid': user.uid,
            });
            if (mounted) showMessage('تم تحديث الملف الشخصي');
          } catch (_) {
            if (mounted) showMessage('تعذر حفظ التعديلات');
          }
        }
      }

      nameController.dispose();
      bioController.dispose();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: purple),
          );
        }

        if (snapshot.hasError || !snapshot.hasData ||
            !snapshot.data!.exists) {
          return const Center(
            child: Text('تعذر تحميل الملف الشخصي'),
          );
        }

        final data = snapshot.data!.data() ?? {};
        final username = data['username']?.toString() ??
            user.email?.split('@').first ?? 'مستخدم KLAED';
        final bio = data['bio']?.toString() ?? '';
        final email = user.email ?? '';

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: purple, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFF30205E),
                  child: Icon(
                    Icons.person,
                    color: purple,
                    size: 55,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                email,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 18),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: postsRef
                  .where('authorId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, postsSnapshot) {
                final count = postsSnapshot.data?.docs.length ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _profileStat('المنشورات', '$count'),
                      _profileStat('المتابعون', 'قريباً'),
                      _profileStat('يتابع', 'قريباً'),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نبذة عني',
                    style: TextStyle(
                      color: purple,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    bio.isEmpty ? 'لم تضف نبذة تعريفية بعد.' : bio,
                    style: const TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => editProfile(data),
              icon: const Icon(Icons.edit),
              label: const Text('تعديل الملف الشخصي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatorPage(),
                  ),
                );
              },
              icon: const Icon(Icons.stars, color: purple),
              label: const Text('صفحة منشئ المحتوى'),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const ListTile(
                leading: Icon(Icons.lock_outline, color: purple),
                title: Text('خصوصية الحساب'),
                subtitle: Text(
                  'إعداد الحساب العام والخاص سيُفعّل بعد تجهيز صلاحيات Firestore',
                ),
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 25),
          ],
        );
      },
    );
  }

  Widget _profileStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: purple,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
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
            'ستتوفر هذه الميزة في المرحلة القادمة',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
