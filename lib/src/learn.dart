import 'package:flutter/material.dart';
import 'package:switch_learning/src/components/appbar.dart';

class LearningModeWidget extends StatefulWidget {
  const LearningModeWidget({
    super.key,
    required this.title,
    required this.keywordList,
    required this.relevanceList,
  });

  final String title;
  final List<String> keywordList;
  final List<String> relevanceList;

  @override
  State<LearningModeWidget> createState() => _LearningModeWidgetState();
}

class _LearningModeWidgetState extends State<LearningModeWidget> {
  List<int> questionOrder = [];
  int index = 0;
  bool isQuestion = true;
  bool isFinished = false;

  @override
  void initState() {
    questionOrder = List<int>.generate(widget.keywordList.length, (i) => i);
    questionOrder.shuffle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: MainAppBar("Learning mode: ${widget.title}"),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Question ${index + 1}/${widget.keywordList.length}",
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuestionDisplay(
                        question: widget.keywordList[questionOrder[index]],
                        answer: widget.relevanceList[questionOrder[index]],
                        isQuestion: isQuestion,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: TextButton(
                                onPressed: () {
                                  if (isQuestion == true) {
                                    setState(() {
                                      if (index == widget.keywordList.length - 1) {
                                        isFinished = true;
                                      }
                                      isQuestion = false;
                                    });
                                  } else if (index < widget.keywordList.length - 1) {
                                    setState(() {
                                      index++;
                                      isQuestion = true;
                                    });
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.zero),
                                  ),
                                ),
                                child: Text(
                                  isFinished == true
                                      ? "Exit learning mode"
                                      : isQuestion == true
                                          ? "See the answer"
                                          : "Next question",
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionDisplay extends StatelessWidget {
  const QuestionDisplay({
    super.key,
    required this.question,
    required this.answer,
    required this.isQuestion,
  });

  final String question;
  final String answer;
  final bool isQuestion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 30.0,
        left: 30.0,
        right: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Q: $question",
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (isQuestion == false) const SizedBox(height: 20),
          if (isQuestion == false)
            Text(
              "A: $answer",
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
