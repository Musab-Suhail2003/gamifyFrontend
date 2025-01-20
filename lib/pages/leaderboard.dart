import 'package:Gamify/bloc/character_bloc.dart';
import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:Gamify/models/user_model.dart';
import 'package:Gamify/pages/characterTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/api_repo.dart';

class LeaderBoardPage extends StatefulWidget {
  final UserModel userData;
  const LeaderBoardPage({super.key, required this.userData});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardBloc()..add(LoadLeaderboard()),
      child: LeaderboardView(userData: widget.userData,),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  final userData;
  const LeaderboardView({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main scaffold remains the same
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LeaderboardBloc>().add(RefreshLeaderboard());
            },
          ),
        ],
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          // Loading and error states remain the same
          if (state is LeaderboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LeaderboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LeaderboardBloc>().add(LoadLeaderboard());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    child: const Text('Try Again', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          }

          if (state is LeaderboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeaderboardBloc>().add(RefreshLeaderboard());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Selected user info section
                  Expanded(
                    flex: 0,
                    child: _buildSelectedUserInfo(state, context),
                  ),
                  // Leaderboard list
                  Expanded(
                    flex: 1,
                    child: leaderboard(state),
                  ),
                  // Bottom bar
                  Expanded(
                    flex: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 0,
                          child: CharacterTile(userId: userData.user_id),
                        ),
                        Row(
                          children: [
                            Text("coin: ${userData.coin} XP: ${userData.XP} "),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final controller = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Change Bio', style: TextStyle(fontStyle: FontStyle.normal),),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          hintText: 'Your new bio...',
                                        ),
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        print('updating user bio');
                                        await ApiRepository().updateBio(userData.user_id, controller.text);
                                        controller.clear();
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                                      ),
                                      child: const Text('Submit', style: TextStyle(color: Colors.black),),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                          ),
                          child: const Text('Change Bio', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSelectedUserInfo(LeaderboardLoaded state, BuildContext context) {
    if (state.selectedUserId == null) {
      return const SizedBox(height: 10);
    }

    // Find the selected user's entry
    final selectedEntry = state.entries.firstWhere(
          (entry) => entry.user.user_id == state.selectedUserId,
      orElse: () => state.entries.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character display
          Expanded(
            flex: 1,
            child: IsolatedCharacterTile(userId: state.selectedUserId!),
          ),
          // User info and bio
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedEntry.user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedEntry.user.bio ?? 'No bio available',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Rank #${selectedEntry.rank}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getCharacter(state){
    if(state.selectedUserId == null) {
      return const SizedBox(width: 10,);
    }
    return IsolatedCharacterTile(userId: state.selectedUserId);
  }

  Widget leaderboard(LeaderboardLoaded state) {
    return ListView.builder(
      itemCount: state.entries.length,
      itemBuilder: (context, index) {
        final entry = state.entries[index];

        return Card(  // Remove the Expanded here
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: ListTile(
            onTap: () {
              context.read<LeaderboardBloc>().add(
                  SelectLeaderboardUser(
                      (state.selectedUserId == null ? entry.user.user_id : null)
                  )
              );
            },
            leading: CircleAvatar(
              child: Image.network(entry.user.profilePicture!),
            ),
            title: Row(
              children: [
                Text(
                  entry.user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20,),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('XP: ${entry.totalXP}', style: const TextStyle(fontSize: 12),),
                Text('Coin: ${entry.totalCoin}', style: const TextStyle(fontSize: 12)),
                Text('Quests: ${entry.user.questsCompleted}', style: const TextStyle(fontSize: 12))
              ],
            ),
            trailing: _buildRankBadge(entry.rank),
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    IconData icon;
    Color color;

    switch (rank) {
      case 1:
        icon = Icons.workspace_premium;
        color = Colors.amber;
        break;
      case 2:
        icon = Icons.military_tech;
        color = Colors.grey[600]!;
        break;
      case 3:
        icon = Icons.emoji_events;
        color = Colors.brown[300]!;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(icon, color: color, size: 30);
  }
}

class IsolatedCharacterTile extends StatelessWidget {
  final String userId;

  const IsolatedCharacterTile({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CharacterBloc(),
      child: CharacterTile(userId: userId),
    );
  }
}
