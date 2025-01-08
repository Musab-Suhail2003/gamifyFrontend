import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:Gamify/pages/characterTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({super.key});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardBloc()..add(LoadLeaderboard()),
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          if (state is LeaderboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                    child: const Text('Try Again'),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 0,
                    child: getCharacter(state),
                  ),
                 Expanded(
                  
                  flex: 1,
                    child: leaderboard(state),
                )
                ],
              )
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[300]!; // Silver
      case 3:
        return Colors.brown[300]!; // Bronze
      default:
        return Colors.blue[100]!;
    }
  }

  Widget getCharacter(state){
    if(state.selectedUserId == null)
      return SizedBox(width: 10,);
    return CharacterTile(userId: state.selectedUserId);
  }

  Widget leaderboard (LeaderboardLoaded state){
    return ListView.builder(
                itemCount: state.entries.length,
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  
                  return Expanded(
                    
                    child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      onTap: (){
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
                      ), const SizedBox(width: 20,),
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
                  ),
                  )
                  ;
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
        color = Colors.grey[300]!;
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