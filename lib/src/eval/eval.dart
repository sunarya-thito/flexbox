import 'package:flexiblebox/flexiblebox_dart.dart';

part 'token.dart';

/// Evaluates a string expression and returns a [SizeUnit].
///
/// Parses mathematical expressions involving size units (e.g., "100px + 50%")
/// and returns the resulting [SizeUnit] object. Supports arithmetic operations
/// (+, -, *, /) and various size unit types.
///
/// Example:
/// ```dart
/// final size = evaluateSizeUnit("100 + 50"); // SizeUnit representing 150
/// final relative = evaluateSizeUnit("50%");   // SizeUnit representing 50% of viewport
/// ```
///
/// Throws an exception if the expression cannot be parsed.
SizeUnit evaluateSizeUnit(String input) {
  final tokenizer = StringTokenizer(input);
  final tokens = tokenizer.tokenize();
  final parser = Parser(tokens);
  return parser.parseSizeUnit();
}

/// Evaluates a string expression and returns a [SpacingUnit].
///
/// Parses mathematical expressions involving spacing units and returns the
/// resulting [SpacingUnit] object. Supports arithmetic operations and various
/// spacing unit types (fixed, relative, viewport-based).
///
/// Example:
/// ```dart
/// final spacing = evaluateSpacingUnit("16"); // SpacingUnit representing 16 pixels
/// final calc = evaluateSpacingUnit("8 * 2"); // SpacingUnit representing 16
/// ```
///
/// Throws an exception if the expression cannot be parsed.
SpacingUnit evaluateSpacingUnit(String input) {
  final tokenizer = StringTokenizer(input);
  final tokens = tokenizer.tokenize();
  final parser = Parser(tokens);
  return parser.parseSpacingUnit();
}

/// Evaluates a string expression and returns a [PositionUnit].
///
/// Parses mathematical expressions involving position units and returns the
/// resulting [PositionUnit] object. Supports arithmetic operations and various
/// position unit types (fixed, relative, viewport-based, content-based, etc.).
///
/// Example:
/// ```dart
/// final pos = evaluatePositionUnit("100");      // PositionUnit representing 100 pixels
/// final center = evaluatePositionUnit("50% - 25"); // Center calculation
/// ```
///
/// Throws an exception if the expression cannot be parsed.
PositionUnit evaluatePositionUnit(String input) {
  final tokenizer = StringTokenizer(input);
  final tokens = tokenizer.tokenize();
  final parser = Parser(tokens);
  return parser.parsePositionUnit();
}

/// Parses a single token from the input string.
///
/// Tokenizes the input and returns the first token found. This is useful
/// for testing or when you only need to identify the first element of
/// an expression without full parsing.
///
/// Example:
/// ```dart
/// final token = parseToken("123"); // Token with type: number, text: "123"
/// ```
Token parseToken(String input) {
  final tokenizer = StringTokenizer(input);
  return tokenizer.tokenize().first;
}

/// A parser for mathematical expressions involving size, spacing, and position units.
///
/// [Parser] implements a recursive descent parser that processes tokenized
/// input and constructs the appropriate unit objects ([SizeUnit], [SpacingUnit],
/// [PositionUnit]). It handles operator precedence, parentheses, and various
/// unit types.
///
/// The parser supports:
/// - Arithmetic operators: +, -, *, /
/// - Parentheses for grouping
/// - Multiple unit types (pixels, percentages, viewport units, etc.)
/// - Unit-specific identifiers (vh, vw, etc.)
class Parser {
  /// The list of tokens to parse.
  final List<Token> tokens;

  /// The current position in the token list.
  int index = 0;

  /// Creates a parser for the given list of tokens.
  ///
  /// The tokens should be produced by [StringTokenizer.tokenize()].
  Parser(this.tokens);

  /// Returns the current token without advancing the parser.
  Token peek() => tokens[index];

  /// Returns the current token and advances to the next token.
  Token advance() => tokens[index++];

  /// Checks if the parser has reached the end of input.
  ///
  /// Returns true if the current token is [TokenType.eof].
  bool isAtEnd() => peek().type == TokenType.eof;

  /// Parses the token stream as a [SizeUnit] expression.
  ///
  /// Entry point for parsing size unit expressions. Processes the entire
  /// expression and returns the resulting [SizeUnit].
  SizeUnit parseSizeUnit() {
    return _parseSizeExpression();
  }

  /// Parses the token stream as a [SpacingUnit] expression.
  ///
  /// Entry point for parsing spacing unit expressions. Processes the entire
  /// expression and returns the resulting [SpacingUnit].
  SpacingUnit parseSpacingUnit() {
    return _parseSpacingExpression();
  }

