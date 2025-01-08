import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/bloc/character_bloc.dart';
import 'package:Gamify/bloc/character_customization_bloc.dart';
import 'package:Gamify/models/character_model.dart';
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
        // Fetch the saved character data from the API
        var c1 = (await ApiRepository().getCharactersByUserId(widget.userId)).toJson();
        var c2 = state.character.toJson();
        
        // Compare the values of the character data
        c1.forEach((key, value) {
          if (value != c2[key]) {
            changes++;
          }
        });

        // Update the state with the total changes
        setState(() {
          totalChanges = changes;
        });
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Customization'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          ()async=>await trackChanges(state);
          print(totalChanges);
          return Row(
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20,),
                  CharacterTile(userId: widget.userId),
                  
                Expanded(
                  flex: 1,
                  child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 20,
                      child: Text('$totalChanges total changes. it will cost ${totalChanges*100} coins'),
                    ),

                    SizedBox(
                          height: 35,
                          child:ElevatedButton(
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

                                // Update the state in the CharacterBloc after saving the character
                                context.read<CharacterBloc>().add(UpdateCharacterIndexes(widget.character_id, characterData, saveToDb: true));

                                // Save the character via API
                                await ApiRepository().updateCharacter(widget.character_id, characterData);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Character Saved Successfully!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to save character: $e')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.tertiary),
                            child: const Text('Save Character'),
                          )
                          ,
                        ),
                  const Text('Customize Hairstyle'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeHairstyle());
                            },
                          ),
                          Text('Hairstyle ${state.hairstyleIndex + 1}'),
                          
                        ],
                      ),
                      const Text('Customize Outfit'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeOutfit());
                            },
                          ),
                          Text('Outfit ${state.outfitIndex + 1}'),
                          
                        ],
                      ),
                      const Text('Select Background'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeBackground());
                            },
                          ),
                          Text('Background ${state.backgroundIndex + 1}'),
                          
                        ],
                      ),
                      const SizedBox(height: 40,),
                      const SizedBox(
                        height: 40,
                        child: Text("Note You will be Charged 100 coin \nper every change, if you dont have \nenough your customization will be cancelled", style: TextStyle(fontSize: 10),),
                      )
],
                ))
                ]
                
              ),
              Expanded(
                flex: 2,
               child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      const Text('Select Face'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeFace());
                            },
                          ),
                          Text('Face ${state.faceIndex + 1}'),
                          
                        ],
                      ),
                      const Text('Select Body'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeBody());
                            },
                          ),
                          Text('Body ${state.bodyIndex + 1}'),
                          
                        ],
                      ),
                      const Text('Select Eyes'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeEye());
                            },
                          ),
                          Text('Eyes ${state.eyeIndex + 1}'),
                          
                        ],
                      ),
                      const Text('Select Back Accessory'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeBackAccessory());
                            },
                          ),
                          Text('Back Access. ${state.backAccessoryIndex + 1}'),
                          
                        ],
                      ),
                      const Text('Select Head Wear'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeHeadWear());
                            },
                          ),
                          Text('Head Wear ${state.headWearIndex + 1}'),
                      
                        ],
                      ),
                      const Text('Select Nose'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeNose());
                            },
                          ),
                          Text('Nose ${state.noseIndex + 1}'),
                        ],
                      ),
                      const Text('Select Iris'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<CharacterBloc>().add(ChangeIris());
                            },
                          ),
                          Text('Iris ${state.irisIndex + 1}'),
                        ],
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

  Widget characterTile(CharacterCustomizationState state, BuildContext context){
    return Expanded(
                flex: 2,
                  child:
                    Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: 150,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Image(image: AssetImage(state.backgrounds[state.backgroundIndex],), fit: BoxFit.fill,)
                        ),
                      ),
                      if (state.backAccessories.isNotEmpty)
                        Positioned(
                          top: 90,
                          child: Image.asset(
                            state.backAccessories[state.backAccessoryIndex],
                            width: 100,
                            fit: BoxFit.fill,
                          ),
                        ),
                     if (state.bodies.isNotEmpty)
                        Positioned(
                          top: 90,
                          child: Image.asset(
                            state.bodies[state.bodyIndex],
                            width: 100,
                          ),
                        ),
                      if (state.outfits.isNotEmpty)
                        Positioned(
                          top: 90,
                          child: Image.asset(
                            state.outfits[state.outfitIndex],
                            width: 100,
                          ),
                        ),
                      if (state.faces.isNotEmpty)
                        Positioned(
                          top: 90,
                          child: Image.asset(
                            state.faces[state.faceIndex],
                            width: 100,
                          ),
                        ),
                       if (state.hairstyles.isNotEmpty)
                        Positioned(
                          top: 90,
                          child: Image.asset(
                            state.hairstyles[state.hairstyleIndex],
                            width: 100,
                          ),
                        ),
                      if (state.noses.isNotEmpty)
                        Positioned(
                          top: 90,
                          child: Image.asset(
                            state.noses[state.noseIndex],
                            width: 100,
                          ),
                        ),
                        if (state.eyes.isNotEmpty)
                        Positioned( 
                          top: 90,
                          child: Image.asset(
                            state.eyes[state.eyeIndex],
                            width: 100,
                          ),),
                        if (state.headWears.isNotEmpty)
                        Positioned(
                          top: 90,
                          child: Image.asset(
                            state.headWears[state.headWearIndex],
                            width: 100,
                          ),
                        ),
                       
                    ],
                  ),
                  
                );
  }
}