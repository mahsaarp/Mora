import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool showPhotos = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: const Color(0xff6E8B5E),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            const SizedBox(height: 25),

            const CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage(
                "assets/images/profile.jpg",
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Mohammad",
              style: TextStyle(
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
              child: const Text(
                "PHOTOGRAPHER",
                style: TextStyle(
                  color: Color(0xff4F6A45),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: const [

                Column(
                  children: [

                    Text(
                      "12",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text("Posts"),

                  ],
                ),

                Column(
                  children: [

                    Text(
                      "4",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text("Albums"),

                  ],
                ),

              ],
            ),

            const SizedBox(height: 25),

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
                  style: TextStyle(
                    color: Colors.white,
                  ),
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
                          showPhotos = true;
                        });

                      },

                      child: Container(

                        padding: const EdgeInsets.symmetric(vertical: 14),

                        decoration: BoxDecoration(

                          color: showPhotos
                              ? const Color(0xff6E8B5E)
                              : Colors.transparent,

                          borderRadius: BorderRadius.circular(15),

                        ),

                        child: Text(

                          "Photos",

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: showPhotos
                                ? Colors.white
                                : Colors.black,
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
                          showPhotos = false;
                        });

                      },

                      child: Container(

                        padding: const EdgeInsets.symmetric(vertical: 14),

                        decoration: BoxDecoration(

                          color: !showPhotos
                              ? const Color(0xff6E8B5E)
                              : Colors.transparent,

                          borderRadius: BorderRadius.circular(15),

                        ),

                        child: Text(

                          "Albums",

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: !showPhotos
                                ? Colors.white
                                : Colors.black,
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
                        if (showPhotos)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 9,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    "assets/images/background.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              children: List.generate(
                                4,
                                (index) => Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xff6E8B5E),
                                      child: Icon(
                                        Icons.photo_album,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text("Album ${index + 1}"),
                                    subtitle: const Text("12 Photos"),
                                    trailing: const Icon(Icons.arrow_forward_ios),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 25),

                      ],
                    ),
                  ),
                );
              }
            }