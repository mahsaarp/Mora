import 'package:flutter/material.dart';
import '../screens/album_detail_screen.dart';
import '../screens/create_album_screen.dart';
import '../screens/photo_detail_screen.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';
import 'edit_profile_page.dart';

class AdminUserItem {
  final String id;
  final String name;
  final String avatarUrl;
  final int photoCount;
  final int albumCount;
  bool isBanned;

  AdminUserItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.photoCount,
    required this.albumCount,
    required this.isBanned,
  });
}

class ProfilePage extends StatefulWidget {
  final String? viewUsername;
  final String? viewAvatar;

  const ProfilePage({
    super.key,
    this.viewUsername,
    this.viewAvatar,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool get isOwnProfile => widget.viewUsername == null;
  bool get showAdminPanel => isOwnProfile && isAdmin;

  final bool isAdmin = true;
  int selectedTabIndex = 0;

  late List<ExplorePhoto> _profilePhotos;
  late List<ExploreAlbum> _profileAlbums;

  final List<AdminUserItem> _adminUsers = [
    AdminUserItem(
      id: "1",
      name: "Sina Rad",
      avatarUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde",
      photoCount: 42,
      albumCount: 5,
      isBanned: false,
    ),
    AdminUserItem(
      id: "2",
      name: "Sara Karimi",
      avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
      photoCount: 18,
      albumCount: 2,
      isBanned: true,
    ),
    AdminUserItem(
      id: "3",
      name: "Ali Alavi",
      avatarUrl: "https://images.unsplash.com/photo-1599566150163-29194dcaad36",
      photoCount: 105,
      albumCount: 12,
      isBanned: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (isOwnProfile) {
      _profilePhotos = List.from(initialMockPhotos);
      _profileAlbums = List.from(mockAlbums);
    } else {
      _profilePhotos = initialMockPhotos
          .where((photo) => photo.username.toLowerCase() == widget.viewUsername!.toLowerCase())
          .toList();

      if (_profilePhotos.isNotEmpty) {
        _profileAlbums = [
          ExploreAlbum(
            id: 'user_album_1',
            title: 'My Works',
            photoCount: _profilePhotos.length,
            imageUrls: _profilePhotos.map((p) => p.imageUrl).toList(),
            createdAt: DateTime.now(),
          )
        ];
      } else {
        _profileAlbums = [];
      }
    }
  }

  Widget _buildImage(String urlOrPath) {
    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerBox(
            width: double.infinity,
            height: double.infinity,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image),
          );
        },
      );
    }

    return Image.asset(
      urlOrPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported),
        );
      },
    );
  }

  void _openPhotoDetail(ExplorePhoto photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoDetailScreen(photo: photo),
      ),
    ).then((_) => setState(() {}));
  }

  void _openAlbumDetail(ExploreAlbum album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumDetailScreen(album: album),
      ),
    );
  }

  Future<void> _createNewAlbum() async {
    final result = await Navigator.push<ExploreAlbum>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAlbumScreen(availablePhotos: _profilePhotos),
      ),
    );

    if (result != null) {
      setState(() {
        _profileAlbums.insert(0, result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // تنظیم تصویر آواتار و نام کاربر
    final String displayName = isOwnProfile ? "Mohammad" : (widget.viewUsername ?? "User");
    final String labelText = isOwnProfile ? "PHOTOGRAPHER" : "CREATOR";

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? "Profile" : "$displayName's Profile"),
        centerTitle: true,
        backgroundColor: const Color(0xff6E8B5E),
        foregroundColor: Colors.white,
        actions: isOwnProfile
            ? [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                builder: (_) {
                  return const SettingsSheet();
                },
              );
            },
          ),
        ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: isOwnProfile
                  ? const AssetImage("assets/images/profile.jpg") as ImageProvider
                  : (widget.viewAvatar != null && widget.viewAvatar!.startsWith('http')
                  ? NetworkImage(widget.viewAvatar!)
                  : AssetImage(widget.viewAvatar ?? "assets/images/profile.jpg") as ImageProvider),
            ),
            const SizedBox(height: 15),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                labelText,
                style: const TextStyle(
                  color: Color(0xff4F6A45),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '${_profilePhotos.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Posts"),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_profileAlbums.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Albums"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (isOwnProfile)
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6E8B5E),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 30),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTabIndex = 0;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selectedTabIndex == 0
                              ? const Color(0xff6E8B5E)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Photos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTabIndex == 0 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTabIndex = 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selectedTabIndex == 1
                              ? const Color(0xff6E8B5E)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Albums",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTabIndex == 1 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),


                  if (showAdminPanel)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTabIndex = 2;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selectedTabIndex == 2
                                ? const Color(0xff6E8B5E)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Users",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedTabIndex == 2 ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildTabContent(),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (selectedTabIndex == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _profilePhotos.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No photos available."),
        )
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _profilePhotos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final photo = _profilePhotos[index];
            return GestureDetector(
              onTap: () => _openPhotoDetail(photo),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(photo.imageUrl),
              ),
            );
          },
        ),
      );
    } else if (selectedTabIndex == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            if (isOwnProfile)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xff6E8B5E), width: 1.5),
                ),
                elevation: 0,
                color: const Color(0xff6E8B5E).withOpacity(0.05),
                child: ListTile(
                  onTap: _createNewAlbum,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xff6E8B5E),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  title: const Text(
                    "Create New Album",
                    style: TextStyle(
                      color: Color(0xff6E8B5E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xff6E8B5E)),
                ),
              ),
            _profileAlbums.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No albums available."),
            )
                : Column(
              children: _profileAlbums.map((album) {
                final coverImage = album.imageUrls.isNotEmpty ? album.imageUrls.first : '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    onTap: () => _openAlbumDetail(album),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: _buildImage(coverImage),
                      ),
                    ),
                    title: Text(album.title),
                    subtitle: Text('${album.photoCount} Photos'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    } else if (selectedTabIndex == 2 && showAdminPanel) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _adminUsers.length,
          itemBuilder: (context, index) {
            final user = _adminUsers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(user.avatarUrl),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Text("Photos: ${user.photoCount}"),
                        const SizedBox(width: 12),
                        Text("Albums: ${user.albumCount}"),
                      ],
                    ),
                  ),
                  trailing: SizedBox(
                    width: 90,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: user.isBanned
                            ? const Color(0xff6E8B5E)
                            : Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          user.isBanned = !user.isBanned;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              user.isBanned
                                  ? "${user.name} has been banned."
                                  : "${user.name} has been unbanned.",
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Text(
                        user.isBanned ? "Unban" : "Ban",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Settings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Night Mode"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("Theme Color"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.orange,
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(color: Colors.orange),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
