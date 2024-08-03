import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switch_learning/components/appbar.dart';
import 'package:switch_learning/components/missing_data.dart';
import 'package:switch_learning/theme/theme.dart';
import 'package:switch_learning/theme/theme_provider.dart';
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
  late TextEditingController keyController;
  late TextEditingController relevanceController;
  late SharedPreferences prefs;
  bool isDoingSomething = false;

  void initVal() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      relevance = prefs.getStringList(relevanceKey) ?? [];
      keyWord = prefs.getStringList(keyWordKey) ?? [];
    });
    if (keyWord == []) {
      await prefs.setStringList(keyWordKey, []);
    }
    if (relevance == []) {
      await prefs.setStringList(relevanceKey, []);
    }
  }

  @override
  void initState() {
    super.initState();
    keyWordKey = "${widget.mainKey}_1";
    relevanceKey = "${widget.mainKey}_2";
    initVal();
    keyController = TextEditingController();
    relevanceController = TextEditingController();
  }

  @override
  void dispose() {
    keyController.dispose();
    relevanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              const SizedBox(height: 50),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (isDoingSomething == true) return;
            isDoingSomething = true;
            relevanceController.text = widget.prefix;
            final List<String> addedValue = await openDialog("Add keyword") ?? ['', ''];
            keyController.text = '';
            relevanceController.text = '';
            String newKeyWord = addedValue[0];
            String newRelevance = addedValue[1];
            if (newKeyWord == '') {
              await errorDialog("Keyword can't be empty!");
              isDoingSomething = false;
              return;
            }
            for (String keyWords in keyWord) {
              if (newKeyWord == keyWords) {
                await errorDialog("The keyword already exists!");
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
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  editData(int index) async {
    if (isDoingSomething == true) return;
    isDoingSomething = true;
    keyController.text = keyWord[index];
    relevanceController.text = relevance[index];
    final List<String> editedValue = await openDialog("Edit keyword") ?? ['', ''];
    String newKeyWord = editedValue[0];
    String newRelevance = editedValue[1];
    if (newKeyWord == '') {
      await errorDialog("Keyword can't be empty!");
      isDoingSomething = false;
      return;
    }
    for (String keyWords in keyWord) {
      if (newKeyWord == keyWords) {
        await errorDialog("Keyword already exists!");
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

  deleteData(int index) async {
    if (isDoingSomething == true) return;
    isDoingSomething = true;
    bool isDelete = await deleteDialog(keyWord[index]) ?? false;
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

  Future<List<String>?> openDialog(String title) => showDialog<List<String>>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Enter the keyword"),
                controller: keyController,
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: const InputDecoration(hintText: "Enter the data"),
                controller: relevanceController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop([keyController.text, relevanceController.text]);
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      );

  Future<void> errorDialog(String error) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ],
        ),
      );

  Future<bool?> deleteDialog(String currentKeyword) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Are you sure you want to delete $currentKeyword?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes, delete it"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No, do not delete"),
            ),
          ],
        ),
      );
}
