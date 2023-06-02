import 'package:flutter/material.dart';
import 'package:mechanic_app/Notifications/NotificationServices.dart';
import 'package:mechanic_app/TabPages/earnings%20TabPage.dart';
import 'package:mechanic_app/TabPages/home%20TabPage.dart';
import 'package:mechanic_app/TabPages/profile%20TabPage.dart';
import 'package:mechanic_app/TabPages/rating%20TabPage.dart';

import '../configMap.dart';
import '../main.dart';
class MainScreen extends StatefulWidget {
   MainScreen({Key? key}) : super(key: key);

  static const String idScreen = 'MainScreen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {


  TabController ?tabController;
  int selectedIndex=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController=TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController?.dispose();
  }

  void onItemClicked(int index){
   setState(() {
     print(index);
     selectedIndex=index;
     tabController?.index=selectedIndex;
   });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),

        children: [
          HomeTabPage(),
          EarningsTabPage(),
          RatingTabPage(),
          ProfileTabPage(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[

          BottomNavigationBarItem(icon: Icon(Icons.home),
          label: "Home"
          ),

          BottomNavigationBarItem(icon: Icon(Icons.credit_card),
              label: "Earnings"
          ),

          BottomNavigationBarItem(icon: Icon(Icons.star),
              label: "Ratings"
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person),
              label: "Account"
          ),

        ],

        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.yellow,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12.0),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
