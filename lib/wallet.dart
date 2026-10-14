import 'package:flutter/material.dart';
import 'shared.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});
  @override
  Widget build(BuildContext context) {
    final withExp = creds.where((c) => c.expires != null && !c.expires!.isBefore(today)).toList()..sort((a, b) => a.expires!.compareTo(b.expires!));
    final attention = [...creds.where((c) => c.expires != null)].where((c) => c.expires!.difference(today).inDays <= 60).toList()..sort((a, b) => a.expires!.compareTo(b.expires!));
    final rest = creds.where((c) => !attention.contains(c)).toList();
    final next = withExp.isEmpty ? null : withExp.first;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      demoBanner(),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${creds.length} saved credentials', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: ink)),
          const SizedBox(height: 2),
          Text(next == null ? 'No expiry dates yet' : 'Next expiry ${dmy(next.expires!)}', style: const TextStyle(fontSize: 16, color: grey)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(children: [
          Expanded(
              child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                      style: FilledButton.styleFrom(textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () async {
                        final c = await Navigator.push<Cred>(context, MaterialPageRoute(builder: (_) => const AddCred()));
                        if (c != null) {
                          creds.add(c);
                          rev.value++;
                          if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => CardAdded(c)));
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add a credential')))),
          const SizedBox(width: 10),
          SizedBox(height: 56, width: 56, child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Icon(Icons.search))),
        ]),
      ),
      if (attention.isNotEmpty) ...[
        const Padding(padding: EdgeInsets.fromLTRB(20, 14, 20, 8), child: Text('Needs attention', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
        for (final c in attention) Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: CredCard(c)),
      ],
      if (rest.isNotEmpty) ...[
        const Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 8), child: Text('Everything else', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
        for (final c in rest) Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: CredCard(c)),
      ],
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Text('A valid expiry date does not mean a job\'s requirements are met. The employer decides that.', style: TextStyle(fontSize: 12.5, color: grey)),
      ),
    ]);
  }
}

class CredCard extends StatelessWidget {
  final Cred c;
  final bool tappable;
  const CredCard(this.c, {super.key, this.tappable = true});
  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border(left: BorderSide(color: c.color, width: 8))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: c.color, child: Text(c.issuer.isEmpty ? '?' : c.issuer[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          const SizedBox(width: 10),
          Expanded(child: Text(c.issuer.isEmpty ? 'Issuer' : c.issuer, style: const TextStyle(color: grey, fontSize: 13))),
          Text(c.type, style: const TextStyle(color: grey, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        Text(c.name.isEmpty ? 'Credential name' : c.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, children: [expiryPill(c), verifyPill(c)]),
      ]),
    );
    if (!tappable) return card;
    return InkWell(borderRadius: BorderRadius.circular(20), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CredDetail(c))), child: card);
  }
}

class FakeQr extends StatelessWidget {
  const FakeQr({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size(150, 150), painter: _QrPainter());
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = ink;
    const n = 21;
    final u = s.width / n;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final finder = (x < 7 && y < 7) || (x > 13 && y < 7) || (x < 7 && y > 13);
        bool on;
        if (finder) {
          final fx = x < 7 ? x : x - 14, fy = y < 7 ? y : y - 14;
          on = fx == 0 || fx == 6 || fy == 0 || fy == 6 || (fx >= 2 && fx <= 4 && fy >= 2 && fy <= 4);
        } else {
          on = ((x * 7 + y * 13 + x * y) % 5) < 2;
        }
        if (on) canvas.drawRect(Rect.fromLTWH(x * u, y * u, u, u), p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class CredDetail extends StatelessWidget {
  final Cred c;
  const CredDetail(this.c, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: sand, actions: [
          PopupMenuButton<String>(
              onSelected: (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo: not wired up'))),
              itemBuilder: (_) => const [PopupMenuItem(value: 'e', child: Text('Edit')), PopupMenuItem(value: 'h', child: Text('Hide from my profile')), PopupMenuItem(value: 'a', child: Text('Archive'))]),
        ]),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
              CredCard(c, tappable: false),
              const SizedBox(height: 16),
              SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                      style: FilledButton.styleFrom(textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () => showShare(context, c),
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Share this credential'))),
              const SizedBox(height: 20),
              Center(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const FakeQr())),
              const Padding(padding: EdgeInsets.only(top: 6), child: Center(child: Text('Demo QR, not scannable', style: TextStyle(fontSize: 12, color: grey)))),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    row('Issued by', c.issuer),
                    row('Type', c.type),
                    row('Expiry', c.expires == null ? 'No expiry date' : dmy(c.expires!)),
                    c.id == null ? Row(children: [const Expanded(child: Text('Credential ID', style: TextStyle(color: grey))), TextButton(onPressed: () {}, child: const Text('Add ID'))]) : row('Credential ID', c.id!),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      );
  Widget row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Expanded(child: Text(a, style: const TextStyle(color: grey))), Text(b, style: const TextStyle(fontWeight: FontWeight.w700))]));
}

void showShare(BuildContext context, Cred c) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Here is what others will see', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 12),
          CredCard(c, tappable: false),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo: nothing was sent.')));
                  },
                  child: const Text('Share'))),
          const SizedBox(height: 4),
          Center(child: TextButton(onPressed: () {}, child: const Text('Still stuck? Tell us'))),
        ]),
      );
    }),
  );
}

