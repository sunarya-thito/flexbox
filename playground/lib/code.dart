import 'package:flexiblebox/flexiblebox.dart';
import 'package:flutter/material.dart';
import 'package:playground/value.dart';

mixin CodeCompound {
  List<Code> get lines;
}

class CodeBracket with CodeCompound implements Code {
  final Code? prefix;
  final String bracketOpen;
  final String bracketClose;
  final String separator;
  @override
  final List<Code> lines;

  const CodeBracket.parentheses(this.lines, {this.prefix})
    : bracketOpen = '(',
      bracketClose = ')',
      separator = ',';

  const CodeBracket.curly(this.lines, {this.prefix})
    : bracketOpen = '{',
      bracketClose = '}',
      separator = ',';

  const CodeBracket.square(this.lines, {this.prefix})
    : bracketOpen = '[',
      bracketClose = ']',
      separator = ',';

  @override
  String buildCode(int depth) {
    if (lines.isEmpty) {
      // return '${'  ' * depth}$bracketOpen$bracketClose';
      final builder = StringBuffer();
      builder.write('  ' * depth);
      if (prefix != null) {
        builder.write(prefix!.buildCode(0));
      }
      builder.write(bracketOpen);
      builder.write(bracketClose);
      return builder.toString();
    } else {
      final builder = StringBuffer();
      builder.write('  ' * depth);
      if (prefix != null) {
        builder.write(prefix!.buildCode(0));
      }
      builder.write(bracketOpen);
      for (var i = 0; i < lines.length; i++) {
        if (i > 0) {
          builder.write(separator);
        }
        builder.write('\n');
        builder.write(lines[i].buildCode(depth + 1));
      }
      builder.write('\n');
      builder.write('  ' * depth);
      builder.write(bracketClose);
      return builder.toString();
    }
  }
}

abstract interface class Code {
  String buildCode(int depth);
  const factory Code(String code) = CodeLine;
  const factory Code.concat(List<Code> parts) = CodeConcat;
  const factory Code.enumValue(String enumName, String valueName) = CodeEnum;
  const factory Code.alignment(AlignmentGeometry alignment) = CodeAlignment;
  const factory Code.edgeInsets(EdgeInsetsGeometry insets) = CodeEdgeInsets;
  const factory Code.boxValue(BoxValue value) = CodeBoxValue;
  const factory Code.color(Color color) = CodeColor;
  const factory Code.group(List<Code> lines) = CodeGroup;
  const factory Code.bracketParentheses(List<Code> parts) =
      CodeBracket.parentheses;
  const factory Code.bracketCurly(List<Code> parts) = CodeBracket.curly;
  const factory Code.bracketSquare(List<Code> parts) = CodeBracket.square;
}

extension CodeExtension on Code {
  Code concat(Code other) {
    if (this is CodeConcat) {
      return CodeConcat([...((this as CodeConcat).parts), other]);
    } else {
      return CodeConcat([this, other]);
    }
  }

  Code thenBracketParentheses(List<Code> parts) {
    return CodeBracket.parentheses(parts, prefix: this);
  }

  Code thenBracketCurly(List<Code> parts) {
    return CodeBracket.curly(parts, prefix: this);
  }

  Code thenBracketSquare(List<Code> parts) {
    return CodeBracket.square(parts, prefix: this);
  }
}

class CodeLine implements Code {
  final String code;
  const CodeLine(this.code);

  @override
  String buildCode(int depth) {
    return '${'  ' * depth}$code';
  }
}

class CodeGroup with CodeCompound implements Code {
  @override
  final List<Code> lines;
  const CodeGroup(this.lines);

  @override
  String buildCode(int depth) {
    final builder = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      if (i > 1) {
        builder.write('\n');
      }
      builder.write(lines[i].buildCode(depth));
    }
    return builder.toString();
  }
}

class CodeConcat implements Code {
  final List<Code> parts;
  const CodeConcat(this.parts);

  @override
  String buildCode(int depth) {
    return '${'  ' * depth}${parts.map((e) => e.buildCode(0)).join()}';
  }
}

class CodeEnum implements Code {
  final String enumName;
  final String valueName;
  const CodeEnum(this.enumName, this.valueName);

  @override
  String buildCode(int depth) {
    return '${'  ' * depth}$enumName.$valueName';
  }
}

class CodeAlignment implements Code {
  final AlignmentGeometry alignment;
  const CodeAlignment(this.alignment);

