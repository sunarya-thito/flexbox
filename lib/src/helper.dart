/// Helper function to generate a string representation of an object with its parameters.
///
/// This utility creates a formatted string showing the class name followed by its
/// parameters in a standard Dart constructor format. It supports positional parameters,
/// named parameters, and optional parameters, combining them in the correct order.
///
/// The output format follows Dart's constructor syntax: `ClassName(params, namedParams, [optionalParams])`
///
/// Parameters:
/// * [className] - The name of the class to display
/// * [params] - List of positional parameter strings (e.g., `['value1', 'value2']`)
/// * [namedParams] - Map of named parameter names to their string values (e.g., `{'width': '100', 'height': '50'}`)
/// * [optionalParams] - List of optional parameter strings displayed in square brackets
///
/// Returns a formatted string like: `MyClass(param1, param2, name: value, [optional])`
///
/// Example:
/// ```dart
/// final str = toStringObject(
///   'FlexBox',
///   params: ['child1', 'child2'],
///   namedParams: {'direction': 'row', 'gap': '8.0'},
///   optionalParams: ['wrap'],
/// );
/// // Output: FlexBox(child1, child2, direction: row, gap: 8.0, [wrap])
/// ```
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
