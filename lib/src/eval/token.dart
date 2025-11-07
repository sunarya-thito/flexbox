part of 'eval.dart';

/// Represents the type of token in the expression evaluator.
///
/// Tokens are the basic building blocks of expressions parsed by the evaluator.
/// Each token type represents a specific syntactic element such as numbers,
/// operators, or punctuation.
enum TokenType {
  /// A numeric literal token (e.g., "123", "45.67").
  number,
  
  /// A string literal token enclosed in quotes.
  string,
  
  /// A symbolic operator or punctuation mark.
  symbol,
  
  /// An identifier token representing a variable or function name.
  identifier,
  
  /// The addition operator (+).
  plus,
  
  /// The subtraction operator (-) or unary negation.
  minus,
  
  /// The multiplication operator (*).
  multiply,
  
  /// The division operator (/).
  divide,
  
  /// The left parenthesis token "(".
  lparen,
  
  /// The right parenthesis token ")".
  rparen,
  
  /// The percent sign token "%".
  percent,
  
  /// The comma separator token ",".
  comma,
  
  /// End-of-file token indicating the end of input.
  eof,
}

/// Represents a single token in the expression evaluator.
///
/// A token is a sequence of characters from the source input that has been
/// identified as a specific syntactic element (number, operator, identifier, etc.).
/// Tokens form the basic units of parsing and are created by the lexer/tokenizer.
///
/// Each token knows its type, position in the source, and can extract its text.
class Token {
  /// The type of this token (number, operator, identifier, etc.).
  final TokenType type;
  
  /// The complete source string from which this token was extracted.
  final String source;
  
  /// The starting index of this token in the source string.
  final int start;
  
  /// The ending index (exclusive) of this token in the source string.
  final int end;

  /// Creates a new token with the specified type and location in the source.
  ///
  /// Parameters:
  /// * [type] - The token type
  /// * [source] - The complete source string
  /// * [start] - Starting position in source
  /// * [end] - Ending position in source (exclusive)
  Token(this.type, this.source, this.start, this.end);

  /// Extracts and returns the text content of this token from the source.
  ///
  /// This returns the substring of [source] from [start] to [end].
  String get text => source.substring(start, end);

  @override
  String toString() => text;
}
