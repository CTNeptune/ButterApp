// ignore_for_file: constant_identifier_names

enum MovieFormat {
  NONE,
  VHS,
  BETAMAX,
  DVD,
  HD_DVD,
  BLU_RAY,
  BLU_RAY_4K,
  DIGITAL,
  OTHER,
  GOOGLE_PLAY,
  AMAZON,
  APPLE_TV,
  FANDANGO,
  MICROSOFT
}

extension MovieFormatExtension on MovieFormat {
  static MovieFormat fromJson(String json) {
    if(json.isEmpty){
      return MovieFormat.NONE;
    }
    return MovieFormat.values.firstWhere((e) => e.toString().split('.').last == json);
  }

  String toJson() {
    return toString().split('.').last;
  }
}