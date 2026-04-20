import 'package:flutter/material.dart';
import 'dashboard/inventory_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
   
    const InventoryScreen(),
   
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          if (isDesktop) 
            _buildSidebar(), // Professional Side Drawer for Desktop
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: !isDesktop ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Stock"),
        ],
      ) : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.library_books, color: Colors.indigo, size: 32),
            title: Text("Librar-X", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
          _sidebarItem(1, "Inventory", Icons.inventory_2_rounded),
          const Spacer(),
          const Divider(),
          _sidebarItem(99, "Logout", Icons.logout, color: Colors.red),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, String title, IconData icon, {Color? color}) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () {
          if (index == 99) Navigator.pushReplacementNamed(context, '/');
          else setState(() => _selectedIndex = index);
        },
        selected: isSelected,
        leading: Icon(icon, color: isSelected ? Colors.indigo : (color ?? Colors.grey[600])),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.indigo : (color ?? Colors.grey[800]), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? Colors.indigo.withOpacity(0.08) : Colors.transparent,
      ),
    );
  }
}