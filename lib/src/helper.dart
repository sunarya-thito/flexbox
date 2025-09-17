String toStringObject(
  String className, {
  List<String>? params,
  Map<String, String>? namedParams,
  List<String>? optionalParams,
}) {
  final buffer = StringBuffer();
  buffer.write('$className(');
  if (params != null && params.isNotEmpty) {
    buffer.write(params.join(', '));
    if ((namedParams != null && namedParams.isNotEmpty) ||
        (optionalParams != null && optionalParams.isNotEmpty)) {
      buffer.write(', ');
    }
  }
  if (namedParams != null && namedParams.isNotEmpty) {
    buffer.write(
      namedParams.entries.map((e) => '${e.key}: ${e.value}').join(', '),
    );
    if (optionalParams != null && optionalParams.isNotEmpty) {
      buffer.write(', ');
    }
  }
  if (optionalParams != null && optionalParams.isNotEmpty) {
    buffer.write('[');
    buffer.write(optionalParams.join(', '));
    buffer.write(']');
  }
  buffer.write(')');
  return buffer.toString();
}
