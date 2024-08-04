import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switch_learning/src/components/dialogue_handler.dart';
import 'package:switch_learning/src/data/validator.dart';
import 'package:switch_learning/src/theme/theme_provider.dart';
import 'package:switch_learning/src/components/appbar.dart';
import 'package:switch_learning/src/components/missing_data.dart';
import 'package:switch_learning/src/display.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String masterKey = "Master123456";
  List<String> topic = [];
  late TextEditingController controller;
  late SharedPreferences prefs;
  String prefix = "";
  bool isDoingSomething = false;

  Future<void> initVal() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      topic = prefs.getStringList(masterKey) ?? [];
    });
    if (topic == []) {
      await prefs.setStringList(masterKey, []);
    }
  }

  @override
  void initState() {
    super.initState();
    initVal();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar("Home"),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              Expanded(
                child: topic.isNotEmpty
                    ? ReorderableListView(
                        children: <Widget>[
                          for (final (index, currentTopic) in topic.indexed)
                            InkWell(
                              key: ValueKey(index),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DisplayPage(currentTopic, prefix),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        const Icon(Icons.info_outline),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Text(
                                            currentTopic,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: Provider.of<ThemeProvider>(context).showMisc,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () => editData(index, currentTopic),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () => deleteData(index, currentTopic),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        onReorder: (oldIndex, newIndex) async {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          setState(() {
                            final name = topic.removeAt(oldIndex);
                            topic.insert(newIndex, name);
                          });
                          await prefs.setStringList(masterKey, topic);
                        },
                      )
                    : const MissingData("There is no topic in the moment"),
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
                        String newPrefix = await openDialog("Change prefix", "Add your prefix") ?? prefix;
                        prefix = newPrefix;
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isDoingSomething == true) return;
          isDoingSomething = true;
          final String? addedTopic = await openDialog("Add topic", "Add your topic");
          controller.text = "";
          if (addedTopic == null) {
            isDoingSomething = false;
            return;
          }
          ValidationResult shouldAdd = await Validator().shouldModifyTopic(addedTopic, masterKey, topic);
          if (shouldAdd.verdict == false) {
            if (context.mounted) {
              await DialogueHandler().errorDialog(context, shouldAdd.errorMessage);
            }
          } else {
            await prefs.setStringList("${addedTopic}_1", []);
            await prefs.setStringList("${addedTopic}_2", []);
            setState(() {
              topic.insert(topic.length, addedTopic);
            });
            await prefs.setStringList(masterKey, topic);
          }
          isDoingSomething = false;
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  editData(int index, String currentTopic) async {
    if (isDoingSomething == true) return;
    isDoingSomething = true;
    controller.text = currentTopic;
    String? newTopic = await openDialog("Edit Topic", "Add your topic");
    controller.text = "";
    ValidationResult shouldModify = await Validator().shouldModifyTopic(newTopic, masterKey, topic);
    if (shouldModify.verdict == false) {
      if (mounted) {
        await DialogueHandler().errorDialog(context, shouldModify.errorMessage);
      }
    } else {
      List<String> lists = prefs.getStringList(currentTopic) ?? [];
      await prefs.setStringList(newTopic!, lists);
      await prefs.remove(currentTopic);
      setState(() {
        topic[index] = newTopic;
      });
      await prefs.setStringList(masterKey, topic);
    }
    isDoingSomething = false;
  }

  deleteData(int index, String currentTopic) async {
    if (isDoingSomething == true) {
      return;
    }
    isDoingSomething = true;
    bool isDelete = false;
    if (mounted) {
      isDelete = await DialogueHandler().deleteDialog(context, currentTopic) ?? false;
    }
    if (isDelete == false) {
      isDoingSomething = false;
      return;
    }
    await prefs.remove("${currentTopic}_1");
    await prefs.remove("${currentTopic}_2");
    setState(() {
      topic.removeAt(index);
    });
    await prefs.setStringList(masterKey, topic);
    isDoingSomething = false;
  }

  Future<String?> openDialog(String title, String hint) => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: TextField(
            decoration: InputDecoration(hintText: hint),
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      );
}
