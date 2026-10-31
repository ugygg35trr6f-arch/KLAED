import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color creatorPurple = Color(0xFF9B5CFF);
const Color creatorSurface = Color(0xFF171520);

class CreatorPage extends StatefulWidget {
  const CreatorPage({super.key});

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> editProfile(Map<String, dynamic> data) async {
    final bioController = TextEditingController(
      text: data['creatorBio']?.toString() ?? '',
    );

    final categories = [
      'ترفيه',
      'ألعاب',
      'موسيقى',
      'رياضة',
      'تعليم',
      'تقنية',
      'طبخ',
      'أخرى',
    ];

    String category = categories.contains(data['creatorCategory'])
        ? data['creatorCategory']
        : categories.first;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: creatorSurface,
              title: const Text('تعديل صفحة المنشئ'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bioController,
                      maxLines: 4,
                      maxLength: 250,
                      decoration: const InputDecoration(
                        labelText: 'نبذة عنك',
                        hintText: 'اكتب شيئاً عن محتواك...',
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'مجال المحتوى',
                      ),
                      items: categories.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => category = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: creatorPurple,
                  ),
                  onPressed: () async {
                    final bio = bioController.text.trim();

                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .update({
                        'creatorBio': bio,
                        'creatorCategory': category,
                        'isCreator': true,
                        'creatorUpdatedAt': FieldValue.serverTimestamp(),
                      });

                      if (!mounted) return;
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديث صفحة منشئ المحتوى'),
                        ),
                      );
                    } catch (_) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('تعذر حفظ التعديلات'),
                        ),
                      );
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );

    bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('يجب تسجيل الدخول أولاً')),
      );
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('منشئ المحتوى'),
          backgroundColor: creatorSurface,
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: creatorPurple),
              );
            }

            if (snapshot.hasError || !snapshot.hasData ||
                !snapshot.data!.exists) {
              return const Center(
                child: Text('تعذر تحميل صفحة المنشئ'),
              );
            }

            final data = snapshot.data!.data() ?? {};
            final username = data['username']?.toString() ??
                user!.email?.split('@').first ??
                'منشئ محتوى';

            final bio = data['creatorBio']?.toString() ?? '';
            final category =
                data['creatorCategory']?.toString() ?? 'لم يحدد بعد';

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xFF30205E),
                    child: Icon(
                      Icons.person,
                      color: creatorPurple,
                      size: 65,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Icon(
                        Icons.verified,
                        color: creatorPurple,
                        size: 21,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'صفحة منشئ محتوى KLAED',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 25),
                Card(
                  color: creatorSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نبذة عن المنشئ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: creatorPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bio.isEmpty ? 'أضف نبذة تعريفية عن نفسك ومحتواك.' : bio,
                          style: const TextStyle(height: 1.6),
                        ),
                        const Divider(height: 30),
                        const Text(
                          'مجال المحتوى',
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          category,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: creatorPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () => editProfile(data),
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل صفحة المنشئ'),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'المزيد من أدوات منشئي المحتوى سيضاف في المراحل القادمة',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