  /// Parses the token stream as a [PositionUnit] expression.
  ///
  /// Entry point for parsing position unit expressions. Processes the entire
  /// expression and returns the resulting [PositionUnit].
  PositionUnit parsePositionUnit() {
    return _parsePositionExpression();
  }

  SizeUnit _parseSizeExpression() {
    return _parseSizeAddition();
  }

  SizeUnit _parseSizeAddition() {
    var left = _parseSizeMultiplication();
    while (peek().type == TokenType.plus || peek().type == TokenType.minus) {
      final op = advance();
      final right = _parseSizeMultiplication();
      final opFunc = op.type == TokenType.plus
          ? calculationAdd
          : calculationSubtract;
      left = SizeUnit.calc(left, right, opFunc);
    }
    return left;
  }

  SizeUnit _parseSizeMultiplication() {
    var left = _parseSizePrimary();
    while (peek().type == TokenType.multiply ||
        peek().type == TokenType.divide) {
      final op = advance();
      final right = _parseSizePrimary();
      final opFunc = op.type == TokenType.multiply
          ? calculationMultiply
          : calculationDivide;
      left = SizeUnit.calc(left, right, opFunc);
    }
    return left;
  }

  SizeUnit _parseSizePrimary() {
    final token = peek();

    // Handle unary minus
    if (token.type == TokenType.minus) {
      advance();
      final expr = _parseSizePrimary();
      return SizeUnit.fixed(0) - expr;
    }

    advance();
    switch (token.type) {
      case TokenType.number:
        final value = double.parse(token.text);
        if (peek().type == TokenType.percent) {
          advance();
          return SizeUnit.viewportSize * (value / 100);
        }
        if (peek().text == 'px') {
          advance();
        }
        return SizeUnit.fixed(value);
      case TokenType.identifier:
        if (token.text == 'viewportSize') {
          return SizeUnit.viewportSize;
        } else if (token.text == 'minContent') {
          return SizeUnit.minContent;
        } else if (token.text == 'maxContent') {
          return SizeUnit.maxContent;
        } else if (token.text == 'fitContent') {
          return SizeUnit.fitContent;
        }
        throw 'Unknown identifier: ${token.text}';
      case TokenType.lparen:
        final expr = _parseSizeExpression();
        if (advance().type != TokenType.rparen) {
          throw 'Expected )';
        }
        return expr;
      default:
        throw 'Unexpected token: ${token.type}';
    }
  }

  SpacingUnit _parseSpacingExpression() {
    return _parseSpacingAddition();
  }

  SpacingUnit _parseSpacingAddition() {
    var left = _parseSpacingMultiplication();
    while (peek().type == TokenType.plus || peek().type == TokenType.minus) {
      final op = advance();
      final right = _parseSpacingMultiplication();
      final opFunc = op.type == TokenType.plus
          ? calculationAdd
          : calculationSubtract;
      left = SpacingUnit.calc(left, right, opFunc);
    }
    return left;
  }

  SpacingUnit _parseSpacingMultiplication() {
    var left = _parseSpacingPrimary();
    while (peek().type == TokenType.multiply ||
        peek().type == TokenType.divide) {
      final op = advance();
      final right = _parseSpacingPrimary();
      final opFunc = op.type == TokenType.multiply
          ? calculationMultiply
          : calculationDivide;
      left = SpacingUnit.calc(left, right, opFunc);
    }
    return left;
  }

  SpacingUnit _parseSpacingPrimary() {
    final token = peek();

    // Handle unary minus
    if (token.type == TokenType.minus) {
      advance();
      final expr = _parseSpacingPrimary();
      return SpacingUnit.fixed(0) - expr;
    }

    advance();
    switch (token.type) {
      case TokenType.number:
        final value = double.parse(token.text);
        if (peek().type == TokenType.percent) {
          advance();
          return SpacingUnit.viewportSize * (value / 100);
        }
        if (peek().text == 'px') {
          advance();
        }
        return SpacingUnit.fixed(value);
      case TokenType.identifier:
        if (token.text == 'viewportSize') {
          return SpacingUnit.viewportSize;
        } else if (token.text == 'childSize') {
          if (peek().type == TokenType.lparen) {
            advance();
            final arg = _parseArgument();
            if (advance().type != TokenType.rparen) {
              throw 'Expected )';
            }
            return SpacingUnit.childSize(arg);
          }
          return SpacingUnit.childSize(null);
        }
        throw 'Unknown identifier: ${token.text}';
      case TokenType.lparen:
        final expr = _parseSpacingExpression();
        if (advance().type != TokenType.rparen) {
          throw 'Expected )';
        }
        return expr;
      default:
        throw 'Unexpected token: ${token.type}';
    }
  }

  PositionUnit _parsePositionExpression() {
    return _parsePositionAddition();
  }

