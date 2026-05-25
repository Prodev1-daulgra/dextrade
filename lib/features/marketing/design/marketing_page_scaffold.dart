import 'package:flutter/material.dart';
import 'marketing_ambient_scene.dart';

class MarketingPageScaffold extends StatelessWidget {
  final List<Widget> children;
  final bool showFooter;

  const MarketingPageScaffold({
    super.key,
    required this.children,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MarketingAmbientScene(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 108),
              ...children,
              if (showFooter) const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
