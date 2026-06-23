import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

// SQLite Draft Model
class TicketDraft {
  final int? id;
  final String subject;
  final String description;
  final String category;
  final DateTime createdAt;

  TicketDraft({
    this.id,
    required this.subject,
    required this.description,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TicketDraft.fromMap(Map<String, dynamic> map) {
    return TicketDraft(
      id: map['id'] as int?,
      subject: '${map['subject'] ?? ''}',
      description: '${map['description'] ?? ''}',
      category: '${map['category'] ?? ''}',
      createdAt: DateTime.tryParse('${map['created_at']}') ?? DateTime.now(),
    );
  }
}

class TicketRepository {
  TicketRepository._();
  static final TicketRepository instance = TicketRepository._();

  Database? _db;

  // SQLite Database Initialization
  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'aeronet.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, _) => database.execute('''
        CREATE TABLE ticket_drafts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      '''),
    );
    return _db!;
  }

  // Local SQLite Draft Methods
  Future<void> saveLocalDraft(TicketDraft draft) async {
    final database = await db;
    await database.insert('ticket_drafts', draft.toMap());
  }

  Future<List<TicketDraft>> getLocalDrafts() async {
    final database = await db;
    final rows = await database.query('ticket_drafts', orderBy: 'id DESC');
    return rows.map(TicketDraft.fromMap).toList();
  }

  Future<void> deleteLocalDraft(int id) async {
    final database = await db;
    await database.delete('ticket_drafts', where: 'id = ?', whereArgs: [id]);
  }

  // Backend API Operations
  Future<List<TicketModel>> getTickets() async {
    final response = await ApiClient.instance.get('/tickets');
    final list = asList(response);
    return list.map((e) => TicketModel.fromJson(asMap(e))).toList();
  }

  Future<List<TicketModel>> getMyTickets() async {
    final response = await ApiClient.instance.get('/tickets/my-tickets');
    final list = asList(response);
    return list.map((e) => TicketModel.fromJson(asMap(e))).toList();
  }

  Future<List<TicketModel>> getAssignedToMe() async {
    final response = await ApiClient.instance.get('/tickets/assigned/me');
    final list = asList(response);
    return list.map((e) => TicketModel.fromJson(asMap(e))).toList();
  }

  Future<TicketModel> createTicket(Map<String, dynamic> data) async {
    final response = await ApiClient.instance.post('/tickets', data);
    return TicketModel.fromJson(asMap(response));
  }

  Future<TicketModel> updateTicket(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.instance.patch('/tickets/$id', data);
    return TicketModel.fromJson(asMap(response));
  }

  Future<void> deleteTicket(String id) async {
    await ApiClient.instance.delete('/tickets/$id');
  }
}
