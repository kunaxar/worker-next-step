import 'package:flutter/material.dart';
import 'data.dart';
import 'shared.dart';

// ---------------- shared trade picker ----------------
Widget tradePicker() => SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: trades.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ChoiceChip(label: Text('${trades[i].emoji} ${trades[i].name}'), selected: tradeIdx.value == i, onSelected: (_) => tradeIdx.value = i),
      ),
    );

// ---------------- Pay ----------------
class PayTab extends StatelessWidget {
  const PayTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = trades[tradeIdx.value];
    final hourly = (t.median / 2080);
    final sorted = [...trades]..sort((a, b) => b.median.compareTo(a.median));
    final maxV = sorted.first.median;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      title('What it pays', 'Typical pay for ${t.name.toLowerCase()}s in the US'),
      tradePicker(),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('\$${hourly.toStringAsFixed(2)} an hour', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: orange)),
              const SizedBox(height: 4),
              Text('${money(t.median)} a year, middle of the pack', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              const Text('Half of workers earn more, half earn less. Local pay can be higher or lower. Not a promise of what you will earn.', style: TextStyle(fontSize: 13, color: grey)),
              const Divider(height: 28),
              Text('${money(t.jobs)} people work as ${t.name.toLowerCase()}s across the US. Average: ${money(t.mean)} a year.', style: const TextStyle(fontSize: 13.5)),
            ]),
          ),
        ),
      ),
      const Padding(padding: EdgeInsets.fromLTRB(20, 14, 20, 8), child: Text('How trades compare (yearly median)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
      for (final s in sorted)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: InkWell(
            onTap: () => tradeIdx.value = trades.indexOf(s),
            child: Row(children: [
              SizedBox(width: 120, child: Text(s.name, style: TextStyle(fontSize: 12.5, fontWeight: s == t ? FontWeight.w800 : FontWeight.w400), overflow: TextOverflow.ellipsis)),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(minHeight: 14, value: s.median / maxV, color: s == t ? orange : const Color(0xFFCBD2D9), backgroundColor: const Color(0xFFF0EAE0)))),
              SizedBox(width: 62, child: Text(money(s.median), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
            ]),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          const Expanded(child: Text('Source: US Bureau of Labor Statistics, Occupational Employment and Wage Statistics, national estimates for 2025.', style: TextStyle(fontSize: 12, color: grey))),
          TextButton(onPressed: () => open('https://www.bls.gov/oes/'), child: const Text('bls.gov')),
        ]),
      ),
    ]);
  }
}

// ---------------- Next step ----------------
const zoneText = {
  2: ['Some training needed', 'Usually a high school diploma or GED, though some jobs do not need one. Training runs from a few days to one year on the job.'],
  3: ['Training plus experience', "Most jobs in this group need vocational school, related work experience, or an associate's degree. One or two years of on-the-job learning, and an apprenticeship may be part of it."],
};

class NextTab extends StatelessWidget {
  const NextTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = trades[tradeIdx.value];
    final z = zoneText[t.zone] ?? ['', ''];
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      title('Your next step', 'Where ${t.name.toLowerCase()}s go from here'),
      tradePicker(),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('HOW PEOPLE GET IN', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: orange)),
              const SizedBox(height: 6),
              Text(z[0], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(z[1], style: const TextStyle(fontSize: 14)),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SIMILAR WORK YOU COULD MOVE INTO', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: orange)),
              const SizedBox(height: 8),
              for (final r in t.related)
                Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [const Icon(Icons.arrow_forward, size: 16), const SizedBox(width: 8), Expanded(child: Text(r, style: const TextStyle(fontSize: 14.5)))])),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('FIND HELP NEAR YOU', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: orange)),
              const SizedBox(height: 10),
              linkBtn(Icons.handshake_outlined, 'Find an apprenticeship', 'Opens Apprenticeship.gov', 'https://www.apprenticeship.gov/apprenticeship-job-finder'),
              linkBtn(Icons.school_outlined, 'Find training near you', 'Opens CareerOneStop', 'https://www.careeronestop.org/Toolkit/Training/find-local-training.aspx'),
              linkBtn(Icons.verified_outlined, 'Look up a certification', 'Opens CareerOneStop', 'https://www.careeronestop.org/Toolkit/Training/find-certifications.aspx'),
              linkBtn(Icons.info_outline, 'Read the full job profile', 'Opens O*NET OnLine', 'https://www.onetonline.org/link/summary/${t.soc}'),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Text(
          'These open outside websites. This prototype copies none of their listings.\n\n'
          'This page includes information from the O*NET 31.0 Database by the U.S. Department of Labor, Employment and Training Administration (USDOL/ETA). Used under the CC BY 4.0 license. O*NET is a trademark of USDOL/ETA. This prototype has modified all or some of this information (selected, reordered, shown in a different layout). USDOL/ETA has not approved, endorsed, or tested these modifications.',
          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
        ),
      ),
    ]);
  }

  Widget linkBtn(IconData i, String t, String s, String url) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: const Color(0xFFFFE3CF), child: Icon(i, color: orange)),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(s, style: const TextStyle(fontSize: 12.5)),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => open(url),
      );
}
