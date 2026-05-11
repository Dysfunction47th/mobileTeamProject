import 'package:flutter/material.dart';
import 'package:mobile_team_project/backend/login/kakao_logout.dart';
import 'package:mobile_team_project/backend/user_data/user_data.dart';

// ══════════════════════════════════════════════════════
//  프로필 화면
//  KakaoUser 에서 이름/성별/나이 표시
//  학과는 사용자가 직접 입력
//  AppBar 우측 상단: 로그아웃 버튼
// ══════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  final KakaoUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _majorCtrl = TextEditingController();

  // 공개/비공개 토글 상태
  bool _namePublic = true;
  bool _genderPublic = true;
  bool _agePublic = false;
  bool _majorPublic = true;

  // ── 표시할 이름: 닉네임 우선, 없으면 이름
  String get _displayName =>
      widget.user.nickname ?? widget.user.name ?? '이름 없음';

  // ── 성별 한글 변환 (male → 남성, female → 여성)
  String get _displayGender {
    final g = widget.user.gender?.toLowerCase();
    if (g == 'male') return '남성';
    if (g == 'female') return '여성';
    return widget.user.gender ?? '정보 없음';
  }

  // ── 나이 표시
  String get _displayAge =>
      widget.user.birthyear != null
          ? '${widget.user.birthyear}년생'
          : (widget.user.ageRange ?? '정보 없음');

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
              // 팀원이 만든 카카오 로그아웃 함수 사용
              await logoutWithKakao(context);
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
            _buildHeader(),
            const SizedBox(height: 28),
            _buildBanner(),
            const SizedBox(height: 24),

            // ── 카카오 연동 정보
            _sectionLabel('카카오 연동 정보', Icons.link_rounded),
            const SizedBox(height: 10),
            _infoTile(
              icon: '👤',
              label: '이름',
              value: _displayName,         // ← 카카오 닉네임/이름
              isPublic: _namePublic,
              onToggle: (v) => setState(() => _namePublic = v),
            ),
            const SizedBox(height: 8),
            _infoTile(
              icon: '⚧️',
              label: '성별',
              value: _displayGender,       // ← 카카오 성별
              isPublic: _genderPublic,
              onToggle: (v) => setState(() => _genderPublic = v),
            ),
            const SizedBox(height: 8),
            _infoTile(
              icon: '🎂',
              label: '나이',
              value: _displayAge,          // ← 카카오 나이/연령대
              isPublic: _agePublic,
              onToggle: (v) => setState(() => _agePublic = v),
            ),
            const SizedBox(height: 24),

            // ── 직접 입력 정보
            _sectionLabel('추가 정보 입력', Icons.edit_outlined),
            const SizedBox(height: 10),
            _editableTile(
              icon: '🎓',
              label: '학과',
              hint: '소속 학과를 입력하세요',
              controller: _majorCtrl,
              isPublic: _majorPublic,
              onToggle: (v) => setState(() => _majorPublic = v),
            ),
            const SizedBox(height: 32),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // ── AppBar: 우측 상단 로그아웃 버튼
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
          // ── 카카오 이름 표시
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

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFFFCCDD).withOpacity(0.6)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '공개 설정된 정보만 상대방에게 보입니다.\n비공개 정보는 매칭 후에도 숨겨집니다.',
              style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF998899),
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _infoTile({
    required String icon,
    required String label,
    required String value,
    required bool isPublic,
    required ValueChanged<bool> onToggle,
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
          const SizedBox(width: 8),
          _toggleBadge(isPublic, onToggle),
        ],
      ),
    );
  }

  Widget _editableTile({
    required String icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isPublic,
    required ValueChanged<bool> onToggle,
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
          _toggleBadge(isPublic, onToggle),
        ],
      ),
    );
  }

  Widget _toggleBadge(bool isPublic, ValueChanged<bool> onToggle) {
    return GestureDetector(
      onTap: () => onToggle(!isPublic),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isPublic
              ? const Color(0xFFFFE4EF)
              : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPublic
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 13,
              color: isPublic
                  ? const Color(0xFFFF6B9D)
                  : const Color(0xFFAAAAAA),
            ),
            const SizedBox(width: 3),
            Text(
              isPublic ? '공개' : '비공개',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPublic
                      ? const Color(0xFFFF6B9D)
                      : const Color(0xFFAAAAAA)),
            ),
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
