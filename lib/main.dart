import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:audioplayers/audioplayers.dart'; Audioplayers is not working on android I can't figure out how to fix it
import 'dart:math';

void main() {
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stake\'s Dice Game',
      home: DiceGame(),
    );
  }
}

class DiceGame extends StatefulWidget {
  const DiceGame({super.key});

  @override
  State<DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  int walletBalance = 10;
  int wagerAmount = 0;
  int multiplier = 2;
  TextEditingController wagerController = TextEditingController();
  //AudioPlayer audioPlayer = AudioPlayer();

  bool isValidWager(int wagerAmount) {
    if (wagerAmount == 0 || wagerAmount > walletBalance) {
      return false;
    }
    int maxPossibleWager = walletBalance ~/ multiplier;
    return wagerAmount <= maxPossibleWager;
  }

  void rollDice() /*async*/ {
    Random random = Random();

    List<int> diceRoll = [];
    for (int i = 0; i < 4; i++) {
      int diceRollValue = random.nextInt(6) + 1;
      diceRoll.add(diceRollValue);
    }

    int wagerAmount = int.tryParse(wagerController.text) ?? 0;

    if (!isValidWager(wagerAmount)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid wager for $multiplier alike!'),
        duration: Duration(seconds: 1),
      ));
      return;
    }

    //Why does this only work on iOS and not on Android :(
    //await audioPlayer.play(AssetSource('rpg-dice-rolling-95182.mp3'));

    //The list containing counts of what number appeared in the 4 rolls (eg. diceRoll = [1,3,4,1] => rollFrequencyDistribution = [2,0,1,1,0,0])
    List<int> rollFrequencyDistribution = [0, 0, 0, 0, 0, 0];

    for (var roll in diceRoll) {
      rollFrequencyDistribution[roll - 1]++;
    }

    int maxFreqCount = rollFrequencyDistribution.reduce(max);

    if (maxFreqCount >= multiplier) {
      int winnings = wagerAmount * multiplier;
      walletBalance += winnings;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Dice: $diceRoll\nYou won $winnings§!'),
        duration: Duration(seconds: 2),
      ));
    } else {
      walletBalance -= wagerAmount * multiplier;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Dice: $diceRoll\nYou lost ${wagerAmount * multiplier}§.'),
        duration: Duration(seconds: 2),
      ));
    }

    wagerController.clear();
    setState(() {});
  }

  void reset() {
    walletBalance = 10;
    wagerController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4EDD3),
      appBar: AppBar(
        backgroundColor: Color(0xFFA5BFCC),
        title: Text(
          'Stake\'s Dice Game',
          style: TextStyle(
            color: Color(0xFF31363F),
            fontFamily: 'Quicksand-Regular',
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(20.0, 200.0, 20.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Wallet: $walletBalance§',
              style: TextStyle(
                color: Color(0xFF222831),
                fontSize: 28,
              ),
            ),
            SizedBox(height: 40),
            TextField(
              controller: wagerController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter your wager',
              ),
              onChanged: (value) {
                setState(() {
                  wagerAmount = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Choose a multiplier:',
              style: TextStyle(fontSize: 14, color: Color(0xFF4C585B)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2, 3, 4].map((multiplierOption) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      multiplier = multiplierOption;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: multiplier == multiplierOption
                        ? Color(0xFF4C585B)
                        : Color(0xFFA5BFCC),
                    foregroundColor: multiplier == multiplierOption
                        ? Color(0xFFA5BFCC)
                        : Color(0xFF222831),
                  ),
                  child: Text('$multiplierOption Alike'),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200.0,
              child: ElevatedButton(
                onPressed: rollDice,
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 55),
                    backgroundColor: Color(0xFFA5BFCC),
                    foregroundColor: Color(0xFF222831)),
                child: Row(
                  spacing: 10.0,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset('assets/dice.png'), Text('Place Bet')],
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4C585B),
                foregroundColor: Color(0xFFA5BFCC),
              ),
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
