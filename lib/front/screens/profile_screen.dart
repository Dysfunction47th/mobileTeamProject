import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/login/kakao_logout.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';
import 'package:mobile_team_project/backend/user_data/user_model.dart';

// 프로필 화면 (사용자 정보 확인 + 수정 + 공개 설정 + 로그아웃)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // =========================
  // 학과 입력 컨트롤러
  // =========================
  final TextEditingController _majorCtrl = TextEditingController();

  // =========================
  // 정보 공개 여부 상태값
  // =========================
  bool _namePublic = true;   // 이름 공개 여부
  bool _genderPublic = true; // 성별 공개 여부
  bool _agePublic = false;   // 나이 공개 여부
  bool _majorPublic = true;  // 학과 공개 여부

  // 저장된 사용자 정보 가져오기
  KakaoUser? get user => UserData.user;

  // =========================
  // 화면에 표시할 이름 (닉네임 > 이름 > 기본값)
  // =========================
  String get _displayName =>
      user?.nickname ?? user?.name ?? '이름 없음';

  // =========================
  // 성별 표시 변환 (영문 → 한글)
  // =========================
  String get _displayGender {
    final g = user?.gender?.toLowerCase();
    if (g == 'male') return '남성';
    if (g == 'female') return '여성';
    return user?.gender ?? '정보 없음';
  }

  // =========================
  // 나이 표시 (출생년도 우선)
  // =========================
  String get _displayAge =>
      user?.birthyear != null
          ? '${user?.birthyear}년생'
          : (user?.ageRange ?? '정보 없음');

  // =========================
  // 저장 버튼 클릭 이벤트
  // =========================
  void _onSave() {
    // 키보드 닫기
    FocusScope.of(context).unfocus();

    // 저장 완료 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              '프로필이 저장되었습니다',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B9D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =========================
  // 로그아웃 처리
  // =========================
  void _onLogout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),

        title: const Text(
          '로그아웃',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),

        content: const Text('로그아웃 하시겠어요?'),

        actions: [
          // 취소 버튼
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),

          // 로그아웃 확인 버튼
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // 카카오 로그아웃 처리
              await logoutWithKakao(context);

              // 로컬 사용자 데이터 초기화
              UserData.clearUser();
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  // =========================
  // 메모리 정리 (컨트롤러 해제)
  // =========================
  @override
  void dispose() {
    _majorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = user;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),

      // 앱바
      appBar: _buildAppBar(),

      // 전체 스크롤 화면
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 상단 프로필 헤더
            _buildHeader(),
            const SizedBox(height: 28),

            // 안내 배너
            _buildBanner(),
            const SizedBox(height: 24),

            // =========================
            // 카카오 연동 정보 섹션
            // =========================
            _sectionLabel('카카오 연동 정보', Icons.link_rounded),
            const SizedBox(height: 10),

            // 이름 정보
            _infoTile(
              icon: '👤',
              label: '이름',
              value: _displayName,
              isPublic: _namePublic,
              onToggle: (v) => setState(() => _namePublic = v),
            ),

            const SizedBox(height: 8),

            // 성별 정보
            _infoTile(
              icon: '⚧️',
              label: '성별',
              value: _displayGender,
              isPublic: _genderPublic,
              onToggle: (v) => setState(() => _genderPublic = v),
            ),

            const SizedBox(height: 8),

            // 나이 정보
            _infoTile(
              icon: '🎂',
              label: '나이',
              value: _displayAge,
              isPublic: _agePublic,
              onToggle: (v) => setState(() => _agePublic = v),
            ),

            const SizedBox(height: 24),

            // =========================
            // 추가 정보 입력 섹션
            // =========================
            _sectionLabel('추가 정보 입력', Icons.edit_outlined),
            const SizedBox(height: 10),

            // 학과 입력 필드
            _editableTile(
              icon: '🎓',
              label: '학과',
              hint: '소속 학과를 입력하세요',
              controller: _majorCtrl,
              isPublic: _majorPublic,
              onToggle: (v) => setState(() => _majorPublic = v),
            ),

            const SizedBox(height: 32),

            // 저장 버튼
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // =========================
  // 앱바 UI
  // =========================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('내 프로필'),

      actions: [
        // 로그아웃 버튼
        IconButton(
          onPressed: _onLogout,
          icon: const Icon(
            Icons.logout_rounded,
            color: Color(0xFFFF6B9D),
          ),
        ),
      ],
    );
  }

  // =========================
  // 프로필 상단 헤더
  // =========================
  Widget _buildHeader() {
    final name = _displayName;

    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 44,
            child: Text('😊', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 12),

          // 사용자 이름 표시
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // 안내 배너
  // =========================
  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFFF0F5),
      child: const Text('공개 설정된 정보만 상대에게 보입니다.'),
    );
  }

  // =========================
  // 섹션 제목 UI
  // =========================
  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6B9D)),
        const SizedBox(width: 6),
        Text(title),
      ],
    );
  }

  // =========================
  // 정보 표시 + 공개 스위치 UI
  // =========================
  Widget _infoTile({
    required String icon,
    required String label,
    required String value,
    required bool isPublic,
    required ValueChanged<bool> onToggle,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),

      // 공개/비공개 스위치
      trailing: Switch(
        value: isPublic,
        onChanged: onToggle,
      ),
    );
  }

  // =========================
  // 입력 필드 UI
  // =========================
  Widget _editableTile({
    required String icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isPublic,
    required ValueChanged<bool> onToggle,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }

  // =========================
  // 저장 버튼
  // =========================
  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _onSave,
      child: const Text('저장하기'),
    );
  }
}