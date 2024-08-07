import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switch_learning/src/components/dialogue_handler.dart';
import 'package:switch_learning/src/data/topic_provider.dart';
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
  late SharedPreferences prefs;
  String prefix = "";
  bool isDoingSomething = false;

  Future<void> initVal() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      topic = prefs.getStringList(masterKey) ?? [];
    });
    for (String key in topic) {
      if (mounted) {
        Provider.of<TopicProvider>(context, listen: false).addTopic(key);
      }
    }
    if (topic == []) {
      await prefs.setStringList(masterKey, []);
    }
  }

  @override
  void initState() {
    super.initState();
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
        appBar: const MainAppBar("Home"),
        backgroundColor: Theme.of(context).colorScheme.background,
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
                                child: TopicList(
                                  index: index,
                                  currentTopic: currentTopic,
                                  editData: editData,
                                  deleteData: deleteData,
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
                          String newPrefix = await DialogueHandler().singleOpenDialog(
                                context,
                                "Change prefix",
                                "Add your prefix",
                                prefix,
                              ) ??
                              prefix;
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
            final String? addedTopic = await DialogueHandler().singleOpenDialog(
              context,
              "Add topic",
              "Add your topic",
              prefix,
            );
            if (addedTopic == null) {
              isDoingSomething = false;
              return;
            }
            ValidationResult shouldAdd = ValidationResult(false, "Context isn't mounted");
            if (context.mounted) {
              shouldAdd = await Validator().shouldModifyTopic(context, addedTopic, masterKey);
            }
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
              if (context.mounted) {
                Provider.of<TopicProvider>(context, listen: false).addTopic(addedTopic);
              }
              await prefs.setStringList(masterKey, topic);
            }
            isDoingSomething = false;
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void editData(TopicListData info) async {
    if (isDoingSomething == true) return;
    isDoingSomething = true;
    int index = info.index;
    String currentTopic = info.currentTopic;
    String? newTopic = await DialogueHandler().singleOpenDialog(context, "Edit Topic", "Add your topic", currentTopic);
    ValidationResult shouldModify = ValidationResult(false, "Context isn't mounted");
    if (mounted) {
      shouldModify = await Validator().shouldModifyTopic(context, newTopic, masterKey);
    }
    if (shouldModify.verdict == false) {
      if (mounted && newTopic != null) {
        await DialogueHandler().errorDialog(context, shouldModify.errorMessage);
      }
    } else {
      List<String> lists = prefs.getStringList(currentTopic) ?? [];
      await prefs.setStringList(newTopic!, lists);
      await prefs.remove(currentTopic);
      setState(() {
        topic[index] = newTopic;
      });
      if (mounted) {
        Provider.of<TopicProvider>(context, listen: false).removeTopic(currentTopic);
        Provider.of<TopicProvider>(context, listen: false).addTopic(newTopic);
      }
      await prefs.setStringList(masterKey, topic);
    }
    isDoingSomething = false;
  }

  void deleteData(TopicListData info) async {
    if (isDoingSomething == true) {
      return;
    }
    isDoingSomething = true;
    int index = info.index;
    String currentTopic = info.currentTopic;
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
}

class TopicList extends StatelessWidget {
  const TopicList({
    super.key,
    required this.index,
    required this.currentTopic,
    required this.editData,
    required this.deleteData,
  });

  final int index;
  final String currentTopic;
  final ValueSetter<TopicListData> editData;
  final ValueSetter<TopicListData> deleteData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.info_outline),
              ),
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
                      onPressed: () => editData(
                        TopicListData(index: index, currentTopic: currentTopic),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteData(
                        TopicListData(index: index, currentTopic: currentTopic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopicListData {
  final int index;
  final String currentTopic;

  const TopicListData({
    required this.index,
    required this.currentTopic,
  });
}
