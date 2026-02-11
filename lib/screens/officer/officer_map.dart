import 'package:flutter/material.dart';

/// Simple placeholder map screen for the Officer dashboard's "Field Map" tab.
/// You can later replace the body with a real Google Maps or similar widget.
class OfficerMapScreen extends StatelessWidget {
	const OfficerMapScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Field Map'),
				backgroundColor: const Color(0xFF0D47A1),
				foregroundColor: Colors.white,
			),
			body: const Center(
				child: Text('Interactive field map will appear here'),
			),
		);
	}
}

