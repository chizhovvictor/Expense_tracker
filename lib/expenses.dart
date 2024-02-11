import 'package:expense_tracker/expenses_list.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';

// главный экран который изменяется при добавлении или удалении расходов и обновляет диаграму
class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  // для визуала создаем в начале два расхода
  final List<Expense> _registeredExpenses = [
    Expense(
        title: 'Flutter Course',
        amount: 19.99,
        date: DateTime.now(),
        category: Category.work),
    Expense(
        title: 'Cinema',
        amount: 15.69,
        date: DateTime.now(),
        category: Category.leisure),
  ];

  //показать модальное окно для добавления расхода
  void _openAddExpenseForm() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return NewExpense(
          onAddExpense: _addExpense,
        );
      },
    );
  }

  // добавление расхода
  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  // удаление расхода со стартового экрана
  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context)
        .clearSnackBars(); //удаляем снекбар если он есть
    ScaffoldMessenger.of(context).showSnackBar(
      //показываем снекбар с возможностью отмены
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // узнаем ширину экрана
    final width = MediaQuery.of(context).size.width;

    // стартовый экран
    Widget mainContent = const Center(
      child: Text('No expense found.'),
    );

    // если есть зарегистрированные расходы меняем стартовый экран
    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    // возвращаем виджет c AppBar и основным содержимым
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text('Expenses Tracker'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: _openAddExpenseForm),
        ],
      ),
      // основное содержимое
      body: width < 600 // если ширина экрана меньше 600 пикселей
          ? Column(
              children: [
                // график расходов
                Chart(expenses: _registeredExpenses),
                // список расходов
                Expanded(
                  child: mainContent,
                ),
              ],
            )
          : Row(
              children: [
                // график расходов
                Expanded(child: Chart(expenses: _registeredExpenses)),
                // список расходов
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
    );
  }
}
