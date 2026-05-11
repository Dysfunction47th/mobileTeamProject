import 'package:flutter/material.dart';
import 'package:mobile_team_project/front/screens/matching_tab_screen.dart';
import 'package:mobile_team_project/front/screens/chat_list_screen.dart';

// ══════════════════════════════════════════════════════
//  매칭 홈 화면
//  TabBar: 매칭 탭 | 채팅 탭
// ══════════════════════════════════════════════════════
class MatchingHomeScreen extends StatefulWidget {
  const MatchingHomeScreen({super.key});

  @override
  State<MatchingHomeScreen> createState() => _MatchingHomeScreenState();
}

class _MatchingHomeScreenState extends State<MatchingHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('매칭'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: const Color(0xFFBBBBBB),
          labelStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400),
          indicatorColor: const Color(0xFFFF6B9D),
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: '매칭'),
            Tab(text: '채팅'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MatchingTabScreen(),
          ChatListScreen(),
        ],
      ),
    );
  }
}
