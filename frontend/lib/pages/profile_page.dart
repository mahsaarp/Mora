import 'package:flutter/material.dart';
import '../main.dart';
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

  final List<AdminUserItem> _adminUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAdminUsers();
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
          ),
        ];
      } else {
        _profileAlbums = [];
      }
    }
  }

  void _loadAdminUsers() {
    _adminUsers.clear();

    final Set<String> uniqueUsernames = {};
    for (var photo in initialMockPhotos) {
      uniqueUsernames.add(photo.username);
    }

    int idCounter = 1;
    for (var username in uniqueUsernames) {
      final userPhotos = initialMockPhotos.where((p) => p.username == username).toList();
      final photoCount = userPhotos.length;
      final avatarUrl =
      userPhotos.isNotEmpty ? userPhotos.first.userAvatar : 'assets/images/profile.jpg';

      int albumCount = 0;
      for (var album in mockAlbums) {
        final belongsToUser =
        album.imageUrls.any((img) => userPhotos.any((p) => p.imageUrl == img));
        if (belongsToUser) {
          albumCount++;
        }
      }

      _adminUsers.add(
        AdminUserItem(
          id: idCounter.toString(),
          name: username,
          avatarUrl: avatarUrl,
          photoCount: photoCount,
          albumCount: albumCount,
          isBanned: false,
        ),
      );
      idCounter++;
    }
  }

  Widget _buildImage(String urlOrPath, ThemeData theme) {
    final scheme = theme.colorScheme;

    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: scheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image,
              color: scheme.onSurfaceVariant,
            ),
          );
        },
      );
    }

    return Image.asset(
      urlOrPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(
            Icons.image_not_supported,
            color: scheme.onSurfaceVariant,
          ),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final String displayName = isOwnProfile ? "Mohammad" : (widget.viewUsername ?? "User");
    final String labelText = isOwnProfile ? "PHOTOGRAPHER" : "CREATOR";

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? "Profile" : "$displayName's Profile"),
        actions: isOwnProfile
            ? [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
              backgroundColor: scheme.surfaceContainerHighest,
              backgroundImage: isOwnProfile
                  ? const AssetImage("assets/images/profile.jpg") as ImageProvider
                  : (widget.viewAvatar != null && widget.viewAvatar!.startsWith('http')
                  ? NetworkImage(widget.viewAvatar!)
                  : AssetImage(widget.viewAvatar ?? "assets/images/profile.jpg")
              as ImageProvider),
            ),
            const SizedBox(height: 15),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                labelText,
                style: TextStyle(
                  color: scheme.primary,
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      "Posts",
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_profileAlbums.length}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      "Albums",
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (isOwnProfile)
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                  child: const Text("Edit Profile"),
                ),
              ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(0.6),
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
                          color: selectedTabIndex == 0 ? scheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Photos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTabIndex == 0
                                ? scheme.onPrimary
                                : scheme.onSurface,
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
                          color: selectedTabIndex == 1 ? scheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Albums",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedTabIndex == 1
                                ? scheme.onPrimary
                                : scheme.onSurface,
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
                            color: selectedTabIndex == 2 ? scheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Users",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedTabIndex == 2
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
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
            _buildTabContent(theme),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    final scheme = theme.colorScheme;

    if (selectedTabIndex == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _profilePhotos.isEmpty
            ? Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No photos available.",
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
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
                child: _buildImage(photo.imageUrl, theme),
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
                child: ListTile(
                  onTap: _createNewAlbum,
                  leading: CircleAvatar(
                    backgroundColor: scheme.primary,
                    child: Icon(Icons.add, color: scheme.onPrimary),
                  ),
                  title: Text(
                    "Create New Album",
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: scheme.primary,
                  ),
                ),
              ),
            _profileAlbums.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No albums available.",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
                : Column(
              children: _profileAlbums.map((album) {
                final coverImage =
                album.imageUrls.isNotEmpty ? album.imageUrls.first : '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _openAlbumDetail(album),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: _buildImage(coverImage, theme),
                      ),
                    ),
                    title: Text(
                      album.title,
                      style: TextStyle(color: scheme.onSurface),
                    ),
                    subtitle: Text(
                      '${album.photoCount} Photos',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: scheme.onSurfaceVariant,
                    ),
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
        child: _adminUsers.isEmpty
            ? Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No users found.",
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _adminUsers.length,
          itemBuilder: (context, index) {
            final user = _adminUsers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: user.avatarUrl.startsWith('http')
                        ? NetworkImage(user.avatarUrl) as ImageProvider
                        : AssetImage(user.avatarUrl) as ImageProvider,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Text(
                          "Photos: ${user.photoCount}",
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Albums: ${user.albumCount}",
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  trailing: SizedBox(
                    width: 90,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: user.isBanned
                            ? scheme.primary
                            : scheme.errorContainer,
                        foregroundColor: user.isBanned
                            ? scheme.onPrimary
                            : scheme.onErrorContainer,
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

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Text(
            "Select Theme Color",
            style: TextStyle(color: scheme.onSurface),
          ),
          backgroundColor: scheme.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFB7D6B0),
                ),
                title: const Text("Green"),
                onTap: () {
                  themeColorNotifier.value = const Color(0xFFB7D6B0);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFC0CB),
                ),
                title: const Text("Pink"),
                onTap: () {
                  themeColorNotifier.value = const Color(0xFFFFC0CB);
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFB3E5FC),
                ),
                title: const Text("Blue"),
                onTap: () {
                  themeColorNotifier.value = const Color(0xFFB3E5FC);
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              final isDarkMode = currentMode == ThemeMode.dark;
              return ListTile(
                leading: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: scheme.primary,
                ),
                title: Text(
                  isDarkMode ? "Day Mode" : "Night Mode",
                  style: TextStyle(color: scheme.onSurface),
                ),
                onTap: () {
                  themeNotifier.value =
                  isDarkMode ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.palette, color: scheme.primary),
            title: Text(
              "Theme Color",
              style: TextStyle(color: scheme.onSurface),
            ),
            onTap: () {
              Navigator.pop(context);
              _showColorPickerDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: scheme.tertiary),
            title: Text(
              "Log Out",
              style: TextStyle(color: scheme.tertiary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.delete, color: scheme.error),
            title: Text(
              "Delete Account",
              style: TextStyle(color: scheme.error),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
