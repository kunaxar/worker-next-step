import 'package:flutter/material.dart';
import 'shared.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final steps = [('Add a trade', works.isNotEmpty), ('Add a credential', creds.isNotEmpty), ('Add what you did on a job', works.any((w) => w.done.isNotEmpty)), ('Ask a supervisor to confirm a job', works.any((w) => w.status != 'self'))];
    final doneN = steps.where((s) => s.$2).length;
    final nextStep = steps.firstWhere((s) => !s.$2, orElse: () => ('', true)).$1;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      demoBanner(),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Row(children: [
          const CircleAvatar(radius: 34, backgroundColor: orange, child: Text('M', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Marcus (demo)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            works.isEmpty ? TextButton(onPressed: () {}, child: const Text('+ Add your trade')) : Text('${works.first.trade.name}  |  ${works.length} ${works.length == 1 ? 'job' : 'jobs'} added', style: const TextStyle(color: grey)),
          ])),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(children: [
          Expanded(child: stat('${works.length}', 'Jobs added')),
          const SizedBox(width: 10),
          Expanded(child: stat('${creds.length}', 'Credentials')),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Profile strength: $doneN of ${steps.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(minHeight: 12, value: doneN / steps.length, color: orange, backgroundColor: const Color(0xFFEDE5DA))),
              const SizedBox(height: 10),
              Text(nextStep.isEmpty ? 'All set for now.' : 'Next: $nextStep', style: const TextStyle(fontSize: 14)),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: Column(children: [
          SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                  style: FilledButton.styleFrom(textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo: nothing was sent.'))),
                  child: const Text('Share my profile'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 48, child: OutlinedButton(onPressed: () => preview(context), child: const Text('Preview what others see'))),
        ]),
      ),
      const Padding(padding: EdgeInsets.fromLTRB(20, 12, 20, 0), child: Text('What visitors can see', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
      SwitchListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20), title: const Text('Credentials'), value: shareCreds, onChanged: (v) => setState(() => shareCreds = v)),
      SwitchListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20), title: const Text('Work experience'), value: shareWork, onChanged: (v) => setState(() => shareWork = v)),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('My organizations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Renewal reminders and company invites land here.', style: TextStyle(color: grey)),
              const SizedBox(height: 10),
              FilledButton.tonal(onPressed: () {}, child: const Text('Enter a company code')),
            ]),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Text('Account settings (language, delete account) would live on their own screen, away from Log out. Not built in this demo.', style: TextStyle(fontSize: 12.5, color: grey)),
      ),
    ]);
  }

  Widget stat(String n, String l) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: orange)), Text(l, style: const TextStyle(color: grey))])));

  void preview(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('What others see', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 10),
              const Text('Marcus (demo)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              if (shareCreds) for (final c in creds.take(3)) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• ${c.name} - ${c.verified ? 'Verified' : 'Not verified'}')),
              if (shareWork) for (final w in works) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• ${w.trade.name}, ${w.employer} (${w.status == 'self' ? 'self-described' : 'waiting for supervisor'})')),
              if (!shareCreds && !shareWork) const Text('Nothing is shared right now.'),
            ]),
          ));
}
