import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switch_learning/src/components/appbar.dart';
import 'package:switch_learning/src/components/missing_data.dart';
import 'package:switch_learning/src/components/dialogue_handler.dart';
import 'package:switch_learning/src/learn.dart';
import 'package:switch_learning/src/theme/theme.dart';
import 'package:switch_learning/src/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplayPage extends StatefulWidget {
  final String mainKey;
  final String prefix;
  const DisplayPage(this.mainKey, this.prefix, {super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  List<String> keyWord = [];
  List<String> relevance = [];
  late String keyWordKey;
  late String relevanceKey;
  String keyPrefix = "";
  String relevancePrefix = "";
  late SharedPreferences prefs;
  bool isDoingSomething = false;

  void initVal() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      relevance = prefs.getStringList(relevanceKey) ?? [];
      keyWord = prefs.getStringList(keyWordKey) ?? [];
    });
    if (keyWord.isEmpty) {
      await prefs.setStringList(keyWordKey, []);
    }
    if (relevance.isEmpty) {
      await prefs.setStringList(relevanceKey, []);
    }
  }

  @override
  void initState() {
    super.initState();
    keyWordKey = "${widget.mainKey}_1";
    relevanceKey = "${widget.mainKey}_2";
    initVal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: MainAppBar(widget.mainKey),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: keyWord.isNotEmpty
                    ? ReorderableListView(
                        children: <Widget>[
                          for (var index = 0; index < keyWord.length; index++)
                            ListTile(
                              key: ValueKey(index),
                              title: Text(textDisplay(index)),
                              trailing: Visibility(
                                visible: Provider.of<ThemeProvider>(context).showMisc,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => editData(index),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () => deleteData(index),
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        onReorder: (oldIndex, newIndex) async {
                          if (isDoingSomething == true) return;
                          isDoingSomething = true;
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          setState(() {
                            final movedKey = keyWord.removeAt(oldIndex);
                            keyWord.insert(newIndex, movedKey);
                            final movedrel = relevance.removeAt(oldIndex);
                            relevance.insert(newIndex, movedrel);
                          });
                          await prefs.setStringList(keyWordKey, keyWord);
                          await prefs.setStringList(relevanceKey, relevance);
                          isDoingSomething = false;
                        },
                      )
                    : const MissingData("It seems like there is nothing in this topic"),
              ),
              Visibility(
                visible: Provider.of<ThemeProvider>(context).showMisc,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (isDoingSomething == true) return;
                        isDoingSomething = true;
                        List<String> newPrefix = await DialogueHandler().doubleOpenDialog(
                              context,
                              "Set prefix",
                              "Keyword prefix",
                              keyPrefix,
                              "Relevance prefix",
                              relevancePrefix,
                              false,
                              [],
                            ) ??
                            [keyPrefix, relevancePrefix];
                        keyPrefix = newPrefix[0];
                        relevancePrefix = newPrefix[1];
                        isDoingSomething = false;
                      },
                      child: const Text("Set prefix"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (keyWord.isNotEmpty)
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearningModeWidget(
                        title: widget.mainKey,
                        keywordList: keyWord,
                        relevanceList: relevance,
                      ),
                    ),
                  );
                },
                heroTag: null,
                child: const Icon(Icons.menu_book),
              ),
            if (keyWord.isNotEmpty) const SizedBox(height: 24),
            FloatingActionButton(
              onPressed: () async {
                if (isDoingSomething == true) return;
                isDoingSomething = true;
                final List<String?> addedValue = await DialogueHandler().doubleOpenDialog(
                      context,
                      "Add keyword",
                      "Enter the keyword",
                      keyPrefix,
                      "Enter the data",
                      relevancePrefix,
                      true,
                      keyWord,
                    ) ??
                    [null, null];
                String? newKeyWord = addedValue[0];
                String? newRelevance = addedValue[1];
                if (newKeyWord == null || newRelevance == null) {
                  isDoingSomething = false;
                  return;
                }
                if (newKeyWord.isEmpty) {
                  if (context.mounted) {
                    await DialogueHandler().errorDialog(context, "Keyword can't be empty!");
                  }
                  isDoingSomething = false;
                  return;
                }
                for (String keyWords in keyWord) {
                  if (newKeyWord == keyWords) {
                    if (context.mounted) {
                      await DialogueHandler().errorDialog(context, "The keyword already exists!");
                    }
                    isDoingSomething = false;
                    return;
                  }
                }
                setState(() {
                  keyWord.insert(keyWord.length, newKeyWord);
                  relevance.insert(relevance.length, newRelevance);
                });
                await prefs.setStringList(keyWordKey, keyWord);
                await prefs.setStringList(relevanceKey, relevance);
                isDoingSomething = false;
              },
              heroTag: null,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void editData(int index) async {
    if (isDoingSomething == true) return;
    isDoingSomething = true;
    final List<String?> editedValue = await DialogueHandler().doubleOpenDialog(
          context,
          "Edit keyword",
          "Enter the keyword",
          keyWord[index],
          "Enter the data",
          relevance[index],
          true,
          keyWord,
        ) ??
        [null, null];
    String? newKeyWord = editedValue[0];
    String? newRelevance = editedValue[1];
    if (newKeyWord == null || newRelevance == null) {
      isDoingSomething = false;
      return;
    }
    if (newKeyWord == '') {
      if (mounted) {
        await DialogueHandler().errorDialog(context, "Keyword can't be empty!");
      }
      isDoingSomething = false;
      return;
    }
    for (String keyWords in keyWord) {
      if (newKeyWord == keyWords && keyWords != keyWord[index]) {
        if (mounted) {
          await DialogueHandler().errorDialog(context, "The keyword already exists!");
        }
        isDoingSomething = false;
        return;
      }
    }
    setState(() {
      keyWord[index] = newKeyWord;
      relevance[index] = newRelevance;
    });
    await prefs.setStringList(keyWordKey, keyWord);
    await prefs.setStringList(relevanceKey, relevance);
    isDoingSomething = false;
  }

  void deleteData(int index) async {
    if (isDoingSomething == true) return;
    isDoingSomething = true;
    bool isDelete = false;
    if (mounted) {
      isDelete = await DialogueHandler().deleteDialog(context, keyWord[index]) ?? false;
    }
    if (isDelete == false) {
      isDoingSomething = false;
      return;
    }
    setState(() {
      keyWord.removeAt(index);
      relevance.removeAt(index);
    });
    await prefs.setStringList(keyWordKey, keyWord);
    await prefs.setStringList(relevanceKey, relevance);
    isDoingSomething = false;
  }

  String textDisplay(int index) {
    String newIndex = (index + 1).toString();
    if (Provider.of<ThemeProvider>(context).themeData == lightMode) {
      return "$newIndex. ${keyWord[index]}";
    } else {
      return "$newIndex. ${relevance[index]} - ${keyWord[index]}";
    }
  }
}
