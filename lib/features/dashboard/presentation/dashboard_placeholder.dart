import 'package:flutter/material.dart';

/// Temporary placeholder shown at the /dashboard route.
/// Will be replaced by the full DashboardPage in Module 2.
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE4ECF2)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 48,
              vertical: 40,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF167D8D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    size: 32,
                    color: Color(0xFF167D8D),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B3A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Module 2 — coming next',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667786),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Stats, charts, and activity feed coming in the next module.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF667786),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
