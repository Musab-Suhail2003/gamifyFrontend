import 'package:bloc/bloc.dart';

enum CharacterCustomizationEvent { changeHairstyle, changeOutfit, changeBackground, changeFace, changeBody, changeEye, changeBackAccessory, changeHeadWear, changeNose, changeIris }

class CharacterCustomizationState {
  final int hairstyleIndex;
  final int outfitIndex;
  final int backgroundIndex;
  final int faceIndex;
  final int bodyIndex;
  final int eyeIndex;
  final int backAccessoryIndex;
  final int headWearIndex;
  final int noseIndex;
  final int irisIndex;


  CharacterCustomizationState({
    required this.hairstyleIndex,
    required this.outfitIndex,
    required this.backgroundIndex,
    required this.faceIndex,
    required this.bodyIndex,
    required this.eyeIndex,
    required this.backAccessoryIndex,
    required this.headWearIndex,
    required this.noseIndex,
    required this.irisIndex
  });

  CharacterCustomizationState copyWith({
    int? hairstyleIndex,
    int? outfitIndex,
    int? backgroundIndex,
    int? faceIndex,
    int? bodyIndex,
    int? eyeIndex,
    int? backAccessoryIndex,
    int? headWearIndex,
    int? noseIndex,
    int? irisIndex
  }) {
    return CharacterCustomizationState(
      hairstyleIndex:     hairstyleIndex ?? this.hairstyleIndex,
      outfitIndex:        outfitIndex ?? this.outfitIndex,
      backgroundIndex:    backgroundIndex ?? this.backgroundIndex,
      faceIndex:          faceIndex ?? this.faceIndex,
      bodyIndex:          bodyIndex ?? this.bodyIndex,
      eyeIndex:           eyeIndex ?? this.eyeIndex,
      backAccessoryIndex: backAccessoryIndex ?? this.backAccessoryIndex,
      headWearIndex:      headWearIndex ?? this.headWearIndex,
      noseIndex:          noseIndex ?? this.noseIndex,
      irisIndex:          irisIndex ?? this.irisIndex
    );
  }

  List<String> get hairstyles => [
        'assets/invisible.png',
        'assets/human_a/hairs/hair_0.png'
      ];
  
  List<String> get bodies => [
    'assets/human_a/bodies/body_1.png',
    'assets/human_a/bodies/body_2.png'
  ];

  List<String> get backAccessories => [
    'assets/invisible.png',
    'assets/human_a/back_accessories/back_1.png'
  ];

  List<String> get outfits => [
        'assets/invisible.png',
        'assets/human_a/outfit/outfit_1_var1.png',
        'assets/human_a/outfit/outfit_1_var2.png',
        'assets/human_a/outfit/outfit_1.png',
      ];
  List<String> get backgrounds => [
    'assets/invisible.png',
    'assets/backgrounds/background_1.png',
    'assets/backgrounds/background_2.png'
  ];

  List<String> get faces => [
        'assets/human_a/face/face_1/angry.png',
        'assets/human_a/face/face_1/laughing.png',
        'assets/human_a/face/face_1/normal.png',
        'assets/human_a/face/face_1/sad.png', 
        'assets/human_a/face/face_1/smile.png',
        'assets/human_a/face/face_1/smirk.png',
        'assets/human_a/face/face_1/surprise.png',
        'assets/human_a/face/face_1/very_angry.png'
      ];

  List<String> get iris => [
    'assets/human_a/iris/iris.png'
  ];

  List<String> get eyes => [
      'assets/invisible.png',
      'assets/human_a/eyes/eyes_1.png',
      'assets/human_a/eyes/eyes_2.png',
      'assets/human_a/eyes/eyes_3.png'
  ];
  
  List<String> get noses => [
    'assets/human_a/noses/nose1.png'
  ];

  List<String> get headWears => [
    'assets/invisible.png',
    'assets/human_a/headwear/headware_1.png',
    'assets/human_a/headwear/headware_2.png'
  ];
}

class CharacterCustomizationBloc
    extends Bloc<CharacterCustomizationEvent, CharacterCustomizationState> {
  CharacterCustomizationBloc()
      : super(CharacterCustomizationState(
          hairstyleIndex:     0, 
          outfitIndex:        0,
          backgroundIndex:    0,
          faceIndex:          0,
          bodyIndex:          0,
          eyeIndex:           0,
          backAccessoryIndex: 0,
          headWearIndex:      0,
          noseIndex:          0,
          irisIndex:          0

        )) {
    on<CharacterCustomizationEvent>((event, emit) {
      switch (event) {
      case CharacterCustomizationEvent.changeHairstyle:
        emit(state.copyWith(hairstyleIndex: (state.hairstyleIndex + 1) % state.hairstyles.length));
        break;
        
      case CharacterCustomizationEvent.changeOutfit:  
        emit(state.copyWith(outfitIndex: (state.outfitIndex + 1) % state.outfits.length));
        break;
        
      case CharacterCustomizationEvent.changeBackground:
        emit(state.copyWith(backgroundIndex: (state.backgroundIndex + 1) % state.backgrounds.length));
        break;
        
      case CharacterCustomizationEvent.changeFace:
        emit(state.copyWith(faceIndex: (state.faceIndex + 1) % state.faces.length));
        break;
        
      case CharacterCustomizationEvent.changeBody:
        emit(state.copyWith(bodyIndex: (state.bodyIndex + 1) % state.bodies.length));
        break;
        
      case CharacterCustomizationEvent.changeEye:
        emit(state.copyWith(eyeIndex: (state.eyeIndex + 1) % state.eyes.length)); 
        break;
        
      case CharacterCustomizationEvent.changeBackAccessory:
        emit(state.copyWith(backAccessoryIndex: (state.backAccessoryIndex + 1) % state.backAccessories.length));
        break;
        
      case CharacterCustomizationEvent.changeHeadWear:
        emit(state.copyWith(headWearIndex: (state.headWearIndex + 1) % state.headWears.length));
        break;
        
      case CharacterCustomizationEvent.changeNose:
        emit(state.copyWith(noseIndex: (state.noseIndex + 1) % state.noses.length));
        break;
        
      case CharacterCustomizationEvent.changeIris:
        emit(state.copyWith(irisIndex: (state.irisIndex + 1) % state.iris.length));
        break;
      }
    });
  }
}