  PositionUnit _parsePositionAddition() {
    var left = _parsePositionMultiplication();
    while (peek().type == TokenType.plus || peek().type == TokenType.minus) {
      final op = advance();
      final right = _parsePositionMultiplication();
      final opFunc = op.type == TokenType.plus
          ? calculationAdd
          : calculationSubtract;
      left = PositionUnit.calc(left, right, opFunc);
    }
    return left;
  }

  PositionUnit _parsePositionMultiplication() {
    var left = _parsePositionPrimary();
    while (peek().type == TokenType.multiply ||
        peek().type == TokenType.divide) {
      final op = advance();
      final right = _parsePositionPrimary();
      final opFunc = op.type == TokenType.multiply
          ? calculationMultiply
          : calculationDivide;
      left = PositionUnit.calc(left, right, opFunc);
    }
    return left;
  }

  PositionUnit _parsePositionPrimary() {
    final token = peek();

    // Handle unary minus
    if (token.type == TokenType.minus) {
      advance();
      final expr = _parsePositionPrimary();
      return PositionUnit.fixed(0) - expr;
    }

    advance();
    switch (token.type) {
      case TokenType.number:
        final value = double.parse(token.text);
        if (peek().type == TokenType.percent) {
          advance();
          return PositionUnit.viewportSize * (value / 100);
        }
        if (peek().text == 'px') {
          advance();
        }
        return PositionUnit.fixed(value);
      case TokenType.identifier:
        if (token.text == 'viewportSize') {
          return PositionUnit.viewportSize;
        } else if (token.text == 'contentSize') {
          return PositionUnit.contentSize;
        } else if (token.text == 'childSize') {
          if (peek().type == TokenType.lparen) {
            advance();
            final arg = _parseArgument();
            if (advance().type != TokenType.rparen) {
              throw 'Expected )';
            }
            return PositionUnit.childSize(arg);
          }
          return PositionUnit.childSize(null);
        } else if (token.text == 'boxOffset') {
          return PositionUnit.boxOffset;
        } else if (token.text == 'scrollOffset') {
          return PositionUnit.scrollOffset;
        } else if (token.text == 'contentOverflow') {
          return PositionUnit.contentOverflow;
        } else if (token.text == 'contentUnderflow') {
          return PositionUnit.contentUnderflow;
        } else if (token.text == 'viewportEndBound') {
          return PositionUnit.viewportEndBound;
        }
        throw 'Unknown identifier: ${token.text}';
      case TokenType.lparen:
        final expr = _parsePositionExpression();
        if (advance().type != TokenType.rparen) {
          throw 'Expected )';
        }
        return expr;
      default:
        throw 'Unexpected token: ${token.type}';
    }
  }

  dynamic _parseArgument() {
    final token = advance();
    switch (token.type) {
      case TokenType.string:
        return token.text.substring(1, token.text.length - 1);
      case TokenType.symbol:
        return Symbol(token.text.substring(1));
      default:
        throw 'Expected string or symbol';
    }
  }
}

/// A tokenizer that breaks strings into lexical tokens for parsing.
///
/// [StringTokenizer] implements a lexer that scans source text and identifies
/// tokens such as numbers, identifiers, operators, and punctuation. It maintains
/// a current position and provides methods for consuming characters and patterns.
///
/// This is used by [Parser] to convert string expressions into parseable tokens
/// before building unit objects.
class StringTokenizer {
  /// The source string being tokenized.
  final String source;

  /// The current position in the source string.
  int index = 0;

  /// The end index (exclusive) for tokenization.
  ///
  /// This is typically the length of the source string but can be set to
  /// a shorter range when tokenizing substrings.
  final int endIndex;

  /// Creates a tokenizer for the entire source string.
  ///
  /// The tokenizer will process from index 0 to the end of [source].
  StringTokenizer(this.source) : endIndex = source.length;

  /// Creates a tokenizer for a range within the source string.
  ///
  /// Tokenizes only the substring from [index] to [endIndex] (exclusive).
  /// Useful for parsing nested expressions or substrings without copying.
  StringTokenizer.fromRange(this.source, this.index, this.endIndex);

  /// Consumes characters that match a test function and returns their range.
  ///
  /// If [length] is null, consumes characters while [test] returns true,
  /// stopping at the first failing character or end of input. The test function
  /// receives each character and its 0-based index from the match start.
  ///
  /// If [length] is specified, consumes exactly that many characters if they
  /// all pass the test. If any character fails, returns null and resets position.
  ///
  /// Returns a record with (startIndex, endIndex) of consumed characters,
  /// or null if no characters matched.
  ///
  /// Example:
  /// ```dart
  /// // Consume all digits
  /// final range = eat((char, _) => char.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
  ///                                   char.codeUnitAt(0) <= '9'.codeUnitAt(0), null);
  /// ```
  ({int startIndex, int endIndex})? eat(
    bool Function(String char, int index) test,
    int? length,
  ) {
    if (length == null) {
      int startIndex = index;
      while (index < endIndex && test(source[index], index - startIndex)) {
        index++;
      }
      if (startIndex == index) {
        return null;
      }
      return (startIndex: startIndex, endIndex: index);
    }
    int startIndex = index;
    for (int i = 0; i < length; i++) {
      if (index >= endIndex || !test(source[index], i)) {
        index = startIndex;
        return null;
      }
      index++;
    }
    return (startIndex: startIndex, endIndex: index);
  }

