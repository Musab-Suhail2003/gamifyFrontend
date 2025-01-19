import 'package:Gamify/bloc/character_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
class CharacterTile extends StatefulWidget {
  final String userId;
  const CharacterTile({Key? key, required this.userId}) : super(key: key);

  @override
  State<CharacterTile> createState() => _CharacterTileState();
}

class _CharacterTileState extends State<CharacterTile> {
  @override
  void initState() {
    super.initState();
    context.read<CharacterBloc>().add(LoadUserCharacters(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    print('making character tile for ${widget.userId}');
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        if (state is CharacterLoading) {
          return const SizedBox(
            width: 80,
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 1)),
          );
        }

        if (state is CharacterError) {
          return SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          );
        }

        if (state is CharacterLoaded) {
          return SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image(
                    image: AssetImage(state.backgrounds[state.backgroundIndex]),
                    fit: BoxFit.contain,
                  ),
                ),
                // Character elements
                Positioned(
                  top: 30, // Adjusted from 90 to maintain proportions
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Back accessories
                      if (state.backAccessories.isNotEmpty)
                        Image.asset(
                          state.backAccessories[state.backAccessoryIndex],
                          width: 50, // Reduced from 100 to maintain proportions
                          fit: BoxFit.contain,
                        ),
                      // Body
                      if (state.bodies.isNotEmpty)
                        Image.asset(
                          state.bodies[state.bodyIndex],
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      // Outfit
                      if (state.outfits.isNotEmpty)
                        Image.asset(
                          state.outfits[state.outfitIndex],
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      // Face
                      if (state.faces.isNotEmpty)
                        Image.asset(
                          state.faces[state.faceIndex],
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      // Eyes
                      if (state.eyes.isNotEmpty)
                        Image.asset(
                          state.eyes[state.eyeIndex],
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      // Nose
                      if (state.noses.isNotEmpty)
                        Image.asset(
                          state.noses[state.noseIndex],
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      // Hairstyle
                      if (state.hairstyles.isNotEmpty)
                        Image.asset(
                          state.hairstyles[state.hairstyleIndex],
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      // Head wear
                      if (state.headWears.isNotEmpty)
                        Image.asset(
                          state.headWears[state.headWearIndex],
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}