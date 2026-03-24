import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../widgets/dashboard_shell.dart';

// Admin-managed PIN → tunnel stream URL map
const Map<String, String> cctvPinToUrl = {
  '1234': 'https://your-tunnel.ngrok.io/stream/cam1',
  '5678': 'https://your-tunnel.ngrok.io/stream/cam2',
  '9012': 'https://your-tunnel.ngrok.io/stream/cam3',
};

class CctvPage extends StatefulWidget {
  const CctvPage({super.key});
  @override
  State<CctvPage> createState() => _CctvPageState();
}

class _CctvPageState extends State<CctvPage> {
  bool _pinVerified = false;
  bool _isSettingPin = false;
  String _enteredPin = '';
  String _savedPin = '';
  String _newPin = '';
  bool _pinLoading = true;
  String? _pinError;
  String? _streamUrl;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final pin = doc.data()?['cctvPin'] ?? '';
    setState(() {
      _savedPin = pin;
      _isSettingPin = pin.isEmpty;
      _pinLoading = false;
    });
  }

  Future<void> _savePin(String pin) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'cctvPin': pin,
    });
  }

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
                _pinVerified = true;
                _isSettingPin = false;
                _streamUrl = cctvPinToUrl[_newPin];
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
      if (_newPin.length < 4)
        setState(() {
          if (_newPin.isNotEmpty)
            _newPin = _newPin.substring(0, _newPin.length - 1);
        });
      else
        setState(() {
          if (_enteredPin.isNotEmpty)
            _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        });
    } else {
      setState(() {
        if (_enteredPin.isNotEmpty)
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (_pinLoading)
      return const Center(child: CircularProgressIndicator(color: kTeal));
    if (!_pinVerified) return _buildPinScreen();
    return _buildStreamScreen();
  }

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
              ),
            if (_pinError == null) const SizedBox(height: 18),
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

  Widget _buildStreamScreen() => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CCTV Live Stream',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kNavy,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your secured private feed',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _pinVerified = false;
                _enteredPin = '';
              }),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
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
                        const Text('📷', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 10),
                        Text(
                          _streamUrl != null
                              ? 'Live Feed – Indoor Cam 1'
                              : 'Stream URL not configured',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _streamUrl != null
                                ? Colors.white70
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Row(
                  children: [
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Indoor Cam 1',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
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
                    ),
                    const SizedBox(width: 12),
                    _CctvBtn(
                      icon: Icons.mic_off_rounded,
                      label: 'Mute',
                      color: kOrange,
                    ),
                    const SizedBox(width: 12),
                    _CctvBtn(
                      icon: Icons.refresh_rounded,
                      label: 'Refresh',
                      color: kTeal,
                    ),
                    const SizedBox(width: 12),
                    _CctvBtn(
                      icon: Icons.fullscreen_rounded,
                      label: 'Fullscreen',
                      color: kPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
              _infoRow('👤', 'User', 'You (Pet Owner)'),
              const Divider(height: 16),
              _infoRow('📷', 'Feed type', 'Real-time Live Stream'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kGreen.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🛡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Your feed is private and secured. Only you can access it with your unique PIN. Admin can reset your PIN if needed.',
                  style: TextStyle(fontSize: 12, color: kGreen, height: 1.5),
                ),
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

class _CctvBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CctvBtn({
    required this.icon,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Column(
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
  );
}
