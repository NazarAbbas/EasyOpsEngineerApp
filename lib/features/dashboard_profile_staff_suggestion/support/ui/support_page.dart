import 'package:easy_ops/features/dashboard_profile_staff_suggestion/support/controller/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportPage extends GetView<SupportController> {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final c = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              // Device / App info
              _Card(
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                child: Obx(() {
                  final last = c.lastSync.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Software Version'),
                      Row(
                        children: [
                          Expanded(
                            child: _Value.rich([
                              TextSpan(
                                text: c.softwareVersion.value,
                                style: _bold,
                              ),
                              const TextSpan(
                                text: '   Latest Version Installed',
                              ),
                            ]),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFF2F6BFF),
                            ),
                            onPressed: c.refreshSoftware,
                            tooltip: 'Check updates',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Label('Device Model'),
                      _Value.text(c.deviceModel.value),
                      const SizedBox(height: 12),
                      _Label('OS Version'),
                      _Value.text(c.osVersion.value),
                      const SizedBox(height: 12),
                      _Label('Last Sync'),
                      Row(
                        children: [
                          Expanded(
                            child: _Value.text(
                              '${_hhmm(last)} | ${_ddmmyyyy(last)}',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFF2F6BFF),
                            ),
                            onPressed: c.refreshSync,
                            tooltip: 'Sync now',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Label('Connectivity Status'),
                      Row(
                        children: const [
                          _ValueText('Online'),
                          SizedBox(width: 8),
                          Icon(
                            Icons.signal_cellular_alt_rounded,
                            size: 16,
                            color: Color(0xFF2F6BFF),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.wifi_rounded,
                            size: 16,
                            color: Color(0xFF2F6BFF),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Contact panel
              _Card(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    const Text(
                      'Send your queries or suggestions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2D2F39),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: c.sendEmail,
                            icon: const Icon(Icons.mail_outline_rounded),
                            label: const Text('via Email'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: BorderSide(color: primary),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: c.callSupport,
                            icon: const Icon(Icons.call_rounded),
                            label: const Text('via Call'),
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Support Material
              _Card(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Column(
                  children: [
                    const Text(
                      'Support Material',
                      style: TextStyle(
                        color: Color(0xFF2D2F39),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Column(
                        children: controller.docs
                            .map(
                              (d) => _MaterialTile(
                                doc: d,
                                onTap: () => controller.openDoc(d),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======= Helpers & Widgets =======

const _bold = TextStyle(fontWeight: FontWeight.w800);

String _hhmm(DateTime dt) => dt.toLocal().toString().substring(11, 16); // HH:mm
String _ddmmyyyy(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        color: Color(0xFF7C8698),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Value {
  static Widget text(String value) =>
      const _ValueText(null, inline: false).withText(value);
  static Widget rich(List<TextSpan> spans) => RichText(
    text: TextSpan(
      style: const TextStyle(color: Color(0xFF2D2F39), fontSize: 13.5),
      children: spans,
    ),
  );
}

class _ValueText extends StatelessWidget {
  final String? text;
  final bool inline;
  const _ValueText(this.text, {this.inline = true});

  Widget withText(String t) => _ValueText(t, inline: inline);

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D2F39),
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final SupportDoc doc;
  final VoidCallback onTap;
  const _MaterialTile({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPdf = doc.type == DocType.pdf;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: isPdf
                ? _PdfBadge()
                : const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFEAF2FF),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF2F6BFF),
                    ),
                  ),
            title: Text(
              doc.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2F39),
              ),
            ),
            subtitle: Text(
              '${doc.pages} Pages',
              style: const TextStyle(
                color: Color(0xFF7C8698),
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF7C8698),
            ),
          ),
        ),
      ),
    );
  }
}

class _PdfBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFEB4B4B),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'PDF',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
