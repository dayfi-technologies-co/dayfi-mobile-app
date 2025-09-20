import 'dart:convert';
import 'dart:developer';

import 'package:dayfi/data/models/transaction_history_model.dart';
import 'package:dayfi/ui/views/virtual_card_details/virtual_card_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dayfi.db');
    return await openDatabase(
      path,
      version: 4, // Increment version for new virtual_cards table
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE banks (
            bankcode TEXT PRIMARY KEY,
            bankname TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE saved_accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            account_number TEXT,
            account_name TEXT,
            bank_name TEXT,
            bank_code TEXT,
            beneficiary_name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE usdtransactions (
            id TEXT PRIMARY KEY,
            wallet_transactions_id TEXT,
            user_id TEXT,
            sender_wallet_id TEXT,
            recipient_wallet_id TEXT,
            external_account_number TEXT,
            external_bank_code TEXT,
            external_bank_name TEXT,
            amount TEXT,
            balance TEXT,
            fees TEXT,
            type TEXT,
            status TEXT,
            reference TEXT,
            narration TEXT,
            metadata TEXT,
            initiated_by TEXT,
            created_at TEXT,
            updated_at TEXT,
            card_last4 TEXT,
            card_type TEXT,
            card_brand TEXT,
            card_country TEXT,
            card_token TEXT,
            card_transaction_ref TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE virtual_cards (
            card_number TEXT PRIMARY KEY,
            user_id TEXT,
            card_holder_name TEXT,
            expiry_date TEXT,
            cvv TEXT,
            street_name TEXT,
            city TEXT,
            state TEXT,
            postcode TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE saved_accounts ADD COLUMN user_id TEXT
          ''');
          await db.execute('''
            ALTER TABLE saved_accounts ADD COLUMN beneficiary_name TEXT
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE usdtransactions (
              id TEXT PRIMARY KEY,
              wallet_transactions_id TEXT,
              user_id TEXT,
              sender_wallet_id TEXT,
              recipient_wallet_id TEXT,
              external_account_number TEXT,
              external_bank_code TEXT,
              external_bank_name TEXT,
              amount TEXT,
              balance TEXT,
              fees TEXT,
              type TEXT,
              status TEXT,
              reference TEXT,
              narration TEXT,
              metadata TEXT,
              initiated_by TEXT,
              created_at TEXT,
              updated_at TEXT,
              card_last4 TEXT,
              card_type TEXT,
              card_brand TEXT,
              card_country TEXT,
              card_token TEXT,
              card_transaction_ref TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE virtual_cards (
              card_number TEXT PRIMARY KEY,
              user_id TEXT,
              card_holder_name TEXT,
              expiry_date TEXT,
              cvv TEXT,
              street_name TEXT,
              city TEXT,
              state TEXT,
              postcode TEXT
            )
          ''');
        }
      },
    );
  }

  Future<void> cacheBanks(List<dynamic> banks) async {
    final db = await database;
    await db.delete('banks');
    for (var bank in banks) {
      await db.insert('banks', {
        'bankcode': bank['bankcode'],
        'bankname': bank['bankname'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCachedBanks() async {
    final db = await database;
    return await db.query('banks');
  }

  Future<Map<String, dynamic>?> getAccountByNumber({
    required String userId,
    required String accountNumber,
  }) async {
    final db = await database;
    final result = await db.query(
      'saved_accounts',
      where: 'user_id = ? AND account_number = ?',
      whereArgs: [userId, accountNumber],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> saveAccount({
    required String userId,
    required String accountNumber,
    required String accountName,
    required String bankName,
    required String bankCode,
    required String beneficiaryName,
  }) async {
    final db = await database;
    await db.insert('saved_accounts', {
      'user_id': userId,
      'account_number': accountNumber,
      'account_name': accountName,
      'bank_name': bankName,
      'bank_code': bankCode,
      'beneficiary_name': beneficiaryName,
    });
  }

  Future<List<Map<String, dynamic>>> getSavedAccounts(String userId) async {
    final db = await database;
    return await db.query(
      'saved_accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteAccount(int id) async {
    final db = await database;
    await db.delete('saved_accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cacheUSDTransactions(
      List<WalletTransaction> transactions) async {
    final db = await database;
    await db.delete('usdtransactions');
    for (var transaction in transactions) {
      await db.insert('usdtransactions', {
        'id': transaction.id,
        'wallet_transactions_id': transaction.walletTransactionsId,
        'user_id': transaction.userId,
        'sender_wallet_id': transaction.senderWalletId,
        'recipient_wallet_id': transaction.recipientWalletId,
        'external_account_number': transaction.externalAccountNumber,
        'external_bank_code': transaction.externalBankCode,
        'external_bank_name': transaction.externalBankName,
        'amount': transaction.amount,
        'balance': transaction.balance,
        'fees': transaction.fees,
        'type': transaction.type,
        'status': transaction.status,
        'reference': transaction.reference,
        'narration': transaction.narration,
        'metadata': jsonEncode(transaction.metadata),
        'initiated_by': transaction.initiatedBy,
        'created_at': transaction.createdAt,
        'updated_at': transaction.updatedAt,
        'card_last4': transaction.cardLast4,
        'card_type': transaction.cardType,
        'card_brand': transaction.cardBrand,
        'card_country': transaction.cardCountry,
        'card_token': transaction.cardToken,
        'card_transaction_ref': transaction.cardTransactionRef,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCachedUSDTransactions(
      String userId) async {
    final db = await database;
    return await db.query(
      'usdtransactions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getUSDTransactionById(String id) async {
    final db = await database;
    final result = await db.query(
      'usdtransactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> deleteUSDTransaction(String id) async {
    final db = await database;
    await db.delete('usdtransactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cacheVirtualCards(
      List<VirtualCardModel> cards, String userId) async {
    final db = await database;
    await db.delete('virtual_cards', where: 'user_id = ?', whereArgs: [userId]);
    for (var card in cards) {
      await db.insert('virtual_cards', {
        'card_number': card.cardNumber,
        'user_id': userId,
        'card_holder_name': card.cardHolderName,
        'expiry_date': card.expiryDate,
        'cvv': card.cvv,
        'street_name': card.streetName,
        'city': card.city,
        'state': card.state,
        'postcode': card.postcode,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCachedVirtualCards(
      String userId) async {
    final db = await database;
    try {
      final cards = await db.query(
        'virtual_cards',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      log('Fetched ${cards.length} virtual cards for user: $userId');
      return cards;
    } catch (e) {
      log('Error fetching virtual cards: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getVirtualCardByNumber({
    required String userId,
    required String cardNumber,
  }) async {
    final db = await database;
    final result = await db.query(
      'virtual_cards',
      where: 'user_id = ? AND card_number = ?',
      whereArgs: [userId, cardNumber],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> deleteVirtualCard(String cardNumber, String userId) async {
    final db = await database;
    await db.delete(
      'virtual_cards',
      where: 'card_number = ? AND user_id = ?',
      whereArgs: [cardNumber, userId],
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('banks');
    await db.delete('saved_accounts');
    await db.delete('usdtransactions');
    await db.delete('virtual_cards');
  }
}
