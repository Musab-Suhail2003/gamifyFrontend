import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/models/character_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class CharacterEvent {}

class LoadCharacters extends CharacterEvent {}

class LoadCharacterById extends CharacterEvent {
  final String id;
  LoadCharacterById(this.id);
}

class LoadUserCharacters extends CharacterEvent {
  final String userId;
  LoadUserCharacters(this.userId);
}

class UpdateCharacterIndexes extends CharacterEvent {
  final String characterId;
  final Map<String, dynamic> indexes;
  final bool saveToDb; // Add flag to control database updates
  UpdateCharacterIndexes(this.characterId, this.indexes, {this.saveToDb = false});
}

// New customization events
class ChangeHairstyle extends CharacterEvent {}
class ChangeOutfit extends CharacterEvent {}
class ChangeBackground extends CharacterEvent {}
class ChangeFace extends CharacterEvent {}
class ChangeBody extends CharacterEvent {}
class ChangeEye extends CharacterEvent {}
class ChangeBackAccessory extends CharacterEvent {}
class ChangeHeadWear extends CharacterEvent {}
class ChangeNose extends CharacterEvent {}
class ChangeIris extends CharacterEvent {}

// States
abstract class CharacterState {
  // Asset getters
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

  // Customization indexes
  int get hairstyleIndex => 0;
  int get outfitIndex => 0;
  int get backgroundIndex => 0;
  int get faceIndex => 0;
  int get bodyIndex => 0;
  int get eyeIndex => 0;
  int get backAccessoryIndex => 0;
  int get headWearIndex => 0;
  int get noseIndex => 0;
  int get irisIndex => 0;
}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharacterLoaded extends CharacterState {
  @override
  final Character character;
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

  CharacterLoaded(
    this.character, {
    this.hairstyleIndex = 0,
    this.outfitIndex = 0,
    this.backgroundIndex = 0,
    this.faceIndex = 0,
    this.bodyIndex = 0,
    this.eyeIndex = 0,
    this.backAccessoryIndex = 0,
    this.headWearIndex = 0,
    this.noseIndex = 0,
    this.irisIndex = 0,
  });

  factory CharacterLoaded.fromCharacter(Character character) {
    return CharacterLoaded(
      character,
      hairstyleIndex: character.hairstyleIndex ?? 0,
      outfitIndex: character.outfitIndex ?? 0,
      backgroundIndex: character.backgroundIndex ?? 0,
      faceIndex: character.faceIndex ?? 0,
      bodyIndex: character.bodyIndex ?? 0,
      eyeIndex: character.eyeIndex ?? 0,
      backAccessoryIndex: character.backAccessoryIndex ?? 0,
      headWearIndex: character.headWearIndex ?? 0,
      noseIndex: character.noseIndex ?? 0,
      irisIndex: character.irisIndex ?? 0,
    );
  }

  CharacterLoaded copyWith({
    Character? character,
    int? hairstyleIndex,
    int? outfitIndex,
    int? backgroundIndex,
    int? faceIndex,
    int? bodyIndex,
    int? eyeIndex,
    int? backAccessoryIndex,
    int? headWearIndex,
    int? noseIndex,
    int? irisIndex,
  }) {
    return CharacterLoaded(
      character ?? this.character,
      hairstyleIndex: hairstyleIndex ?? this.hairstyleIndex,
      outfitIndex: outfitIndex ?? this.outfitIndex,
      backgroundIndex: backgroundIndex ?? this.backgroundIndex,
      faceIndex: faceIndex ?? this.faceIndex,
      bodyIndex: bodyIndex ?? this.bodyIndex,
      eyeIndex: eyeIndex ?? this.eyeIndex,
      backAccessoryIndex: backAccessoryIndex ?? this.backAccessoryIndex,
      headWearIndex: headWearIndex ?? this.headWearIndex,
      noseIndex: noseIndex ?? this.noseIndex,
      irisIndex: irisIndex ?? this.irisIndex,
    );
  }
}

class AllCharactersLoaded extends CharacterState {
  final List<Character> characters;
  AllCharactersLoaded(this.characters);
}

class SingleCharacterLoaded extends CharacterState {
  final Character character;
  SingleCharacterLoaded(this.character);
}

class CharacterError extends CharacterState {
  final String message;
  CharacterError(this.message);
}

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final apirepo = ApiRepository();

  CharacterBloc() : super(CharacterInitial()) {
    on<LoadCharacters>((event, emit) async {
      emit(CharacterLoading());
      try {
        final characters = await apirepo.getAllCharacters();
        emit(AllCharactersLoaded(characters));
      } catch (e) {
        emit(CharacterError(e.toString()));
      }
    });

    on<LoadCharacterById>((event, emit) async {
      emit(CharacterLoading());
      try {
        final character = await apirepo.getCharacterById(event.id);
        if (character != null) {
          emit(SingleCharacterLoaded(character));
        } else {
          emit(CharacterError("Character not found"));
        }
      } catch (e) {
        emit(CharacterError(e.toString()));
      }
    });

    on<LoadUserCharacters>((event, emit) async {
      emit(CharacterLoading());
      try {
        final character = await apirepo.getCharactersByUserId(event.userId);
          // Use the new factory constructor to properly load saved indexes
          emit(CharacterLoaded.fromCharacter(character));
      } catch (e) {
        emit(CharacterError(e.toString()));
      }
    });

    on<UpdateCharacterIndexes>((event, emit) async {
      if (event.saveToDb) {
        emit(CharacterLoading());
        try {
          await apirepo.updateCharacter(event.characterId, event.indexes);
          emit(CharacterLoaded(Character.fromJson(event.indexes)));
        } catch (e) {
          emit(CharacterError(e.toString()));
        }
      }
    });

    // Modify customization handlers to only update UI state
    on<ChangeHairstyle>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          hairstyleIndex: (currentState.hairstyleIndex + 1) % currentState.hairstyles.length
        ));
      }
    });

    on<ChangeOutfit>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          outfitIndex: (currentState.outfitIndex + 1) % currentState.outfits.length
        ));
      }
    });

    on<ChangeBackground>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          backgroundIndex: (currentState.backgroundIndex + 1) % currentState.backgrounds.length
        ));
      }
    });

    on<ChangeFace>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          faceIndex: (currentState.faceIndex + 1) % currentState.faces.length
        ));
      }
    });

    on<ChangeBody>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          bodyIndex: (currentState.bodyIndex + 1) % currentState.bodies.length
        ));
      }
    });

    on<ChangeEye>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          eyeIndex: (currentState.eyeIndex + 1) % currentState.eyes.length
        ));
      }
    });

    on<ChangeBackAccessory>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          backAccessoryIndex: (currentState.backAccessoryIndex + 1) % currentState.backAccessories.length
        ));
      }
    });

    on<ChangeHeadWear>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          headWearIndex: (currentState.headWearIndex + 1) % currentState.headWears.length
        ));
      }
    });

    on<ChangeNose>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          noseIndex: (currentState.noseIndex + 1) % currentState.noses.length
        ));
      }
    });

    on<ChangeIris>((event, emit) {
      if (state is CharacterLoaded) {
        final currentState = state as CharacterLoaded;
        emit(currentState.copyWith(
          irisIndex: (currentState.irisIndex + 1) % currentState.iris.length
        ));
      }
    });
  }
}