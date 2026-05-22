import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        selectedItemColor: Colors.black,

        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Paket",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Dasbor",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // TOP BAR
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: const [

                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.person,
                        color: Colors.orange,
                      ),
                    ),

                    Icon(
                      Icons.notifications,
                      size: 30,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // SALDO + HISTORY
                Row(
                  children: [

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: const Color(0xffF6D98F),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Row(
                              children: [

                                Icon(Icons.account_balance_wallet),

                                SizedBox(width: 6),

                                Text(
                                  "Saldo",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 6),

                            Text("Rp. 145.000"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: const Color(0xffC8F1C8),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: const Row(
                          children: [

                            Icon(Icons.history),

                            SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                "Riwayat\nPemesanan",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}