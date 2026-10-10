class HistoryItem {
  final String expression;
  final String result;
  final DateTime time;

  HistoryItem({
    required this.expression,
    required this.result,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'expression': expression,
        'result': result,
        'time': time.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        expression: json['expression'],
        result: json['result'],
        time: DateTime.parse(json['time']),
      );
}