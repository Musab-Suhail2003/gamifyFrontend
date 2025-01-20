import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/bloc/character_bloc.dart';
import 'package:Gamify/pages/characterTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterCustomizationScreen extends StatefulWidget {
  final String character_id;
  final String userId;
  const CharacterCustomizationScreen({required this.character_id, required this.userId});

  @override
  _CharacterCustomizationScreenState createState() => _CharacterCustomizationScreenState();
}

class _CharacterCustomizationScreenState extends State<CharacterCustomizationScreen> {
  @override
  Widget build(BuildContext context) {
    int totalChanges = 0;

    Future<void> trackChanges(CharacterState state) async {
      int changes = 0;
      if (state is CharacterLoaded) {
        var c1 = (await ApiRepository().getCharactersByUserId(widget.userId)).toJson();
        var c2 = state.character.toJson();
        c1.forEach((key, value) {
          if (value != c2[key]) changes++;
        });
        setState(() => totalChanges = changes);
      }
    }

    Widget customizationOption({
      required String label,
      required int index,
      required VoidCallback onTap,
    }) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Text(label, style: const TextStyle(fontSize: 14)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(
                width: 40,
                child: Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Character Customization'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                '$totalChanges changes • ${totalChanges * 100} coins',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          () async => await trackChanges(state);

          return Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      // Character Preview
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CharacterTile(userId: widget.userId),
                        ),
                      ),

                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                customizationOption(
                                  label: 'Hairstyle',
                                  index: state.hairstyleIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeHairstyle()),
                                ),
                                customizationOption(
                                  label: 'Outfit',
                                  index: state.outfitIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeOutfit()),
                                ),
                                customizationOption(
                                  label: 'Background',
                                  index: state.backgroundIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeBackground()),
                                ),
                                customizationOption(
                                  label: 'Face',
                                  index: state.faceIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeFace()),
                                ),
                                customizationOption(
                                  label: 'Body',
                                  index: state.bodyIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeBody()),
                                ),
                                customizationOption(
                                  label: 'Eyes',
                                  index: state.eyeIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeEye()),
                                ),
                                customizationOption(
                                  label: 'Back Accessory',
                                  index: state.backAccessoryIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeBackAccessory()),
                                ),
                                customizationOption(
                                  label: 'Head Wear',
                                  index: state.headWearIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeHeadWear()),
                                ),
                                customizationOption(
                                  label: 'Nose',
                                  index: state.noseIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeNose()),
                                ),
                                customizationOption(
                                  label: 'Iris',
                                  index: state.irisIndex,
                                  onTap: () => context.read<CharacterBloc>().add(ChangeIris()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom section with warning and save button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (totalChanges > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Note: You will be charged 100 coins per change. If you don\'t have enough coins, your customization will be cancelled.',
                          style: TextStyle(fontSize: 12, color: Colors.amber),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final characterData = {
                            'hairstyleIndex': state.hairstyleIndex,
                            'outfitIndex': state.outfitIndex,
                            'backgroundIndex': state.backgroundIndex,
                            'faceIndex': state.faceIndex,
                            'bodyIndex': state.bodyIndex,
                            'eyeIndex': state.eyeIndex,
                            'backAccessoryIndex': state.backAccessoryIndex,
                            'headWearIndex': state.headWearIndex,
                            'noseIndex': state.noseIndex,
                            'irisIndex': state.irisIndex,
                          };

                          context.read<CharacterBloc>().add(UpdateCharacterIndexes(
                              widget.character_id,
                              characterData,
                              saveToDb: true
                          ));

                          await ApiRepository().updateCharacter(widget.character_id, characterData);
                          context.read<CharacterBloc>().add(LoadCharacterById(widget.character_id));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Character Saved Successfully!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save character: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Character'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}