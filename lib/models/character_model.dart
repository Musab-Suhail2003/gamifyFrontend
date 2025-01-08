// models/character.dart
class Character {
  final String id;
  final String userId;
   int? hairstyleIndex;
   int? outfitIndex;
   int? backgroundIndex;
   int? faceIndex;
   int? bodyIndex;
   int? eyeIndex;
   int? backAccessoryIndex;
   int? headWearIndex;
   int? noseIndex;
   int? irisIndex;

Character({
    required this.id,
    required this.userId,
    this.hairstyleIndex=0,
    this.outfitIndex=0,
    this.backgroundIndex=0,
    this.faceIndex=0,
    this.bodyIndex=0,
    this.eyeIndex=0,
    this.backAccessoryIndex=0,
    this.headWearIndex=0,
    this.noseIndex=0,
    this.irisIndex=0,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['_id'],
      userId: json['userId'],
      hairstyleIndex: json['hairstyleIndex'],
      outfitIndex: json['outfitIndex'],
      backgroundIndex: json['backgroundIndex'],
      faceIndex: json['faceIndex'],
      bodyIndex: json['bodyIndex'],
      eyeIndex: json['eyeIndex'],
      backAccessoryIndex: json['backAccessoryIndex'],
      headWearIndex: json['headWearIndex'],
      noseIndex: json['noseIndex'],
      irisIndex: json['irisIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hairstyleIndex': hairstyleIndex,
      'outfitIndex': outfitIndex,
      'backgroundIndex': backgroundIndex,
      'faceIndex': faceIndex,
      'bodyIndex': bodyIndex,
      'eyeIndex': eyeIndex,
      'backAccessoryIndex': backAccessoryIndex,
      'headWearIndex': headWearIndex,
      'noseIndex': noseIndex,
      'irisIndex': irisIndex,
    };
  }
}
