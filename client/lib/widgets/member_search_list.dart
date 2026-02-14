import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:time_keeper/generated/db/db.pb.dart';

/// A reusable searchable list of team members with a customizable
/// trailing widget per row.
class MemberSearchList extends HookWidget {
  final Map<String, TeamMember> teamMembers;
  final Widget Function(String memberId, TeamMember member) trailingBuilder;

  const MemberSearchList({
    super.key,
    required this.teamMembers,
    required this.trailingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchText = useState('');

    final filteredMembers =
        searchText.value.isEmpty
              ? <MapEntry<String, TeamMember>>[]
              : teamMembers.entries.where((entry) {
                  final member = entry.value;
                  final query = searchText.value.toLowerCase();
                  return member.firstName.toLowerCase().contains(query) ||
                      member.lastName.toLowerCase().contains(query) ||
                      member.displayName.toLowerCase().contains(query);
                }).toList()
          ..sort(
            (a, b) => a.value.displayName.toLowerCase().compareTo(
              b.value.displayName.toLowerCase(),
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Search by name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => searchText.value = value,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filteredMembers.isEmpty
              ? Center(
                  child: Text(
                    searchText.value.isEmpty
                        ? 'Type to search for a team member'
                        : 'No members found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final entry = filteredMembers[index];
                    final member = entry.value;
                    final memberId = entry.key;
                    return ListTile(
                      title: Text(member.displayName),
                      subtitle: Text(member.memberType.name),
                      trailing: trailingBuilder(memberId, member),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
