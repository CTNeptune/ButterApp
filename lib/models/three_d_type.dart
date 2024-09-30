// ignore_for_file: constant_identifier_names

enum ThreeDType {
  NONE,
  ANAGLYPHIC,
  POLARIZED,
  ACTIVE_SHUTTER
}

extension ThreeDTypeExtension on ThreeDType {
  static ThreeDType fromJson(String json) {
    if(json.isEmpty){
      return ThreeDType.NONE;
    }
    return ThreeDType.values.firstWhere((e) => e.toString().split('.').last == json);
  }

  String toJson() {
    return toString().split('.').last;
  }
}