class CardAdded extends StatelessWidget {
  final Cred c;
  const CardAdded(this.c, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🎉', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                const Text('Card added', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${creds.length} credentials saved', style: const TextStyle(color: grey, fontSize: 16)),
                const SizedBox(height: 20),
                CredCard(c, tappable: false),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 56, child: FilledButton.icon(onPressed: () => showShare(context, c), icon: const Icon(Icons.ios_share), label: const Text('Share it'))),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to my cards')),
              ]),
            ),
          ),
        ),
      );
}

class AddCred extends StatefulWidget {
  const AddCred({super.key});
  @override
  State<AddCred> createState() => _AddCredState();
}

class _AddCredState extends State<AddCred> {
  int step = 0;
  String type = '';
  String issuer = '';
  final name = TextEditingController();
  final idC = TextEditingController();
  final search = TextEditingController();
  DateTime? issued, expiry;
  bool noExpiry = false;
  static const types = [('Certificate', '📜'), ('License', '🪪'), ('Education', '🎓'), ('Training', '🦺'), ('Membership', '🤝'), ('Other', '📎')];
  static const issuers = ['NCCER', 'OSHA-authorized trainer', '360training', 'Demo Safety Org', 'Demo Training Co.', 'State licensing board'];

  Cred preview() => Cred(name.text, type.isEmpty ? 'Credential' : type, issuer, noExpiry ? null : expiry, false, orange, pending: !noExpiry && expiry == null);

  @override
  Widget build(BuildContext context) {
    final heads = ['What kind of credential?', 'Who issued it?', 'Dates and ID'];
    final can = step == 0 ? type.isNotEmpty : step == 1 ? issuer.isNotEmpty && name.text.trim().isNotEmpty : (noExpiry || expiry != null);
    return Scaffold(
      appBar: AppBar(title: Text('Add a credential  (${step + 1} of 3)'), backgroundColor: sand),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(children: [
            LinearProgressIndicator(minHeight: 8, value: (step + 1) / 3, color: orange, backgroundColor: const Color(0xFFEDE5DA)),
            title(heads[step]),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), child: [stepType(), stepIssuer(), stepDates()][step])),
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: CredCard(preview(), tappable: false)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(children: [
                if (step > 0) OutlinedButton(onPressed: () => setState(() => step--), child: const Text('Back')),
                const Spacer(),
                SizedBox(
                    height: 52,
                    child: FilledButton(
                        onPressed: can
                            ? () {
                                if (step < 2) {
                                  setState(() => step++);
                                } else {
                                  Navigator.pop(context, Cred(name.text.trim(), type, issuer, noExpiry ? null : expiry, false, orange, id: idC.text.trim().isEmpty ? null : idC.text.trim()));
                                }
                              }
                            : null,
                        child: Text(step == 2 ? 'Save card' : 'Next'))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget stepType() => Wrap(spacing: 10, runSpacing: 10, children: [
        for (final t in types)
          InkWell(
            onTap: () => setState(() => type = t.$1),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 140,
              height: 92,
              decoration: BoxDecoration(color: type == t.$1 ? const Color(0xFFFFE3CF) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: type == t.$1 ? orange : const Color(0xFFEDE5DA), width: type == t.$1 ? 2 : 1)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(t.$2, style: const TextStyle(fontSize: 28)), const SizedBox(height: 4), Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w700))]),
            ),
          ),
      ]);

  Widget stepIssuer() {
    final q = search.text.toLowerCase();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), hintText: 'Search issuers', filled: true, fillColor: Colors.white)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [for (final i in issuers.where((i) => i.toLowerCase().contains(q))) ChoiceChip(label: Text(i), selected: issuer == i, onSelected: (_) => setState(() => issuer = i))]),
      const SizedBox(height: 16),
      TextField(controller: name, onChanged: (_) => setState(() {}), decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Credential name', filled: true, fillColor: Colors.white)),
    ]);
  }

  Widget stepDates() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
            tileColor: Colors.white,
            title: const Text('Issue date'),
            trailing: Text(issued == null ? 'Pick' : dmy(issued!), style: const TextStyle(fontWeight: FontWeight.w700)),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: today, firstDate: DateTime(2000), lastDate: today);
              if (d != null) setState(() => issued = d);
            }),
        const SizedBox(height: 8),
        ListTile(
            tileColor: Colors.white,
            title: const Text('Expiry date'),
            trailing: Text(noExpiry ? 'None' : expiry == null ? 'Pick' : dmy(expiry!), style: const TextStyle(fontWeight: FontWeight.w700)),
            onTap: noExpiry
                ? null
                : () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime(2028), firstDate: DateTime(2020), lastDate: DateTime(2040));
                    if (d != null) setState(() => expiry = d);
                  }),
        SwitchListTile(title: const Text('This card has no expiry date'), value: noExpiry, onChanged: (v) => setState(() => noExpiry = v)),
        const Text('Read the date from your card. We only suggest an expiry when the issuer supplies it, and you confirm it.', style: TextStyle(fontSize: 12.5, color: grey)),
        const SizedBox(height: 12),
        TextField(controller: idC, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Credential ID (optional)', filled: true, fillColor: Colors.white)),
      ]);
}
