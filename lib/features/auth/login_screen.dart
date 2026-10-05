import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/providers/app_provider.dart';
import 'package:trainer_app/widgets/common_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _idController = TextEditingController(text: 'TR-DEMO-001');
  final _passController = TextEditingController(text: '••••••••••••');
  bool _isLoading = false;
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _idController.dispose();
    _passController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      ref.read(isLoggedInProvider.notifier).state = true;
    }
  }

  Future<void> _demoLogin() async {
    setState(() => _isLoading = true);
    ref.read(demoModeProvider.notifier).state = true;
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ref.read(isLoggedInProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 960;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient gradient orb
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.teal.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 550,
              height: 550,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.blue.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: isWide ? _wideLayout() : _narrowLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        // Left Showcase Panel
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.navyBorder.withValues(alpha: 0.7), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BrandHeader(),
                const SizedBox(height: 56),
                const Text(
                  'Train Smarter.\nDetect Hazards Faster.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: const Text(
                    'Next-generation diagnostic & safety simulator for skilled industrial trades. Real-time telemetry, simulated hazard injections, and AI-driven coaching.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                _FeaturePillRow(
                  icon: Icons.sensors_outlined,
                  title: 'Multi-Sensor Telemetry Fusion',
                  desc: 'High-frequency Methane, CO & H2S ppm monitoring',
                ),
                const SizedBox(height: 16),
                _FeaturePillRow(
                  icon: Icons.radar_outlined,
                  title: 'Autonomous Drone Flight HUD',
                  desc: 'Live waypoint navigation with manual hazard injection',
                ),
                const SizedBox(height: 16),
                _FeaturePillRow(
                  icon: Icons.psychology_outlined,
                  title: 'AI Diagnostic Coach',
                  desc: 'Personalized rubric analysis & trainee remediation',
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    const PulseDot(color: AppColors.safe, size: 7),
                    const SizedBox(width: 8),
                    Text(
                      'SYSTEM OPERATIONAL  •  READY FOR TRAINER SIGN-IN',
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Right Login Form Panel
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _loginCard(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              _BrandHeader(),
              const SizedBox(height: 32),
              _loginCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'TRAINER PORTAL',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your credentials to access the mission cockpit',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 28),
          // Trainer ID Input
          const Text(
            'TRAINER ID',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _idController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'e.g. TR-DEMO-001',
              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(height: 20),
          // Password Input
          const Text(
            'SECURITY PASSWORD',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passController,
            obscureText: _obscure,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 26),
          // Sign In Primary Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: const Color(0xFF080A0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF080A0F),
                        strokeWidth: 2.2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Launch Dashboard',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.navyBorder.withValues(alpha: 0.7))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'OR QUICK EVALUATION',
                  style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.navyBorder.withValues(alpha: 0.7))),
            ],
          ),
          const SizedBox(height: 20),
          // 1-Click Demo Evaluation Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _demoLogin,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5), width: 1),
                backgroundColor: AppColors.warning.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.bolt, size: 18),
              label: const Text(
                'Explore Live Demo Prototype',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.navyLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.navyBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Preconfigured demo trainer profile with populated telemetry, active sessions, and AI Coach models.',
                    style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.teal, AppColors.blue],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.radar, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'SkillSense AI',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'v1.0',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Diagnostic & Safety Training Platform',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeaturePillRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeaturePillRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.navyLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.navyBorder),
          ),
          child: Icon(icon, color: AppColors.teal, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
