import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';

const orange = Color(0xFFE8590C);
const ink = Color(0xFF1F2933);
const sand = Color(0xFFFAF6F0);
const grey = Color(0xFF52606D);

// "Today" is fixed so the fictional demo dates always read the same.
final today = DateTime(2026, 10, 15);

class Work {
  final Trade trade;
  final String employer, period;
  final List<String> done;
  String status; // self, requested
  Work(this.trade, this.employer, this.period, this.done, {this.status = 'self'});
}

class Cred {
  final String name, type, issuer;
  final DateTime? expires;
  final bool verified;
  final Color color;
  final String? id;
  Cred(this.name, this.type, this.issuer, this.expires, this.verified, this.color, {this.id});
}

final List<Cred> creds = [
  Cred('NCCER Core', 'Certificate', 'NCCER (demo)', null, true, const Color(0xFF1C7ED6), id: 'DEMO-0001'),
  Cred('Forklift Operator', 'Certificate', 'Demo Training Co.', DateTime(2026, 11, 18), false, const Color(0xFFE8590C), id: 'DEMO-0002'),
  Cred('First Aid / CPR', 'Training', 'Demo Safety Org', DateTime(2027, 4, 2), false, const Color(0xFF9C36B5)),
  Cred('Fall Protection', 'Training', 'Demo Safety Org', DateTime(2026, 9, 30), false, const Color(0xFF2B8A3E)),
];

final List<Work> works = [
  Work(trades[0], 'Brightline Electric (demo)', '2023 - now', [trades[0].tasks[0], trades[0].tasks[1], trades[0].tasks[4]]),
];

final ValueNotifier<int> tradeIdx = ValueNotifier(0);
final ValueNotifier<int> rev = ValueNotifier(0);
bool shareCreds = true, shareWork = true, hasTradeHeadline = true;

String money(int v) => '\$${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String dmy(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';

Future<void> open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

Widget title(String t, [String? sub]) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
        if (sub != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(sub, style: const TextStyle(fontSize: 15, color: grey))),
      ]),
    );

Widget demoBanner() => Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFFFF3BF), borderRadius: BorderRadius.circular(10)),
      child: const Text('Prototype. Fictional worker and records. Not connected to any real account.', style: TextStyle(fontSize: 12.5, color: ink)),
    );

Widget pill(String text, Color bg, Color fg, [IconData? icon]) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );

// Expiry and verification are separate labels, each a word plus a color.
Widget expiryPill(Cred c, {bool onDark = false}) {
  if (c.expires == null) return pill('No expiry date', const Color(0xFFE4E7EB), ink);
  final days = c.expires!.difference(today).inDays;
  if (days < 0) return pill('Expired ${dmy(c.expires!)}', const Color(0xFFFFE3E3), const Color(0xFFC92A2A), Icons.error_outline);
  if (days <= 60) return pill('Expires ${dmy(c.expires!)}', const Color(0xFFFFF0C2), const Color(0xFF8A5A00), Icons.schedule);
  return pill('Expires ${dmy(c.expires!)}', const Color(0xFFE0F5E6), const Color(0xFF1F6B33), Icons.event_available);
}

Widget verifyPill(Cred c) => c.verified
    ? pill('Verified', const Color(0xFFE0ECFF), const Color(0xFF1C5FB8), Icons.verified)
    : pill('Not verified', const Color(0xFFE4E7EB), ink);

Widget softBanner(String msg, {VoidCallback? retry}) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFF3BF), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13.5))),
        if (retry != null) TextButton(onPressed: retry, child: const Text('Try again')),
      ]),
    );
