import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Notification_Page extends StatefulWidget {
  const Notification_Page({super.key});

  @override
  State<Notification_Page> createState() => _Notification_PageState();
}

class _Notification_PageState extends State<Notification_Page> {
  Box? notificationsBox;

  @override
  void initState() {
    super.initState();
    notificationsBox = Hive.box('notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationsBox != null && notificationsBox!.isNotEmpty)
            IconButton(
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
            ),
          if (notificationsBox != null && notificationsBox!.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: notificationsBox!.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final reversedIndex = box.length - 1 - index;
              final dynamic raw = box.getAt(reversedIndex);
              final Map notification = (raw is Map) ? raw : {};

              final title = (notification['title'] ?? 'Notification').toString();
              final body = (notification['body'] ?? '').toString();
              final type = (notification['type'] ?? 'general').toString();
              final isRead = notification['is_read'] == true;
              final createdAtRaw = (notification['created_at'] ?? '').toString();
              final createdAt = DateTime.tryParse(createdAtRaw);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: isRead ? 0.5 : 1.5,
                child: ListTile(
                  onTap: () => _markAsRead(reversedIndex),
                  leading: CircleAvatar(
                    backgroundColor:
                        isRead ? Colors.grey.shade200 : Colors.blue.shade100,
                    child: Icon(
                      _iconForType(type),
                      color: isRead ? Colors.grey.shade600 : Colors.blue.shade700,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (body.isNotEmpty) Text(body),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _typeChip(type),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimestamp(createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAsRead(int index) async {
    final dynamic raw = notificationsBox?.getAt(index);
    if (raw is! Map) return;
    final updated = Map<String, dynamic>.from(raw);
    updated['is_read'] = true;
    await notificationsBox?.putAt(index, updated);
  }

  Future<void> _markAllAsRead() async {
    if (notificationsBox == null) return;
    for (var i = 0; i < notificationsBox!.length; i++) {
      final dynamic raw = notificationsBox!.getAt(i);
      if (raw is! Map) continue;
      final updated = Map<String, dynamic>.from(raw);
      updated['is_read'] = true;
      await notificationsBox!.putAt(i, updated);
    }
  }

  Future<void> _clearAll() async {
    await notificationsBox?.clear();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'status_update':
        return Icons.assignment_turned_in;
      case 'new_job':
        return Icons.work_outline;
      default:
        return Icons.notifications_none;
    }
  }

  Widget _typeChip(String type) {
    String label;
    Color color;
    switch (type) {
      case 'status_update':
        label = 'Application';
        color = Colors.green;
        break;
      case 'new_job':
        label = 'New Job';
        color = Colors.orange;
        break;
      default:
        label = 'General';
        color = Colors.blueGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? time) {
    if (time == null) return 'now';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
