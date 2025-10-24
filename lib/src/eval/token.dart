part of 'eval.dart';

enum TokenType {
  number,
  string,
  symbol,
  identifier,
  plus,
  minus,
  multiply,
  divide,
  lparen,
  rparen,
  percent,
  comma,
  eof,
}

class Token {
  final TokenType type;
  final String source;
  final int start;
  final int end;

  Token(this.type, this.source, this.start, this.end);

  String get text => source.substring(start, end);

  @override
  String toString() => text;
}
