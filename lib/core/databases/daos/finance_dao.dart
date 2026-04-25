import 'package:sqflite/sqflite.dart';
import '../../models/finance_model.dart';
import '../schemas/finance_schema.dart';

class FinanceDao {
  final Database db;

  FinanceDao(this.db);

  Future<int> insertTransaction(FinanceModel finance) async {
    return await db.insert(FinanceSchema.tableName, finance.toMap());
  }

  Future<List<FinanceModel>> getAllTransactions() async {
    final List<Map<String, dynamic>> maps = await db.query(
      FinanceSchema.tableName,
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => FinanceModel.fromMap(maps[i]));
  }

  Future<int> deleteTransaction(int id) async {
    return await db.delete(
      FinanceSchema.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalIncome({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String query =
        "SELECT SUM(amount) FROM ${FinanceSchema.tableName} WHERE type IN ('Offrande', 'Dîme')";
    List<dynamic> args = [];

    if (startDate != null) {
      query += " AND date >= ?";
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      query += " AND date <= ?";
      args.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery(query, args);
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String query =
        "SELECT SUM(amount) FROM ${FinanceSchema.tableName} WHERE type = 'Dépense'";
    List<dynamic> args = [];

    if (startDate != null) {
      query += " AND date >= ?";
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      query += " AND date <= ?";
      args.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery(query, args);
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalByType(String type) async {
    final result = await db.rawQuery(
      "SELECT SUM(amount) FROM ${FinanceSchema.tableName} WHERE type = ?",
      [type],
    );
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<List<FinanceModel>> getRecentTransactions(int limit) async {
    final List<Map<String, dynamic>> maps = await db.query(
      FinanceSchema.tableName,
      orderBy: 'date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => FinanceModel.fromMap(maps[i]));
  }

  Future<List<FinanceModel>> getTransactionsByEntity(String entity) async {
    final List<Map<String, dynamic>> maps = await db.query(
      FinanceSchema.tableName,
      where: 'entity = ?',
      whereArgs: [entity],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => FinanceModel.fromMap(maps[i]));
  }

  Future<int> getMonthlyTransactionCount(DateTime month) async {
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
    ).toIso8601String();
    final result = await db.rawQuery(
      "SELECT COUNT(*) FROM ${FinanceSchema.tableName} WHERE date >= ? AND date <= ?",
      [start, end],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getLargestDonation() async {
    final result = await db.rawQuery(
      "SELECT MAX(amount) FROM ${FinanceSchema.tableName} WHERE type = 'Don'",
    );
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<String?> getBestMonthName() async {
    final result = await db.rawQuery(
      "SELECT substr(date, 6, 2) as month, SUM(amount) as total "
      "FROM ${FinanceSchema.tableName} "
      "WHERE type != 'Dépense' "
      "GROUP BY month "
      "ORDER BY total DESC "
      "LIMIT 1",
    );
    if (result.isEmpty) return null;
    final months = [
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre",
    ];
    int monthIdx = int.parse(result.first['month'].toString()) - 1;
    return months[monthIdx];
  }

  Future<double> getMonthlyTotalByType(String type, DateTime month) async {
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
    ).toIso8601String();
    final result = await db.rawQuery(
      "SELECT SUM(amount) FROM ${FinanceSchema.tableName} WHERE type = ? AND date >= ? AND date <= ?",
      [type, start, end],
    );
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTrend(int monthsCount) async {
    List<Map<String, dynamic>> trend = [];
    DateTime now = DateTime.now();

    for (int i = monthsCount - 1; i >= 0; i--) {
      DateTime monthDate = DateTime(now.year, now.month - i, 1);
      final start = monthDate.toIso8601String();
      final end = DateTime(
        monthDate.year,
        monthDate.month + 1,
        0,
        23,
        59,
        59,
      ).toIso8601String();

      final incomeResult = await db.rawQuery(
        "SELECT SUM(amount) FROM ${FinanceSchema.tableName} WHERE type != 'Dépense' AND date >= ? AND date <= ?",
        [start, end],
      );
      final expenseResult = await db.rawQuery(
        "SELECT SUM(amount) FROM ${FinanceSchema.tableName} WHERE type = 'Dépense' AND date >= ? AND date <= ?",
        [start, end],
      );

      trend.add({
        'month': monthDate.month,
        'year': monthDate.year,
        'income': (incomeResult.first.values.first as num?)?.toDouble() ?? 0.0,
        'expense':
            (expenseResult.first.values.first as num?)?.toDouble() ?? 0.0,
      });
    }
    return trend;
  }

  Future<List<Map<String, dynamic>>> getYearlyTrend(int year) async {
    List<Map<String, dynamic>> trend = [];
    for (int i = 1; i <= 12; i++) {
      DateTime monthStart = DateTime(year, i, 1);
      final start = monthStart.toIso8601String();
      final end = DateTime(year, i + 1, 0, 23, 59, 59).toIso8601String();

      final incomeResult = await db.rawQuery(
        "SELECT SUM(amount) FROM ${FinanceSchema.tableName} WHERE type != 'Dépense' AND date >= ? AND date <= ?",
        [start, end],
      );
      final expenseResult = await db.rawQuery(
        "SELECT SUM(amount) FROM ${FinanceSchema.tableName} WHERE type = 'Dépense' AND date >= ? AND date <= ?",
        [start, end],
      );

      trend.add({
        'month': i,
        'income': (incomeResult.first.values.first as num?)?.toDouble() ?? 0.0,
        'expense':
            (expenseResult.first.values.first as num?)?.toDouble() ?? 0.0,
      });
    }
    return trend;
  }
}
