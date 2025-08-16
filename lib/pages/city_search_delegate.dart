import 'package:flutter/material.dart';

class CitySearchDelegate extends SearchDelegate<String> {
  final List<String> suggestions = [
    "Jakarta",
    "Bandung",
    "Surabaya",
    "Yogyakarta",
    "Medan",
    "Tokyo",
    "Singapore",
    "Manchester",
    "London",
    "New York",
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ""),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(title: Text(query), onTap: () => close(context, query));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = suggestions
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        return ListTile(
          title: Text(filtered[i]),
          onTap: () => close(context, filtered[i]),
        );
      },
    );
  }
}
