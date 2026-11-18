import 'package:intl/intl.dart';

final _money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

String formatMoney(double value) => _money.format(value);
