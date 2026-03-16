import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfileView extends StatefulWidget {
  final VoidCallback? onNavigateToChat;
  const ProfileView({super.key, this.onNavigateToChat});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _profileExpanded = true;
  bool _counsellorExpanded = true;

  static const Color _primaryRed = Color(0xFFC00A15);
  static const Color _bgGrey = Color(0xFFF2F3F7);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _borderGrey = Color(0xFFE5E7EB);
  static const Color _sectionLabel = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Page Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
            ),

            // ── USER PROFILE CARD ──────────────────────────────────────
            SliverToBoxAdapter(child: _buildProfileCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── YOUR COUNSELLOR LABEL ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'YOUR COUNSELLOR',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _sectionLabel,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // ── COUNSELLOR CARD ────────────────────────────────────────
            SliverToBoxAdapter(child: _buildCounsellorCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── MENU SECTION 1: Documents / Shortlist / Refer ──────────
            SliverToBoxAdapter(
              child: _buildMenuCard([
                _MenuItem(
                  icon: Icons.description_outlined,
                  label: 'Documents',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.favorite_border_rounded,
                  label: 'Shortlist',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.card_giftcard_outlined,
                  label: 'Refer Now',
                  onTap: () {},
                  isReferral: true,
                ),
              ]),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── MENU SECTION 2: Feedback / Settings ───────────────────
            SliverToBoxAdapter(
              child: _buildMenuCard([
                _MenuItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Give us feedback',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
              ]),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── MENU SECTION 3: Terms / Privacy ───────────────────────
            SliverToBoxAdapter(
              child: _buildMenuCard([
                _MenuItem(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Terms Of Service',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
              ]),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── LOG OUT BUTTON ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLogoutButton(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── VERSION ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'VERSION 3.23.19',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  // ── PROFILE CARD ────────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return _card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar + name/location + chevron
          GestureDetector(
            onTap: () => setState(() => _profileExpanded = !_profileExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D2D2D),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                // Name + Location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medhavi Sharma',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Delhi Cantonment,\nIndia',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: _textGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _profileExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _primaryRed,
                  size: 26,
                ),
              ],
            ),
          ),

          // Expandable content
          if (_profileExpanded) ...[
            const SizedBox(height: 14),
            // Divider
            const Divider(thickness: 0.5, color: _borderGrey, height: 1),
            const SizedBox(height: 14),
            // Summary text
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _textDark,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(text: 'Looking for a '),
                  TextSpan(
                    text: 'Postgraduate',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' Course in '),
                  TextSpan(
                    text: 'Health care, Business',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' by '),
                  TextSpan(
                    text: 'April 2026',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' in '),
                  TextSpan(
                    text: 'United States',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Edit button
            Center(
              child: SizedBox(
                width: 130,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => showEditProfileSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryRed,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── COUNSELLOR CARD ─────────────────────────────────────────────────────────
  Widget _buildCounsellorCard() {
    return _card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar + name/role + chevron
          GestureDetector(
            onTap: () =>
                setState(() => _counsellorExpanded = !_counsellorExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Counsellor avatar (colorful placeholder)
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFF6B5BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    // Online indicator
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF50CE54),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Name + role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medhavi Sharma',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Counsellor',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _counsellorExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _primaryRed,
                  size: 26,
                ),
              ],
            ),
          ),

          // Expandable content
          if (_counsellorExpanded) ...[
            const SizedBox(height: 16),
            // Book a Session button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _bgGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GestureDetector(
                    onTap: widget.onNavigateToChat,
                    child: const Icon(
                      Icons.chat_rounded,
                      color: Colors.grey,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC00A15), Color(0xFFE53935)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Book a Session',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quote
            Text(
              '"Unlocking global horizons, one journey at a time - your passport to educational adventures abroad, where dreams take flight and futures are forged globally!"',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primaryRed,
                height: 1.55,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── MENU CARD ────────────────────────────────────────────────────────────────
  Widget _buildMenuCard(List<_MenuItem> items) {
    return _card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildMenuRow(items[i]),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                thickness: 0.5,
                color: _borderGrey,
                indent: 54,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuRow(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 22,
              color: item.isReferral ? _primaryRed : _textGrey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.isReferral ? _primaryRed : _textDark,
                ),
              ),
            ),
            if (item.isReferral)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'New',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primaryRed,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: _textGrey,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ── LOG OUT BUTTON ───────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(
        Icons.logout_rounded,
        color: Color(0xFFEF4444),
        size: 20,
      ),
      label: Text(
        'Log out',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFEF4444),
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        shape: const StadiumBorder(),
        backgroundColor: Colors.white,
      ),
    );
  }

  // ── CARD HELPER ──────────────────────────────────────────────────────────────
  Widget _card({
    required Widget child,
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

// ── MODEL ────────────────────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isReferral;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isReferral = false,
  });
}
