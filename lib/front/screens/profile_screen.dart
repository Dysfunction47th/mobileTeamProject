import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/login/kakao_logout.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';
import 'package:mobile_team_project/backend/user_data/user_model.dart';
import 'package:mobile_team_project/front/schoolCheck.dart';

// 프로필 화면 (사용자 정보 확인 + 수정 + 로그아웃)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // 학과 입력 컨트롤러
  final TextEditingController _majorCtrl = TextEditingController();

  // 학년 선택 상태값
  String _selectedYear = '';

  // 저장된 사용자 정보 가져오기
  KakaoUser? get user => UserData.user;

  // 화면에 표시할 이름 (닉네임 > 이름 > 기본값)
  String get _displayName =>
      user?.nickname ?? user?.name ?? '이름 없음';

  // 성별 표시 변환 (영문 → 한글)
  String get _displayGender {
    final g = user?.gender?.toLowerCase();
    if (g == 'male') return '남성';
    if (g == 'female') return '여성';
    return user?.gender ?? '정보 없음';
  }

  // 나이 표시 (출생년도 우선)
  String get _displayAge =>
      user?.birthyear != null
          ? '${user?.birthyear}년생'
          : (user?.ageRange ?? '정보 없음');

  // 저장 버튼 클릭 이벤트
  void _onSave() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('프로필이 저장되었습니다',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B9D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 로그아웃 처리
  void _onLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('로그아웃',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text('로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소',
                style: TextStyle(color: Color(0xFFAAAAAA))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // 카카오 로그아웃 처리
              await logoutWithKakao(context);
              // 로컬 사용자 데이터 초기화
              UserData.clearUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('로그아웃',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // 메모리 정리 (컨트롤러 해제)
  @override
  void dispose() {
    _majorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 프로필 헤더
            _buildHeader(),
            const SizedBox(height: 28),

            // 카카오 연동 정보 섹션
            _sectionLabel('카카오 연동 정보', Icons.link_rounded),
            const SizedBox(height: 10),

            _infoTile(icon: '👤', label: '이름', value: _displayName),
            const SizedBox(height: 8),
            _infoTile(icon: '⚧️', label: '성별', value: _displayGender),
            const SizedBox(height: 8),
            _infoTile(icon: '🎂', label: '나이', value: _displayAge),
            const SizedBox(height: 24),

            // 추가 정보 입력 섹션
            _sectionLabel('추가 정보 입력', Icons.edit_outlined),
            const SizedBox(height: 10),

            // 학과 입력 필드
            _editableTile(
              icon: '🎓',
              label: '학과',
              hint: '소속 학과를 입력하세요',
              controller: _majorCtrl,
            ),
            const SizedBox(height: 8),

            // 학년 선택
            _yearTile(),
            const SizedBox(height: 24),

            // 학교 인증 버튼
            _schoolCheckButton(),
            const SizedBox(height: 32),

            // 저장 버튼
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // AppBar - 우측 상단 로그아웃 버튼
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('내 프로필'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _onLogout,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFFFCCDD), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout_rounded,
                      color: Color(0xFFFF6B9D), size: 15),
                  SizedBox(width: 4),
                  Text('로그아웃',
                      style: TextStyle(
                          color: Color(0xFFFF6B9D),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF2E0E8)),
      ),
    );
  }

  // 프로필 상단 헤더
  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFFFF99BB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: const Center(
                    child: Text('😊', style: TextStyle(fontSize: 40))),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_displayName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D2D2D))),
          const SizedBox(height: 5),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0EC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('대학생',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF6B9D),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // 섹션 제목
  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6B9D), size: 17),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF666666))),
      ],
    );
  }

  // 카카오 연동 정보 타일
  Widget _infoTile({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _tileDeco(),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBBAAAB),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D))),
              ],
            ),
          ),
          // 카카오 제공 정보 태그
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE500).withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('카카오',
                style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF8B7500),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // 입력 필드 타일
  Widget _editableTile({
    required String icon,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _tileDeco(),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBBAAAB),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D)),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                        color: Color(0xFFCCBBCC), fontSize: 14),
                    filled: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 학년 선택 타일
  Widget _yearTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _tileDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📅', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Text('학년',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFBBAAAB),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: ['1학년', '2학년', '3학년', '4학년']
                .asMap()
                .entries
                .map((e) {
              final year = e.value;
              final isSelected = year == _selectedYear;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedYear = year),
                  child: Container(
                    margin:
                        EdgeInsets.only(right: e.key < 3 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFE4EF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF6B9D)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(
                      year,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFFFF6B9D)
                            : const Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 학교 인증 버튼
  Widget _schoolCheckButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SchoolCheck()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCCDD)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded,
                color: Color(0xFFFF6B9D), size: 18),
            SizedBox(width: 8),
            Text('학교 이메일 인증',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF6B9D))),
          ],
        ),
      ),
    );
  }

  BoxDecoration _tileDeco() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      );

  // 저장 버튼
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B9D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text('저장하기',
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