  @override
  String buildCode(int depth) {
    switch (alignment) {
      case Alignment.center:
        return '${'  ' * depth}Alignment.center';
      case Alignment.topLeft:
        return '${'  ' * depth}Alignment.topLeft';
      case Alignment.topCenter:
        return '${'  ' * depth}Alignment.topCenter';
      case Alignment.topRight:
        return '${'  ' * depth}Alignment.topRight';
      case Alignment.centerLeft:
        return '${'  ' * depth}Alignment.centerLeft';
      case Alignment.centerRight:
        return '${'  ' * depth}Alignment.centerRight';
      case Alignment.bottomLeft:
        return '${'  ' * depth}Alignment.bottomLeft';
      case Alignment.bottomCenter:
        return '${'  ' * depth}Alignment.bottomCenter';
      case Alignment.bottomRight:
        return '${'  ' * depth}Alignment.bottomRight';
      case AlignmentDirectional.center:
        return '${'  ' * depth}AlignmentDirectional.center';
      case AlignmentDirectional.topStart:
        return '${'  ' * depth}AlignmentDirectional.topStart';
      case AlignmentDirectional.topCenter:
        return '${'  ' * depth}AlignmentDirectional.topCenter';
      case AlignmentDirectional.topEnd:
        return '${'  ' * depth}AlignmentDirectional.topEnd';
      case AlignmentDirectional.centerStart:
        return '${'  ' * depth}AlignmentDirectional.centerStart';
      case AlignmentDirectional.centerEnd:
        return '${'  ' * depth}AlignmentDirectional.centerEnd';
      case AlignmentDirectional.bottomStart:
        return '${'  ' * depth}AlignmentDirectional.bottomStart';
      case AlignmentDirectional.bottomCenter:
        return '${'  ' * depth}AlignmentDirectional.bottomCenter';
      case AlignmentDirectional.bottomEnd:
        return '${'  ' * depth}AlignmentDirectional.bottomEnd';
      case Alignment():
        return '${'  ' * depth}Alignment(${(alignment as Alignment).x}, ${(alignment as Alignment).y})';
      case AlignmentDirectional():
        return '${'  ' * depth}AlignmentDirectional(${(alignment as AlignmentDirectional).start}, ${(alignment as AlignmentDirectional).y})';
      default:
        return '${'  ' * depth}$alignment';
    }
  }
}

class CodeEdgeInsets implements Code {
  final EdgeInsetsGeometry insets;
  const CodeEdgeInsets(this.insets);

  @override
  String buildCode(int depth) {
    if (insets is EdgeInsets) {
      final e = insets as EdgeInsets;
      if (e.left == e.right && e.left == e.top && e.left == e.bottom) {
        return '${'  ' * depth}EdgeInsets.all(${e.left}px)';
      } else if (e.left == e.right && e.top == e.bottom) {
        return '${'  ' * depth}EdgeInsets.symmetric(vertical: ${e.top}px, horizontal: ${e.left}px)';
      } else {
        return '${'  ' * depth}EdgeInsets.fromLTRB(${e.left}px, ${e.top}px, ${e.right}px, ${e.bottom}px)';
      }
    } else if (insets is EdgeInsetsDirectional) {
      final e = insets as EdgeInsetsDirectional;
      if (e.start == e.end && e.start == e.top && e.start == e.bottom) {
        return '${'  ' * depth}EdgeInsetsDirectional.all(${e.start}px)';
      } else if (e.start == e.end && e.top == e.bottom) {
        return '${'  ' * depth}EdgeInsetsDirectional.symmetric(vertical: ${e.top}px, horizontal: ${e.start}px)';
      } else {
        return '${'  ' * depth}EdgeInsetsDirectional.fromSTEB(${e.start}px, ${e.top}px, ${e.end}px, ${e.bottom}px)';
      }
    } else {
      return '${'  ' * depth}$insets';
    }
  }
}

class CodeBoxValue implements Code {
  final BoxValue value;
  const CodeBoxValue(this.value);

  @override
  String buildCode(int depth) {
    return '${'  ' * depth}$value';
  }
}

class CodeColor implements Code {
  final Color color;
  const CodeColor(this.color);

  @override
  String buildCode(int depth) {
    return '${'  ' * depth}Color.from(alpha: ${color.a}, red: ${color.r}, green: ${color.g}, blue: ${color.b})';
  }
}
