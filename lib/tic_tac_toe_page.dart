import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  static const String USER = 'X';
  static const String BOT = 'O';
  static const String EMPTY = '';

  List<String> board = List.generate(9, (_) => EMPTY);
  bool isUserTurn = true;
  String? winner;

  void _handleTap(int index) {
    if (board[index] != EMPTY || winner != null || !isUserTurn) return;

    setState(() {
      board[index] = USER;
      isUserTurn = false;
      winner = _checkWinner();
    });

    if (winner == null && board.contains(EMPTY)) {
      Future.delayed(const Duration(milliseconds: 600), _botMove);
    }
  }

  void _botMove() {
    if (winner != null || !board.contains(EMPTY)) return;

    // Simple AI: Try to win, then block, then random
    int? move = _findBestMove();

    setState(() {
      board[move!] = BOT;
      isUserTurn = true;
      winner = _checkWinner();
    });
  }

  int? _findBestMove() {
    // 1. Can bot win?
    for (int i = 0; i < 9; i++) {
      if (board[i] == EMPTY) {
        board[i] = BOT;
        if (_checkWinner() == BOT) {
          board[i] = EMPTY;
          return i;
        }
        board[i] = EMPTY;
      }
    }

    // 2. Can user win? (Block)
    for (int i = 0; i < 9; i++) {
      if (board[i] == EMPTY) {
        board[i] = USER;
        if (_checkWinner() == USER) {
          board[i] = EMPTY;
          return i;
        }
        board[i] = EMPTY;
      }
    }

    // 3. Center
    if (board[4] == EMPTY) return 4;

    // 4. Random
    List<int> available = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == EMPTY) available.add(i);
    }
    return available[Random().nextInt(available.length)];
  }

  String? _checkWinner() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (var line in lines) {
      if (board[line[0]] != EMPTY &&
          board[line[0]] == board[line[1]] &&
          board[line[0]] == board[line[2]]) {
        return board[line[0]];
      }
    }

    if (!board.contains(EMPTY)) return 'Draw';
    return null;
  }

  void _resetGame() {
    setState(() {
      board = List.generate(9, (_) => EMPTY);
      isUserTurn = true;
      winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'TokN Tic Tac Toe',
          style: GoogleFonts.poppins(color: const Color(0xFF2E4C9D), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2E4C9D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatusArea(),
          const SizedBox(height: 40),
          _buildGrid(),
          const SizedBox(height: 50),
          if (winner != null)
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4C9D),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Play Again', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusArea() {
    String status = winner == 'Draw' 
        ? 'It\'s a Draw!' 
        : winner != null 
            ? (winner == USER ? 'You Won! 🎉' : 'Bot Won! 🤖')
            : (isUserTurn ? 'Your Turn' : 'Bot is thinking...');

    return Column(
      children: [
        Text(
          status,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: winner == BOT ? Colors.redAccent : const Color(0xFF2E4C9D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          winner != null ? 'Game Over' : 'Beat the Bot to prove your brain power!',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _handleTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  board[index],
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: board[index] == USER ? const Color(0xFF2E4C9D) : Colors.redAccent,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
