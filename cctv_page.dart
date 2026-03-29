import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import '../app_colors.dart';



const Map<String, String> cctvPinToUrl = {
  '1234': 'http://10.16.136.81:8080/video',
};

const Map<String, String> cctvPinToName = {'1234': 'Android Cam'};
// ─────────────────────────────────────────────────────────────────────────────

class CctvPage extends StatefulWidget {
  const CctvPage({super.key});
  @override
  State<CctvPage> createState() => _CctvPageState();
}

class _CctvPageState extends State<CctvPage> {
  // ── PIN state ──
  bool _pinVerified = false;
  bool _isSettingPin = false;
  String _enteredPin = '';
  String _savedPin = '';
  String _newPin = '';
  bool _pinLoading = true;
  String? _pinError;

  // ── Stream state ──
  String? _streamUrl;
  String? _streamName;
  bool _streamError = false;
  bool _isMuted = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  // ── Firestore helpers ────────────────────────────────────────────────────

  Future<void> _loadPin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _pinLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final pin = doc.data()?['cctvPin'] as String? ?? '';
      setState(() {
        _savedPin = pin;
        _isSettingPin = pin.isEmpty;
        _pinLoading = false;
      });
    } catch (_) {
      setState(() => _pinLoading = false);
    }
  }

  Future<void> _savePin(String pin) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'cctvPin': pin,
    });
  }

  // ── PIN input logic ──────────────────────────────────────────────────────

  void _onDigit(String digit) {
    if (_isSettingPin) {
      if (_newPin.length < 4) {
        setState(() {
          _newPin += digit;
          _pinError = null;
        });
        if (_newPin.length == 4) setState(() => _enteredPin = '');
      } else {
        if (_enteredPin.length < 4) {
          setState(() {
            _enteredPin += digit;
            _pinError = null;
          });
          if (_enteredPin.length == 4) {
            if (_enteredPin == _newPin) {
              _savePin(_newPin);
              setState(() {
                _savedPin = _newPin;
                _isSettingPin = false;
                _pinVerified = true;
                _streamUrl = cctvPinToUrl[_newPin];
                _streamName = cctvPinToName[_newPin] ?? 'Camera';
                _streamError = _streamUrl == null;
              });
            } else {
              setState(() {
                _pinError = 'PINs do not match. Try again.';
                _newPin = '';
                _enteredPin = '';
              });
            }
          }
        }
      }
    } else {
      if (_enteredPin.length < 4) {
        setState(() {
          _enteredPin += digit;
          _pinError = null;
        });
        if (_enteredPin.length == 4) {
          if (_enteredPin == _savedPin) {
            setState(() {
              _pinVerified = true;
              _streamUrl = cctvPinToUrl[_enteredPin];
              _streamName = cctvPinToName[_enteredPin] ?? 'Camera';
              _streamError = _streamUrl == null;
            });
          } else {
            setState(() {
              _pinError = 'Wrong PIN. Try again.';
              _enteredPin = '';
            });
          }
        }
      }
    }
  }

  void _onBackspace() {
    if (_isSettingPin) {
      if (_newPin.length < 4) {
        setState(() {
          if (_newPin.isNotEmpty)
            _newPin = _newPin.substring(0, _newPin.length - 1);
        });
      } else {
        setState(() {
          if (_enteredPin.isNotEmpty)
            _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        });
      }
    } else {
      setState(() {
        if (_enteredPin.isNotEmpty)
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _lockScreen() {
    setState(() {
      _pinVerified = false;
      _enteredPin = '';
      _streamUrl = null;
      _streamName = null;
      _streamError = false;
      _isFullscreen = false;
    });
  }

  void _refreshStream() {
    final url = _streamUrl;
    setState(() => _streamUrl = null);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _streamUrl = url);
    });
  }

  // ── Computed getters ─────────────────────────────────────────────────────

  int get _filledDots => _isSettingPin
      ? (_newPin.length < 4 ? _newPin.length : _enteredPin.length)
      : _enteredPin.length;

  String get _pinTitle => _isSettingPin
      ? (_newPin.length < 4 ? 'Set your CCTV PIN' : 'Confirm your PIN')
      : 'CCTV Live Access';

  String get _pinSubtitle => _isSettingPin
      ? (_newPin.length < 4
            ? 'Choose a 4-digit PIN to protect your CCTV'
            : 'Re-enter the PIN to confirm')
      : 'Enter your unique 4-digit PIN to access your live camera feed';

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_pinLoading) {
      return const Center(child: CircularProgressIndicator(color: kTeal));
    }
    if (!_pinVerified) return _buildPinScreen();
    return _isFullscreen ? _buildFullscreenView() : _buildStreamScreen();
  }

  // ── PIN screen ───────────────────────────────────────────────────────────

  Widget _buildPinScreen() => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: kTeal.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam_rounded, color: kTeal, size: 42),
            ),
            const SizedBox(height: 24),
            Text(
              _pinTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _pinSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _filledDots ? kTeal : Colors.transparent,
                    border: Border.all(
                      color: i < _filledDots ? kTeal : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_pinError != null)
              Text(
                _pinError!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              const SizedBox(height: 18),
            const SizedBox(height: 16),
            _buildNumPad(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, size: 13, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  'Your PIN is unique and encrypted',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );

  Widget _buildNumPad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: keys.map((k) {
        if (k.isEmpty) return const SizedBox();
        return Material(
          color: k == '⌫' ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => k == '⌫' ? _onBackspace() : _onDigit(k),
            child: Center(
              child: k == '⌫'
                  ? const Icon(
                      Icons.backspace_outlined,
                      color: Colors.red,
                      size: 22,
                    )
                  : Text(
                      k,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kNavy,
                      ),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Stream screen ────────────────────────────────────────────────────────

  Widget _buildStreamScreen() => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CCTV Live Stream',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _streamName != null
                        ? 'Viewing: $_streamName'
                        : 'Your secured private feed',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Lock button
            GestureDetector(
              onTap: _lockScreen,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kNavy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_rounded, color: kNavy, size: 20),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── LIVE STREAM CONTAINER ──────────────────────────────────────
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: kTeal.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ── MJPEG player or error/placeholder ──
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _buildMjpegPlayer(height: 220),
              ),

              // ── LIVE badge & cam name (top bar) ──
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    // LIVE pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kTeal.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Cam name pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _streamName ?? 'Camera',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Action buttons (bottom bar) ──
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CctvBtn(
                      icon: Icons.screenshot_monitor_rounded,
                      label: 'Snapshot',
                      color: kSky,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Snapshot feature coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _CctvBtn(
                      icon: _isMuted
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      label: _isMuted ? 'Unmute' : 'Mute',
                      color: kOrange,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    const SizedBox(width: 12),
                    _CctvBtn(
                      icon: Icons.refresh_rounded,
                      label: 'Refresh',
                      color: kTeal,
                      onTap: _refreshStream,
                    ),
                    const SizedBox(width: 12),
                    _CctvBtn(
                      icon: Icons.fullscreen_rounded,
                      label: 'Fullscreen',
                      color: kPurple,
                      onTap: () => setState(() => _isFullscreen = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Stream URL status card ─────────────────────────────────────
        if (_streamUrl != null)
          _buildStatusCard(
            icon: '🟢',
            title: 'Stream Active',
            subtitle: 'Connected to your camera tunnel',
            color: kGreen,
          )
        else
          _buildStatusCard(
            icon: '🔴',
            title: 'Stream Not Configured',
            subtitle: 'No URL found for your PIN. Contact admin.',
            color: Colors.red,
          ),

        const SizedBox(height: 16),

        // ── Info rows card ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _infoRow('🛡', 'Access', 'Private – PIN Protected'),
              const Divider(height: 16),
              _infoRow('🔗', 'Connection', 'Encrypted Tunnel (HTTPS)'),
              const Divider(height: 16),
              _infoRow('📡', 'Protocol', 'MJPEG over HTTP'),
              const Divider(height: 16),
              _infoRow('👤', 'User', 'You (Pet Owner)'),
              const Divider(height: 16),
              _infoRow('📷', 'Feed type', 'Real-time Live Stream'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Security note ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kGreen.withOpacity(0.25)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🛡', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your feed is private and secured. Only you can access it with your unique PIN. Admin can reset your PIN if needed.',
                  style: TextStyle(fontSize: 12, color: kGreen, height: 1.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    ),
  );

  // ── Fullscreen view ──────────────────────────────────────────────────────

  Widget _buildFullscreenView() => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // Full-screen MJPEG stream
        Center(child: _buildMjpegPlayer(height: null)),

        // Top-left: back button
        Positioned(
          top: 48,
          left: 16,
          child: GestureDetector(
            onTap: () => setState(() => _isFullscreen = false),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fullscreen_exit_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        // Top-right: LIVE badge
        Positioned(
          top: 48,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kTeal.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom: cam name
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _streamName ?? 'Camera',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ── MJPEG player widget ──────────────────────────────────────────────────

  /// Renders the MJPEG stream if [_streamUrl] is set, otherwise shows a
  /// placeholder or error state.  Pass [height] for fixed-height containers;
  /// pass null for fullscreen (SizedBox.expand).
  Widget _buildMjpegPlayer({required double? height}) {
    final Widget content;

    if (_streamUrl == null) {
      // No URL mapped to this PIN
      content = _buildStreamPlaceholder(
        icon: Icons.videocam_off_rounded,
        message: 'Stream URL not configured.\nContact your admin.',
        iconColor: Colors.redAccent,
      );
    } else {
      content = Mjpeg(
        stream: _streamUrl!,
        isLive: true,
        fit: BoxFit.cover,
        loading: (context) => _buildStreamPlaceholder(
          icon: Icons.wifi_tethering_rounded,
          message: 'Connecting to stream…',
          iconColor: kTeal,
          showSpinner: true,
        ),
        error: (context, error, stack) => _buildStreamPlaceholder(
          icon: Icons.signal_wifi_bad_rounded,
          message: 'Unable to load stream.\nTap Refresh to retry.',
          iconColor: Colors.orangeAccent,
          actionLabel: 'Refresh',
          onAction: _refreshStream,
        ),
      );
    }

    if (height != null) {
      return SizedBox(width: double.infinity, height: height, child: content);
    }
    return SizedBox.expand(child: content);
  }

  /// Dark placeholder shown while loading or on error.
  Widget _buildStreamPlaceholder({
    required IconData icon,
    required String message,
    required Color iconColor,
    bool showSpinner = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0D1B2A), Color(0xFF163050)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner)
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(color: kTeal, strokeWidth: 3),
            )
          else
            Icon(icon, color: iconColor, size: 48),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.5),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kTeal.withOpacity(0.5)),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: kTeal,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  // ── Helper widgets ───────────────────────────────────────────────────────

  Widget _buildStatusCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _infoRow(String icon, String label, String value) => Row(
    children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 10),
      Text(
        '$label: ',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kNavy,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────

/// Small circular icon button used in the stream overlay.
class _CctvBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _CctvBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