  bool eatString(String string) {
    return eat((char, index) => char == string[index], string.length) != null;
  }

  bool eatCharacter(String char) {
    return eat((c, _) => c == char, 1) != null;
  }

  int _parseInteger(int start, int end) {
    int value = 0;
    for (int i = start; i < end; i++) {
      value = value * 10 + (source.codeUnitAt(i) - '0'.codeUnitAt(0));
    }
    return value;
  }

  double? eatNumber() {
    int startIndex = index;
    bool isNegative = eatCharacter('-');
    var digits = eat(
      (char, _) =>
          char.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
          char.codeUnitAt(0) <= '9'.codeUnitAt(0),
      null,
    );
    if (digits == null) {
      index = startIndex;
      return null;
    }
    var hasDecimal = eatCharacter('.');
    if (hasDecimal) {
      var decimalDigits = eat(
        (char, _) =>
            char.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
            char.codeUnitAt(0) <= '9'.codeUnitAt(0),
        null,
      );
      if (decimalDigits == null) {
        index = startIndex;
        return null;
      }
      int integerPart = _parseInteger(digits.startIndex, digits.endIndex);
      int decimalPart = _parseInteger(
        decimalDigits.startIndex,
        decimalDigits.endIndex,
      );
      double decimalValue =
          decimalPart /
          (10 ^ (decimalDigits.endIndex - decimalDigits.startIndex));
      return isNegative
          ? -(integerPart + decimalValue)
          : (integerPart + decimalValue);
    }
    int integerPart = _parseInteger(digits.startIndex, digits.endIndex);
    return isNegative ? -integerPart.toDouble() : integerPart.toDouble();
  }

  bool eatWhitespace() {
    return eat((char, _) => char.trim().isEmpty, null) != null;
  }

  bool? eatBoolean() {
    if (eatString('true')) {
      return true;
    } else if (eatString('false')) {
      return false;
    }
    return null;
  }

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (index < endIndex) {
      eatWhitespace();
      if (index >= endIndex) break;

      final start = index;
      final char = source[index];

      if (char == '+') {
        tokens.add(Token(TokenType.plus, source, start, ++index));
      } else if (char == '-') {
        tokens.add(Token(TokenType.minus, source, start, ++index));
      } else if (char == '*') {
        tokens.add(Token(TokenType.multiply, source, start, ++index));
      } else if (char == '/') {
        tokens.add(Token(TokenType.divide, source, start, ++index));
      } else if (char == '(') {
        tokens.add(Token(TokenType.lparen, source, start, ++index));
      } else if (char == ')') {
        tokens.add(Token(TokenType.rparen, source, start, ++index));
      } else if (char == '%') {
        tokens.add(Token(TokenType.percent, source, start, ++index));
      } else if (char == ',') {
        tokens.add(Token(TokenType.comma, source, start, ++index));
      } else if (char == '#') {
        final range = eat(
          (c, i) => i == 0
              ? c == '#'
              : (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
                        c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
                    (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
                        c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
                    (c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
                        c.codeUnitAt(0) <= '9'.codeUnitAt(0)) ||
                    c == '_',
          null,
        );
        tokens.add(
          Token(TokenType.symbol, source, range!.startIndex, range.endIndex),
        );
      } else if (char == "'") {
        index++;
        eat((c, i) => c != "'", null);
        tokens.add(Token(TokenType.string, source, start, index + 1));
        index++;
      } else if (char == '"') {
        index++;
        eat((c, i) => c != '"', null);
        tokens.add(Token(TokenType.string, source, start, index + 1));
        index++;
      } else if (char.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
          char.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
        eatNumber();
        tokens.add(Token(TokenType.number, source, start, index));
      } else if ((char.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
              char.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
          (char.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
              char.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
          char == '_') {
        final range = eat(
          (c, i) =>
              (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
              (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
              (c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= '9'.codeUnitAt(0)) ||
              c == '_',
          null,
        );
        tokens.add(
          Token(
            TokenType.identifier,
            source,
            range!.startIndex,
            range.endIndex,
          ),
        );
      } else {
        throw 'Unexpected character: $char';
      }
    }
    tokens.add(Token(TokenType.eof, source, index, index));
    return tokens;
  }
}
