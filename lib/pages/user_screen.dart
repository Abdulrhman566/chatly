import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:session_29_9/pages/auth/auth_screen.dart';
import 'package:session_29_9/pages/chat_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF5F7FC);
  static const Color dark = Color(0xFF172554);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Logout
  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;

    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME BACK 👋',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Messages',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: dark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Connect with your friends',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: _logout,
                      tooltip: 'Log out',
                      icon: const Icon(Icons.logout_rounded, color: dark),
                    ),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,

                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },

                decoration: InputDecoration(
                  hintText: 'Search by email...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),

                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),

                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),

                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Users Stream
            Expanded(
              child: userId == null
                  ? const Center(child: Text('Please sign in to view users.'))
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),

                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return _EmptyState(
                            icon: Icons.error_outline,
                            title: 'Something went wrong',
                            subtitle: snapshot.error.toString(),
                          );
                        }

                        // Filter current user
                        final allUsers = (snapshot.data?.docs ?? []).where((
                          doc,
                        ) {
                          final data = doc.data();

                          final uid = data['uid'];

                          return doc.id != userId && uid != userId;
                        }).toList();

                        // Search users
                        final users = allUsers.where((doc) {
                          final data = doc.data();

                          final email = (data['email'] ?? '')
                              .toString()
                              .toLowerCase();

                          return email.contains(searchQuery);
                        }).toList();

                        if (users.isEmpty) {
                          return _EmptyState(
                            icon: searchQuery.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.people_outline,
                            title: searchQuery.isNotEmpty
                                ? 'No results found'
                                : 'No users yet',
                            subtitle: searchQuery.isNotEmpty
                                ? 'Try another email'
                                : 'Other users will appear here.',
                          );
                        }

                        return Column(
                          children: [
                            // Section Title
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'All conversations',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: dark,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    '${users.length} users',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Users List
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  24,
                                ),

                                itemCount: users.length,

                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),

                                itemBuilder: (context, index) {
                                  final data = users[index].data();

                                  final email = (data['email'] ?? '')
                                      .toString();

                                  final name = (data['name'] ?? '')
                                      .toString()
                                      .trim();

                                  final displayName = name.isNotEmpty
                                      ? name
                                      : email.split('@').first;

                                  final recipientId =
                                      (data['uid'] ?? '').toString().isNotEmpty
                                      ? data['uid'].toString()
                                      : users[index].id;

                                  final avatarColors = [
                                    const Color(0xFFDBEAFE),
                                    const Color(0xFFFCE7F3),
                                    const Color(0xFFD1FAE5),
                                    const Color(0xFFFEF3C7),
                                  ];

                                  final avatarTextColors = [
                                    const Color(0xFF2563EB),
                                    const Color(0xFFDB2777),
                                    const Color(0xFF059669),
                                    const Color(0xFFD97706),
                                  ];

                                  final colorIndex =
                                      index % avatarColors.length;

                                  return Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),

                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),

                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              reciverId: recipientId,
                                              reciverEmail: email,
                                            ),
                                          ),
                                        );
                                      },

                                      child: Padding(
                                        padding: const EdgeInsets.all(14),

                                        child: Row(
                                          children: [
                                            // Avatar
                                            CircleAvatar(
                                              radius: 26,
                                              backgroundColor:
                                                  avatarColors[colorIndex],

                                              child: Text(
                                                displayName.isNotEmpty
                                                    ? displayName[0]
                                                          .toUpperCase()
                                                    : '?',

                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      avatarTextColors[colorIndex],
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 14),

                                            // User Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    displayName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: dark,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 5),

                                                  Text(
                                                    email,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            // Chat Icon
                                            Container(
                                              padding: const EdgeInsets.all(9),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .chat_bubble_outline_rounded,
                                                color: primary,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty / Error State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: Color(0xFF2563EB)),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172554),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
