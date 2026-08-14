import 'package:flutter/material.dart';
import '../services/SocketService.dart';
import '../services/session_manager.dart';
import '../pages/profile_page.dart';
import 'log_in_screen.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  int _totalUsers = 0;
  int _totalPhotos = 0;
  int _bannedUsers = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await SocketService.getAllUsers();
      if (response['statusCode'] == 200) {
        final List<dynamic> users = response['data'] ?? [];
        int photos = 0;
        int banned = 0;
        for (var u in users) {
          photos += (u['photoCount'] as num).toInt();
          if (u['isBanned'] == true) banned++;
        }
        setState(() {
          _users = users;
          _totalUsers = users.length;
          _totalPhotos = photos;
          _bannedUsers = banned;
        });
      }
    } catch (e) {
      debugPrint("Admin fetch error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBan(int userId, bool isCurrentlyBanned) async {
    try {
      final response = isCurrentlyBanned
          ? await SocketService.unbanUser(userId)
          : await SocketService.banUser(userId);

      if (response['statusCode'] == 200) {
        _fetchData();
      }
    } catch (e) {
      debugPrint("Ban/Unban error: $e");
    }
  }

  ImageProvider _buildAvatarProvider(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    }
    if (avatarPath.startsWith('assets/')) {
      return AssetImage(avatarPath);
    }
    return NetworkImage('${SocketService.baseUrl}/$avatarPath');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SessionManager().clear();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildStatCard("Total Users", _totalUsers.toString(), Icons.people, Colors.blue, scheme),
                    _buildStatCard("Total Photos", _totalPhotos.toString(), Icons.photo_library, Colors.green, scheme),
                    _buildStatCard("Banned", _bannedUsers.toString(), Icons.block, Colors.red, scheme),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final user = _users[index];
                    final bool isBanned = user['isBanned'] == true;
                    final avatarRoute = user['avatarRoute'] as String?;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfilePage(
                                viewUsername: user['username'],
                                viewAvatar: user['avatarRoute'],
                              ),
                            ),
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: scheme.primaryContainer,
                          backgroundImage: _buildAvatarProvider(avatarRoute),
                          onBackgroundImageError: (e, s) {},
                          child: avatarRoute == null || avatarRoute.isEmpty
                              ? Text(
                            user['username']?[0].toUpperCase() ?? "?",
                            style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                          )
                              : null,
                        ),
                        title: Text(
                          user['username'] ?? "Unknown",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Photos: ${user['photoCount']} | Albums: ${user['albumCount']}"),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isBanned ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isBanned ? "Banned" : "Active",
                                style: TextStyle(
                                  color: isBanned ? Colors.red : Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBanned ? scheme.primary : Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _toggleBan(user['id'], isBanned),
                          child: Text(isBanned ? "Unban" : "Ban"),
                        ),
                      ),
                    );
                  },
                  childCount: _users.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ColorScheme scheme) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: color.withOpacity(0.2))
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
