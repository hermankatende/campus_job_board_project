// ignore_for_file: prefer_const_constructors

import 'package:cjb/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _searchController = TextEditingController();
  String _role = '';
  String _status = '';
  late Future<List<AdminUserRecord>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  Future<List<AdminUserRecord>> _loadUsers() {
    return AdminService.instance.listUsers(
      search: _searchController.text,
      role: _role,
      status: _status,
    );
  }

  void _refresh() {
    setState(() {
      _usersFuture = _loadUsers();
    });
  }

  Future<void> _changeRole(AdminUserRecord user, String role) async {
    try {
      await AdminService.instance.setUserRole(userId: user.id, role: role);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Role update failed: $e')));
    }
  }

  Future<void> _toggleSuspend(AdminUserRecord user) async {
    try {
      await AdminService.instance.setUserSuspended(
        userId: user.id,
        suspend: !user.isSuspended,
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Suspend action failed: $e')));
    }
  }

  Future<void> _verifyLecturer(AdminUserRecord user) async {
    try {
      await AdminService.instance
          .verifyLecturer(userId: user.id, verify: !user.isVerified);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Verification failed: $e')));
    }
  }

  Future<void> _deleteUser(AdminUserRecord user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete user?'),
        content: Text('This action permanently removes this user profile.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await AdminService.instance.deleteUser(user.id);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name/email',
                    suffixIcon: IconButton(
                        icon: Icon(Icons.search), onPressed: _refresh),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _role.isEmpty ? null : _role,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['student', 'recruiter', 'lecturer', 'admin']
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => setState(() => _role = v ?? ''),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status.isEmpty ? null : _status,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['online', 'offline']
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v ?? ''),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(onPressed: _refresh, child: Text('Apply')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AdminUserRecord>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Failed to load users: ${snapshot.error}'));
                }

                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return Center(child: Text('No users found.'));
                }

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user.name.isEmpty ? user.email : user.name),
                      subtitle:
                          Text('${user.role} • ${user.status} • ${user.email}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value.startsWith('role:')) {
                            _changeRole(user, value.split(':')[1]);
                          } else if (value == 'suspend') {
                            _toggleSuspend(user);
                          } else if (value == 'verify') {
                            _verifyLecturer(user);
                          } else if (value == 'delete') {
                            _deleteUser(user);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                              value: 'suspend',
                              child: Text(
                                  user.isSuspended ? 'Unsuspend' : 'Suspend')),
                          if (user.role == 'lecturer')
                            PopupMenuItem(
                                value: 'verify',
                                child: Text(user.isVerified
                                    ? 'Unverify Lecturer'
                                    : 'Verify Lecturer')),
                          PopupMenuDivider(),
                          PopupMenuItem(
                              value: 'role:student',
                              child: Text('Set role: student')),
                          PopupMenuItem(
                              value: 'role:recruiter',
                              child: Text('Set role: recruiter')),
                          PopupMenuItem(
                              value: 'role:lecturer',
                              child: Text('Set role: lecturer')),
                          PopupMenuItem(
                              value: 'role:admin',
                              child: Text('Set role: admin')),
                          PopupMenuDivider(),
                          PopupMenuItem(
                              value: 'delete', child: Text('Delete user')),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
